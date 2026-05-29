import os
import time

import psycopg
from fastapi import FastAPI, Request, Response, status
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest


APP_NAME = os.getenv("APP_NAME", "vhl-devops-application")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")


app = FastAPI(
    title=APP_NAME,
    version=APP_VERSION,
    description="Python VHL application.",
)


HTTP_REQUESTS_TOTAL = Counter(
    "http_requests_total",
    "Total number of HTTP requests.",
    ["method", "endpoint", "http_status"],
)

HTTP_REQUEST_DURATION_SECONDS = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds.",
    ["method", "endpoint"],
)

DB_CHECK_TOTAL = Counter(
    "db_check_total",
    "Total number of database checks.",
    ["status"],
)


def get_database_config() -> dict:
    return {
        "host": os.getenv("POSTGRES_HOST", "localhost"),
        "port": int(os.getenv("POSTGRES_PORT", "5432")),
        "dbname": os.getenv("POSTGRES_DB", "vhl_db"),
        "user": os.getenv("POSTGRES_USER", "vhl_user"),
        "password": os.getenv("POSTGRES_PASSWORD", "vhl_password"),
        "connect_timeout": 5,
    }


@app.middleware("http")
async def collect_http_metrics(request: Request, call_next):
    start_time = time.time()
    response = None

    try:
        response = await call_next(request)
        return response
    finally:
        endpoint = request.scope.get("path", request.url.path)
        http_status = response.status_code if response else status.HTTP_500_INTERNAL_SERVER_ERROR

        HTTP_REQUESTS_TOTAL.labels(
            method=request.method,
            endpoint=endpoint,
            http_status=str(http_status),
        ).inc()

        HTTP_REQUEST_DURATION_SECONDS.labels(
            method=request.method,
            endpoint=endpoint,
        ).observe(time.time() - start_time)


@app.get("/")
def root():
    return {
        "application": APP_NAME,
        "version": APP_VERSION,
        "message": "VHL DevOps application is running.",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "application": APP_NAME,
        "version": APP_VERSION,
    }


@app.get("/db-check")
def db_check():
    database_config = get_database_config()

    try:
        with psycopg.connect(**database_config) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1;")
                result = cursor.fetchone()

        DB_CHECK_TOTAL.labels(status="success").inc()

        return {
            "status": "success",
            "database": "connected",
            "result": result[0],
        }

    except Exception as error:
        DB_CHECK_TOTAL.labels(status="error").inc()

        return {
            "status": "error",
            "database": "unavailable",
            "detail": str(error),
        }


@app.get("/metrics")
def metrics():
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )

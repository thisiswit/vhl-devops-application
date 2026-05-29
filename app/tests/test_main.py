from fastapi.testclient import TestClient

from main import app


client = TestClient(app)


def test_root_endpoint_returns_application_info():
    response = client.get("/")

    assert response.status_code == 200

    body = response.json()

    assert body["application"] == "vhl-devops-application"
    assert body["message"] == "VHL DevOps application is running."


def test_health_endpoint_returns_healthy_status():
    response = client.get("/health")

    assert response.status_code == 200

    body = response.json()

    assert body["status"] == "healthy"
    assert body["application"] == "vhl-devops-application"


def test_metrics_endpoint_returns_prometheus_metrics():
    response = client.get("/metrics")

    assert response.status_code == 200
    assert "text/plain" in response.headers["content-type"]
    assert "http_requests_total" in response.text
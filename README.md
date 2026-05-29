# VHL DevOps Application

Projeto desenvolvido para o teste técnico da vaga **DevOps - VHL Sistemas**.

O objetivo é provisionar um ambiente local com Kubernetes em execução dentro de uma VM criada com Vagrant, realizar o deploy de uma aplicação containerizada integrada a um banco PostgreSQL, expor a aplicação via HTTPS, configurar monitoramento, alerta, isolamento de rede e pipeline CI/CD.

## Tecnologias utilizadas

* Vagrant
* VirtualBox
* Kubernetes com k3s
* Terraform
* Helm
* FastAPI
* PostgreSQL
* Prometheus
* Grafana
* Alertmanager
* kube-state-metrics
* GitHub Actions
* Docker

## Arquitetura

O ambiente é composto por uma VM Ubuntu provisionada com Vagrant.

Dentro da VM é instalado um cluster Kubernetes single-node usando k3s. A aplicação FastAPI e o PostgreSQL são implantados no cluster usando Terraform com modules.

A aplicação é exposta externamente via Ingress HTTPS usando o Traefik, que já é instalado por padrão pelo k3s.

```text
Host Machine
    |
    | HTTPS :8443
    v
Vagrant VM
    |
    v
k3s Kubernetes Cluster
    |
    |-- Traefik Ingress
    |-- FastAPI Application
    |-- PostgreSQL
    |-- Prometheus / Grafana / Alertmanager
```

## Estrutura do projeto

```text
.
├── app
│   ├── Dockerfile
│   ├── main.py
│   ├── pytest.ini
│   ├── requirements.txt
│   └── tests
│       └── test_main.py
├── infra
│   ├── terraform
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   └── modules
│   │       ├── application
│   │       ├── database
│   │       ├── ingress
│   │       ├── monitoring
│   │       ├── namespace
│   │       └── network-policy
│   └── vagrant
│       ├── Vagrantfile
│       └── scripts
│           └── install-k3s.sh
├── k8s
├── .github
│   └── workflows
│       └── ci.yml
└── README.md
```

## Pré-requisitos

Na máquina host:

* Git
* Docker
* Vagrant
* VirtualBox

Na VM, o provisionamento instala automaticamente:

* k3s
* kubectl
* Helm

O Terraform deve estar instalado dentro da VM Vagrant, pois o cluster Kubernetes também roda dentro dela.

## Como subir o ambiente

Entre na pasta do Vagrant:

```bash
cd infra/vagrant
```

Suba a VM:

```bash
vagrant up
```

Acesse a VM:

```bash
vagrant ssh
```

Valide o cluster Kubernetes:

```bash
kubectl get nodes
```

Resultado esperado:

```text
NAME      STATUS   ROLES           VERSION
vhl-k8s   Ready    control-plane   v1.x.x+k3s1
```

Valide os pods do sistema:

```bash
kubectl get pods -A
```

## Gerar e importar a imagem da aplicação no k3s

A imagem da aplicação é criada localmente e importada para o containerd do k3s.

Na máquina host, na raiz do projeto:

```bash
docker build -t vhl-devops-application:local -f app/Dockerfile app
docker save vhl-devops-application:local -o app-image.tar
```

Dentro da VM:

```bash
sudo k3s ctr -n k8s.io images import /workspace/app-image.tar
```

Validar imagem importada:

```bash
sudo k3s ctr -n k8s.io images ls | grep vhl-devops-application
```

> O arquivo `app-image.tar` é apenas um artefato local e não deve ser versionado no Git.

## Aplicar a infraestrutura com Terraform

Dentro da VM:

```bash
cd /workspace/infra/terraform
```

Inicialize o Terraform:

```bash
terraform init
```

Formate e valide:

```bash
terraform fmt -recursive
terraform validate
```

Veja o plano:

```bash
terraform plan
```

Aplique:

```bash
terraform apply
```

Confirme com:

```text
yes
```

## Recursos criados pelo Terraform

O Terraform cria e configura:

* Namespace da aplicação
* PostgreSQL

  * Secret
  * PersistentVolumeClaim
  * Deployment
  * Service
* Aplicação FastAPI

  * ConfigMap
  * Deployment
  * Service
  * Liveness Probe
  * Readiness Probe
* Ingress HTTPS

  * Certificado self-signed
  * TLS Secret
  * Ingress
* Stack de monitoramento

  * Prometheus
  * Grafana
  * Alertmanager
  * kube-state-metrics
* Regra de alerta

  * `AppDown`
* Network Policies

  * Default deny
  * Permissão do Ingress para a API
  * Permissão do Prometheus para coletar métricas
  * Permissão da API para acessar PostgreSQL
  * Bloqueio de acesso direto ao PostgreSQL por outros pods

## Validar aplicação

Valide os recursos no namespace da aplicação:

```bash
kubectl get all -n vhl-app
```

Resultado esperado:

```text
pod/postgres-...
pod/vhl-python-app-...

service/postgres-service
service/vhl-python-app-service

deployment.apps/postgres
deployment.apps/vhl-python-app
```

## Acessar aplicação via HTTPS

A aplicação é exposta pela porta `8443` da máquina host.

Na máquina host:

```bash
curl.exe -k https://localhost:8443/health
```

Resultado esperado:

```json
{"status":"healthy","application":"vhl-devops-application","version":"0.1.0"}
```

Validar conexão da aplicação com o banco:

```bash
curl.exe -k https://localhost:8443/db-check
```

Resultado esperado:

```json
{"status":"success","database":"connected","result":1}
```

Também é possível testar usando o host local `vhl.local`:

```bash
curl.exe -k --resolve vhl.local:8443:127.0.0.1 https://vhl.local:8443/health
```

## Validar PostgreSQL

Dentro da VM:

```bash
kubectl get pvc -n vhl-app
```

Resultado esperado:

```text
postgres-pvc   Bound
```

Testar conexão direta usando um pod temporário autorizado antes das Network Policies, ou validar pela aplicação:

```bash
curl.exe -k https://localhost:8443/db-check
```

Resultado esperado:

```json
{"status":"success","database":"connected","result":1}
```

## Monitoramento

O monitoramento é instalado no namespace `monitoring`.

Validar pods:

```bash
kubectl get pods -n monitoring
```

Resultado esperado:

```text
alertmanager-monitoring-kube-prometheus-alertmanager-0   2/2   Running
monitoring-grafana-...                                   3/3   Running
monitoring-kube-prometheus-operator-...                  1/1   Running
monitoring-kube-state-metrics-...                        1/1   Running
monitoring-prometheus-node-exporter-...                  1/1   Running
prometheus-monitoring-kube-prometheus-prometheus-0        2/2   Running
```

Validar services:

```bash
kubectl get svc -n monitoring
```

## Acessar Prometheus

Dentro da VM, execute:

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 --address 0.0.0.0
```

Na máquina host, acesse:

```text
http://192.168.56.10:9090
```

Validar readiness:

```bash
curl.exe http://192.168.56.10:9090/-/ready
```

Resultado esperado:

```text
Prometheus Server is Ready.
```

Validar coleta da aplicação:

```bash
curl.exe "http://192.168.56.10:9090/api/v1/query?query=up%7Bjob%3D%22vhl-python-app%22%7D"
```

Resultado esperado:

```json
"value": [..., "1"]
```

Query no Prometheus:

```promql
up{job="vhl-python-app"}
```

## Acessar Grafana

Dentro da VM, em outro terminal:

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 --address 0.0.0.0
```

Na máquina host, acesse:

```text
http://192.168.56.10:3000
```

Credenciais padrão do ambiente local:

```text
user: admin
password: admin
```

## Alerta

Foi criada uma regra de alerta chamada `AppDown`.

Condição:

```promql
up{job="vhl-python-app"} == 0
```

Validar regra no Kubernetes:

```bash
kubectl get prometheusrules -n monitoring
```

Validar regra específica:

```bash
kubectl get prometheusrule monitoring-kube-prometheus-vhl-application-rules \
  -n monitoring \
  -o yaml | grep -A20 AppDown
```

Resultado esperado:

```yaml
- alert: AppDown
  expr: up{job="vhl-python-app"} == 0
  for: 1m
  labels:
    service: vhl-python-app
    severity: critical
```

Também é possível validar pela interface web do Prometheus:

```text
http://192.168.56.10:9090/alerts
```

O estado esperado é `inactive` enquanto a aplicação estiver saudável.

## Network Policies

Foram criadas policies para isolar o tráfego no namespace `vhl-app`.

Validar policies:

```bash
kubectl get networkpolicy -n vhl-app
```

Resultado esperado:

```text
default-deny-all
allow-ingress-to-app
allow-app-egress
allow-app-to-database
```

Validar regra de acesso ao banco:

```bash
kubectl describe networkpolicy allow-app-to-database -n vhl-app
```

Resultado esperado:

```text
PodSelector: app=postgres,component=database
Allowing ingress traffic:
  To Port: 5432/TCP
  From:
    PodSelector: app=vhl-python-app,component=api
```

### Teste de bloqueio ao PostgreSQL

Um pod aleatório no namespace `vhl-app` não deve conseguir acessar diretamente o PostgreSQL.

Dentro da VM:

```bash
kubectl run postgres-block-test \
  --rm -it \
  --restart=Never \
  --namespace vhl-app \
  --image=postgres:16-alpine \
  --env="PGPASSWORD=vhl_password" \
  --command -- sh -c 'psql "host=postgres-service user=vhl_user dbname=vhl_db connect_timeout=5" -c "SELECT 1;"'
```

Resultado esperado:

```text
connection refused
```

A aplicação continua conseguindo acessar o banco:

```bash
curl.exe -k https://localhost:8443/db-check
```

Resultado esperado:

```json
{"status":"success","database":"connected","result":1}
```

## CI/CD

O projeto possui pipeline no GitHub Actions em:

```text
.github/workflows/ci.yml
```

O pipeline executa:

* Testes da aplicação Python
* Validação de Terraform
* Build da imagem Docker

Jobs:

```text
python-test
terraform-validate
docker-build
```

Como o cluster é local e provisionado via Vagrant, o pipeline não realiza deploy automático no Kubernetes. O objetivo do CI é validar que a aplicação, os manifests Terraform e a imagem Docker estão corretos antes da entrega.

## Testes locais da aplicação

Dentro da pasta `app`:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m pip install pytest httpx
pytest -v
```

Resultado esperado:

```text
3 passed
```

## Decisões técnicas

### k3s single-node

Foi utilizado k3s em modo single-node porque o objetivo do desafio é demonstrar automação, deploy, exposição, monitoramento, TLS e isolamento de rede em um ambiente local simples e reproduzível.

Para um ambiente produtivo, a arquitetura poderia ser expandida para múltiplos nós, com control plane e workers separados.

### Terraform com modules

O Terraform foi organizado em modules para manter separação clara de responsabilidades:

* `namespace`
* `database`
* `application`
* `ingress`
* `monitoring`
* `network-policy`

Isso facilita manutenção, leitura e evolução da infraestrutura.

### PostgreSQL no Kubernetes

Para o teste local, o PostgreSQL foi implantado com `Deployment` e `PersistentVolumeClaim`.

Em produção, seria recomendado avaliar:

* StatefulSet
* backups automatizados
* storage gerenciado
* secrets externos
* alta disponibilidade

### TLS com certificado self-signed

A aplicação é exposta via HTTPS usando certificado self-signed gerado pelo Terraform.

Por isso os testes usam:

```bash
curl -k
```

Em produção, seria recomendado usar certificados emitidos por uma CA confiável, como Let's Encrypt ou solução corporativa.

### Monitoramento

Foi utilizado o `kube-prometheus-stack` para instalar Prometheus, Grafana, Alertmanager e kube-state-metrics de forma integrada.

A aplicação expõe métricas no endpoint:

```text
/metrics
```

E o Prometheus coleta essas métricas através do job:

```text
vhl-python-app
```

### Network Policy

As Network Policies aplicam isolamento básico:

* tráfego negado por padrão;
* Ingress pode acessar a API;
* Prometheus pode coletar métricas da API;
* API pode acessar PostgreSQL;
* pods aleatórios não podem acessar PostgreSQL diretamente.

## Comandos úteis

Desligar VM:

```bash
vagrant halt
```

Subir VM novamente:

```bash
vagrant up
```

Acessar VM:

```bash
vagrant ssh
```

Reaplicar provisionamento:

```bash
vagrant provision
```

Destruir ambiente:

```bash
vagrant destroy -f
```

Recriar ambiente:

```bash
vagrant up
```

Reaplicar Terraform:

```bash
cd /workspace/infra/terraform
terraform apply
```

## Status dos requisitos

| Requisito                                | Status    |
| ---------------------------------------- | --------- |
| VMs com Vagrant                          | Concluído |
| Cluster Kubernetes funcional             | Concluído |
| Aplicação containerizada                 | Concluído |
| Banco de dados PostgreSQL                | Concluído |
| Acesso externo à aplicação               | Concluído |
| HTTPS/TLS                                | Concluído |
| Monitoramento                            | Concluído |
| Regra de alerta                          | Concluído |
| Infraestrutura como Código com Terraform | Concluído |
| CI/CD                                    | Concluído |
| Isolamento de rede                       | Concluído |

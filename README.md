# Nodeprobe — DSi DevOps Club Project

Containerized Flask app deployed across 3 VMs behind an Nginx reverse proxy. Shows which node served your request and what commit it's running. Full CI/CD via GitHub Actions with Prometheus + Grafana monitoring.

---

## Architecture Overview

```
                        Internet
                           │
                    ┌──────▼──────┐
                    │  myapp.com  │
                    │  (DNS/hosts)│
                    └──────┬──────┘
                           │
              ┌────────────▼────────────┐
              │     Reverse Proxy VM    │  192.168.123.10
              │  Nginx (Docker)         │
              │  Prometheus + Grafana   │
              └──┬──────────┬────────┬──┘
                 │          │        │
        ┌────────▼──┐ ┌─────▼───┐ ┌─▼────────┐
        │   VM 1    │ │  VM 2   │ │   VM 3   │
        │:5000      │ │ :5000   │ │  :5000   │
        │Flask App  │ │Flask App│ │Flask App │
        │(Docker)   │ │(Docker) │ │(Docker)  │
        └───────────┘ └─────────┘ └──────────┘
     192.168.123.11  .12          .13
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| OS | Ubuntu Server 24.04 (no GUI) |
| Containerization | Docker |
| Web App | Python / Flask |
| Reverse Proxy | Nginx (Docker) |
| CI/CD | GitHub Actions |
| Container Registry | Docker Hub |
| Monitoring | Prometheus + Grafana |
| Virtualization | VirtualBox / VMware |

---

## Problem 1 — Infrastructure Setup

### Virtual Machines

4 VMs on network `192.168.123.0/24`:

| VM | Role | IP |
|---|---|---|
| VM1 | App server | 192.168.123.11 |
| VM2 | App server | 192.168.123.12 |
| VM3 | App server | 192.168.123.13 |
| VM4 | Reverse proxy + monitoring | 192.168.123.10 |

All VMs run Ubuntu Server 24.04 with Docker installed.

### Reverse Proxy (VM4)

Nginx runs in Docker on VM4 and load balances traffic across the 3 app VMs.

**Nginx config snippet:**
```nginx
upstream flask_app {
    server 192.168.123.11:5000;
    server 192.168.123.12:5000;
    server 192.168.123.13:5000;
}

server {
    listen 80;
    server_name myapp.com;

    location / {
        proxy_pass http://flask_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**Run Nginx:**
```bash
docker run -d \
  --name nginx-proxy \
  -p 80:80 \
  -v /path/to/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx
```

Add to `/etc/hosts` (or DNS) to resolve `myapp.com`:
```
192.168.123.10  myapp.com
```

---

## Problem 2 — Web Application

Simple Flask app that displays:
- **VM Hostname** — the host machine's hostname (mounted from `/etc/hostname`)
- **Git Branch** — branch the image was built from
- **Commit Hash** — full SHA of the triggering commit
- **Commit Message** — message of the triggering commit

Git metadata is baked into the Docker image at build time via `--build-arg`.

### Key Files

```
.
├── app.py               # Flask app
├── Dockerfile           # Container definition
├── requirements.txt     # Python deps (flask)
├── templates/
│   └── index.html       # Bootstrap UI
└── .github/
    └── workflows/
        └── ci-cd.yml    # GitHub Actions pipeline
```

### Running Locally

```bash
# Build
docker build \
  --build-arg GIT_BRANCH=$(git branch --show-current) \
  --build-arg GIT_COMMIT=$(git rev-parse HEAD) \
  --build-arg GIT_MESSAGE="$(git log -1 --pretty=%s)" \
  -t vm-web-app .

# Run
docker run -d \
  -p 5000:5000 \
  -v /etc/hostname:/host_hostname:ro \
  vm-web-app
```

Visit `http://localhost:5000`

---

## Problem 3 — CI/CD Pipeline

GitHub Actions workflow triggers on every push to `main`.

### Pipeline Stages

```
push to main
     │
     ▼
┌─────────────────┐
│ CI: build-and-  │  Builds Docker image with git metadata
│     push        │  Pushes to Docker Hub
└────────┬────────┘
         │ (parallel)
    ┌────┴────┐
    │         │
    ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌───────┐
│  CD   │ │  CD   │ │  CD   │
│  VM1  │ │  VM2  │ │  VM3  │
└───────┘ └───────┘ └───────┘
```

### How It Works

1. **CI job** — runs on `ubuntu-latest` (GitHub-hosted):
   - Checks out code
   - Logs into Docker Hub (via `DOCKER_USERNAME` / `DOCKER_PASSWORD` secrets)
   - Builds image with `GIT_BRANCH`, `GIT_COMMIT`, `GIT_MESSAGE` as build args
   - Pushes `imnasim31415/vm-web-app:latest` to Docker Hub

2. **CD jobs** — run on self-hosted runners tagged `vm1`, `vm2`, `vm3`:
   - Stop and remove existing container
   - Pull latest image from Docker Hub
   - Start new container with host's `/etc/hostname` mounted read-only

### Required GitHub Secrets

| Secret | Value |
|---|---|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |

### Self-Hosted Runner Setup (each VM)

```bash
# On each app VM — register a self-hosted runner
# GitHub → Repo Settings → Actions → Runners → New self-hosted runner
# Follow the instructions, then add labels: vm1 / vm2 / vm3
```

---

## Problem 4 — Monitoring

Prometheus and Grafana are deployed on VM4 (reverse proxy) using Docker.

### Node Exporter (on each VM)

Exposes system metrics on port `9100`:

```bash
docker run -d \
  --name node-exporter \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  prom/node-exporter \
  --path.rootfs=/host
```

### Prometheus (VM4)

Scrapes all 4 VMs every 15 seconds.

**`prometheus.yml`:**
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets:
          - '192.168.123.11:9100'
          - '192.168.123.12:9100'
          - '192.168.123.13:9100'
          - '192.168.123.10:9100'
```

```bash
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

### Grafana (VM4)

```bash
docker run -d \
  --name grafana \
  -p 3000:3000 \
  grafana/grafana
```

Access at `http://192.168.123.10:3000` (default credentials: `admin` / `admin`).

Add Prometheus as a data source (`http://192.168.123.10:9090`), then import **Node Exporter Full** dashboard (ID: `1860`) for:

- CPU usage
- Memory usage
- Disk usage
- Network statistics

---

## Accessing the App

After setup, the app is reachable at:

```
http://myapp.com
```

Each refresh may hit a different VM — the hostname field confirms which node served the request.

---

## Repository

Docker Hub: [imnasim31415/vm-web-app](https://hub.docker.com/r/imnasim31415/vm-web-app)

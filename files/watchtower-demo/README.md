# Watchtower Demo — YZV 322E Tool Presentation

A reproducible demo of [Watchtower](https://containrrr.dev/watchtower/), a tool that automatically updates running Docker containers when their base images change in a registry.

This repo accompanies my YZV 322E (Applied Data Engineering) Individual Tool Presentation at ITU.

---

## 1. What is this tool?

**Watchtower** is a small container that monitors the images of your running Docker containers, polls the registry they came from, and — when a newer image is published — pulls it and gracefully restarts the container with the same configuration. It is open-source (Apache 2.0), maintained by the `containrrr` community, and ships as a single Docker image.

In short: it removes the manual "pull, stop, recreate" loop that every Docker user does by hand.

---

## 2. Prerequisites

| Requirement | Version used |
|---|---|
| OS | Linux / macOS / Windows (WSL2) |
| Docker Engine | 24.0+ |
| Docker Compose | v2 (`docker compose`, not `docker-compose`) |
| Free ports | `5000` (registry), `8080` (demo app) |
| Disk | ~300 MB for images |

Check your setup:
```bash
docker --version
docker compose version
```

---

## 3. Installation

Clone the repo and make the helper scripts executable:

```bash
git clone https://github.com/<your-username>/watchtower-demo.git
cd watchtower-demo
chmod +x scripts/*.sh
```

That's it. No system packages, no Python, no Node — only Docker.

---

## 4. Running the example

The demo runs three containers:

1. **`registry`** — a private Docker registry on `localhost:5000` (so we can push our own image versions).
2. **`app`** — a tiny nginx page that displays its current version. Built locally, pushed to the registry.
3. **`watchtower`** — polls the registry every 30 seconds, watching containers labelled `com.centurylinklabs.watchtower.enable=true`.

### Step 1 — Start the stack

```bash
./scripts/start.sh
```

This boots the registry, builds version `v1.0.0` of the demo app, pushes it to the local registry, then starts the app and Watchtower.

Open http://localhost:8080 — you should see **v1.0.0**.

### Step 2 — Watch Watchtower

In a second terminal:

```bash
./scripts/logs.sh
```

You'll see a poll every 30 seconds reporting "Session done" with no updates yet.

### Step 3 — Release a new version

```bash
./scripts/release.sh v2.0.0
```

This rebuilds the app with a new version label and pushes it to `localhost:5000/myapp:latest`. The image digest changes.

### Step 4 — Watch the auto-update

Within ~30 seconds the Watchtower logs print:

```
Found new localhost:5000/myapp:latest image (...)
Stopping /demo-app ... done
Creating /demo-app ... done
```

Refresh http://localhost:8080 — it now shows **v2.0.0**.

You can repeat step 3 with any version string and any hex colour:

```bash
./scripts/release.sh v3.0.0 "#22d3ee"
```

### Step 5 — Tear down

```bash
./scripts/stop.sh
```

---

## 5. Expected output

Watchtower logs after a successful update look like this:

```
time="..." level=info msg="Watchtower 1.7.x"
time="..." level=info msg="Using no notifications"
time="..." level=info msg="Checking all containers (except explicitly disabled with label)"
time="..." level=info msg="Scheduling first run: ..."
time="..." level=debug msg="Checking containers for updated images"
time="..." level=info msg="Found new localhost:5000/myapp:latest image (sha256:abc...)"
time="..." level=info msg="Stopping /demo-app (...) with SIGTERM"
time="..." level=info msg="Creating /demo-app"
time="..." level=info msg="Session done" Failed=0 Scanned=1 Updated=1
```

The browser at http://localhost:8080 reflects the new version on the next refresh.

A screenshot of the running app and Watchtower logs is in [`screenshots/`](screenshots/).

---

## 6. Project structure

```
.
├── README.md
├── docker-compose.yml      # registry + app + watchtower
├── .env.example
├── app/
│   ├── Dockerfile          # nginx + static page
│   └── html/index.html     # version page (rewritten by release.sh)
├── scripts/
│   ├── start.sh            # bootstrap stack and v1.0.0
│   ├── release.sh          # build + push a new version
│   ├── logs.sh             # tail watchtower
│   └── stop.sh             # tear down
└── AI_USAGE.md
```

---

## 7. Watchtower options used here

| Flag / env var | Purpose |
|---|---|
| `WATCHTOWER_POLL_INTERVAL=30` | Poll every 30 s (default is 24 h — too slow to demo) |
| `WATCHTOWER_LABEL_ENABLE=true` | Only watch containers with the opt-in label |
| `WATCHTOWER_CLEANUP=true` | Delete the old image after a successful update |
| `WATCHTOWER_DEBUG=true` | Verbose logs so the demo is visible |
| `com.centurylinklabs.watchtower.enable=true` | Label on the `app` container that opts it in |

The full list lives in the [Watchtower argument reference](https://containrrr.dev/watchtower/arguments/).

---

## 8. Course connection (YZV 322E)

Watchtower belongs to the **Docker** family from the course's seven core tools. In a real Compose-based pipeline (e.g. PostgreSQL + NiFi + Elasticsearch + Airflow), Watchtower can:

- Keep base images patched against CVEs without manual `docker pull` runs.
- Pick up upstream NiFi or Airflow point releases automatically when running `:latest`.
- Free students and small teams from a maintenance task that scales linearly with the number of services.

It does **not** replace Kubernetes, GitOps, or CI/CD — it is intentionally small and aimed at single-host or small-fleet deployments.

---

## 9. AI Usage Disclosure

See [`AI_USAGE.md`](AI_USAGE.md). Anthropic Claude was used to draft the docker-compose, scripts, and README; everything was reviewed and tested by me before submission.

---

## 10. References

- Watchtower documentation: https://containrrr.dev/watchtower/
- Watchtower GitHub: https://github.com/containrrr/watchtower
- Docker Registry image: https://hub.docker.com/_/registry
- Container label reference: https://containrrr.dev/watchtower/container-selection/

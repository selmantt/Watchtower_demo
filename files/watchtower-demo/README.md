# Watchtower Demo — YZV 322E Tool Presentation

A reproducible demo of **Watchtower**, a tool that automatically updates running Docker containers when their base images change in a registry.

> **Note on the image used.** The original `containrrr/watchtower` repository was [archived on December 17, 2025](https://github.com/containrrr/watchtower) after a Docker v29 API break that the unmaintained image could not handle. This demo uses **`nickfedor/watchtower`**, the actively-maintained community fork — same flags, same labels, drop-in replacement.

---

## 1. What is this tool?

Watchtower is a small daemon that runs as a Docker container itself, polls the registries that produced the images of your other running containers, and — when it spots a newer image — pulls it and recreates the container with the same configuration. It is open-source (Apache 2.0) and ships as a single ~15 MB image.

In short: it removes the manual "pull, stop, recreate" loop that every Docker user does by hand.

---

## 2. Prerequisites

| Requirement | Tested with |
|---|---|
| OS | Windows 10/11 (Git Bash), Linux, macOS |
| Docker Engine | 24.0+ (works with Docker Desktop's bundled engine, including v29) |
| Docker Compose | v2 (`docker compose`, **not** `docker-compose`) |
| Free ports | `5000` (registry), `8090` (demo app) |
| Disk | ~300 MB for images |

Quick check:
```bash
docker --version
docker compose version
```

> Port `8090` was chosen instead of the more common `8080` because Apache Airflow already uses `8080` in many local setups.

---

## 3. Installation

```bash
git clone https://github.com/<your-username>/watchtower-demo.git
cd watchtower-demo
```

That's it. No Python, no Node, no system packages — only Docker.

> On Windows, run all commands from **Git Bash** (the `bash` interpreter that ships with Git for Windows). PowerShell and cmd are not supported.

---

## 4. Running the example

The demo runs three containers:

1. **`registry`** — a private Docker registry on `localhost:5000` so we can push our own image versions.
2. **`app`** — a tiny nginx page that displays its current version. Built locally, pushed to the registry.
3. **`watchtower`** — polls the registry every 30 seconds, watching containers labelled `com.centurylinklabs.watchtower.enable=true`.

### Step 1 — Start the stack

```bash
bash scripts/start.sh
```

This boots the registry, builds version `v1.0.0` of the demo app, pushes it to the local registry, then starts the app and Watchtower.

Open **<http://localhost:8090>** — you should see **v1.0.0** in cyan.

### Step 2 — Watch Watchtower

In a second Git Bash window:

```bash
bash scripts/logs.sh
```

You'll see a poll every 30 seconds reporting `Session done scanned=1 updated=0` — there's nothing to update yet.

### Step 3 — Release a new version

Back in the first window:

```bash
bash scripts/release.sh v2.0.0
```

This rebuilds the app with a new version label and pushes it to `localhost:5000/myapp:latest`. The image digest changes, which is exactly what Watchtower watches for.

### Step 4 — Watch the auto-update

Within ~30 seconds the Watchtower logs print:

```
level=info msg="Found new image: localhost:5000/myapp:latest"
level=info msg="Stopping container" container=demo-app
level=info msg="Started new container" container=demo-app
level=info msg="Update session completed" scanned=1 updated=1
```

Refresh **<http://localhost:8090>** — it now shows **v2.0.0** in red.

You can repeat step 3 with any version string and any hex colour:

```bash
bash scripts/release.sh v3.0.0 "#10b981"
```

### Step 5 — Tear down

```bash
docker compose down -v
```

---

## 5. Expected output

A successful Watchtower update looks like this:

```
time="..." level=info msg="Watchtower 1.7.x"
time="..." level=info msg="Using no notifications"
time="..." level=info msg="Checking all containers (except explicitly disabled with label)"
time="..." level=info msg="Scheduling first run: ..."
time="..." level=info msg="Found new image: localhost:5000/myapp:latest"
time="..." level=info msg="Stopping container" container=demo-app
time="..." level=info msg="Started new container" container=demo-app
time="..." level=info msg="Update session completed" failed=0 scanned=1 updated=1
```

Browser at **<http://localhost:8090>** reflects the new version on the next refresh. See [`screenshots/`](screenshots/) for example output.

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
│   ├── start.sh            # bootstrap stack + push v1.0.0
│   ├── release.sh          # build + push a new version
│   ├── logs.sh             # tail watchtower
│   └── stop.sh             # tear down
├── screenshots/
│   ├── app-v1.png
│   ├── app-v2.png
│   └── watchtower-logs.png
└── AI_USAGE.md
```

---

## 7. Watchtower options used here

| Flag / env var | Purpose |
|---|---|
| `WATCHTOWER_POLL_INTERVAL=30` | Poll every 30 s (default is 24 h — too slow to demo) |
| `WATCHTOWER_LABEL_ENABLE=true` | Only watch containers with the opt-in label |
| `WATCHTOWER_CLEANUP=true` | Delete the old image after a successful update |
| `com.centurylinklabs.watchtower.enable=true` | Label on the `app` container that opts it in |

The full reference lives in the [Watchtower argument reference](https://nickfedor.github.io/watchtower/arguments/).

---

## 8. Course connection (YZV 322E)

Watchtower belongs to the **Docker** family from the course's seven core tools. In a real Compose-based pipeline (e.g. PostgreSQL + NiFi + Elasticsearch + Airflow), Watchtower can:

- Keep base images patched against CVEs without manual `docker pull` runs.
- Pick up upstream NiFi or Airflow point releases automatically when running `:latest`.
- Free students and small teams from a maintenance task that scales linearly with the number of services.

It does **not** replace Kubernetes, GitOps, or CI/CD — it is intentionally small and aimed at single-host or small-fleet deployments.

---

## 9. AI Usage Disclosure

See [`AI_USAGE.md`](AI_USAGE.md). Anthropic Claude was used to draft the docker-compose, scripts, and README; everything was reviewed and tested locally before submission.

---

## 10. References

- Watchtower documentation (community fork): <https://nickfedor.github.io/watchtower/>
- Maintained fork on Docker Hub: <https://hub.docker.com/r/nickfedor/watchtower>
- Original (archived) repository: <https://github.com/containrrr/watchtower>
- Archive announcement & API break thread: <https://github.com/containrrr/watchtower/issues/2122>
- Docker Registry image: <https://hub.docker.com/_/registry>
- Container label reference: <https://nickfedor.github.io/watchtower/container-selection/>

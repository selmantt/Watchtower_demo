#!/bin/bash
set -e

VERSION=${1:-v2.0.0}
COLOR=${2:-#f43f5e}

echo "==> bump to $VERSION"

cat > app/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Watchtower Demo App</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: #0f172a;
            color: #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
        }
        .card {
            background: #1e293b;
            padding: 48px 64px;
            border-radius: 16px;
            border: 1px solid #334155;
            text-align: center;
        }
        h1 { margin: 0 0 8px 0; font-size: 14px; color: #94a3b8; letter-spacing: 2px; text-transform: uppercase; }
        .version { font-size: 72px; font-weight: 800; margin: 16px 0; color: ${COLOR}; }
        .meta { font-size: 13px; color: #64748b; margin-top: 24px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Demo App</h1>
        <div class="version">${VERSION}</div>
        <div class="meta">build: $(date -u +%Y-%m-%dT%H:%M:%SZ)</div>
    </div>
</body>
</html>
EOF

echo "==> build"
docker build -t localhost:5000/myapp:latest ./app

echo "==> push"
docker push localhost:5000/myapp:latest

echo ""
echo "Pushed $VERSION. Watchtower polls every 30s."
echo "Watch:  ./scripts/logs.sh"

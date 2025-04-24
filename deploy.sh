#!/bin/bash
set -euxo pipefail

# 배포 대상 경로
APP_ROOT="/home/ubuntu/media_app"
JANODE_DIR="$APP_ROOT/janode"

# 1. 기존 서비스 정지
if command -v pm2 >/dev/null 2>&1; then
  pm2 stop media-server || true
fi

# 2. 기존 앱 백업 및 교체
if [ -d "$APP_ROOT" ]; then
  mv "$APP_ROOT" "${APP_ROOT}_bak_$(date +%s)" || true
fi

mkdir -p "$APP_ROOT"
cp -r /home/ubuntu/deploy_workspace/media_app/* "$APP_ROOT"

# 3. Node 모듈 설치 및 환경 구성
cd "$JANODE_DIR"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use 18

npm ci --omit=dev

cat > .env <<'EOF'
DB_HOST=10.0.2.5
DB_USER=admin
DB_PASSWORD=Axhdxhdqhfl124@
DB_NAME=threetier_app
PORT=3000
EOF

# 4. PM2 기동
command -v pm2 >/dev/null 2>&1 || npm install -g pm2
pm2 start server.mjs --name media-server --update-env
pm2 save

echo "✅ Node-Janus media server deployed & started successfully"

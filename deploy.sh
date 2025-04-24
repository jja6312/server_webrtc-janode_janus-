#!/bin/bash
set -euxo pipefail

##### 0. 변수/경로 정의 ########################################################
# 🎯 DevOps가 내려준 아티팩트는 아래 변수가 가리키는 디렉터리에 존재합니다.
#   OCI_PRIMARY_ARTIFACT_DIR  : 아티팩트가 풀린 디렉터리
#   OCI_PRIMARY_ARTIFACT_FILE : 실제 파일명 (nodejs-janus-app.tar.gz)
ART_DIR="$OCI_PRIMARY_ARTIFACT_DIR"
TAR_FILE="$OCI_PRIMARY_ARTIFACT_DIR/$OCI_PRIMARY_ARTIFACT_FILE"

# 배포 대상 경로
APP_ROOT="/home/ubuntu/media_app"
JANODE_DIR="$APP_ROOT/janode"

##### 1. 기존 서비스 정지(있으면) ##############################################
if command -v pm2 >/dev/null 2>&1; then
  pm2 stop media-server || true
fi

##### 2. 새 코드 반영 ###########################################################
# 백업 & 교체
if [ -d "$APP_ROOT" ]; then
  mv "$APP_ROOT" "${APP_ROOT}_bak_$(date +%s)" || true
fi

mkdir -p "$APP_ROOT"
tar -xzf "$TAR_FILE" -C "$APP_ROOT" --strip-components=1

##### 3. Node 모듈 설치 / 환경변수 구성 ########################################
cd "$JANODE_DIR"

# 필요한 경우 nvm 로딩 (AMI에 nvm이 이미 깔려 있다고 가정)
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
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

##### 4. 서비스 기동 ###########################################################
# PM2가 없다면 설치
command -v pm2 >/dev/null 2>&1 || npm install -g pm2

pm2 start server.mjs --name media-server --update-env
pm2 save

echo "✅ Node-Janus media server deployed & started successfully"


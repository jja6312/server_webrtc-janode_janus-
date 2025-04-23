FROM oraclelinux:7

# 1. Node + devtoolset-8 설치
RUN yum install -y yum-utils oraclelinux-developer-release-el7 && \
    yum-config-manager --enable ol7_developer ol7_optional_latest ol7_software_collections && \
    yum install -y devtoolset-8 devtoolset-8-gcc devtoolset-8-gcc-c++ \
                   curl tar xz make gcc gcc-c++ && \
    curl -fsSL https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-x64.tar.xz -o /tmp/node.tar.xz && \
    mkdir -p /usr/local/node && \
    tar -xf /tmp/node.tar.xz -C /usr/local/node --strip-components=1 && \
    ln -sf /usr/local/node/bin/* /usr/local/bin/

# 2. 앱 복사 및 빌드
WORKDIR /app
COPY ./media_app ./media_app

SHELL ["/bin/bash", "-c"]
RUN source /opt/rh/devtoolset-8/enable && \
    cd media_app/janode && \
    npm ci

# 3. 결과물 압축
RUN tar -czf /app/media_app.tar.gz media_app

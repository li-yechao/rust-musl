# syntax = docker/dockerfile:1.0-experimental
FROM --platform=amd64 rust:1.53.0-slim

ARG TARGETPLATFORM

RUN sed -i -E 's/deb.debian.org|security.debian.org/mirrors.163.com/g' \
    /etc/apt/sources.list; \
    apt update; \
    apt install -y git build-essential wget

RUN set -eux; \
    git clone --branch v0.9.9 https://github.com/richfelker/musl-cross-make.git /tmp/musl-cross; \
    cd /tmp/musl-cross; \
    case "$TARGETPLATFORM" in \
    # amd64
    linux/amd64) \
    TARGET=x86_64-linux-musl make install -j`nproc`; \
    rustup target add x86_64-unknown-linux-musl; \
    ;; \
    # aarch64
    linux/arm64) \
    TARGET=aarch64-linux-musl make install -j`nproc`; \
    rustup target add aarch64-unknown-linux-musl; \
    ;; \
    esac; \
    cp -r output /opt/musl-cross; \
    rm -rf /tmp/musl-cross; \
    ln -s /opt/musl-cross/bin/x86_64-linux-musl-gcc /opt/musl-cross/bin/musl-gcc;

ENV PATH="$PATH:/opt/musl-cross/bin"

COPY config.toml /usr/local/cargo/config.toml

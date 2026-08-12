FROM ubuntu:26.04 AS source

ARG APP_SHA256=df956ee0abf75c122ff3a68b815f75514a28eb396ef8bebf5c6d71b00ffa908a

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    curl --fail --location --output /tmp/Bitwarden-2026.7.0-x86_64.AppImage "https://github.com/bitwarden/clients/releases/download/desktop-v2026.7.0/Bitwarden-2026.7.0-x86_64.AppImage" && \
    echo "${APP_SHA256}  /tmp/Bitwarden-2026.7.0-x86_64.AppImage" | sha256sum --check

FROM ghcr.io/containerpak/mesa:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/bitwarden"

COPY --from=source /tmp/Bitwarden-2026.7.0-x86_64.AppImage /tmp/Bitwarden-2026.7.0-x86_64.AppImage
COPY bitwarden /usr/bin/bitwarden
COPY com.bitwarden.desktop.desktop /usr/share/applications/com.bitwarden.desktop.desktop

RUN apt-get update && \
    apt-get install -y --no-install-recommends squashfs-tools && \
    chmod +x /tmp/Bitwarden-2026.7.0-x86_64.AppImage && \
    /tmp/Bitwarden-2026.7.0-x86_64.AppImage --appimage-extract && \
    mv squashfs-root /opt/bitwarden && \
    chmod 0755 /usr/bin/bitwarden && \
    if [ -e /opt/bitwarden/.DirIcon ]; then install -Dm644 /opt/bitwarden/.DirIcon /usr/share/icons/hicolor/256x256/apps/com.bitwarden.desktop.png; fi && \
    rm -rf /tmp/Bitwarden-2026.7.0-x86_64.AppImage /tmp/archive && \
    cpak-clean-junk


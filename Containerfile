FROM ubuntu:26.04 AS source

ARG APP_SHA256=39fa0e8ea86369286b5062e23e362dd884b104448ba09a484ef58a3d37af4dfa

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl squashfs-tools && \
    curl --fail --location --output /tmp/Bitwarden-2026.8.0-x86_64.AppImage "https://github.com/bitwarden/clients/releases/download/desktop-v2026.8.0/Bitwarden-2026.8.0-x86_64.AppImage" && \
    echo "${APP_SHA256}  /tmp/Bitwarden-2026.8.0-x86_64.AppImage" | sha256sum --check && \
    chmod 0755 /tmp/Bitwarden-2026.8.0-x86_64.AppImage && \
    cd /tmp && \
    ./Bitwarden-2026.8.0-x86_64.AppImage --appimage-extract >/dev/null && \
    mv /tmp/squashfs-root /out

FROM ghcr.io/containerpak/gtk3:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/bitwarden"

COPY --from=source /out /opt/bitwarden
COPY bitwarden /usr/bin/bitwarden
COPY com.bitwarden.desktop.desktop /usr/share/applications/com.bitwarden.desktop.desktop

RUN chmod 0755 /usr/bin/bitwarden && \
    if [ -e /opt/bitwarden/.DirIcon ]; then install -Dm644 /opt/bitwarden/.DirIcon /usr/share/icons/hicolor/256x256/apps/com.bitwarden.desktop.png; fi && \
    cpak-clean-junk

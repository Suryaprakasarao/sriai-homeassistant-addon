# File: Dockerfile
# This wrapper image starts from the pre-built SriAi engine image and adds
# the necessary Home Assistant labels, SriAi branding, and a custom startup script.

ARG BUILD_FROM
FROM ghcr.io/open-webui/open-webui:v0.9.6

# Labels for Home Assistant Supervisor
LABEL \
  io.hass.version="v0.9.6" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

# By default, expose the same port
EXPOSE 8080

ENV DATA_DIR=/data

# --- SriAi white-label branding -------------------------------------------
# Display name shown throughout the web interface (title, headers, PWA name).
ENV WEBUI_NAME="SriAi"

# Overlay SriAi favicons / logos / splash over the upstream static assets so
# none of the original branding is visible in the dashboard UI.
COPY sriai/branding/ /sriai-branding/
RUN sh /sriai-branding/apply-branding.sh
# --------------------------------------------------------------------------

COPY sriai/run.sh .
RUN chmod a+x run.sh

# Run the wrapper script on startup
# CMD [ "/run.sh" ]

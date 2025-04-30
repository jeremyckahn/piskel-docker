# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies needed for Piskel (and general GUI apps)
# - unzip: To extract the application
# - Libraries: Common libraries needed for Electron/GTK apps and X11 forwarding
# - ca-certificates: Often needed for network requests
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  unzip \
  libgtk-3-0 \
  libgtk2.0-0 \
  libnotify4 \
  libnss3 \
  libnspr4 \
  libxss1 \
  libxtst6 \
  xdg-utils \
  libatspi2.0-0 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libuuid1 \
  libappindicator3-1 \
  libsecret-1-0 \
  ca-certificates \
  fonts-liberation \
  libx11-xcb1 \
  libasound2 \
  libxrandr2 \
  libxcomposite1 \
  libxdamage1 \
  libxi6 \
  libxrender1 \
  libgconf-2-4 \
  libcups2 \
  libdbus-1-3 \
  fontconfig \
  libdrm2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy the Piskel zip file into the container
COPY piskel/Piskel-0.14.0-64bits.zip /tmp/piskel.zip

# Create a directory for the application and extract it
RUN mkdir -p /opt/piskel && \
  unzip /tmp/piskel.zip -d /opt/piskel && \
  rm /tmp/piskel.zip

# Create a non-root user to run the application (good practice)
RUN useradd --create-home --shell /bin/bash appuser
USER appuser
WORKDIR /home/appuser

# Set the command to run Piskel
# Note: The archive extracts into a folder, adjust path if necessary
# Assuming the executable path inside the container is /opt/piskel/piskel
CMD ["/opt/piskel/Piskel-0.14.0-64bits/piskel"]

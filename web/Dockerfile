# Use a standard Node.js image (includes Node, npm)
FROM node:20

# --- Build Argument for Port ---
# Define a build-time argument for the application port
# This value can be overridden during the build process, e.g.,
# docker build --build-arg APP_PORT=8080 -t your-image .
ARG APP_PORT=3000

# Install git so we can clone the repository
RUN apt-get update && apt-get install -y git --no-install-recommends && \
  # Clean up apt cache to reduce layer size
  rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Clone the Piskel repository (master branch by default) into the current directory (.)
# --depth 1 creates a shallow clone (faster, less data)
# Remove the .git folder afterwards as it's not needed for runtime
RUN git clone --depth 1 https://github.com/piskelapp/piskel.git . && \
  rm -rf .git

# Install dependencies using the lock file.
# This will install *all* dependencies (including devDependencies)
# because we are in a single stage.
RUN npm ci

# Build the application using Grunt
RUN npx grunt build

# --- Environment Variables ---
# Set environment variables for production
ENV NODE_ENV=production
# Set the application port using the build argument defined earlier
ENV PIKSAPP_SERVER_PORT=${APP_PORT}

# Expose the port the application runs on (using the build argument)
EXPOSE ${APP_PORT}

# --- Runtime Command ---
# Command to run the application server using the environment variable
# The Python http.server uses the PIKSAPP_SERVER_PORT environment variable if available.
# Note: Python's http.server doesn't directly read environment variables like this in its default arguments.
# We need to explicitly pass the port number to the command.
# The ENV variable is still useful for other potential parts of the app or scripts.
# Using sh -c allows environment variable expansion in the CMD.
CMD ["sh", "-c", "python3 -m http.server --directory dest/prod --bind 0.0.0.0 ${PIKSAPP_SERVER_PORT}"]

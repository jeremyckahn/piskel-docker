# Makefile for Piskel Docker GUI App

# --- Configuration ---
# Name for the Docker image
IMAGE_NAME := piskel-app
# Name for the running container
CONTAINER_NAME := piskel-gui
# Piskel zip file (used as a dependency check for build)
ZIP_FILE := piskel/Piskel-0.14.0-64bits.zip

# --- Targets ---

# Default target: cleans up host permissions and runs the app
all: clean-host run

# Phony targets don't represent files
.PHONY: all build run prep-host clean-host clean-image help

# Build the Docker image if Dockerfile or zip file is newer
build: Dockerfile $(ZIP_FILE)
	@echo "--> Building Docker image '$(IMAGE_NAME)'..."
	@docker build -t $(IMAGE_NAME) .

# Prepare host: Allow local connections to the X server
prep-host:
	@echo "--> Allowing local connections to X server (requires user confirmation if not already set)..."
	@xhost +local:

# Run the application: Ensures image is built and host is prepped first
run: build prep-host
	@echo "--> Running container '$(CONTAINER_NAME)' from image '$(IMAGE_NAME)'..."
	@docker run -it --rm \
		--env="DISPLAY=$(DISPLAY)" \
		--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME)
	@echo "--> Container exited."
	@echo "--> Consider running 'make clean-host' to secure your X server."

# Clean host: Disallow local connections to the X server
clean-host:
	@echo "--> Disallowing local connections to X server..."
	@xhost -local:

# Clean image: Remove the built Docker image
clean-image:
	@echo "--> Removing Docker image '$(IMAGE_NAME)'..."
	@docker image rm $(IMAGE_NAME) || echo "Image $(IMAGE_NAME) not found or removal failed."

# Help: Display available commands
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all          Clean host X permissions then run the application (Default)"
	@echo "  build        Build the Docker image '$(IMAGE_NAME)'"
	@echo "  run          Build (if needed), prepare host X server, and run the container"
	@echo "  prep-host    Allow local X server connections (run once per session before 'run')"
	@echo "  clean-host   Disallow local X server connections (run after finishing)"
	@echo "  clean-image  Remove the built Docker image '$(IMAGE_NAME)'"
	@echo "  help         Show this help message"
	@echo ""
	@echo "Current configuration:"
	@echo "  IMAGE_NAME     : $(IMAGE_NAME)"
	@echo "  CONTAINER_NAME : $(CONTAINER_NAME)"
	@echo "  PISKEL_ZIP     : $(ZIP_FILE)"

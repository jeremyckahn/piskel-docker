# Makefile for building, running, and publishing the piskel-web Docker image

# --- Configurable Variables ---
# Docker Hub username (REQUIRED for push/tag) - Override: make push DOCKERHUB_USER=youruser
DOCKERHUB_USER ?= your-dockerhub-username
# Docker Hub repository name - Override: make push DOCKERHUB_REPO=my-piskel
DOCKERHUB_REPO ?= piskel-docker
# Image tag - Override: make build TAG=1.0
TAG ?= latest

# --- Build & Run Variables ---
# Local image name (base name)
IMAGE_NAME := piskel-web
# Fully qualified image name for Docker Hub
FULL_IMAGE_NAME := $(DOCKERHUB_USER)/$(DOCKERHUB_REPO):$(TAG)
# Directory containing the Dockerfile and build context
CONTEXT_DIR := ./web
# Default container port (matches ARG APP_PORT in Dockerfile)
# Override at build time: make build CONTAINER_PORT=8080
CONTAINER_PORT ?= 3000
# Host port to map to the container's port
# Override at run time: make run HOST_PORT=9002
HOST_PORT ?= 9100


# --- Targets ---

# Phony targets are rules that don't represent actual files
.PHONY: build run stop clean clean-hub tag push login help all

# Default target: build the image
all: build

# Build the Docker image
# Usage: make build [CONTAINER_PORT=xxxx] [TAG=yyyy]
# Example: make build CONTAINER_PORT=8080 TAG=1.1
build:
	@echo "Building Docker image $(IMAGE_NAME):$(TAG) from $(CONTEXT_DIR)..."
	@echo "Using container port (APP_PORT): $(CONTAINER_PORT)"
	docker build \
		--build-arg APP_PORT=$(CONTAINER_PORT) \
		-t $(IMAGE_NAME):$(TAG) \
		$(CONTEXT_DIR)
	@echo "Build complete: $(IMAGE_NAME):$(TAG)"

# Tag the local image for Docker Hub
# Usage: make tag [DOCKERHUB_USER=user] [DOCKERHUB_REPO=repo] [TAG=yyyy]
# Requires DOCKERHUB_USER to be set
tag: build
ifeq ($(DOCKERHUB_USER), your-dockerhub-username)
	$(error DOCKERHUB_USER is not set. Use 'make tag DOCKERHUB_USER=your_username')
endif
	@echo "Tagging $(IMAGE_NAME):$(TAG) as $(FULL_IMAGE_NAME)..."
	docker tag $(IMAGE_NAME):$(TAG) $(FULL_IMAGE_NAME)
	@echo "Tagging complete."

# Log in to Docker Hub (interactive)
# Usage: make login
login:
	@echo "Please log in to Docker Hub..."
	docker login

# Push the tagged image to Docker Hub
# Usage: make push [DOCKERHUB_USER=user] [DOCKERHUB_REPO=repo] [TAG=yyyy]
# Requires prior 'make login' and 'make tag' (or runs tag implicitly)
# Requires DOCKERHUB_USER to be set
push: tag
	@echo "Pushing $(FULL_IMAGE_NAME) to Docker Hub..."
	docker push $(FULL_IMAGE_NAME)
	@echo "Push complete."

# Run the Docker container
# Usage: make run [HOST_PORT=xxxx] [CONTAINER_PORT=yyyy] [TAG=zzzz]
# Example: make run HOST_PORT=9002
# Note: CONTAINER_PORT here refers to the port *exposed* by the image built with that port.
#       It should match the APP_PORT used during the 'make build' for the specific TAG.
run:
	@echo "Running Docker container $(IMAGE_NAME):$(TAG)..."
	@echo "Mapping host port $(HOST_PORT) to container port $(CONTAINER_PORT)..."
	# Stop existing container with the same host port mapping if any (best effort)
	-docker ps -q --filter "publish=$(HOST_PORT)" | xargs -r docker stop
	# Run the container
	docker run --rm -d \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--name piskel-app-$(HOST_PORT) \
		$(IMAGE_NAME):$(TAG)
	@echo "Container started in detached mode. Access at http://localhost:$(HOST_PORT)"
	@echo "View logs: docker logs piskel-app-$(HOST_PORT)"
	@echo "Stop container: make stop"

# Stop the running container started by 'make run'
# Usage: make stop [HOST_PORT=xxxx]
stop:
	@echo "Stopping container named piskel-app-$(HOST_PORT)..."
	-docker stop piskel-app-$(HOST_PORT) # Use '-' to ignore error if container doesn't exist
	@echo "Container stopped."

# Clean up: Stop container and remove the *local* Docker image
# Usage: make clean [TAG=xxxx]
clean: stop
	@echo "Removing local Docker image $(IMAGE_NAME):$(TAG)..."
	docker rmi $(IMAGE_NAME):$(TAG) || true # Use '|| true' to ignore errors if the image doesn't exist
	@echo "Local cleanup complete."

# Clean up: Remove the *Docker Hub tagged* local image
# Usage: make clean-hub [DOCKERHUB_USER=user] [DOCKERHUB_REPO=repo] [TAG=yyyy]
# Requires DOCKERHUB_USER to be set
clean-hub:
ifeq ($(DOCKERHUB_USER), your-dockerhub-username)
	$(error DOCKERHUB_USER is not set. Use 'make clean-hub DOCKERHUB_USER=your_username')
endif
	@echo "Removing Docker Hub tagged local image $(FULL_IMAGE_NAME)..."
	docker rmi $(FULL_IMAGE_NAME) || true # Use '|| true' to ignore errors if the image doesn't exist
	@echo "Docker Hub image cleanup complete."


# Help target: Provides usage instructions
help:
	@echo "Makefile Commands:"
	@echo ""
	@echo "  Variables (can be overridden on command line):"
	@echo "    DOCKERHUB_USER   Your Docker Hub username (default: $(DOCKERHUB_USER))"
	@echo "    DOCKERHUB_REPO   Docker Hub repository name (default: $(DOCKERHUB_REPO))"
	@echo "    TAG              Image tag (default: $(TAG))"
	@echo "    CONTEXT_DIR      Build context directory (default: $(CONTEXT_DIR))"
	@echo "    CONTAINER_PORT   Port exposed inside the container (build-time, default: $(CONTAINER_PORT))"
	@echo "    HOST_PORT        Port on the host machine to map (run-time, default: $(HOST_PORT))"
	@echo ""
	@echo "  Core Targets:"
	@echo "    make build       Build the local image ($(IMAGE_NAME):$(TAG))"
	@echo "                     Example: make build CONTAINER_PORT=8080 TAG=1.1"
	@echo "    make run         Run the container ($(IMAGE_NAME):$(TAG))"
	@echo "                     Example: make run HOST_PORT=9002"
	@echo "    make stop        Stop the running container"
	@echo "    make clean       Stop container and remove local image ($(IMAGE_NAME):$(TAG))"
	@echo ""
	@echo "  Docker Hub Targets (Requires DOCKERHUB_USER set):"
	@echo "    make login       Log in to Docker Hub interactively"
	@echo "    make tag         Tag the local image for Docker Hub ($(FULL_IMAGE_NAME))"
	@echo "    make push        Push the tagged image to Docker Hub (runs tag first)"
	@echo "    make clean-hub   Remove the Docker Hub tagged local image ($(FULL_IMAGE_NAME))"
	@echo ""
	@echo "  Other Targets:"
	@echo "    make all         Default target (runs 'make build')"
	@echo "    make help        Show this help message"


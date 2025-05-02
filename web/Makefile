
# Makefile for building and running the piskel-web Docker image

# --- Variables ---
# Define the name for the Docker image
IMAGE_NAME := piskel-web
# Define the directory containing the Dockerfile and build context
CONTEXT_DIR := .
# Define the host port to map to the container's port 3000
# This can be overridden from the command line, e.g., make run HOST_PORT=9002
HOST_PORT ?= 9100
# Define the container port (internal port the application listens on)
CONTAINER_PORT := 3000

# --- Targets ---

# Phony targets are rules that don't represent actual files
.PHONY: build run clean all help

# Default target (optional, uncomment if you want 'make' to run 'build' by default)
# all: build

# Build the Docker image
# Usage: make build
build:
	@echo "Building Docker image $(IMAGE_NAME) from $(CONTEXT_DIR)..."
	docker build -t $(IMAGE_NAME) $(CONTEXT_DIR)
	@echo "Build complete."

# Run the Docker container
# Usage: make run [HOST_PORT=xxxx]
# Example: make run HOST_PORT=9002
# This assumes the image has already been built (e.g., via 'make build')
run:
	# Runs the container, map $(HOST_PORT) (the host port) to $(CONTAINER_PORT)
	# (the container port), remove the container on exit (--rm), run
	# interactively (-it), and redirect output to /dev/null to run in the
	# background detached-like (though -it might keep it attached). If you truly
	# want detached mode, use -d instead of
	# -it and remove > /dev/null.
	@echo "Running Docker container $(IMAGE_NAME), mapping host port $(HOST_PORT) to container port $(CONTAINER_PORT)..."
	docker run --rm -it -p $(HOST_PORT):$(CONTAINER_PORT) $(IMAGE_NAME) > /dev/null

# Clean up: Remove the Docker image
# Usage: make clean
clean:
	@echo "Removing Docker image $(IMAGE_NAME)..."
	# Stop any running container using the image before removing the image
	docker ps -q --filter ancestor=$(IMAGE_NAME) | xargs -r docker stop
	# Remove the image, ignore errors if it doesn't exist
	docker rmi $(IMAGE_NAME) || true
	@echo "Cleanup complete."

# Help target (optional, provides usage instructions)
help:
	@echo "Makefile Commands:"
	@echo "  make build             Build the Docker image ($(IMAGE_NAME))"
	@echo "  make run [HOST_PORT=N] Run the Docker container, mapping host port N (default: $(HOST_PORT)) to $(CONTAINER_PORT)"
	@echo "                         Example: make run HOST_PORT=9002"
	@echo "  make clean             Stop running containers and remove the Docker image ($(IMAGE_NAME))"
	@echo "  make help              Show this help message"



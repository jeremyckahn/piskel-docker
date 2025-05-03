# Piskel Docker

> [!IMPORTANT]
> This repo was put together in haste with AI (Gemini 2.5 Pro). It is known to
> work for my needs, and it may or may not work for yours. Feel free to improve
> it with a Pull Request.

This project provides Dockerfiles and Makefiles to containerize the
[Piskel](https://www.piskelapp.com/) application. It includes configurations
for both the web and desktop versions of Piskel.

## Web Version (`web/`)

The `web/` directory contains the necessary files to build and run a Docker
image for the web version of Piskel.

### Prerequisites

- Docker installed and running.

### Makefile Usage (Top-Level)

The top-level Makefile provides convenient commands to manage the web version
of the Piskel Docker image.

- **Build the image:**

  ```bash
  make build
  ```

  This command builds the `piskel-web` Docker image.

- **Run the container:**

  ```bash
  make run HOST_PORT=9002
  ```

  This command runs the `piskel-web` Docker container, mapping the host port
  `9002` to the container port `3000`. Access Piskel in your browser at
  `http://localhost:9002`. The `HOST_PORT` variable is optional; if not
  provided, it defaults to `9100`.

- **Push the image to Docker Hub:**

  ```bash
  make tag DOCKERHUB_USER=<your_dockerhub_username>
  make push DOCKERHUB_USER=<your_dockerhub_username>
  ```

  Make sure to replace `<your_dockerhub_username>` with your actual Docker Hub
  username. You may also need to run `make login` first.

- **Clean up:**

  ```bash
  make clean
  ```

  This command stops any running containers and removes the `piskel-web` Docker image.

## Desktop Version (`desktop/`)

The `desktop/` directory contains files for building and running the desktop
version of Piskel in Docker. Refer to the `desktop/README.md` file for
instructions.

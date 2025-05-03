# piskel-docker

Run Piskel offline inside of Docker. This has been tested to work under Ubuntu 24.04.

This was slapped together with AI (Gemini 2.5 Pro) to unblock myself and I make
no guarantees how well it might work for you.

## Commands

- `make build`: Builds the Docker image (if it doesn't exist or if `Dockerfile`
  or the zip file changed).
- `make prep-host`: Runs `xhost +local`: to allow the container to connect to
  your display. You typically only need to do this once per host login session.
- `make run`: This is the main command. It will first ensure the image is built
  (`make build`) and the host is prepped (make `prep-host`), then it will start
  the Piskel container using the docker run command.
- `make`: Running make without arguments will execute the all target, which
  defaults to `clean-host` then run. This ensures X permissions are reset before
  running.
- `make clean-host`: Runs `xhost -local:` to revoke the permissions granted by
  `prep-host`. Good practice to run this when you're done using the container for
  the session.
- `make clean-image`: Deletes the `piskel-app` Docker image from your system.
- `make help`: Shows the available commands and current configuration.

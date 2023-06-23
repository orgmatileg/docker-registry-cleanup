# Docker Registry Cleanup

This project provides a Docker image that periodically deletes old images from a Docker registry. The Docker image includes a cleanup script that uses the Docker Registry HTTP API V2 to identify and delete images older than a specified age.

The image is available on Docker Hub at [orgmatileg/docker-registry-cleanup:latest](https://hub.docker.com/repository/docker/orgmatileg/docker-registry-cleanup).

The source code can be found on [GitHub](https://github.com/orgmatileg/docker-registry-cleanup).

## Usage

You can run this Docker image by using the `docker run` command or by using Docker Compose.

### Docker CLI

Pull the Docker image:

    docker pull orgmatileg/docker-registry-cleanup:latest

Run the Docker container:

    docker run \
    -e DOCKER_REGISTRY_URL=<your_registry_url> \
    -e DOCKER_REGISTRY_USER=<your_registry_username> \
    -e DOCKER_REGISTRY_PASSWORD=<your_registry_password> \
    -e DOCKER_IMAGE_CUTOFF_DAYS=<cutoff_age_in_days> \
    orgmatileg/docker-registry-cleanup:latest

### Docker Compose

You can also use Docker Compose to run the Docker container. Here's an example `docker-compose.yml`:

```yaml
version: '3.8'
services:
  docker-registry-cleanup:
    image: orgmatileg/docker-registry-cleanup:latest
    environment:
      DOCKER_REGISTRY_URL: <your_registry_url>
      DOCKER_REGISTRY_USER: <your_registry_username>
      DOCKER_REGISTRY_PASSWORD: <your_registry_password>
      DOCKER_IMAGE_CUTOFF_DAYS: <cutoff_age_in_days>
```

Just run docker-compose up to start the service.

Replace `<your_registry_url>`, `<your_registry_username>`, `<your_registry_password>`, `<cutoff_age_in_days>`, and `<your_cron_schedule>` with your Docker registry URL, your Docker registry username, your Docker registry password, the maximum age (in days) for Docker images to keep, and your desired cron schedule, respectively.

## Environment Variables

The cleanup script uses the following environment variables:

- `DOCKER_REGISTRY_URL`: The URL of your Docker registry.
- `DOCKER_REGISTRY_USER`: The username to log in to the registry.
- `DOCKER_REGISTRY_PASSWORD`: The password to log in to the registry.
- `DOCKER_IMAGE_CUTOFF_DAYS`: The maximum age (in days) for Docker images to keep. Any image in the registry that is older than this age will be deleted when the script runs.

Please ensure that all of these environment variables are set when running the Docker container.

## Warning

Please use this Docker image with caution. Deleting Docker images from a registry can't be undone. We recommend thoroughly testing the cleanup script in your specific environment before scheduling it to run automatically.

## Disclaimer

The maintainers of this project are not responsible for any misuse or misconfiguration of this Docker image by users. It is the users' responsibility to ensure that the Docker image and the cleanup script are configured correctly and that their usage complies with all applicable laws and regulations. Use this Docker image at your own risk.

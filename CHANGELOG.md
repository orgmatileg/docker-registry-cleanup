# Changelog

All notable changes to the Docker Registry Cleanup project will be documented in this file.

## [1.0.0] - 2023-06-24

### Added

- Initial release of the Docker registry cleanup image.
- Implemented cleanup script that uses the Docker Registry HTTP API V2 to delete images older than a specified age.
- Added environment variable configurations for Docker registry URL, username, password, image cutoff age, and cron schedule.
- Docker image published to Docker Hub at [orgmatileg/docker-registry-cleanup:latest](https://hub.docker.com/repository/docker/orgmatileg/docker-registry-cleanup).
- Source code available on [GitHub](https://github.com/orgmatileg/docker-registry-cleanup).
- README includes usage instructions, environment variable details, and important warnings and disclaimers.

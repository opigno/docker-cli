# OpignoLMS Docker Image

## Overview
The `opigno/cli` Docker image is primarily designed to run the OpignoLMS FPM instance. It includes minimal features or components, which makes it suitable for users to test OpignoLMS. Please note that this image is not recommended for production use.

## Features
- Minimal features or components included
- Provides a quick testing environment for OpignoLMS
- Default `settings.php` and `php.ini` configurations included

## Prerequisites
To run this Docker image, you'll need to use `docker-compose` to run both this image and the necessary webserver image.

## Running the Docker Image
A simple example of the `docker-compose` setup is provided below:
```yml
version: "3.7"
services:
  alpine:
    build:
      context: .
      dockerfile: Dockerfile
    command: php -S 0.0.0.0:8888 .ht.router.php
    ports:
      - "8888:8888"
```

### Configuration & Environment Variables
 - Note: The image is not recommended for production.
 - The settings.php file is included with default values. It's not designed for overrides in the current version.
 - The php.ini file is included with default values. It's not designed for overrides in the current version.

### Interaction with the Running Container
You can access and interact with the running container using the following command:
```bash
docker exec -it <container_name> sh
```

### Known Issues & Limitations
This image is intended for testing and is not recommended for production environments.

### Support & Contact
For any questions, issues, or concerns, please contact the author at:
E-mail: yboichenko@connect-i.ch
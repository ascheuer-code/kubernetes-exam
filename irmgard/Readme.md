# Irmgard - The Image Guard

A minimalistic example of an image processing web app accessing a PostgreSQL [1] database and a minio object store written in Go [2]. For each incoming image a message is posted to a RabbitMQ [5] message queue.

This application is part of an exam for the free [anynines Kubernetes Training](https://learn.kubernetes.anynines.com/).

This code contains refactoring challenges for the training participants.
It implements the "happy path" - there is little to no error handling - and thus is rather fragile.

## Go

    go mod init github.com/fischerjulian/irmgard

### Run

Assumptions:

* RabbitMQ is available via local network
* PostgreSQL is available via local network

Assuming there is a PostgreSQL server running with a user `postgres` and an empty database `postgresl`:

    POSTGRES_HOST=<postgresql-host> POSTGRES_USERNAME=<postgresql-username> POSTGRES_PASSWORD=<postgresl-password> go run main.go

e.g.

    POSTGRES_HOST=localhost POSTGRES_USERNAME=postgres POSTGRES_PASSWORD=xxx go run main.go

## Docker

**TODO** Create a Dockerfile and build a container image. As a hint, the workflow of creating a Docker container image is stated below.

### Build

    docker image build -t irmgard:0.3.0 .
    
### Tag

    docker image tag irmgard:0.3.0 fischerjulian/irmgard:0.3.0

### Publish to Registry

    docker image push fischerjulian/irmgard:0.3.0                                   

### Pull Image from Registry

    docker image pull fischerjulian/irmgard:0.3.0

### Run
In order to run the image you will also have to set the env vars `POSTGRES_HOST` and `POSTGRES_PASSWORD` which is not contained in the examples below as the images will be used in the context of Kubernetes, only.

Run local image with version tag `0.3.0`:

    docker container run -p 8080:8080 irmgard:0.3.0

Run remote image with version tag `0.3.0`:

    docker container run -p  8080:8080 fischerjulian/irmgard:0.3.0

## Using the WebService

### Submitting an Image

```bash
curl -F 'image=@/Users/jfischer/Downloads/000d8ea8207c6d7dae321da11083a312.jpg' localhost:8080
```

## Links

1. PostgreSQL, https://www.postgresql.org/
2. Go, https://golang.org/
3. Go PQ, https://github.com/lib/pq
4. RabbitMQ, https://www.rabbitmq.com/
5. RabbitMQ Go Introduction, https://www.rabbitmq.com/tutorials/tutorial-one-go.html

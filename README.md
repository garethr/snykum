# Snykum

![Image](https://github.com/garethr/snykum/workflows/Image/badge.svg)

A technical demonstration of building ARM images using Docker and GitHub Actions, and testing them for vulnerabilities using [Snyk](https://snyk.io).

> 1. Install QEMU using [docker/setup-qemu-action](https://github.com/docker/setup-qemu-action)
> 2. Install and configure buildx using [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action)
> 3. Build the ARM image using `docker buildx` and [docker/build-push-action](https://github.com/docker/build-push-action)
> 4. Check the image for vulnerabilities using [snyk/actions/docker](https://github.com/snyk/actions/tree/master/docker)
> 5. Push to Docker Hub using [docker/github-action](https://github.com/docker/github-actions)

```yaml
name: Image

on:
  push:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      # QEMU is used to emulated the ARM architecture, allowing us
      # to build not-x86 images
      - name: Set up QEMU
        uses: docker/setup-qemu-action@master
        with:
          platforms: all
      # Buildx provides an easier way of building DOcker images for other architectures
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@master
        with:
          install: true
      # Using install above sets buildx to be the default for docker build, which
      # means the build-push-action can use it. Note we don't push the image here
      # because we want to test it first. Buildx requires additional args as well
      # to load the image into the local Docker daemon
      - name: Build image
        uses: docker/build-push-action@v1
        with:
          repository: garethr/snykum
          add_git_labels: true
          tag_with_sha: true
          push: false
          args: --platform=linux/arm64 --load
      - name: Run Snyk to check Docker image for vulnerabilities
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          command: monitor
          image: garethr/snykum
          args: --file=Dockerfile --platform=linux/arm64 --project=docker.io/garethr/snykum
      - name: Login
        uses: docker://docker/github-actions:v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}
          args: login
      # We use the low-level github-action image in order to access to the
      # built-in ability to push the SHA automatically
      - name: Push image to Docker Hub
        uses: docker://docker/github-actions:v1
        with:
          repository: garethr/snykum
          tag_with_sha: true
          args: push
```

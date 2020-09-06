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
      - uses: github/super-linter@v3
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      # QEMU is used to emulated the ARM architecture, allowing us
      # to build not-x86 images
      - uses: docker/setup-qemu-action@master
        with:
          platforms: all
      # Buildx provides an easier way of building Docker images for other architectures
      - uses: docker/setup-buildx-action@master
      - name: Build image
        run: |
          docker buildx build --platform=linux/arm64 --load -t temporary .
      - name: Run Snyk to check Docker image for vulnerabilities
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          command: monitor
          image: temporary
          args: --file=Dockerfile --platform=linux/arm64 --project-name=docker.io/garethr/snykum
      - uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}
      # Use the build cache and push the imagee
      - name: Push image to Docker Hub
        run: |
          docker buildx build --platform=linux/arm64 --push -t garethr/snykum .
```

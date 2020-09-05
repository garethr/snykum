# Snykuk

A technical demonstration of building ARM images using Docker and GitHub Actions, and testing them for vulnerabilities using [Snyk](https://snyk.io).

> 1. Install QEMU using [docker/setup-qemu-action](https://github.com/docker/setup-qemu-action)
> 2. Install and configure buildx using [docker/buildx](https://github.com/docker/setup-buildx-action)
> 3. Build the ARM image using `docker buildx`
> 4. Check the image for vulnerabilities using [snyk/actions/docker](https://github.com/snyk/actions/tree/master/docker)



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
      - name: Set up QEMU
        uses: docker/setup-qemu-action@master
        with:
          platforms: all
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@master
        with:
          install: true
      - name: Build
        run: |
          docker build --platform=linux/arm64 --load -t garethr/snykum .
      - uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}
      - name: Run Snyk to check Docker image for vulnerabilities
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          image: garethr/snykum
          args: --file=Dockerfile --platform=linux/arm64
      - name: Push
        run: |
          docker push garethr/snykum
```

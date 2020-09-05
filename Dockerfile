FROM debian:stable

RUN apt-get update && apt-get install -y --no-install-recommends \
    sqlite3=3.27.2-3 \
 && rm -rf /var/lib/apt/lists/*

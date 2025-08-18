FROM ghcr.io/gleam-lang/gleam:v1.12.0-erlang
WORKDIR /app
RUN apt-get update && \
    apt-get install -y inotify-tools && \
    rm -rf /var/lib/apt/lists/*
CMD ["tail", "-f", "/dev/null"]

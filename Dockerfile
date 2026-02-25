FROM crystallang/crystal:latest
WORKDIR /data

COPY --from=oven/bun:latest /usr/local/bin/bun /usr/local/bin/bun

RUN apt-get update && \
  apt-get install -y curl libreadline-dev && \
  # Cleanup leftovers
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /data

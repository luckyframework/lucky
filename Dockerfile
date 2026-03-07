FROM crystallang/crystal:latest
WORKDIR /data

RUN apt-get update && \
  apt-get install -y curl libreadline-dev unzip file imagemagick && \
  curl -fsSL https://bun.sh/install | bash && \
  ln -s /root/.bun/bin/bun /usr/local/bin/bun && \
  # Cleanup leftovers
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /data

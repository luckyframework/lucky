FROM crystallang/crystal:0.36.1
WORKDIR /data

RUN apt-get update && \
  apt-get install -y libgconf-2-4 curl libreadline-dev && \
  # Cleanup leftovers
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /data

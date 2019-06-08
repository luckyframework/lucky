FROM crystallang/crystal:0.29.0

RUN apt-get update && \
  apt-get install -y libgconf-2-4 build-essential curl libreadline-dev libevent-dev libssl-dev libxml2-dev libyaml-dev libgmp-dev git  && \
  # Cleanup leftovers
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /data
WORKDIR /data
ADD . /data

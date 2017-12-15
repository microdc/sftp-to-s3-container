FROM ubuntu:16.04

RUN apt-get update -qq
RUN apt-get install -y automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config wget tar

RUN wget https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.82.tar.gz -O /usr/src/s3fs-fuse-v1.82.tar.gz
RUN tar xvz -C /usr/src -f /usr/src/s3fs-fuse-v1.82.tar.gz
RUN cd /usr/src/s3fs-fuse-1.82 && ./autogen.sh && ./configure --prefix=/usr && make && make install

RUN mkdir /s3bucket


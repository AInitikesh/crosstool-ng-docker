FROM alpine:3.8

MAINTAINER 007nitikeshrock@gmail.com nitikesh 

# add user ctng
RUN mkdir /home/ctng \
&&  groupadd -r ctng -g 1000 \
&&  useradd -u 1000 -r -g ctng -d /home/ctng -s /bin/bash -c "Docker image user" ctng \
&&  chown -R ctng:ctng /home/ctng \
&&  adduser ctng sudo \
&&  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
RUN apk update
RUN apk add alpine-sdk wget xz git bash autoconf automake bison flex texinfo help2man gawk libtool ncurses-dev gettext-dev python-dev
RUN wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64
RUN chmod a+x /sbin/dumb-init
RUN echo 'export PATH=/opt/ctng/bin:$PATH' >> /etc/profile



WORKDIR /home/ctng
USER ctng

RUN git clone https://github.com/crosstool-ng/crosstool-ng.git \
&&  cd /home/ctng/crosstool-ng \
&&  ./bootstrap \
&&  ./configure \
&&  make \
&&  sudo make install \
&&  rm -rf ../crosstool-ng/ 

ENTRYPOINT [ "/sbin/dumb-init", "--" ]
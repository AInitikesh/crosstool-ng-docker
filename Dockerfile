FROM centos:7 as ct-ng

MAINTAINER 007nitikeshrock@gmail.com nitikesh 

RUN mkdir /home/ctng \
&&  groupadd -g 1000 ctng \
&&  useradd -d /home/ctng -m -g 1000 -u 1000 -s /bin/bash ctng \
&&  chown -R ctng:ctng /home/ctng 


# Install dependencies to build toolchain
RUN yum -y update && \
    yum install -y epel-release && \
    yum install -y autoconf gperf bison file flex texinfo help2man gcc-c++ \
    libtool make patch ncurses-devel python36-devel perl-Thread-Queue bzip2 \
    git wget which xz unzip && \
    yum clean all

RUN ln -sf python36 /usr/bin/python3
RUN wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64
RUN chmod a+x /sbin/dumb-init
RUN echo 'export PATH=/opt/ctng/bin:$PATH' >> /etc/profile

WORKDIR /home/ctng

RUN git clone https://github.com/crosstool-ng/crosstool-ng.git 
RUN cd /home/ctng/crosstool-ng \
    && ./bootstrap \
    && ./configure \
    && make \
    && make install \
    && rm -rf ../crosstool-ng/

USER ctng
RUN /sbin/dumb-init -- ct-ng arm-unknown-linux-gnueabi
RUN /sbin/dumb-init -- ct-ng build

ENTRYPOINT [ "/sbin/dumb-init", "--" ]

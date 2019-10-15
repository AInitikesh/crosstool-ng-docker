FROM centos:7 as ct-ng

MAINTAINER 007nitikeshrock@gmail.com nitikesh 


# Install dependencies to build toolchain
RUN yum -y update && \
    yum install -y epel-release && \
    yum install -y autoconf gperf bison file flex texinfo help2man gcc-c++ \
    libtool make patch ncurses-devel python36-devel perl-Thread-Queue bzip2 \
    git wget which xz unzip && \
    yum install -y sudo dtc bc && \
    yum clean all

RUN ln -sf python36 /usr/bin/python3
RUN wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64
RUN chmod a+x /sbin/dumb-init
RUN echo 'export PATH=/opt/ctng/bin:$PATH' >> /etc/profile

RUN useradd -m ctng && echo "ctng:ctng" | chpasswd && usermod -aG wheel ctng

ENV PATH=/home/ctng/x-tools/arm-unknown-linux-gnueabi/bin:$PATH

WORKDIR /home/ctng
USER ctng

ENV CT_NG_VERSION=1.24.0
RUN git clone -b crosstool-ng-${CT_NG_VERSION} --single-branch --depth 1 \
        https://github.com/crosstool-ng/crosstool-ng.git

RUN cd crosstool-ng && \
    ./bootstrap && \
    ./configure --prefix=/home/ctng/.local && \
    make -j$(($(nproc) * 2)) && \
    make install &&  \
    cd .. && rm -rf crosstool-ng
ENV PATH=/home/ctng/.local/bin:$PATH

USER ctng
RUN /sbin/dumb-init -- ct-ng arm-unknown-linux-gnueabi
RUN /sbin/dumb-init -- ct-ng build

ENV PATH=/home/ctng/x-tools/arm-unknown-linux-gnueabi/bin:$PATH

ENTRYPOINT [ "/sbin/dumb-init", "--" ]

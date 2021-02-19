# Copyright (C) 2016 by Ewan Barr
# Licensed under the Academic Free License version 3.0
# This program comes with ABSOLUTELY NO WARRANTY.
# You are free to modify and redistribute this code as long
# as you do not remove the above attribution and reasonably
# inform receipients that you have modified the original work.

# derived from https://hub.docker.com/r/mpifrpsr/dspsr/dockerfile
# modified and updated

FROM debian:10.7

# Suppress debconf warnings
ENV DEBIAN_FRONTEND noninteractive

RUN echo "root:root" | chpasswd && \
    mkdir -p /root/.ssh

# Create psr user which will be used to run commands with reduced privileges.
RUN adduser --disabled-password --gecos 'unprivileged user' psr && \
    echo "psr:psr" | chpasswd && \
    mkdir -p /home/psr/.ssh && \
    chown -R psr:psr /home/psr/.ssh

# Install dependencies
RUN sed -i "s/ main/ main non-free/g" /etc/apt/sources.list && \
    mkdir /var/run/sshd && \
    apt-get -y check && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get --no-install-recommends -y install \
      apt-utils \
      apt-transport-https \
      software-properties-common \
      build-essential \
      autoconf \
      autotools-dev \
      automake \
      autogen \
      libtool \
      pkg-config \
      cmake \
      csh \
      gcc \
      gfortran \
      wget \
      git \
      libcfitsio-dev \
      pgplot5 \
      swig \
      python \
      python-dev \
      python-pip \
      libfftw3-3 \
      libfftw3-bin \
      libfftw3-dev \
      libfftw3-single3 \
      libx11-dev \
      libpng-dev \
      libpnglite-dev \
      libhdf5-dev \
      libhdf5-serial-dev \
      libxml2 \
      libxml2-dev \
      libltdl-dev \
      libgsl-dev \
      libgsl23 \
      linux-perf \
      linux-base \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y clean

# Install python packages
RUN pip install pip -U && \
    pip install setuptools -U && \
    pip install numpy -U && \
    pip install scipy -U && \
    pip install matplotlib -U

# PGPLOT
ENV PGPLOT_DIR /usr/lib/pgplot5
ENV PGPLOT_FONT /usr/lib/pgplot5/grfont.dat
ENV PGPLOT_INCLUDES /usr/include
ENV PGPLOT_BACKGROUND white
ENV PGPLOT_FOREGROUND black
ENV PGPLOT_DEV /xs

USER psr

# Define home, psrhome, OSTYPE and create the directory
ENV HOME /home/psr
ENV PSRHOME $HOME/software
ENV OSTYPE linux
RUN mkdir -p $PSRHOME
WORKDIR $PSRHOME

# Pull all repos
RUN wget http://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz && \
    tar -xvf psrcat_pkg.tar.gz -C $PSRHOME && \
    git clone https://bitbucket.org/psrsoft/tempo2.git --depth=1 && \
    git clone git://git.code.sf.net/p/dspsr/code dspsr --depth=1 && \
    git clone git://git.code.sf.net/p/psrchive/code psrchive --depth=1 && \
    git clone https://git.astron.nl/ro/dal2.git DAL --depth=1 && \
    git clone https://github.com/ajameson/pfits.git --depth=1

# DAL
ENV DAL $PSRHOME/DAL
ENV PATH $PATH:$DAL/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$DAL/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$DAL/install/lib
WORKDIR $DAL
RUN mkdir build
WORKDIR $DAL/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$DAL/install -DGENERATE_DOCS=OFF && \
    make -j $(nproc) && \
    make && \
    make install

# Psrcat
ENV PSRCAT_FILE $PSRHOME/psrcat_tar/psrcat.db
ENV PATH $PATH:$PSRHOME/psrcat_tar
WORKDIR $PSRHOME/psrcat_tar
RUN /bin/bash makeit && \
    rm -f ../psrcat_pkg.tar.gz

# tempo2
ENV TEMPO2 $PSRHOME/tempo2/T2runtime
ENV PATH $PATH:$PSRHOME/tempo2/T2runtime/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/tempo2/T2runtime/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/tempo2/T2runtime/lib
WORKDIR $PSRHOME/tempo2
RUN sync && perl -pi -e 's/chmod \+x/#chmod +x/' bootstrap # Get rid of: returned a non-zero code: 126.
RUN ./bootstrap && \
    ./configure --x-libraries=/usr/lib/x86_64-linux-gnu --enable-shared --enable-static --with-pic F77=gfortran && \
    make -j $(nproc) && \
    make install && \
    make plugins-install && \
    rm -rf .git

# PSRCHIVE
ENV PSRCHIVE $PSRHOME/psrchive
ENV PATH $PATH:$PSRCHIVE/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRCHIVE/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRCHIVE/install/lib
ENV PYTHONPATH $PSRCHIVE/install/lib/python2.7/site-packages
WORKDIR $PSRCHIVE
RUN ./bootstrap && \
    ./configure --prefix=$PSRCHIVE/install --x-libraries=/usr/lib/x86_64-linux-gnu --enable-shared --enable-static F77=gfortran && \
    make -j $(nproc) && \
    make && \
    make install && \
    rm -rf .git
WORKDIR $HOME
RUN echo "Predictor::default = tempo2" >> .psrchive.cfg && \
    echo "Predictor::policy = default" >> .psrchive.cfg

# DSPSR
ENV DSPSR $PSRHOME/dspsr
ENV PATH $PATH:$DSPSR/install/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$DSPSR/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$DSPSR/install/include
WORKDIR $DSPSR
RUN ./bootstrap && \
    echo "apsr asp bcpm bpsr caspsr cpsr cpsr2 dummy fits kat lbadr lbadr64 lofar_dal lump lwa puma2 sigproc ska1" > backends.list && \
    ./configure --prefix=$DSPSR/install --x-libraries=/usr/lib/x86_64-linux-gnu --with-hdf5-libdir=/usr/lib/x86_64-linux-gnu/hdf5/serial/ CPPFLAGS="-I"$DAL"/install/include -I/usr/include/hdf5/serial" LDFLAGS="-L"$DAL"/install/lib" LIBS="-lpgplot -lcpgplot" && \
    make -j $(nproc) && \
    make && \
    make install

# pfits
WORKDIR $PSRHOME/pfits
ENV PATH $PATH:$PSRHOME/pfits/install/bin
RUN ./bootstrap && \
    ./configure --prefix=$PSRHOME/pfits/install && \
    make -j $(nproc) && \
    make && \
    make install

# finalize
USER root
RUN env | awk '{print "export ",$0}' >> $HOME/.profile
WORKDIR $HOME

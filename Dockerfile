##################################################################################
#
#  NVIDIA CUDA BUILD:
#    we really just want mpi at this point, but perhaps in the future we will add tensorflow support for this build
#    working off newer version of the base img that Mark used for RynLib

#
##################################################################################
FROM nvidia/cuda:11.3.1-devel-centos7

# Wget
RUN \
    yum install -y \
        wget &&\
    rm -rf /var/cache/yum/*

# GNU compiler runtime , installs openMP (for funsies)
RUN \
    yum install -y \
        libgfortran \
        libgomp &&\
    rm -rf /var/cache/yum/*

# Centos Development Tools
RUN \
    yum groupinstall -y 'Development Tools'

# OPA
RUN \
    yum install -y \
        hwloc-libs \
        infinipath-psm \
        libfabric \
        libhfil \
        libibverbs \
        libibverbs-devel \
        libpsm2 \
        libsysfs-devel \
        numactl-libs \
        opa-basic-tools \
        rdma-core

# OpenMPI
RUN \
    yum install -y \
        hwloc \
        openssh-clients &&\
    rm -rf /var/cache/yum/*

# OpenMPI Installation !!!!!
ARG MPI_VERSION=3.1.4
ARG MPI_MAJOR_VERSION=3.1
ARG MPI_URL="https://download.open-mpi.org/release/open-mpi/v${MPI_MAJOR_VERSION}/openmpi-${MPI_VERSION}.tar.bz2"
ARG MPI_DIR=/opt/ompi
RUN mkdir -p /tmp/ompi && \
    mkdir -p /opt && \
    # Download
    cd /tmp/ompi && wget -O openmpi-$MPI_VERSION.tar.bz2 $MPI_URL && tar -xjf openmpi-$MPI_VERSION.tar.bz2 && \
    # Compile and install
    cd /tmp/ompi/openmpi-$MPI_VERSION && ./configure --prefix=$MPI_DIR --disable-oshmem --enable-branch-probabilities && make -j12 install && \
    make clean


ENV BASH_ENV=/etc/bash.bashrc

ENV PATH=$MPI_DIR/bin:$PATH
ENV LD_LIBRARY_PATH=$MPI_DIR/lib:$LD_LIBRARY_PATH

RUN \
    yum install -y\
      g++ \
      git
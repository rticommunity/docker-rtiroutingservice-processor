# (c) 2019 Copyright, Real-Time Innovations, Inc. All rights reserved.
# No duplications, whole or partial, manual or electronic, may be made
# without express written permission.  Any such copies, or revisions thereof,
# must display this notice unaltered.
# This code contains trade secrets of Real-Time Innovations, Inc.

#===========================================================================#
#================= Container where the build will be done ==================#
#===========================================================================#
FROM ubuntu:18.04 as builder

#-------------------------------------------------------------------#
#----------------------- Install third party -----------------------#
#-------------------------------------------------------------------#
# From official repositories
RUN apt update && \
    apt install -y --no-install-recommends \
        wget \
        build-essential \
        ca-certificates && \
    mkdir rti_artifacts

# Download and install CMake 3.13.3
# We need to download it from the official website because the version provided
# in the official repositories is really old
RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.3/cmake-3.13.3-Linux-x86_64.tar.gz
RUN mkdir cmake && \
    tar -xvzf cmake-3.13.3-Linux-x86_64.tar.gz \
        -C /usr/local \
        --strip-components=1

#-------------------------------------------------------------------#
#----------------------- Install ConnextDDS ------------------------#
#-------------------------------------------------------------------#
# Download and install RTI host bundle
WORKDIR rti_artifacts
RUN wget http://localhost:8000/rti_connext_dds-6.0.0-pro-host-x64Linux.run
RUN chmod +x rti_connext_dds-6.0.0-pro-host-x64Linux.run
RUN ./rti_connext_dds-6.0.0-pro-host-x64Linux.run \
        --mode unattended \
        --unattendedmodeui none \
        --prefix /rti \
        --disable_copy_examples true

# Donwload and install the target bundle for x64Linux4gcc7.3.0
RUN wget \
    http://localhost:8000/rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg
RUN /rti/rti_connext_dds-6.0.0/bin/rtipkginstall \
    -unattended rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg

#-------------------------------------------------------------------#
#--------------------- Build the RS processor ----------------------#
#-------------------------------------------------------------------#
ENV NDDSHOME /rti/rti_connext_dds-6.0.0

# Add the source code from the host machine
COPY src /src

RUN mkdir /build && \
    cmake \
        -S /src \
        -B /build \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=1 && \
    cmake --build /build

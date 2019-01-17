# (c) 2019 Copyright, Real-Time Innovations, Inc. All rights reserved.
# No duplications, whole or partial, manual or electronic, may be made
# without express written permission.  Any such copies, or revisions thereof,
# must display this notice unaltered.
# This code contains trade secrets of Real-Time Innovations, Inc.

########## Conteiner where the build will be done ##########
FROM ubuntu:18.04 as builder
RUN apt update && apt install wget build-essential ca-certificates -y --no-install-recommends && mkdir rti_artifacts

# Donwload and install RTI host bundle
WORKDIR rti_artifacts
RUN wget http://localhost:8000/rti_connext_dds-6.0.0-pro-host-x64Linux.run
RUN chmod +x rti_connext_dds-6.0.0-pro-host-x64Linux.run
RUN ./rti_connext_dds-6.0.0-pro-host-x64Linux.run \
    --mode unattended \
    --unattendedmodeui none \
    --prefix /rti \
    --disable_copy_examples true

RUN wget http://localhost:8000/rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg
RUN /rti/rti_connext_dds-6.0.0/bin/rtipkginstall -unattended rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg

# Download and install CMake 3.13.3
RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.3/cmake-3.13.3-Linux-x86_64.tar.gz
RUN mkdir cmake && tar -xvzf cmake-3.13.3-Linux-x86_64.tar.gz  -C /usr/local --strip-components=1

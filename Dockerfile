# (c) 2019 Copyright, Real-Time Innovations, Inc. All rights reserved.
# No duplications, whole or partial, manual or electronic, may be made
# without express written permission.  Any such copies, or revisions thereof,
# must display this notice unaltered.
# This code contains trade secrets of Real-Time Innovations, Inc.
FROM ubuntu:18.04 as builder

# Install the compiler and wget
RUN apt update && apt install build-essential wget -y

# Download and install CMake 3.13.3
RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.3/cmake-3.13.3-Linux-x86_64.tar.gz
RUN mkdir cmake && tar -xvzf cmake-3.13.3-Linux-x86_64.tar.gz  -C /usr/local --strip-components=1
#RUN cp -R cmake-3.13.3-Linux-x86_64/* /usr/local/


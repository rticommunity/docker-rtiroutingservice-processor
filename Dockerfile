# (c) 2019 Copyright, Real-Time Innovations, Inc. All rights reserved.
# No duplications, whole or partial, manual or electronic, may be made
# without express written permission.  Any such copies, or revisions thereof,
# must display this notice unaltered.
# This code contains trade secrets of Real-Time Innovations, Inc.

#===========================================================================#
#================= Container where the build will be done ==================#
#===========================================================================#
FROM ubuntu:18.04 as builder

# Where the dependencies manager server is located
ARG ARTIFACTS_SERVER=http://localhost:8000

# The ConnextDDS installation will be done here
ENV NDDSHOME /rti/rti_connext_dds-6.0.0

#-------------------------------------------------------------------#
#----------------------- Install third party -----------------------#
#-------------------------------------------------------------------#
# From official repositories
RUN apt update && \
    apt install -y --no-install-recommends \
        wget \
        build-essential \
        ca-certificates

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
RUN mkdir /rti_artifacts
WORKDIR /rti_artifacts
RUN wget $ARTIFACTS_SERVER/rti_connext_dds-6.0.0-pro-host-x64Linux.run
RUN chmod +x rti_connext_dds-6.0.0-pro-host-x64Linux.run
RUN ./rti_connext_dds-6.0.0-pro-host-x64Linux.run \
        --mode unattended \
        --unattendedmodeui none \
        --prefix /rti \
        --disable_copy_examples true

# Donwload and install the target bundle for x64Linux4gcc7.3.0
RUN wget \
    $ARTIFACTS_SERVER/rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg
RUN $NDDSHOME/bin/rtipkginstall \
    -unattended rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg

#-------------------------------------------------------------------#
#--------------------- Build the RS processor ----------------------#
#-------------------------------------------------------------------#

# Add the source code from the host machine
COPY src /src

# Generate the build system with CMake and build
RUN mkdir /build && \
    cmake \
        -S /src \
        -B /build \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=1 && \
    cmake --build /build

FROM ubuntu:18.04 as pre-deploy
RUN mkdir -p \
        /rti/rti_connext_dds-6.0.0/ \
        /rti/rti_connext_dds-6.0.0/bin/ \
        /rti/rti_connext_dds-6.0.0/resource/scripts/ \
        /rti/rti_connext_dds-6.0.0/resource/app/bin/x64Linux2.6gcc4.4.5/ \
        /rti/rti_connext_dds-6.0.0/resource/app/ \
        /rti/rti_connext_dds-6.0.0/resource/xml/ \
        /rti/rti_connext_dds-6.0.0/resource/app/lib/x64Linux2.6gcc4.4.5/ \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/bin/rtiroutingservice \
        /rti/rti_connext_dds-6.0.0/bin/
COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/resource/scripts/rticommon.sh \
        /rti/rti_connext_dds-6.0.0/resource/scripts/
COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/resource/scripts/rticommon_config.sh \
        /rti/rti_connext_dds-6.0.0/resource/scripts/
COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/resource/app/bin/x64Linux2.6gcc4.4.5/rtiroutingservice \
        /rti/rti_connext_dds-6.0.0/resource/app/bin/x64Linux2.6gcc4.4.5/
COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/resource/xml/RTI_ROUTING_SERVICE.xml \
        /rti/rti_connext_dds-6.0.0/resource/xml/
COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/resource/app/lib/x64Linux2.6gcc4.4.5/ \
        /rti/rti_connext_dds-6.0.0/resource/app/lib/x64Linux2.6gcc4.4.5/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/librtiroutingservice.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/
COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/librticonnextmsgc.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/librtidlc.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/libnddsmetp.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/libnddsc.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/resource/app/lib/x64Linux2.6gcc4.4.5/librtixml2.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/libnddscore.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/libnddscpp2.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

COPY --from=builder \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/librtirsinfrastructure.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/


COPY --from=builder /src/RsShapesProcessor.xml /rti

COPY --from=builder \
        /build/libshapesprocessor.so \
        /rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/libshapesprocessor.so

FROM ubuntu:18.04 as deploy

COPY --from=pre-deploy \
        /rti \
        /rti

RUN groupadd -g 999 rtiuser && \
    useradd -r -u 999 -g rtiuser rtiuser
USER rtiuser

ENV PATH /rti/rti_connext_dds-6.0.0/bin/:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/rti/rti_connext_dds-6.0.0/lib/x64Linux4gcc7.3.0/

ENTRYPOINT ["rtiroutingservice"]
CMD ["-cfgFile", "/rti/RsShapesProcessor.xml", "-cfgName", "RsShapesAggregator", "-DSHAPES_PROC_KIND=aggregator_simple"]

Running Routing Service Processors on Docker Containers
#######################################################

Introduction
************

Routing Service Processors are event-oriented pluggable components that allow
you to control the forwarding process that occurs within a RTI Routing Service
Route.

In this repository, we show how you to build and deploy a Routing Service
Processor using Docker. Our instructions assume you have a basic understanding
of Docker containers. However, if you are new to Docker, the following
documents will give you enough information to get started:

* \ |Getting started|\

* \ |Docker overview|\

* \ |Google Cloud best practices|\

Also, the RTI Community Portal contains some useful documents that cover the
integration of DDS in a Docker environment:

* \ |ConnextDDS and shared memory|\

* \ |ConnextDDS and host driver|\

Lastly, to learn more about how to implement and use custom processor plugins,
please check the *README.rst* files in this repository directory and the
\ |RS Documentation|\.


Dependencies
************

Before diving into the hands-on instructions, make sure you install the
necessary dependencies. The instructions, which we developed and tested
using **Docker CE version 18.09.0** (build ``4d60db4``) assume you are using
a **Linux host**.

First, install Docker on your Linux host. Please, follow the appropriate
instructions for your Linux distribution:

* \ |Install Docker CentOS|\

* \ |Install Docker Debian|\

* \ |Install Docker Fedora|\

* \ |Install Docker Ubuntu|\

Note that you will need to use Docker Compose to run some scenarios. Please
refer to the \ |Install Docker Compose|\.

Second, to run RTI Routing Service and your custom Processor plugin, download
the following RTI packages (Connext 6 or above):

* RTI Host for 64-bit Linux: rti_connext_dds-6.0.0-pro-host-x64Linux.run

* RTI Target Libraries for x64Linux4gcc7.3.0: rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg

Hands on!
*********

In this manual, we will use Docker to:

* Setup a basic dependency management server.

* Build the RTI Routing Service Processor.

* Deploy RTI Routing Service and the custom Processor on a Docker container.

To get started, create an empty directory to prepare the workspace to run
these scenarios:

.. code-block::

    mkdir docker_example

Next, clone the repository within the recently created folder:

.. code-block::

    cd docker_example
    git clone https://github.com/rticommunity/docker-rtiroutingservice-processor rs-docker

Lastly, create a folder called ``artifacts`` and copy the following files into
it:

.. code-block::

    mkdir artifacts
    cp /path/to/rti_connext_dds-6.0.0-pro-host-x64Linux.run ./artifacts/
    cp /path/to/rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg ./artifacts/

The final directory structure should be as follows:

.. code-block::

    ├── artifacts
    │   ├── rti_connext_dds-6.0.0-pro-host-x64Linux.run
    │   └── rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg
    └── rs-docker
        ├── artifacts-server
        │   ├── docker-compose.yml
        │   └── Dockerfile
        ├── Dockerfile
        ├── README.md
        └── src
            ├── CMakeLists.txt
            ├── README.rst
            ├── RsShapesProcessor.xml
            ├── ShapesProcessor.cxx
            └── ShapesProcessor.hpp


Setting Up Dependency Management Server
=======================================

The first step in this manual is to setup a basic HTTP server to provide the
RTI installation packages.

Under ``rs-docker/artifactor-server`` you will find two files:

* ``Dockerfile``, which specifies how create the Docker image for the server.

* ``docker-compose.yml``, which specifies how to execute the Docker image.

Usually, we use ``docker run`` to start and run a Docker container. However,
in this example we use ``docker-compose``, which is better suited for scenarios
where:

* More than one container is needed to run the application.

* A service must be executed.

* We are in a development environment.

For more information on `docker-compose`, please refer to
\ |Docker Compose documentation|\.

Therefore, to start the HTTP server, simply go to the ``artifacts-server``
folder and run:

.. code-block::

    docker-compose up --build -d

You should see the following output:

.. code-block::

    rtiuser@rtimachine> docker-compose up --build -d
    Creating network "artifacts-server_default" with the default driver
    Building artifact
    Step 1/5 : FROM python:3.7.2-alpine3.7
    ---> a94f1b57a462
    Step 2/5 : RUN adduser -D myuser
    ---> Using cache
    ---> 2344b3330802
    Step 3/5 : USER myuser
    ---> Using cache
    ---> 40b5e8b4aebb
    Step 4/5 : WORKDIR /artifacts
    ---> Using cache
    ---> dfd20a75cc51
    Step 5/5 : CMD ["python", "-m", "http.server"]
    ---> Using cache
    ---> a88db953abe8
    Successfully built a88db953abe8
    Successfully tagged artifactor-server:latest
    Creating artifacts-server_artifact_1 ... done


This will start the server, building the image described in the Dockerfile, in
detached mode. You should be able to access the contents of the server
on \ |localhost|\.

\ |IMG1|\

.. |IMG1| image:: static/Docker_for_CKO_1.png

To stop the server, run:

.. code-block::

    docker-compose stop

Building Docker Image
=====================

Once you have setup the dependency management server, you can start to build
the Docker image where we will deploy the Routing Service Processor.

To build the Docker image, run the following commands from the ``rs-docker``
directory:

.. code-block::

    export DOCKER_BUILDKIT=1
    docker build -t routingservice-processor . --network="host"

If you are using Docker version 18.09 or newer, you can leverage new build
enhancements. In particular, in this example we enable the new "builkit"
front end setting using the ``DOCKER_BUILDKIT`` environment variable.

Also, note we need to set the parameter ``--network="host"`` to ensure
that the resources the container depends on (i.e., those available on the
dependency management server) are available.

After building the image, you should see the following output:

.. code-block::

    => exporting to image                                                                             0.1s
    => => exporting layers                                                                            0.1s
    => => writing image sha256:2c45d2ea992ac32676898092ed2af3668c855cd20f87172d06a36f1ccd8b7613       0.0s
    => => naming to docker.io/library/routingserviceprocessor

Running Docker Image
====================

To run the Docker image, execute the following command:

.. code-block::

    docker run --name routingservice  -d routingserviceprocessor


This will run a Docker container in detached mode, which will execute RTI
Routing Service with the following arguments:

.. code-block::

    -cfgFile /rti/RsShapesProcessor.xml \
    -cfgName RsShapesAggregator \
    -DSHAPES_PROC_KIND=aggregator_simple

For more information on the Routing Service configuration, please check the
``README.rst`` file under the ``src`` directory.

You can overwrite the default execution parameters by appending new arguments
to the ``docker run`` command as follows:

.. code-block::

    docker run  -ti routingserviceprocessor -help

To list your running containers run:

.. code-block::

    docker ps

To stop the Docker container, run:

.. code-block::

    docker stop routingservice

To learn more
*************

* \ |RTI Docker Debugger|\



.. |RS Documentation| raw:: html

    <a href="https://community.rti.com/static/documentation/connext-dds/current/doc/api/connext_dds/api_cpp/group__RTI__RoutingServiceProcessorModule.html" target="_blank">Routing Service SDK documentation</a>

.. |Getting started| raw:: html

    <a href="https://docs.docker.com/get-started/" target="_blank">Docker
    Documentation: Get Started</a>

.. |Docker overview| raw:: html

    <a href="https://docs.docker.com/engine/docker-overview/" target="_blank">
    Docker Documentation: Overview</a>

.. |Google Cloud best practices| raw:: html

    <a href="https://cloud.google.com/blog/products/gcp/7-best-practices-for-building-containers" target="_blank">Google Cloud: 7 Best Practices for Building Containers</a>

.. |ConnextDDS and shared memory| raw:: html

    <a href="https://community.rti.com/kb/communicate-two-docker-containers-using-rti-connext-dds-and-shared-memory" target="_blank">Communicate two Docker containers using RTI Connext DDS and shared memory</a>

.. |ConnextDDS and host driver| raw:: html

    <a href="https://community.rti.com/kb/how-use-rti-connext-dds-communicate-across-docker-containers-using-host-driver" target="_blank">How to use RTI Connext DDS to Communicate Across Docker Containers Using the Host Driver</a>

.. |Install Docker CentOS| raw:: html

    <a href="https://docs.docker.com/install/linux/docker-ce/centos/" target="_blank">CentOS</a>

.. |Install Docker Debian| raw:: html

    <a href="https://docs.docker.com/install/linux/docker-ce/debian/" target="_blank">Debian</a>

.. |Install Docker Fedora| raw:: html

    <a href="https://docs.docker.com/install/linux/docker-ce/fedora/" target="_blank">Fedora</a>

.. |Install Docker Ubuntu| raw:: html

    <a href="https://docs.docker.com/install/linux/docker-ce/ubuntu/" target="_blank">Ubuntu</a>

.. |Install Docker Compose| raw:: html

    <a href="https://docs.docker.com/compose/install/" target="_blank">instructions on how to install Docker Compose in Docker Documentation</a>

.. |Artifactory| raw:: html

    <a href="https://jfrog.com/artifactory/" target="_blank">Artifactory</a>

.. |Docker run command| raw:: html

    <a href="https://docs.docker.com/engine/reference/run/" target="_blank">run command</a>

.. |Docker Compose documentation| raw:: html

    <a href="https://docs.docker.com/compose/" target="_blank">Docker Documentation: Docker Compose</a>

.. |localhost| raw:: html

    <a href="http://localhost:8000" target="_blank">http://localhost:8000</a>

.. |RTI Docker Debugger| raw:: html

    <a href="https://github.com/rticommunity/docker-rticonnextdds-debugger" target="_blank">RTI Docker Debugger</a>


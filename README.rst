Running your new RS6 processor in Docker - CKO'19 Workshop
##########################################################

Introduction
************

During a previous workshop, you built an Routing Service processor suing the
new API provided in ConnextDDS 6.0.0.

Routing Service Processor is a pluggable-component that allows controlling the
forwarding process that occurs within Routes. Refer to the
\ |RS Documentation|\ to learn more about how to implement and use custom
``Processor`` plug-ins. For more information, you can read the *README.rst*
file included under the *src* folder.

During this workshop we will see how to build and deploy the Routing Service
Processor using Docker.

Pre-reading
***********

Some basic concepts about Docker will be assumed during this workshop. You can
learn them from  these links:

* \ |Getting started|\

* \ |Docker overview|\

* \ |Google Cloud best practices|\

Also, there are some articles in our community that will be of your interest:

* \ |ConnextDDS and shared memory|\

* \ |ConnextDDS and host driver|\

.. _h3a271d91f1d561e71361a2e612d154:

Requisites
**********

We designed this workshop to be run on a **Linux machine**.

The workshop was developed and tested using **Docker CE version 18.09.0**,
build ``4d60db4``.

Install Docker on Linux:

* \ |Install Docker CentOS|\

* \ |Install Docker Debian|\

* \ |Install Docker Fedora|\

* \ |Install Docker Ubuntu|\

Finally, Docker Compose is needed for some steps. \ |Install Docker Compose|\ .

Download the following RTI bundles:

* RTI Host for Linux 64 bits: rti_connext_dds-6.0.0-pro-host-x64Linux.run

* RTI Target libraries for x64Linux4gcc7.3.0: rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg

.. _h6353753524492e25656b801a717f5a5d:

Hands on!
*********

We will use Docker for three tasks during this workshop:

* Start a basic dependencies server

* Build the RTI Routing Service Processor

* Deploy RTI Routing Service using the built processor in Docker

After installing all the requisites described in the “Requisites” section,
you can clone the repository in your machine.


.. code-block::

    git clone <URL to the repository> rs-cko19

This will create a folder called rs-cko19 with all the content from the
repository. At the same level where you cloned the repository, create a folder
called “artifacts” and copy there the files:

* rti_connext_dds-6.0.0-pro-host-x64Linux.run

* rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg

The final folder structure should be this one:

.. code-block::

    ├── artifacts
    │   ├── rti_connext_dds-6.0.0-pro-host-x64Linux.run
    │   └── rti_connext_dds-6.0.0-pro-target-x64Linux4gcc7.3.0.rtipkg
    └── rs-cko19
        ├── artifactor-server
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


Start a basic dependencies manager server
=========================================

During this first step, we will start a basic HTTP server to store the RTI
bundles. We will use this server to get Connext DDS as a third-party
dependency.

**Important: this server must never be used in a production environment** . It
is only for development/demo purposes. For production, you should use systems
like \ |Artifactory|\ .

In the folder “artifacts-server” you will find two files:

* docker-compose.yml

* Dockerfile

The Dockerfile defines how the image for the server is created.
The ``docker-compose.yml`` file how the image should be executed.

The Docker \ |Docker run command|\  is used when you want to start running one
container. Docker compose is a better choice when:

* More than one container is needed in order to run the application

* A service will be executed

* We are in a development environment

Docker for more information, \ |Docker Compose documentation|\ .

To start the HTTP server, go to the “artifacts-server” folder and run:

.. code-block::

    docker-compose up --build -d

Expected output:

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
detached mode. The server will be available in \ |localhost|\ .

\ |IMG1|\

.. |IMG1| image:: static/Docker_for_CKO_1.png
   :height: 226 px
   :width: 588 px


To stop the server, you need to run:

.. code-block::

    docker-compose stop

Build the Docker image
======================

After starting the dependencies manager server, you can start to build the
Docker image to deploy.

To build the Docker image, you should go to the “rs-cko19” folder. Then, you
should run:

.. code-block::

    export DOCKER_BUILDKIT=1
    docker build -t routingservice-processor . --network="host"

If you are using Docker 18.09 or newer, you can enable some build enhancements.
For this example, we enabled the new “builkit” frontend setting the
``DOCKER_BUILDKIT`` environment variable.

For this example, we need to set the parameter “--network” because we are
running the dependencies manager server in *localhost*. If we don’t specify
that option, the container will try to download the RTI bundles from its
localhost and the container build will fail.

After running some commands, the output will be:

.. code-block::

    => exporting to image                                                                             0.1s
    => => exporting layers                                                                            0.1s
    => => writing image sha256:2c45d2ea992ac32676898092ed2af3668c855cd20f87172d06a36f1ccd8b7613       0.0s
    => => naming to docker.io/library/routingserviceprocessor

Run the Docker image
====================

To run the Docker image, you only need to run the following command:

.. code-block::
    docker run --name routingservice  -d routingserviceprocessor


This will run a Docker container in detached mode with Routing Service using
this arguments:

.. code-block::

    -cfgFile /rti/RsShapesProcessor.xml -cfgName RsShapesAggregator \
    -DSHAPES_PROC_KIND=aggregator_simple

The effect of these parameters is described in the readme file under the
``src`` folder: Routing Service will be running and you can follow the steps
described in the "Running" section to test the created plugin.

You can overwrite these parameters from the command line. For instance, you can
get the help options:

.. code-block::

    docker run  -ti routingserviceprocessor -help

You can list your containers using the command:

.. code-block::

    docker ps

To stop your container, run:

.. code-block::

    docker stop routingservice

To learn more
*************

* \ |RTI Docker Debugger|\



.. |RS Documentation| raw:: html

    <a href="https://community.rti.com/static/documentation/connext-dds/current/doc/api/connext_dds/api_cpp/group__RTI__RoutingServiceProcessorModule.html" target="_blank">SDK documentation </a>

.. |Getting started| raw:: html

    <a href="https://docs.docker.com/get-started/" target="_blank">Docker
    official documentation: get started</a>

.. |Docker overview| raw:: html

    <a href="https://docs.docker.com/engine/docker-overview/" target="_blank">
    Docker official documentation: overview</a>

.. |Google Cloud best practices| raw:: html

    <a href="https://cloud.google.com/blog/products/gcp/7-best-practices-for-building-containers" target="_blank">Google Cloud: 7 best practices for building containers</a>

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

    <a href="https://docs.docker.com/compose/install/" target="_blank">The instructions to install Docker Compose are available in the official documentation</a>

.. |Artifactory| raw:: html

    <a href="https://jfrog.com/artifactory/" target="_blank">Artifactory</a>

.. |Docker run command| raw:: html

    <a href="https://docs.docker.com/engine/reference/run/" target="_blank">run command</a>

.. |Docker Compose documentation| raw:: html

    <a href="https://docs.docker.com/compose/" target="_blank">visit the official Docker Compose documentation</a>

.. |localhost| raw:: html

    <a href="http://localhost:8000" target="_blank">http://localhost:8000</a>

.. |RTI Docker Debugger| raw:: html

    <a href="https://github.com/rticommunity/rticonnextdds-docker-debugger" target="_blank">RTI Docker Debugger</a>



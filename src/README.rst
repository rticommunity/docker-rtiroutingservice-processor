Routing Service Processor
***************************************

.. |RS| replace:: *RoutingService*
.. |PROCESSOR| replace:: *Processor*

Concept
=======

*Routing Service Processor* is a pluggable-component that allows controlling
the forwarding process that occurs within *Routes*. Refer to the
`SDK documentation <https://community.rti.com/static/documentation/connext-dds/current/doc/api/connext_dds/api_cpp/group__RTI__RoutingServiceProcessorModule.html>`_
to learn more about how to implement and use custom |PROCESSOR| plug-ins.

Example Description
===================

This example shows how to implement a custom |PROCESSOR| plug-in, build it
into a shared library and load it with |RS|.
re
This example illustrates the realization of two common enterprise patterns:
aggregation and splitting. There is a single plug-in implementation,
*ShapesProcessor* that is factory of three types of |PROCESSOR|\s:

- *ShapesAggregatorSimple* and *ShapesAggregatorAdv*: |PROCESSOR|
  implementations that performs the aggregation of two *ShapeType* objects
  into a single *ShapeType* object.

- *ShapesSplitter*: |PROCESSOR| implementation that performs the separation
  of a single *ShapeType* object into two  *ShapeType* objects.

In the example, these processors are instantiated as part of a *TopicRoute*,
in which all its inputs and outputs represent instantiations of the
*Connext DDS Adapter StreamReader* and *StreamWriter*, respectively.

In this example you will find files for the following elements:

- ``ShapesProcessor``: the custom |PROCESSOR| plug-in, generated as a
  shared library, that contains the implementation for both aggregation
  and split processors.
- Configuration for the |RS| that loads the custom |PROCESSOR| and provides
  the communication between publisher and subscriber applications.


This |PROCESSOR| implementation can receive the properties in table
`TableShapesAggregatorProperties`_.

.. list-table:: ShapesAggregator Configuration Properties
    :name: TableShapesAggregatorProperties
    :widths: 30 10 60
    :header-rows: 1

    * - Name
      - Value
      - Description
    * - **shapes_processor.kind**
      - <enum>
      - - ``aggregator_simple:`` Indicates the plug-in to instantiate a
          *ShapesAggregatoSimpler*.
        - ``aggregator_adv:`` Indicates the plug-in to instantiate a
          *ShapesAggregatorAdv*.
        - ``splittler:`` Indicates the plug-in to instantiate a
          *ShapesSplitter*.

        If a different value other than the ones above is specified, the creation
        of the |PROCESSOR|  will throw an exception. If this property is not
        specified, it will create a *ShapesSplitter*.
    * - **shapes_processor.leading_input_index**
      - ``<integer>``
      - Only applicable to  *ShapesAggregatorAdv*. Indicates the index of the
        leading input. In this example, only ``0`` and ``1`` are valid values.


*ShapesAggregator*
------------------

There are two implementations of aggregation intended to show different
approaches to access and manipulate data.

*ShapesAggregatorSimple*
^^^^^^^^^^^^^^^^^^^^^^^^
This implementation shows very basic usage of the capabilities |PROCESSOR| where
inputs and outputs are accessed by their configuration names (which also
match the *Topic* names, and the aggregation pattern is very simple: it produces
``Triangle`` samples whose position is obtained from ``Square`` samples, and the
size is obtained from the ``y`` coordinate obtained from ``Circle`` samples.

The aggregation logic relies on the reception samples from the ``Square``input
to trigger data forwarding, and merge available data from the ``Circle`` input.
Note that for the purpose of this example, the names of the inputs and outputs
are hardcoded into the plug-in implementation. A recommended approach is to
make this value as arguments to the |PROCESSOR| creation, or use an algorithm
independent of these values, as shown in *ShapesAggregatorAdv*.

*ShapesAggregatorAdv*
^^^^^^^^^^^^^^^^^^^^^

The data processing is tied to a *leading input*, that represents
the input from which the processor reads *new* data first. For each instance
found in the data read from the leading input, the processor reads *any*
existing data for the equivalent instance.

The aggregation algorithm consists of simply an average of the values ``x``
and ``y`` of all inputs. The remaining elements are set equal to the values of
the data read from the leading input.

....

Note that for the proper behavior of both |PROCESSOR|\s it's required for the
DDS inputs to be configured with a history policy that preserves only the last
sample. This guarantees that memory doesn't grow unbounded since the processor
will never remove the samples from the StreamReader's cache.


*ShapesSplitter*
----------------

The splitting algorithm consists of assigning:

- Input value ``x`` to the first output, leaving ``y`` with value zero.
- Input value ``y`` to the second output, leaving ``x`` with value zero.
- Remaining values are set equally from the input values.

This |PROCESSOR| implementation does not receive any configuration properties.

Requirements
============

To run this example you will need:

- RTI Connext Professional version 6.0.0 or higher.
- CMake version 3.10 or higher
- A target platform supported by *RTI* |RS|.



Example Code: Routing Service Processor
***************************************

.. |RS| replace:: *RoutingService*
.. |PROCESSOR| replace:: *Processor*
.. |SD| replace:: *ShapesDemo*.

Below there are the instructions to build and run this example. All the commands
and syntax used assume a Unix-based system. If you run this example in a different
architecture, please adapt the commands accordingly.

Building
========

To build the example you will need first to run CMake to generate the build files.
From the directory containing the example sources:

::

    mkdir build
    cd build
    cmake-DCONNEXTDDS_DIR=<Connext directory> \
             -DCONNEXTDDS_ARCH=<ARCH> \
             -DBUILD_SHARED_LIBS=ON ..
    cmake --build .


where:

- ``<Connext directory>`` shall be replaced with the path to the installation
  directory of *RTI Connext*.
- ``<ARCH>`` shall be replaced with the target architecture where you are
  running the example (e.g., x64Darwin15clang7.0).

.. note::

    Certain `CMake generators <https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html>`_
    generate multi-configuration files that needs explicit selection of the
    configuration through ``--config``. For example on Windows systems, by
    default you can select ``x86-Debug``, ``x86-Release``, ``x64-Debug``,
    and ``x64-Release``.

Upon success of the previous command it will create a shared library file in
the build directory.


Running
=======

To run this example you will need two instances of *RTI Shapes Demo* and a single
instance of |RS|.

Aggregation (Simple)
--------------------

#. Run one instance of |SD| on domain 0. This will be the publisher application.
   Publish a blue squares and blue circles.

#. Run the other instance of |SD| on domain 1. This will be the subscriber
   application.
   Subscribe to squares, circles and triangles and observe how no data is received.

#. Now run |RS| to cause the aggregation data from the publisher application
   to the subscriber application.  Run the following command from the example
   build directory:

   ::

        <Connext directory>/bin/rtiroutingservice \
                -cfgFile ../RsShapesProcessor.xml \
                -cfgName RsShapesAggregator \
                -DSHAPES_PROC_KIND=aggregator_simple


   You should see how the subscriber application receives samples from squares,
   circles and triangles. The squares and circles samples are exactly the same
   generated by the publisher application. The triangles are follow the same
   direction than the squares, with their size changing depending on the position
   of the circles.

   Note that we are using the configuration variable ``SHAPES_PROC_KIND`` to
   indicate which class we want to instantiate, and its value is provided
   with the ``-D`` command-line option.

#. Repeat the first step but publish other colors. You should observe the same
   behavior in the subscriber application for the new colors.

#. In the publisher application, delete all the *DataWriters*. You should
   see the instances being disposed. Now delete all *DataReaders* from the
   subscriber application.

Aggregation (Advanced)
----------------------

#. Run one instance of |SD| on domain 0. This will be the publisher application.
   Publish a blue squares and blue circles.

#. Run the other instance of |SD| on domain 1. This will be the subscriber
   application.
   Subscribe to squares, circles and triangles and observe how no data is received.

#. Now run |RS| to cause the aggregation data from the publisher application
   to the subscriber application.  Run the following command from the example
   build directory:

   ::

        <Connext directory>/bin/rtiroutingservice \
                -cfgFile ../RsShapesProcessor.xml \
                -cfgName RsShapesAggregator \
                -DSHAPES_PROC_KIND=aggregator_adv


   You should see how the subscriber application receives samples from squares,
   circles and triangles. The squares and circles samples are exactly the same
   generated by the publisher application. The triangles are samples are the
   result of the route that contains the *ShapesAggegator*.

   Note that we are using the configuration variable ``SHAPES_PROC_KIND`` to
   indicate which class we want to instantiate, and its value is provided
   with the ``-D`` command-line option.

#. Repeat the first step but publish other colors. You should observe the same
   behavior in the subscriber application for the new colors.

#. In the publisher application, delete all the *DataWriters*. You should
   see the instances being disposed. Now delete all *DataReaders* from the
   subscriber application.



Splitter
--------

#. Run one instance of |SD| on domain 0. This will be the publisher application.
   Publish a blue squares.

#. Run the other instance of |SD| on domain 1. This will be the subscriber
   application.
   Subscribe to squares, circles and triangles and observe how no data is
   received.

#. Now run |RS| to cause the aggregation data from the publisher application
   to the subscriber application.  Run the following command from the example
   build directory:

   ::

        <Connext directory>/bin/rtiroutingservice \
                -cfgFile ../RsShapesProcessor.xml \
                -cfgName RsShapesSplitter \
                -DSHAPES_PROC_KIND=splitter

   You should see how the subscriber application receives samples from squares,
   circles and triangles. The squares samples are exactly the same generated by
   the publisher application. The circles and triangles are samples are the
   result of the route that contains the *ShapesSplitter*.

   Note that we are using the configuration variable ``SHAPES_PROC_KIND`` to
   indicate which class we want to instantiate, and its value is provided
   with the ``-D`` command-line option.

#. Repeat the first step but publish other colors. You should observe the same
   behavior in the subscriber application for the new colors.

#. In the publisher application, delete all the *DataWriters*. You should
   see the instances being disposed. Now delete all *DataReaders* from the
   subscriber application.

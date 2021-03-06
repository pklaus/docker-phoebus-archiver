# phoebus-archiver for Docker

Container images for the Phoebus Archiver for EPICS
(a.k.a. CSS RDB Archiver or BEAUTY).

In the build process of the container images, the Phoebus
archive-service is built from source allowing to provide
images for multiple CPU architectures.

### Example Usage

An example on how to use the container with `docker-compose`
can be found in [./compose-example](./compose-example).

### Resources

* Source code:
  https://github.com/ControlSystemStudio/phoebus/tree/master/services/archive-engine
* Available settings:
  https://control-system-studio.readthedocs.io/en/latest/preference_properties.html#archive
* Documentation:
  https://control-system-studio.readthedocs.io/en/latest/services/archive-engine/doc/index.html

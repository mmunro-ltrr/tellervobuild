tellervobuild
=============

# Build Tellervo in a Docker container

Build a tellervo-server .deb package from a fresh Git clone of the main
repository, then install this in a kitchen-sink container with all the
supporting services.

## Requirements

This uses [multistage builds](https://docs.docker.com/develop/develop-images/multistage-build/), so requires Docker 17.05 or higher on the daemon and client.

## Warning

The build stage applies a patch and other modifications to the upstream version
of Tellervo. These are fragile, so are tied to a specific commit.

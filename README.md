Perkeep Docker
=========================

A Dockerfile for building a Perkeep server.

* Run `git submodule update --init --recursive` to clone the perkeep submodule
* Test the build with `docker build .`
* Tag the build with `docker build -t angelcabo/perkeep .`
* Run the build with `docker run -d --name perkeep_build angelcabo/perkeep` (which you can monitor with `docker attach perkeep_build`)

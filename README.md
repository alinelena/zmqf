# zmqf
zmq modern fortran interface


# building the examples
There are 2 alternatives using `make`:

1. Build from the source path in a build path supplied in the flags.mk file.

    Edit flags.mk as you see fit.
    make -j

2. Build from existing build path.

    mkdir ~/some/build/path
    cp flags.mk ~/some/build/path/
    cd ~/some/build/path
    Edit flags.mk as you see fit. The bldpath variable is now discarded!
    make -f /path/to/the/repo/Makefile -j


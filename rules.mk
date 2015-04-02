
# Main executable and list of sources.
exec := taskvent.x taskwork.x tasksink.x wuserver.x wuclient.x 

taskvent.x: ldflags = -lzmq
taskvent.x: examples/taskvent.F90 zmq.F90.o
taskwork.x: examples/taskwork.F90 zmq.F90.o -lzmq
tasksink.x: examples/tasksink.F90 zmq.F90.o -lzmq

wuserver.x: examples/wuserver.c -lzmq
wuclient.x: examples/wuclient.c -lzmq


zmq.F90 zmq_constants.F90: create_fortran_zmq_mod.py /usr/include/zmq.h
	python3 $<

# List of .mod files produced together with a given .f90.o file. Autogenerator coming real soon now!
zmq.mod : zmq.F90.o

# List of .f90.o files depending on the given .mod file. Autogenerator also coming real soon now!
# Multiple targets and prerequisites allowed.
examples/taskvent.F90.o examples/taskwork.F90.o examples/tasksink.F90.o : zmq.mod



modpath := mods

.SUFFIXES:

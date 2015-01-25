program zmqhello
  use zmq
  implicit none

  integer :: major,minor,patch

  call zmq_version(major,minor,patch)

  write(*,'(a,i0,".",i0,".",i0)')"zeromq version ",major,minor,patch

end program zmqhello  

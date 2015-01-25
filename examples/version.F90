program version
  use zmq
  implicit none

  integer :: major,minor,patch

  call zmq_version(major,minor,patch)

  write(*,'(a,i0,".",i0,".",i0)')"Current 0MQ version is ",major,minor,patch

end program version  

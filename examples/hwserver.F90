program hwserver
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none

  type(c_ptr) :: context
  type(c_ptr) :: responder
  integer     :: rc 
  integer     :: ierror
  character(len=10), target :: buffer
  integer(c_size_t) :: lb=10
  integer :: i=0

  context = zmq_ctx_new()
  responder = zmq_socket (context, ZMQ_REP)
  rc = zmq_bind (responder, "tcp://*:5555")

  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind with code: ",rc
    stop -1
  end if
  do 
    i=i+1 
    ierror=zmq_recv(responder,c_loc(buffer(1:1)),lb,0)
    write(*,'(a)')"Received "//trim(buffer)
    write(buffer,'(a,i0)')"World! ",i
    ierror=zmq_send(responder,c_loc(buffer(1:1)),lb,0)
  end do 
  rc = zmq_close(responder)
  rc = zmq_ctx_destroy(context)

end program hwserver

program hwserver
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none

  type(c_ptr) :: context
  type(c_ptr) :: responder
  integer     :: rc 
  integer     :: ierror
  character, target   :: buffer(10)
  integer(c_size_t) :: lb=10

  context = zmq_ctx_new()
  responder = zmq_socket (context, ZMQ_REP)
  rc = zmq_bind (responder, "tcp://*:5555")

  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind with code: ",rc
    stop -1
  end if

  ierror=zmq_recv(responder,c_loc(buffer),lb,0)
  write(*,'(a)')"Received "//buffer
  buffer = "Hello"
  lb=5
  ierror=zmq_send(responder,c_loc(buffer),lb,0)

  rc = zmq_close(responder)
  rc = zmq_ctx_destroy(context)

end program hwserver

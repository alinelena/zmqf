program hwclient
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none

  type(c_ptr) :: context
  type(c_ptr) :: requester
  integer     :: rc 
  integer     :: ierror
  character, target   :: buffer(10)
  integer(c_size_t) :: lb=10

  context = zmq_ctx_new()
  requester = zmq_socket (context, ZMQ_REQ)
  rc = zmq_connect (requester, "tcp://*:5555")

  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to connect with code: ",rc
    stop -1
  end if
  buffer="Hello"
  lb=len(buffer)
  ierror=zmq_send(requester,c_loc(buffer),lb,0)
  lb=10;buffer=""
  ierror=zmq_recv(requester,c_loc(buffer),lb,0)
  write(*,'(a)')"Received "//buffer
  rc = zmq_close(requester)
  rc = zmq_ctx_destroy(context)

end program hwclient

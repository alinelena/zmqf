program hwclient
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none

  type(c_ptr) :: context
  type(c_ptr) :: requester
  type(c_ptr) :: err
  integer     :: rc 
  integer     :: ierror
  character, target   :: buffer(10)
  character(len=200),pointer :: errmsg
  integer(c_size_t) :: lb=10

  context = zmq_ctx_new()
  requester = zmq_socket (context, ZMQ_REQ)
  rc = zmq_connect (requester, "tcp://*:5555"//C_NULL_CHAR)

  if (rc /= 0) then
!   allocate(errmsg(200))
    err = zmq_strerror_c(rc)
    call c_f_pointer(err,errmsg)
    write(*,'(a,i0)'),errmsg,len(trim(errmsg))
    write(*,'(a,i0)')"Failure to connect with code: ",rc
    stop -1
  end if
  buffer="Hello"//C_NULL_CHAR
  lb=len(buffer)
  ierror=zmq_send(requester,c_loc(buffer),lb,0)
  lb=10;buffer=""
  ierror=zmq_recv(requester,c_loc(buffer),lb,0)
  write(*,'(a)')"Received "//buffer
  rc = zmq_close(requester)
  rc = zmq_ctx_destroy(context)

end program hwclient

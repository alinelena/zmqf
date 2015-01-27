program hwclient
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none

  type(c_ptr) :: context
  type(c_ptr) :: requester
  type(c_ptr) :: err
  integer     :: rc 
  integer     :: ierror
  character(len=10), target :: buffer
  character(len=200),pointer :: errmsg
  integer(c_size_t) :: lb=10
  integer :: i=10

  context = zmq_ctx_new()
  requester = zmq_socket (context, ZMQ_REQ)
  rc = zmq_connect (requester, "tcp://127.0.0.1:5555")

  if (rc /= 0) then
    err = zmq_strerror_c(rc)
    call c_f_pointer(err,errmsg)
    write(*,'(a,i0)'),errmsg,len(trim(errmsg))
    write(*,'(a,i0)')"Failure to connect with code: ",rc
    stop -1
  end if

  do i=1,10
    write(buffer,'(a,i0)')"Hello ",i 
    ierror=zmq_send(requester,c_loc(buffer(1:1)),lb,0)
    buffer=""
    ierror=zmq_recv(requester,c_loc(buffer(1:1)),lb,0)
    write(*,'(a)')"Received "//trim(buffer)
  end do 
  rc = zmq_close(requester)
  rc = zmq_ctx_destroy(context)
 
end program hwclient

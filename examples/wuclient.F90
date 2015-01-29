program wuclient
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none
  type(c_ptr) :: context
  type(c_ptr) :: subscriber
  integer     :: rc,ierror 
 
  real(kind=8) :: temp,zip,relhum,at,ar
  character(len=100,kind=c_char),target :: message,filter
  character(len=30) :: dummy
  integer(c_size_t) :: lm = 100,lf
  integer :: i, j,n = 10
  
  context = zmq_ctx_new()
  subscriber = zmq_socket(context, ZMQ_SUB)
  rc = zmq_connect(subscriber, "tcp://127.0.0.1:5556")
  call get_command_argument(1,dummy)
  filter=trim(dummy)
  lf=len(trim(filter))
  rc = zmq_setsockopt(subscriber, ZMQ_SUBSCRIBE,c_loc(filter(1:1)), lf)
  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind with code: ",rc
    stop -1
  end if
  do i=1,n
    ierror = zmq_recv(subscriber,c_loc(message(1:1)),lm,0)
    print *, trim(message)
    read(message,*)zip,j,dummy,temp,dummy,relhum
    at = at + temp
    ar = ar + relhum
  end do

  write(*,*)zip,at/n,ar/n

  rc = zmq_close(subscriber)
  rc = zmq_ctx_destroy(context)

end program wuclient

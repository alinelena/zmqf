program taskvent
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none
  type(c_ptr) :: context
  type(c_ptr) :: sender
  type(c_ptr) :: sink
  integer     :: rc,ierror 
 
  real(kind=8) :: temp,relhum,r
  integer :: workload
  character(len=100,kind=c_char),target :: update
  character(len=1,kind=c_char),target :: msg
  integer(c_size_t) :: lu=100,i
  character(len=10) :: dummy

  context = zmq_ctx_new()

  sender = zmq_socket(context, ZMQ_PUSH)
  rc = zmq_bind(sender, "tcp://127.0.0.1:5557")
  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind with code: ",rc
    stop -1
  end if

  sink = zmq_socket(context, ZMQ_PUSH)
  rc = zmq_bind(sink, "tcp://127.0.0.1:5558")
  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind with code: ",rc
    stop -1
  end if
  write(*,*)"Press 1 when the workers are ready!"
  read(*,*) dummy
  write(*,*)"Let the flood began!"
  msg="0"
  lu=1
  ierror = zmq_send(sink,c_loc(msg(1:1)),lu,0)

  call random_seed()
  i=0
  lu=100
  do i=1,100 
    call random_number(r)
    workload = int(100*r)
    write(update,'(i3)')workload
    ierror = zmq_send(sender,c_loc(update(1:1)),lu,0)
  end do 

  rc = zmq_close(sink)
  rc = zmq_close(sender)
  rc = zmq_ctx_destroy(context)

end program taskvent

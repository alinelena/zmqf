program tasksink
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none
  type(c_ptr) :: context
  type(c_ptr) :: receiver
  
  integer     :: rc,ierror 
  integer(kind=8) :: c1,c2,r
  real(kind=8) :: temp,relhum
  integer :: workload
  character(len=100,kind=c_char),target :: update
  character(len=1,kind=c_char),target :: msg
  integer(c_size_t) :: lu=100,i

  context = zmq_ctx_new()
  receiver = zmq_socket(context, ZMQ_PULL)
  rc = zmq_bind(receiver, "tcp://127.0.0.1:5558")
  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind with code: ",rc
    stop -1
  end if

  lu=1
  ierror = zmq_recv(receiver,c_loc(msg(1:1)),lu,0)

  lu=100
  call system_clock(count=c1,count_rate=r)
  do i=1,100 
    ierror = zmq_recv(receiver,c_loc(update(1:1)),lu,0)
    if (mod(i,10)==0) then 
      write(*,'(a)')":"
    else
      write(*,'(a)')"."
    end if
  end do 
  call system_clock(count=c2)
  write(*,'(a,f8.2)')"Time in s ",(c2-c1)/real(r,8)
  rc = zmq_close(receiver)
  rc = zmq_ctx_destroy(context)

end program tasksink

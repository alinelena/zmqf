program wuserver
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none
  type(c_ptr) :: context
  type(c_ptr) :: publisher
  integer     :: rc,ierror 
 
  real(kind=8) :: temp,relhum,r(3)
  integer :: zip
  character(len=100,kind=c_char),target :: update
  integer(c_size_T) :: lu

  context = zmq_ctx_new()
  publisher = zmq_socket(context, ZMQ_PUB)
  rc = zmq_bind(publisher, "tcp://*:5556")

  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind with code: ",rc
    stop -1
  end if
  call random_seed()
  do 
    call random_number(r)
    zip = int(50*r(1))
    temp = r(2)*215 - 80
    relhum = r(3)*50 + 10
    write(update,'(i2,1x,2(a10,f8.2),a2)')zip,"temp: ",temp, " humidity: ",relhum," x"
    lu = len(trim(update))
    ierror = zmq_send(publisher,c_loc(update(1:1)),lu,0)
  end do 
  rc = zmq_close(publisher)
  rc = zmq_ctx_destroy(context)

end program wuserver

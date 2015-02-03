program tasksink
  use, intrinsic :: iso_c_binding
  use zmq
  implicit none
  type(c_ptr) :: context
  type(c_ptr) :: receiver
  type(c_ptr) :: sender
  
  integer     :: rc,ierror 
  character(len=100,kind=c_char),target :: update
  character(len=1,kind=c_char),target :: msg
  integer(c_size_t) :: lu=100,i,lm

  context = zmq_ctx_new()
  receiver = zmq_socket(context, ZMQ_PULL)
  rc = zmq_bind(receiver, "tcp://localhost:5557")
  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind receiver with code: ",rc
    stop -1
  end if

  sender = zmq_socket(context, ZMQ_PUSH)
  rc = zmq_bind(sender, "tcp://localhost:5558")
  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind sender with code: ",rc
    stop -2
  end if

  lu=100
  lm=0
  msg=""
  do 
    ierror = zmq_recv(receiver,c_loc(update(1:1)),lu,0)
    read(update,*)i
    write(*,'(a,i0,a)') "You shall sleep ",i," ms."
    ierror = zmq_send(sender,c_loc(msg(1:1)),lm,0) 
  end do 

  rc = zmq_close(receiver)
  rc = zmq_close(sender)
  rc = zmq_ctx_destroy(context)

end program tasksink

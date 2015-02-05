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

! The order is important for some reason. First open listening connections then senders.

  sender = zmq_socket(context, ZMQ_PUSH)
  rc = zmq_connect(sender, "tcp://localhost:5558")
  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind sender with code: ",rc
    stop -2
  end if

! It is apparently necessary to put an address and not a name to zmq_bind.
  receiver = zmq_socket(context, ZMQ_PULL)
  rc = zmq_bind(receiver, "tcp://127.0.0.1:5557")
  if (rc /= 0) then
    write(*,'(a,i0)')"Failure to bind receiver with code: ",rc
    stop -1
  end if

  lu=100
  lm=0
  msg=""
  do 
    ierror = zmq_recv(receiver,c_loc(update(1:1)),lu,0)
    read(update,*)i
    write(*,'(a,i0,a)') "You shall sleep ",i," ms."
    ierror = zmq_send(sender,c_loc(msg(1:1)),lm,0) 
    if (ierror < 0) print '("Send err: ",i0)', ierror
  end do 

  rc = zmq_close(receiver)
  rc = zmq_close(sender)
  rc = zmq_ctx_destroy(context)

end program tasksink

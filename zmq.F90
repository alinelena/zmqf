module zmq
  use, intrinsic :: iso_c_binding
  implicit none
  include 'zmq_constants.F90'
  public

  type, bind(c) :: zmq_msg_t
    character(kind=c_char) :: cfvar0_cfvar0(32)
  end type zmq_msg_t
  
  type, bind(c) :: zmq_event_t
    integer(c_int16_t) :: event
    integer(c_int32_t) :: value
  end type zmq_event_t
  
  type, bind(c) :: zmq_pollitem_t
    type(c_ptr) :: socket
#if defined _WIN32
    *to be def* SOCKET :: fd
#else
    integer(c_int) :: fd
#endif
    integer(c_short) :: events
    integer(c_short) :: revents
  end type zmq_pollitem_t

  interface
!! typedef void (zmq_free_fn) (void *data, void *hint);
    subroutine zmq_free_fn(data, hint) bind(c)
      import c_ptr
      type(c_ptr), value :: data
      type(c_ptr), value :: hint
    end subroutine zmq_free_fn
  end interface


  interface
!! ZMQ_EXPORT void zmq_version (int *major, int *minor, int *patch);
    subroutine zmq_version(major, minor, patch) bind(c)
      import c_ptr, c_int
      integer(c_int) :: major
      integer(c_int) :: minor
      integer(c_int) :: patch
    end subroutine zmq_version

!! ZMQ_EXPORT int zmq_errno (void);
    function zmq_errno() bind(c)
      import c_int
      integer(c_int) :: zmq_errno
    end function zmq_errno

!! ZMQ_EXPORT const char *zmq_strerror (int errnum);
    function zmq_strerror_c(errnum) bind(c, name="zmq_strerror")
      import c_ptr, c_int
      integer(c_int), intent(in), value :: errnum
      type(c_ptr) :: zmq_strerror_c
    end function zmq_strerror_c

!! ZMQ_EXPORT void *zmq_ctx_new (void);
    function zmq_ctx_new() bind(c)
      import c_ptr
      type(c_ptr) :: zmq_ctx_new
    end function zmq_ctx_new

!! ZMQ_EXPORT int zmq_ctx_term (void *context);
    function zmq_ctx_term(context) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: context
      integer(c_int) :: zmq_ctx_term
    end function zmq_ctx_term

!! ZMQ_EXPORT int zmq_ctx_shutdown (void *ctx_);
    function zmq_ctx_shutdown(ctx_) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: ctx_
      integer(c_int) :: zmq_ctx_shutdown
    end function zmq_ctx_shutdown

!! ZMQ_EXPORT int zmq_ctx_set (void *context, int option, int optval);
    function zmq_ctx_set(context, option, optval) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: context
      integer(c_int), intent(in), value :: option
      integer(c_int), intent(in), value :: optval
      integer(c_int) :: zmq_ctx_set
    end function zmq_ctx_set

!! ZMQ_EXPORT int zmq_ctx_get (void *context, int option);
    function zmq_ctx_get(context, option) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: context
      integer(c_int), intent(in), value :: option
      integer(c_int) :: zmq_ctx_get
    end function zmq_ctx_get

!! ZMQ_EXPORT void *zmq_init (int io_threads);
    function zmq_init(io_threads) bind(c)
      import c_ptr, c_int
      integer(c_int), intent(in), value :: io_threads
      type(c_ptr) :: zmq_init
    end function zmq_init

!! ZMQ_EXPORT int zmq_term (void *context);
    function zmq_term(context) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: context
      integer(c_int) :: zmq_term
    end function zmq_term

!! ZMQ_EXPORT int zmq_ctx_destroy (void *context);
    function zmq_ctx_destroy(context) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: context
      integer(c_int) :: zmq_ctx_destroy
    end function zmq_ctx_destroy

!! ZMQ_EXPORT int zmq_msg_init (zmq_msg_t *msg);
    function zmq_msg_init(msg) bind(c)
      import zmq_msg_t, c_int
      type(zmq_msg_t) :: msg
      integer(c_int) :: zmq_msg_init
    end function zmq_msg_init

!! ZMQ_EXPORT int zmq_msg_init_size (zmq_msg_t *msg, size_t size);
    function zmq_msg_init_size(msg, size) bind(c)
      import c_size_t, zmq_msg_t, c_int
      type(zmq_msg_t), dimension(*) :: msg
      integer(c_size_t), intent(in), value :: size
      integer(c_int) :: zmq_msg_init_size
    end function zmq_msg_init_size

!! ZMQ_EXPORT int zmq_msg_init_data (zmq_msg_t *msg, void *data,    size_t size, zmq_free_fn *ffn, void *hint);
    function zmq_msg_init_data(msg, data, size, ffn, hint) bind(c)
      import c_size_t, zmq_msg_t, c_ptr, zmq_free_fn, c_int
      type(zmq_msg_t), dimension(*) :: msg
      type(c_ptr), value :: data
      integer(c_size_t), intent(in), value :: size
      procedure(zmq_free_fn) :: ffn
      type(c_ptr), value :: hint
      integer(c_int) :: zmq_msg_init_data
    end function zmq_msg_init_data

!! ZMQ_EXPORT int zmq_msg_send (zmq_msg_t *msg, void *s, int flags);
    function zmq_msg_send(msg, s, flags) bind(c)
      import zmq_msg_t, c_ptr, c_int
      type(zmq_msg_t) :: msg
      type(c_ptr), value :: s
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_msg_send
    end function zmq_msg_send

!! ZMQ_EXPORT int zmq_msg_recv (zmq_msg_t *msg, void *s, int flags);
    function zmq_msg_recv(msg, s, flags) bind(c)
      import zmq_msg_t, c_ptr, c_int
      type(zmq_msg_t) :: msg
      type(c_ptr), value :: s
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_msg_recv
    end function zmq_msg_recv

!! ZMQ_EXPORT int zmq_msg_close (zmq_msg_t *msg);
    function zmq_msg_close(msg) bind(c)
      import zmq_msg_t, c_int
      type(zmq_msg_t) :: msg
      integer(c_int) :: zmq_msg_close
    end function zmq_msg_close

!! ZMQ_EXPORT int zmq_msg_move (zmq_msg_t *dest, zmq_msg_t *src);
    function zmq_msg_move(dest, src) bind(c)
      import zmq_msg_t, c_int
      type(zmq_msg_t) :: dest
      type(zmq_msg_t) :: src
      integer(c_int) :: zmq_msg_move
    end function zmq_msg_move

!! ZMQ_EXPORT int zmq_msg_copy (zmq_msg_t *dest, zmq_msg_t *src);
    function zmq_msg_copy(dest, src) bind(c)
      import zmq_msg_t, c_int
      type(zmq_msg_t) :: dest
      type(zmq_msg_t) :: src
      integer(c_int) :: zmq_msg_copy
    end function zmq_msg_copy

!! ZMQ_EXPORT void *zmq_msg_data (zmq_msg_t *msg);
    function zmq_msg_data(msg) bind(c)
      import zmq_msg_t, c_ptr
      type(zmq_msg_t) :: msg
      type(c_ptr) :: zmq_msg_data
    end function zmq_msg_data

!! ZMQ_EXPORT size_t zmq_msg_size (zmq_msg_t *msg);
    function zmq_msg_size(msg) bind(c)
      import c_size_t, zmq_msg_t
      type(zmq_msg_t) :: msg
      integer(c_size_t) :: zmq_msg_size
    end function zmq_msg_size

!! ZMQ_EXPORT int zmq_msg_more (zmq_msg_t *msg);
    function zmq_msg_more(msg) bind(c)
      import zmq_msg_t, c_int
      type(zmq_msg_t) :: msg
      integer(c_int) :: zmq_msg_more
    end function zmq_msg_more

!! ZMQ_EXPORT int zmq_msg_get (zmq_msg_t *msg, int option);
    function zmq_msg_get(msg, option) bind(c)
      import zmq_msg_t, c_int
      type(zmq_msg_t) :: msg
      integer(c_int), intent(in), value :: option
      integer(c_int) :: zmq_msg_get
    end function zmq_msg_get

!! ZMQ_EXPORT int zmq_msg_set (zmq_msg_t *msg, int option, int optval);
    function zmq_msg_set(msg, option, optval) bind(c)
      import zmq_msg_t, c_int
      type(zmq_msg_t) :: msg
      integer(c_int), intent(in), value :: option
      integer(c_int), intent(in), value :: optval
      integer(c_int) :: zmq_msg_set
    end function zmq_msg_set

!! ZMQ_EXPORT void *zmq_socket (void *s0, int type);
    function zmq_socket(s0, type) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: s0
      integer(c_int), intent(in), value :: type
      type(c_ptr) :: zmq_socket
    end function zmq_socket

!! ZMQ_EXPORT int zmq_close (void *s);
    function zmq_close(s) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: s
      integer(c_int) :: zmq_close
    end function zmq_close

!! ZMQ_EXPORT int zmq_setsockopt (void *s, int option, const void *optval,    size_t optvallen);
    function zmq_setsockopt(s, option, optval, optvallen) bind(c)
      import c_size_t, c_ptr, c_int
      type(c_ptr), value :: s
      integer(c_int), intent(in), value :: option
      type(c_ptr), intent(in), value :: optval
      integer(c_size_t), intent(in), value :: optvallen
      integer(c_int) :: zmq_setsockopt
    end function zmq_setsockopt

!! ZMQ_EXPORT int zmq_getsockopt (void *s, int option, void *optval,    size_t *optvallen);
    function zmq_getsockopt(s, option, optval, optvallen) bind(c)
      import c_size_t, c_ptr, c_int
      type(c_ptr), value :: s
      integer(c_int), intent(in), value :: option
      type(c_ptr), value :: optval
      integer(c_size_t), dimension(*) :: optvallen
      integer(c_int) :: zmq_getsockopt
    end function zmq_getsockopt

!! ZMQ_EXPORT int zmq_bind (void *s, const char *addr);
    function zmq_bind(s, addr) bind(c)
      import c_ptr, c_signed_char, c_int
      type(c_ptr), value :: s
      character(kind=c_signed_char), intent(in), dimension(*) :: addr
      integer(c_int) :: zmq_bind
    end function zmq_bind

!! ZMQ_EXPORT int zmq_connect (void *s, const char *addr);
    function zmq_connect(s, addr) bind(c)
      import c_ptr, c_signed_char, c_int
      type(c_ptr), value :: s
      character(kind=c_signed_char), intent(in), dimension(*) :: addr
      integer(c_int) :: zmq_connect
    end function zmq_connect

!! ZMQ_EXPORT int zmq_unbind (void *s, const char *addr);
    function zmq_unbind(s, addr) bind(c)
      import c_ptr, c_signed_char, c_int
      type(c_ptr), value :: s
      character(kind=c_signed_char), intent(in), dimension(*) :: addr
      integer(c_int) :: zmq_unbind
    end function zmq_unbind

!! ZMQ_EXPORT int zmq_disconnect (void *s, const char *addr);
    function zmq_disconnect(s, addr) bind(c)
      import c_ptr, c_signed_char, c_int
      type(c_ptr), value :: s
      character(kind=c_signed_char), intent(in), dimension(*) :: addr
      integer(c_int) :: zmq_disconnect
    end function zmq_disconnect

!! ZMQ_EXPORT int zmq_send (void *s, const void *buf, size_t len, int flags);
    function zmq_send(s, buf, len, flags) bind(c)
      import c_size_t, c_ptr, c_int
      type(c_ptr), value :: s
      type(c_ptr), intent(in), value :: buf
      integer(c_size_t), intent(in), value :: len
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_send
    end function zmq_send

!! ZMQ_EXPORT int zmq_send_const (void *s, const void *buf, size_t len, int flags);
    function zmq_send_const(s, buf, len, flags) bind(c)
      import c_size_t, c_ptr, c_int
      type(c_ptr), value :: s
      type(c_ptr), intent(in), value :: buf
      integer(c_size_t), intent(in), value :: len
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_send_const
    end function zmq_send_const

!! ZMQ_EXPORT int zmq_recv (void *s, void *buf, size_t len, int flags);
    function zmq_recv(s, buf, len, flags) bind(c)
      import c_size_t, c_ptr, c_int
      type(c_ptr), value :: s
      type(c_ptr), value :: buf
      integer(c_size_t), intent(in), value :: len
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_recv
    end function zmq_recv

!! ZMQ_EXPORT int zmq_socket_monitor (void *s, const char *addr, int events);
    function zmq_socket_monitor(s, addr, events) bind(c)
      import c_ptr, c_signed_char, c_int
      type(c_ptr), value :: s
      character(kind=c_signed_char), intent(in), dimension(*) :: addr
      integer(c_int), intent(in), value :: events
      integer(c_int) :: zmq_socket_monitor
    end function zmq_socket_monitor

!! ZMQ_EXPORT int zmq_sendmsg (void *s, zmq_msg_t *msg, int flags);
    function zmq_sendmsg(s, msg, flags) bind(c)
      import zmq_msg_t, c_ptr, c_int
      type(c_ptr), value :: s
      type(zmq_msg_t) :: msg
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_sendmsg
    end function zmq_sendmsg

!! ZMQ_EXPORT int zmq_recvmsg (void *s, zmq_msg_t *msg, int flags);
    function zmq_recvmsg(s, msg, flags) bind(c)
      import zmq_msg_t, c_ptr, c_int
      type(c_ptr), value :: s
      type(zmq_msg_t) :: msg
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_recvmsg
    end function zmq_recvmsg

!! ZMQ_EXPORT int zmq_sendiov (void *s, struct iovec *iov, size_t count, int flags);
    function zmq_sendiov(s, iov, count, flags) bind(c)
      import c_size_t, c_ptr, c_int
      type(c_ptr), value :: s
      type(c_ptr) :: iov
      integer(c_size_t), intent(in), value :: count
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_sendiov
    end function zmq_sendiov

!! ZMQ_EXPORT int zmq_recviov (void *s, struct iovec *iov, size_t *count, int flags);
    function zmq_recviov(s, iov, count, flags) bind(c)
      import c_size_t, c_ptr, c_int
      type(c_ptr), value :: s
      type(c_ptr) :: iov
      integer(c_size_t), dimension(*) :: count
      integer(c_int), intent(in), value :: flags
      integer(c_int) :: zmq_recviov
    end function zmq_recviov

!! ZMQ_EXPORT int zmq_poll (zmq_pollitem_t *items, int nitems, long timeout);
    function zmq_poll(items, nitems, timeout) bind(c)
      import c_long, zmq_pollitem_t, c_int
      type(zmq_pollitem_t) :: items
      integer(c_int), intent(in), value :: nitems
      integer(c_long), intent(in), value :: timeout
      integer(c_int) :: zmq_poll
    end function zmq_poll

!! ZMQ_EXPORT int zmq_proxy (void *frontend, void *backend, void *capture);
    function zmq_proxy(frontend, backend, capture) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: frontend
      type(c_ptr), value :: backend
      type(c_ptr), value :: capture
      integer(c_int) :: zmq_proxy
    end function zmq_proxy

!! ZMQ_EXPORT int zmq_proxy_steerable (void *frontend, void *backend, void *capture, void *control);
    function zmq_proxy_steerable(frontend, backend, capture, control) bind(c)
      import c_ptr, c_int
      type(c_ptr), value :: frontend
      type(c_ptr), value :: backend
      type(c_ptr), value :: capture
      type(c_ptr), value :: control
      integer(c_int) :: zmq_proxy_steerable
    end function zmq_proxy_steerable

!! ZMQ_EXPORT char *zmq_z85_encode (char *dest, uint8_t *data, size_t size);
    function zmq_z85_encode_c(dest, data, size) bind(c, name="zmq_z85_encode")
      import c_size_t, c_ptr, c_int8_t, c_signed_char
      character(kind=c_signed_char), dimension(*) :: dest
      integer(c_int8_t), dimension(*) :: data
      integer(c_size_t), intent(in), value :: size
      type(c_ptr) :: zmq_z85_encode_c
    end function zmq_z85_encode_c

!! ZMQ_EXPORT uint8_t *zmq_z85_decode (uint8_t *dest, char *string);
    function zmq_z85_decode_c(dest, string) bind(c, name="zmq_z85_decode")
      import c_ptr, c_int8_t, c_signed_char
      integer(c_int8_t) :: dest
      character(kind=c_signed_char), dimension(*) :: string
      type(c_ptr) :: zmq_z85_decode_c
    end function zmq_z85_decode_c

!! ZMQ_EXPORT int zmq_device (int type, void *frontend, void *backend);
    function zmq_device(type, frontend, backend) bind(c)
      import c_ptr, c_int
      integer(c_int), intent(in), value :: type
      type(c_ptr), value :: frontend
      type(c_ptr), value :: backend
      integer(c_int) :: zmq_device
    end function zmq_device
  end interface
end module


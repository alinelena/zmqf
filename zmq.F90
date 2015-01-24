module zmq
  use iso_c_binding
  implicit none
  include 'zmq_constants.F90'
  public 
  interface 
    subroutine zmqVersion(major,minor,patch) bind(c,name='zmq_version')
     import c_int
     integer(c_int), intent(out) :: major
     integer(c_int), intent(out) :: minor
     integer(c_int), intent(out) :: patch

    end subroutine zmqVersion
  end interface 
end module zmq

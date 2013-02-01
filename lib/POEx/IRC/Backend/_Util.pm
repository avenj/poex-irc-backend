package POEx::IRC::Backend::_Util;

use strictures 1;
use Carp;

use Exporter 'import';

our @EXPORT = qw/
  get_unpacked_addr
/;

  
use Socket qw/
  :addrinfo

  sockaddr_family

  AF_INET
  unpack_sockaddr_in

  AF_INET6
  inet_ntop
  unpack_sockaddr_in6
/;


sub get_unpacked_addr {
  ## v4/v6-compat address unpack.
  my ($sock_packed) = @_;

  confess "No address passed to get_unpacked_addr"
    unless $sock_packed;

  my $sock_family = sockaddr_family($sock_packed);

  my ($inet_proto, $sockaddr, $sockport);

  FAMILY: {

    if ($sock_family == AF_INET6) {
      ($sockport, $sockaddr) = unpack_sockaddr_in6($sock_packed);
      $sockaddr   = inet_ntop(AF_INET6, $sockaddr);
      $inet_proto = 6;

      last FAMILY
    }

    if ($sock_family == AF_INET) {
      ($sockport, $sockaddr) = unpack_sockaddr_in($sock_packed);
      $sockaddr   = inet_ntop(AF_INET, $sockaddr);
      $inet_proto = 4;

      last FAMILY
    }

    confess "Unknown socket family type"
  }

  ($inet_proto, $sockaddr, $sockport)
}


1;
package POEx::IRC::Backend::_Util;

=for Pod::Coverage .*

=cut

use strictures 1;
use Carp;

use parent 'Exporter::Tiny';
our @EXPORT = our @EXPORT_OK = 'get_unpacked_addr';

use Socket qw/
  getnameinfo
  NI_NUMERICHOST
  NI_NUMERICSERV
  NIx_NOSERV
/;

sub get_unpacked_addr {
  my ($sock_packed, %params) = @_;
  my ($err, $addr, $port) = getnameinfo $sock_packed,
     NI_NUMERICHOST | NI_NUMERICSERV,
      ( $params{noserv} ? NIx_NOSERV : () );
  croak $err if $err;
  $params{noserv} ? $addr : ($addr, $port)
}

1;

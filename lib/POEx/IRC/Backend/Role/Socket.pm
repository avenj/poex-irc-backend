package POEx::IRC::Backend::Role::Socket;

use Moo::Role;
with 'POEx::IRC::Backend::Role::HasWheel';

has args => (
  lazy      => 1,
  is        => 'ro',
  predicate => 1,
  default   => sub { +{} },
);

has protocol => (
  required => 1,
  is       => 'ro',
);

has ssl => (
  is      => 'ro',
  default => sub { 0 },
);

1;

=pod

=for Pod::Coverage has_\w+

=head1 NAME

POEx::IRC::Backend::Role::Socket - IRC socket connector behavior

=head1 DESCRIPTION

This role is consumed by L<POEx::IRC::Backend::Connector> and 
L<POEx::IRC::Backend::Listener> objects; it defines some basic attributes
shared by listening/connecting sockets.

See also: L<POEx::IRC::Backend::Role::HasEndpoint>

This role consumes L<POEx::IRC::Backend::Role::HasWheel> and adds the
following attributes:

=head2 args

Arbitrary metadata attached to this Connector. (By default, this is a HASH.)

This is typically passed on to a successfully spawned
L<POEx::IRC::Backend::Connect>.

Predicate: B<has_args>

=head2 protocol

The Internet protocol version for this listener (4 or 6).

=head2 ssl

Boolean value indicating whether connections should be SSLified.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

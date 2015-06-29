package POEx::IRC::Backend::Role::Connector;

use Moo::Role;
with 'POEx::IRC::Backend::Role::HasWheel';

has addr => (
  required => 1,
  is       => 'ro',
);

has args => (
  lazy      => 1,
  is        => 'ro',
  predicate => 1,
  default   => sub { +{} },
);

has port => (
  required => 1,
  is       => 'ro',
  writer   => 'set_port',
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

=head1 NAME

POEx::IRC::Backend::Role::Connector - IRC socket connector behavior

=head1 SYNOPSIS

A L<Moo::Role> defining some basic common attributes for listening/connecting
sockets.

=head1 DESCRIPTION

This role is consumed by L<POEx::IRC::Backend::Connector> and 
L<POEx::IRC::Backend::Listener> objects; it defines some basic attributes
shared by listening/connecting sockets.

This role consumes L<POEx::IRC::Backend::Role::HasWheel> and adds the
following attributes:

=head2 addr

The local address we are bound to.

=head2 args

Arbitrary metadata attached to this Connector. (By default, this is a HASH.)

This is typically passed on to a successfully spawned
L<POEx::IRC::Backend::Connect>.

Predicate: B<has_args>

=head2 port

The local port we are listening on.

=head2 set_port

Change the current port attribute.

This won't trigger any automatic Wheel changes (at this time), 
but it is useful when creating a listener on port 0.

=head2 protocol

The Internet protocol version for this listener (4 or 6).

=head2 ssl

Boolean value indicating whether connections should be SSLified.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

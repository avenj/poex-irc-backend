package POEx::IRC::Backend::Connect;

use Types::Standard -all;

use Moo;
with 'POEx::IRC::Backend::Role::HasWheel';

has args => (
  lazy      => 1,
  is        => 'ro',
  predicate => 1,
  default   => sub { +{} },
);

has alarm_id => (
  ## Idle alarm ID.
  lazy      => 1,
  is        => 'rw',
  predicate => 'has_alarm_id',
  default   => sub { 0 },
);


has compressed => (
  ## zlib filter added.
  lazy    => 1,
  is      => 'rwp',
  isa     => Bool,
  writer  => 'set_compressed',
  default => sub { !!0 },
);


has idle => (
  ## Idle delay.
  lazy    => 1,
  is      => 'ro',
  isa     => StrictNum,
  default => sub { 180 },
);


has is_client => (
  lazy    => 1,
  is      => 'rw',
  isa     => Bool,
  default => sub { !!0 },
);


has is_peer => (
  lazy    => 1,
  is      => 'rw',
  isa     => Bool,
  default => sub { !!0 },
);


has is_disconnecting => (
  ## Bool or string (disconnect message)
  is      => 'rw',
  isa     => (Bool | Str),
  default => sub { !!0 },
);


has is_pending_compress => (
  ## Wheel needs zlib filter after a socket flush.
  is      => 'rw',
  isa     => Bool,
  default => sub { !!0 },
);


has peeraddr => (
  required => 1,
  isa      => Str,
  is       => 'ro',
  writer   => 'set_peeraddr',
);


has peerport => (
  required => 1,
  is       => 'ro',
  writer   => 'set_peerport',
);

has ping_pending => (
  lazy    => 1,
  is      => 'rw',
  default => sub { 0 },
);

has protocol => (
  ## 4 or 6.
  required => 1,
  is       => 'ro',
  isa      => StrictNum,
);


has seen => (
  ## TS of last activity on this Connect.
  lazy    => 1,
  is      => 'rw',
  default => sub { 0 },
);


has sockaddr => (
  required => 1,
  isa      => Str,
  is       => 'ro',
  writer   => 'set_sockaddr',
);


has sockport => (
  required => 1,
  is       => 'ro',
  writer   => 'set_sockport',
);


1;

=pod

=for Pod::Coverage has_\w+ set_\w+

=head1 NAME

POEx::IRC::Backend::Connect - A connected IRC socket

=head1 SYNOPSIS

Typically created by L<POEx::IRC::Backend> to represent an established
connection.

=head1 DESCRIPTION

These objects contain details regarding connected socket 
L<POE::Wheel::ReadWrite> wheels managed by 
L<POEx::IRC::Backend>.

Consumes L<POEx::IRC::Backend::Role::HasWheel> and adds the following
attributes:

=head2 alarm_id

Connected socket wheels normally have a POE alarm ID attached for an idle 
timer.

Predicate: C<has_alarm_id>

B<rw> attribute.

=head2 args

Arbitrary metadata attached to this connection; by default, any C<args>
attached to a L<POEx::IRC::Backend::Connector> that spawns a
L<POEx::IRC::Backend::Connect> are passed along.

Predicate: B<has_args>

=head2 compressed

Boolean true if the Zlib filter has been added.

See also: L<POEx::IRC::Backend/set_compressed_link>

=head2 set_compressed

Change the boolean value of the L</compressed> attrib.

=head2 idle

Idle time used for connection check alarms.

See also: L</ping_pending>, L<POEx::IRC::Backend/ircsock_connection_idle>

=head2 is_disconnecting

Boolean false if the Connect is not in a disconnecting state; if it is 
true, it is the disconnect message:

  $obj->is_disconnecting("Client quit")

B<rw> attribute.

See also: L<POEx::IRC::Backend/disconnect>

=head2 is_client

Boolean true if the connection wheel has been marked as a client.

B<rw> attribute.

=head2 is_peer

Boolean true if the connection wheel has been marked as a peer.

B<rw> attribute.

=head2 is_pending_compress

Primarily for internal use; boolean true if the Wheel needs a Zlib filter on
next buffer flush.

B<rw> attribute.

=head2 ping_pending

The C<ping_pending> attribute can be used to manage standard IRC
PING/PONG heartbeating; a server can call C<< $conn->ping_pending(1) >> upon
dispatching a PING to a client (because of an C<ircsock_connection_idle>
event, for example) and C<< $conn->ping_pending(0) >> when a
response is received.

If C<< $conn->ping_pending >> is true on the next C<ircsock_connection_idle>,
the client can be considered to have timed out and your server-side C<Backend>
can issue a disconnect; this emulates standard IRCD behavior.

B<rw> attribute.

See also: L<POEx::IRC::Backend/ircsock_connection_idle>

=head2 peeraddr

The remote peer address.

Writer: C<set_peeraddr>

=head2 peerport

The remote peer port.

Writer: C<set_peerport>

=head2 protocol

The protocol in use (4 or 6); set by L<POEx::IRC::Backend> at connection time.

=head2 seen

Timestamp of last socket activity; updated by L<POEx::IRC::Backend> when
traffic is seen from this Connect.

B<rw> attribute.

=head2 sockaddr

Our socket address.

Writer: C<set_sockaddr>

=head2 sockport

Our socket port.

Writer: C<set_sockport>

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

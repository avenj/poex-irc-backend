package POEx::IRC::Backend::Connector;

use Moo;
with 'POEx::IRC::Backend::Role::Connector';

has args => (
  lazy      => 1,
  is        => 'ro',
  predicate => 1,
  default   => sub { +{} },
);

has bindaddr => (
  lazy      => 1,
  is        => 'ro',
  predicate => 1,
  default   => sub { '' },
);

1;

=pod

=for Pod::Coverage has_\w+

=head1 NAME

POEx::IRC::Backend::Connector - An outgoing IRC socket connector

=head1 SYNOPSIS

Created by L<POEx::IRC::Backend> for outgoing connector sockets.

=head1 DESCRIPTION

These objects contain details regarding 
L<POEx::IRC::Backend> outgoing connector sockets.

This class consumes L<POEx::IRC::Backend::Role::Connector> and adds the
following attributes:

=head2 bindaddr

The local address this Connector should bind to.

Predicate: B<has_bindaddr>

=head2 args

Arbitrary metadata attached to this Connector. (By default, this is a HASH.)

This is typically passed on to a successfully spawned
L<POEx::IRC::Backend::Connect>.

Predicate: B<has_args>

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

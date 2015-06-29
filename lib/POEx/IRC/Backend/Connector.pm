package POEx::IRC::Backend::Connector;

use Moo;
with 'POEx::IRC::Backend::Role::Connector';

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

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

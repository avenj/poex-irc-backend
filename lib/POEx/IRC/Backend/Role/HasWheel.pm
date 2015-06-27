package POEx::IRC::Backend::Role::HasWheel;

use Types::Standard -all;

use Moo::Role;

has wheel_id => (
  lazy    => 1,
  isa     => Defined,
  is      => 'ro',
  writer  => '_set_wheel_id',
  builder => sub { shift->wheel->ID },
);

has wheel => (
  required  => 1,
  isa       => Maybe[ InstanceOf['POE::Wheel'] ],
  is        => 'ro',
  clearer   => 'clear_wheel',
  writer    => 'set_wheel',
  predicate => 'has_wheel',
  trigger   => sub {
    my ($self, $wheel) = @_;
    $self->_set_wheel_id( $wheel->ID )
  },
);

1;

=pod

=for Pod::Coverage has_\w+

=head1 NAME

POEx::IRC::Backend::Role::HasWheel

=head1 SYNOPSIS

A L<Moo::Role> for classes that have associated POE::Wheel instances.

=head1 DESCRIPTION

=head2 wheel

A L<POE::Wheel> instance (typically L<POE::Wheel::SocketFactory> for listeners
and connectors or L<POE::Wheel::ReadWrite> for live connections).

This is primarily for internal use. External code should not interact directly
with the C<wheel>.

Can be cleared via B<clear_wheel>; use B<has_wheel> to determine if this
listener's wheel has been cleared.

Can be replaced via B<set_wheel> (although whether this is a good idea or not
is debatable; better to spawn a new instance of your class)

=head2 wheel_id

The POE ID of the last known L</wheel>.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

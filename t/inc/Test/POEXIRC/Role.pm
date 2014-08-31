package Test::POEXIRC::Role;

use strictures 1;

use Moo::Role;

has test_received_events => (
  is      => 'ro',
  builder => sub { [] },
);

sub record_event {
  my ($self, $event, $val) = @_;
  push @{ $self->test_received_events }, [ $event, $val ]
}

1;

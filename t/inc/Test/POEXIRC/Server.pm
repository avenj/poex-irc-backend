package Test::POEXIRC::Server;

use strictures 1;

use POE;
use POEx::IRC::Backend;

use IRC::Message::Object;


use Moo;
with 'Test::POEXIRC::Role';


has controller => (
  required    => 1,
  is          => 'ro',
);

has backend_opts => (
  lazy        => 1,
  is          => 'ro',
  builder     => sub { [] },
);

has listener_opts => (
  require     => 1,
  is          => 'ro',
);

has backend => (
  lazy        => 1,
  is          => 'ro',
  writer      => 'set_backend',
  builder     => sub {
    my ($self) = @_;
    POEx::IRC::Backend->new( @{ $self->backend_opts } )
  },
);


sub BUILD {
  POE::Session->create(
    object_states => [
      $self => [ qw/
        _start
        ircsock_registered
        ircsock_listener_created
        ircsock_input
      / ],
    ],
  );
}

# FIXME method to test listener_removed
# FIXME stop method that issues shutdown

sub _start {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  $self->backend->spawn;
  $kernel->post( $self->backend->session_id => 'register' );
}

sub ircsock_registered {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  $self->backend->create_listener( @{ $self->listener_opts } );
}

sub ircsock_listener_created {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  my $listener = $_[ARG0];

  $self->record_event( listener_created => 1 )
    if $listener->isa('POEx::IRC::Backend::Listener');

  $kernel->post( $self->controller => 'server_ready', $listener );
}

my $response = +{
  helloserver => ircmsg(
    command => 'helloclient',
    params  => [ 'hello', 'client' ],
  ),

  byeserver => +{
    command => 'byeclient',
    params  => [ 'bye', 'client' ],
  },
};

sub ircsock_input {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  my ($conn, $event)  = @_[ARG0 .. $#_];

  # FIXME ->record_event, issue responses out of static set
}

1;

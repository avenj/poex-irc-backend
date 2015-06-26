use Test::More;
use strict; use warnings FATAL => 'all';

sub POE::Kernel::CATCH_EXCEPTIONS () { 0 }
use POE;
use POEx::IRC::Backend;
use IRC::Message::Object 'ircmsg';

alarm 60;

# FIXME
#  - sessions start
#  - server_listener_created posts 'connect' to $client_sid
#  - client_connector_open starts conversation with server
#    (states for this?)
#  - server send()s some data and then issues disconnect()
#    (all data should be received)
#  - post another 'connect' to $client_sid
#  - server send()s some data and then issues disconnect_now()
#    (data should not be received)
#
# -> check_if_done state?

my $expected = +{

};
my $got = +{};

my ($server_sid, $client_sid);
my ($server_addr, $server_port);

# 'server' session
POE::Session->create(
  package_states => [
    main => +{
      _start      => 'server_start',
      shutdown    => 'server_shutdown',
      ircsock_registered    => 'server_registered',
      ircsock_listener_created => 'server_listener_created',
      ircsock_listener_open => 'server_listener_open',
      ircsock_input         => 'server_input',
    },
  ],
);


sub server_start {
  $_[HEAP] = POEx::IRC::Backend->new;
  my ($k, $backend) = @_[KERNEL, HEAP];
  $server_sid = $_[SESSION]->ID;
  $backend->spawn;
  $k->post( $backend->session_id, 'register' );
  $backend->create_listener(
    protocol => 4,
    bindaddr => '127.0.0.1',
    port     => 0,
  );
}

sub server_shutdown {
  my ($k, $backend) = @_[KERNEL, HEAP];
  $k->post( $backend->session_id => 'shutdown' );
}

sub server_registered {

}

sub server_listener_created {
  my $listener = $_[ARG0];
  $server_addr = $listener->addr;
  $server_port = $listener->port;
}

sub server_listener_open {

}

sub server_input {

}


# 'client' session
POE::Session->create(
  package_states => [
    main => +{
      _start   => 'client_start',
      shutdown => 'client_shutdown',
      connect  => 'client_connect',
      ircsock_registered => 'client_registered',
      ircsock_connector_open => 'client_connector_open',
    },
  ],
);

sub client_start {
  $client_sid = $_[SESSION]->ID;
  $_[HEAP] = POEx::IRC::Backend->new;
  my ($k, $backend) = @_[KERNEL, HEAP];
  $backend->spawn;
  $k->post( $backend->session_id, 'register' );
}

sub client_connect {
  my ($k, $backend) = @_[KERNEL, HEAP];
  $backend->create_connector(
    remoteaddr => $server_addr,
    remoteport => $server_port,
    tag        => 'foo',
  )
}

sub client_shutdown {

}

sub client_registered {

}

sub client_connector_open {

}


POE::Kernel->run;


done_testing

use Test::More;
use strict; use warnings FATAL => 'all';

use POE;

use_ok( 'POEx::IRC::Backend' );


my $expected = {
  'got registered'       => 1,
  'got listener_created' => 1,
  'got connector_open'   => 1,
};
my $got = {};


POE::Session->create(
  package_states => [
    main => [ qw/
      _start
      shutdown
      ircsock_registered

      ircsock_connector_open
      ircsock_listener_created
      ircsock_listener_removed
      ircsock_listener_failure
      ircsock_listener_open
      ircsock_disconnect
      ircsock_input
    / ],
  ],
);

sub _start {
  $_[HEAP] = new_ok( 'POEx::IRC::Backend' );
  my ($k, $backend) = @_[KERNEL, HEAP];
  $backend->spawn;
  $k->post( $backend->session_id, 'register' );
  $backend->create_listener(
    protocol => 4,
    bindaddr => '127.0.0.1',
    port     => 0,
  );
}

sub shutdown {
  my ($k, $backend) = @_[KERNEL, HEAP];
  $k->post( $backend->session_id, 'shutdown' );
}

sub ircsock_registered {
  $got->{'got registered'}++;
  isa_ok( $_[ARG0], 'POEx::IRC::Backend' );
}

sub ircsock_listener_created {
  my ($k, $backend) = @_[KERNEL, HEAP];
  my $listener = $_[ARG0];

  $got->{'got listener_created'}++;

  isa_ok( $listener, 'POEx::IRC::Backend::Listener' );

  $backend->create_connector(
    remoteaddr => $listener->addr,
    remoteport => $listener->port,
  );
}

sub ircsock_connector_open {
  my ($k, $backend) = @_[KERNEL, HEAP];
  my $conn = $_[ARG0];

  $got->{'got connector_open'}++;

  isa_ok( $conn, 'POEx::IRC::Backend::Connect' );

  ## FIXME talk to myself.
  $k->yield( shutdown => 1 ); # FIXME
}

sub ircsock_listener_removed {
  ## FIXME test listener_removed
}

sub ircsock_listener_failure {
  ## FIXME fail out
}

sub ircsock_listener_open {
  ## FIXME make sure we got our own Connect
}

sub ircsock_disconnect {
  ## FIXME
  my ($k, $backend) = @_[KERNEL, HEAP];
  $k->yield( shutdown => 1 )
}

sub ircsock_input {
  ## FIXME
}


$poe_kernel->run;
is_deeply( $got, $expected, 'backend tests look ok' );
done_testing;

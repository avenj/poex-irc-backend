#!/usr/bin/env perl

use strictures 2;

use POE;
use POEx::IRC::Backend;

use IRC::Message::Object 'ircmsg';

use IRC::Toolkit;

my $port = 6667;
my $addr = '127.0.0.1';
# FIXME getopts:
#   --port
#   --bind

POE::Session->create(
  package_states => [
    main => [ qw/
      _start
      ircsock_registered
      ircsock_input
      ircsock_listener_open
      ircsock_listener_failure
      ircsock_disconnected
      ircsock_connection_idle
    / ],
  ],
);

# If this were real, you would probably want Moo(se) attributes and POE
# object_states, but lexicals will do us:
my %conns;    # live connects pre-registration, keyed on obj identity
my %users;    # registered connects, keyed on obj identity
my $backend;  # POEx::IRC::Backend

sub _start {
  $backend = POEx::IRC::Backend->spawn;
  $_[KERNEL]->post( $backend->session_id, 'register' );
}

sub ircsock_registered {
  $backend->create_listener(
    bindaddr => $addr,
    port     => $port,
  );
}

sub ircsock_listener_open {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  my ($conn, $listener) = @_[ARG0, ARG1];

  $backend->send(
    ircmsg(
      command => 'NOTICE',
      prefix  => 'tinyircd',
      params  => [
        'AUTH',
        '*** Looking up your hostname...',
      ],
    ),
    $conn
  );
}

sub ircsock_listener_failure {

}

sub ircsock_disconnected {

}

sub ircsock_connection_idle {
  my ($kernel, $self, $conn) = @_[KERNEL, OBJECT, ARG0];

  unless ($conn->is_client) {
    my $msg = 'Registration timed out';
    $backend->send(
      ircmsg(
        command => 'ERROR',
        params  => [ 'Closing Link (Registration timed out)' ],
      ),
      $conn
    );
    $backend->client_quit($conn, $msg);
  }

  if ($conn->ping_pending) {
    my $msg = 'Ping timeout';
    $backend->send(
      ircmsg(
        command => 'ERROR',
        params  => [ 'Closing Link (Ping timeout)' ],
      ),
      $conn
    );
    $self->client_quit($conn, $msg);
  }

  # FIXME ping/pong handler, see i-s-p
}

sub ircsock_input {
  my ($kernel, $self) = @_[KERNEL, OBJECT];
  my ($this_conn, $input_obj) = @_[ARG0, ARG1];

  $this_conn->ping_pending(0) if $this_conn->ping_pending;

  my $cmd = lc $input_obj->command;
  my $meth = 'irccmd_'.$cmd;
  
  unless ($cmd =~ m/^[a-z]$/ && $self->can($meth)) {
    # FIXME bad cmd rpl (IRC::Toolkit)
    return
  }

  # only NICK/USER/QUIT allowed for preregistration
  return unless
    exists $users{$this_conn+0} 
    or grep {; $cmd eq $_ } qw/NICK USER QUIT/;

  $self->$meth($input_obj, $this_conn);
}


sub irccmd_user {
  my ($self, $input, $conn) = @_;
  my @params = @{ $input->params };

  # FIXME set up $conns{$conn+0}->{%metadata}
  #  may have NICK already, run ->check_if_registered
  #  set is_client on registration, send intro rpls,
  #  $users{$conn+0} = delete $conns{$conn+0}
}

sub irccmd_nick {
  my ($self, $input, $conn) = @_;
  my @params = @{ $input->params };

  unless (@params) {
    # FIXME bad args reply
    return
  }

  # FIXME set up $conns{$conn}->{nickname} = $param
  #  run ->check_if_registered to see if USER has been sent
}

sub irccmd_ping {

}

sub irccmd_pong {
  # No-op, ->ping_pending adjusted in _input
}

sub irccmd_quit {

}

sub irccmd_join {

}

sub irccmd_part {

}

sub irccmd_privmsg {

}

sub irccmd_notice {

}

sub client_quit {
  my ($self, $conn, $msg) = @_;
  # FIXME relay QUIT
  $backend->disconnect($conn, $msg);  
}

POE::Kernel->run;
print "Terminated cleanly\n";

#!/usr/bin/env perl

use strictures 1;

use POE;
use POEx::IRC::Backend;

use IRC::Message::Object;

use IRC::Toolkit;

my $port = 6667;
my $addr = '0.0.0.0';

# FIXME getopts:
#   --port
#   --bind

my %KnownCmd = map {; $_ => 1 } qw/
  JOIN
  NICK
  PART
  PING
  PRIVMSG
  QUIT
  USER
/;

POE::Session->create(
  package_states => [
    main => [ qw/
      _start
      ircsock_registered
      ircsock_input

      irccmd_nick
      irccmd_user
      irccmd_ping
      irccmd_privmsg
      irccmd_join
      irccmd_part
      irccmd_quit
    / ],
  ],
);

sub _start {
  my $backend = POEx::IRC::Backend->spawn;
  $_[HEAP]->{ircd} = $backend;
  $_[KERNEL]->post( $backend->session_id, 'register' );
}

sub ircsock_registered {
  $_[HEAP]->{ircd}->create_listener(
    bindaddr => $addr,
    port     => $port,
  );
}

sub ircsock_input {
  my ($this_conn, $input_obj) = @_[ARG0, ARG1];
  my $cmd = lc $input_obj->command;
  
  unless ($cmd =~ m/[a-zA-Z]/ && exists $KnownCmd{$cmd}) {
    # FIXME bad cmd rpl (IRC::Toolkit)
    return
  }
  $_[KERNEL]->yield( 'irccmd_'.$cmd, $input_obj, $this_conn );
}


POE::Kernel->run;
print "Terminated cleanly\n";

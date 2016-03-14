#!/usr/bin/env perl

use strictures 2;

use POE;
use POEx::IRC::Backend;

use IRC::Message::Object 'ircmsg';

use IRC::Toolkit;

my $port = 6667;
my $addr = '127.0.0.1';

GetOptions(
  'port=i' => \$port,
  'bind=s' => \$addr,

  help => sub {
    print
      "POEx::IRC::Backend example\n\n",
      "  --bind=ADDR   Address to bind to\n",
      "  --port=PORT   Port to bind to\n",
    ;
    exit 0
  },
);

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
# object_states, but lexicals will do us;
#   $user_ref = +{
#
#   }
#
#   $conns{$conn+0} = $user_ref   (preregistration)
#   $users{$conn+0} = $user_ref
#   $nicks{lc_irc $nick} = $user_ref
#   $chans{lc_irc $chan} = [ @nicknames ]
my $backend;  # POEx::IRC::Backend
my %conns;    # live connects pre-registration, keyed on obj identity
my %users;    # registered connects, keyed on obj identity
my %nicks;    # registered connects, keyed on lc_irc nickname
my %chans;    # known channels, keyed on lc_Irc channame
sub get_user_by_conn { my $conn = shift; $users{$conn+0} }
sub get_user_by_nick { my $nick = shift; $nicks{lc_irc $nick} }
sub get_preregistered { my $conn = shift; $conns{$conn+0} }

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
        '*** Connected to POEx::IRC::Backend example',
      ],
    ),
    $conn
  );
}

sub ircsock_listener_failure {
  my ($listener, $op, $errno, $errstr) = @_[ARG0 .. $#_];
  warn "Listener socket reported: ($errno) $errstr in operation $op";
  exit 1
}

sub ircsock_disconnected {
  # FIXME relay QUIT
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
  my $meth = 'irccmd_'.($cmd eq 'notice' ? 'privmsg' : $cmd);
  
  unless ($cmd =~ m/^[a-z]$/ && $self->can($meth)) {
    # FIXME bad cmd rpl (IRC::Toolkit)
    return
  }

  # only NICK/USER/QUIT allowed for preregistration
  # (everything else is a no-op)
  return unless get_user($this_conn)
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
  #  (probably forcejoin to +lobby too)
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
  my ($self, $input, $conn) = @_;
  $backend->send(
    ircmsg(
      prefix  => 'tinyircd',
      command => 'PONG',
      params  => [ $input->get(0) || time ],
    ),
    $conn
  );
}

sub irccmd_pong {
  # No-op, ->ping_pending adjusted in _input
}

sub irccmd_quit {

}

sub irccmd_join {
  my ($self, $input, $conn) = @_;
  my $channel = $input->params->get(0);
  # FIXME 461 unless $channel

  unless ( substr($channel, 0, 1) eq '+' ) {
    # FIXME illegal channel rpl
    return
  }

  # FIXME return if $user->{channels}->{$thischan}
  # FIXME relay JOIN
  # FIXME add to $user->{channels}, $chans{$thischan}
}

sub irccmd_part {
  my ($self, $input, $conn) = @_;
  my $channel = $input->params->get(0);
  # FIXME 461 unless $channel
  # FIXME not-on-channel rpl unless $user->{channels}->{$thischan}
  # FIXME relay PART, remove from $user->{$channels}->{$thischan}, %chans
}

sub irccmd_names {
  my ($self, $input, $conn) = @_;
  my $channel = $input->params->get(0);
  
  unless (defined $channel) {
    # FIXME bad params
  }

  $channel = lc_irc $channel;

  unless (exists $chans{$channel}) {
    # FIXME no such chan
  }

  # FIXME iterate over X names per line
  $backend->send(
    ircmsg(
      prefix  => 'tinyircd',
      command => 'NAMES',
      params  => [ join ' ', @{ $chans{$channel} } ],
      colonify => 1,
    ),
    $conn
  );
}

sub irccmd_who {

}

sub irccmd_whois {

}

sub irccmd_privmsg {
  # FIXME
  # also NOTICE handler
}

sub client_quit {
  my ($self, $conn, $msg) = @_;
  # FIXME relay QUIT if this user's live
  $backend->disconnect($conn, $msg);  
}

POE::Kernel->run;
print "Terminated cleanly\n";

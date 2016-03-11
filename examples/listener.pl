use strictures 2;

use feature 'say';
use POE;
use POEx::IRC::Backend;

use Data::Dumper;

my $bind = '0.0.0.0';
my $port = 8000;
use Getopt::Long;
GetOptions(
  help => sub {
    say "$0 --bind ADDR --port PORT";
    exit 0
  },

  'bind=s' => \$bind,
  'port=i' => \$port,
);


POE::Session->create(
  package_states => [
    main => [ qw/
      _start
      _default
    / ],
  ],
);

POE::Kernel->run;

sub _start {
  my $backend = $_[HEAP]->{irc} = POEx::IRC::Backend->spawn();

  POE::Kernel->post( $backend->session_id, 'register' );

  POE::Kernel->post( $backend->session_id,
    'create_listener',
    bindaddr => $bind,
    port     => $port,
  );

  say "Listening on [$bind] : $port";
}

sub _default {
  my ($event, $args) = @_[ARG0, ARG1];
  say "$event - ".Dumper($args)
}

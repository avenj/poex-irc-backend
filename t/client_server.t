use Test::More;
use strict; use warnings FATAL => 'all';


use lib 't/inc';
use Test::POEXIRC::Server;
use Test::POEXIRC::Client;

alarm 60;

POE::Session->create(
  inline_states => +{
    _start => sub {
      $_[KERNEL]->sig(ALRM => 'handle_sigalrm');
      $_[HEAP]->{server} = Test::POEXIRC::Server->new(
        controller => $_[SESSION]->ID,
      );
      $_[HEAP]->{client} = Test::POEXIRC::Client->new(
        controller => $_[SESSION]->ID,
      );
    },

    server_ready => sub {
      my $listener = $_[ARG0];

      # FIXME tell client to connect & start dialog
    },

    handle_sigalrm => sub {
      # FIXME timeout, shutdown components and die
    },
  },
);

POE::Kernel->run;
 

is_deeply $server->test_received_events,
  [
    # FIXME
  ],
  'test server received expected events';

is_deeply $client->test_received_events,
  [
  ],
  'test client received expected events';

done_testing

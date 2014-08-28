use Test::More;
use strict; use warnings FATAL => 'all';

use POEx::IRC::Backend::Connector;

{ package
    POE::Wheel; use strict; use warnings;
  sub new { bless [], shift }
  sub ID  { 1234 }
}

my $listener = POEx::IRC::Backend::Connector->new(
  protocol => 4,
  addr  => '127.0.0.1',
  port  => 1234,
  wheel => POE::Wheel->new,

  args     => +{ foo => 1 },
  bindaddr => '127.0.0.1',
);

ok $listener->does('POEx::IRC::Backend::Role::Connector');

ok $listener->has_bindaddr, 'has_bindaddr ok';
cmp_ok $listener->bindaddr, 'eq', '127.0.0.1', 'bindaddr ok';

is_deeply $listener->args, +{ foo => 1 }, 'args ok';


$listener = POEx::IRC::Backend::Connector->new(
  protocol => 4,
  addr  => '127.0.0.1',
  port  => 1234,
  wheel => POE::Wheel->new,
);

cmp_ok $listener->bindaddr, 'eq', '', 'default bindaddr ok';
is_deeply $listener->args, +{}, 'default args ok';

done_testing

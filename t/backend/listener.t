use Test::More;
use strict; use warnings FATAL => 'all';

use POEx::IRC::Backend::Listener;

{ package
    POE::Wheel; use strict; use warnings;
  sub new { bless [], shift }
  sub ID  { 1234 }
}

my $listener = POEx::IRC::Backend::Listener->new(
  protocol => 4,
  addr  => '127.0.0.1',
  port  => 1234,
  wheel => POE::Wheel->new,
  args  => +{ foo => 1 },
);

ok $listener->does('POEx::IRC::Backend::Role::Socket');

ok $listener->has_args, 'has_args ok';
is_deeply $listener->args, +{ foo => 1 }, 'args ok';

cmp_ok $listener->idle, '==', 180, 'idle attr defaults to 180';
$listener->set_idle(60);
cmp_ok $listener->idle, '==', 60, 'idle attr settable';

done_testing

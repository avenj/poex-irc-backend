use Test::More;
use strict; use warnings FATAL => 'all';

{ package
    Testing::Role::Connector;
  use Moo; with 'POEx::IRC::Backend::Role::Connector';
}

{ package
    POE::Wheel;
  use strict; use warnings;
  sub new { bless [], shift }
  sub ID { 1234 }
}

my $obj = Testing::Role::Connector->new(
  addr      => '127.0.0.1',
  port      => 1234,
  protocol  => 4,
  wheel     => POE::Wheel->new,
);

# HasWheel behavior
ok $obj->does('POEx::IRC::Backend::Role::HasWheel'),
  'POEx::IRC::Backend::Role::Connector consumes'
  .' POEx::IRC::Backend::Role::HasWheel';
cmp_ok $obj->wheel_id, '==', 1234, 'mock wheel attr ok';

# addr
cmp_ok $obj->addr, 'eq', '127.0.0.1', 'addr ok';

# protocol
cmp_ok $obj->protocol, '==', 4, 'protocol ok';

# port (rw)
cmp_ok $obj->port, '==', 1234, 'port ok';
$obj->set_port(4321);
cmp_ok $obj->port, '==', 4321, 'set_port ok';

# ssl
ok !$obj->ssl, 'ssl default off';
my $ssl_enabled = Testing::Role::Connector->new(
  wheel     => POE::Wheel->new,
  addr      => '127.0.0.1',
  port      => 1234,
  protocol  => 4,
  ssl       => 1,
);
ok $ssl_enabled->ssl, 'ssl init arg ok';


# missing addr
eval {; 
  Testing::Role::Connector->new(
    protocol => 4, port => 1234, wheel => POE::Wheel->new
  ) 
};
like $@, qr/addr/, 'died on missing addr attribute';

# missing port
eval {; Testing::Role::Connector->new(
    protocol => 4, addr => '0.0.0.0', wheel => POE::Wheel->new
  ) 
};
like $@, qr/port/, 'died on missing port attribute';

done_testing

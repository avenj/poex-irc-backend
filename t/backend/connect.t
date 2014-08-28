use Test::More;
use strict; use warnings FATAL => 'all';

use POEx::IRC::Backend::Connect;

{ package
    POE::Wheel; use strict; use warnings;
  sub new { bless [], shift }
  sub ID  { 1234 }
}

my $conn = POEx::IRC::Backend::Connect->new(
  wheel => POE::Wheel->new,
);

ok $conn->does('POEx::IRC::Backend::Role::HasWheel'),
  'consumes POEx::IRC::Backend::Role::HasWheel';

# (rw) alarm_id

# (rw) is_client

# (rw) is_peer

# (rw) is_disconnecting

# (rw) is_pending_compress

# idle

# compressed / set_compressed

# peeraddr

# peerport

# (rw) ping_pending

# protocol

# (rw) seen

# sockaddr

# sockport

# peeraddr required

# peerport required

# protocol required

# sockaddr required

# sockport required

done_testing

package POEx::IRC::Backend::Role::CheckAvail;

use strictures 2;
use Try::Tiny;


use Role::Tiny;

my %_can_haz;

sub has_ssl_support {
  unless (defined $_can_haz{ssl}) {
    local @INC = @INC;
    pop @INC if $INC[-1] eq '.';
    try {; require POE::Component::SSLify; $_can_haz{ssl} = 1 }
      catch {; $_can_haz{ssl} = 0 };
  }
  $_can_haz{ssl}
}

sub has_zlib_support {
  unless (defined $_can_haz{zlib}) {
    local @INC = @INC;
    pop @INC if $INC[-1] eq '.';
    try {; require POE::Filter::Zlib::Stream; $_can_haz{zlib} = 1 }
      catch {; $_can_haz{zlib} = 0 };
  }
  $_can_haz{zlib}
}


1;

=for Pod::Coverage .*

=cut

package main;

use 5.018;

use strict;
use warnings;
use typing;

use Test::More;
use Test::Trap;

sub multiply :Function(number, number) {
  my ($lvalue, $rvalue) = &_;

  return $lvalue * $rvalue;
}

trap{multiply()};
like $trap->stderr, qr/No valid type handlers/,
  'No valid type handlers';

# this can be done on import of the MooseX::Types based library
typing::set_spaces('main', 'main');

trap{multiply()};
like $trap->stderr, qr/Validation failed for 'Num' with value undef/,
  'multiply() throws error';

trap{multiply(2)};
like $trap->stderr, qr/Validation failed for 'Num' with value undef/,
  'multiply(2) throws error';

is multiply(2,2), 4, 'multiply(2, 2) returns 4';

# this is one way to hook into the resolution of a specific type
package main::number {
  use MooseX::Types::Moose 'Num';

  sub make {
    my $err; ($_[0], do{$err = Num->validate($_[0]) // ''; !$err} ? 1 : 0, "$err")
  }
};

ok 1 and done_testing;

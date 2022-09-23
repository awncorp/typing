package main;

use 5.018;

use strict;
use warnings;
use typing;

use Test::More;
use Test::Trap;

use MooseX::Types::Moose 'Num';

# this can be done on import of the MooseX::Types based library
typing::set_resolver('main', ['main', 'resolver']);

sub resolver {
  my $err; ($_[2], do{$err = Num->validate($_[2]) // ''; !$err} ? 1 : 0, "$err")
}

sub multiply :Function(number, number) {
  my ($lvalue, $rvalue) = &_;

  return $lvalue * $rvalue;
}

trap{multiply()};
like $trap->stderr, qr/Validation failed for 'Num' with value undef/,
  'multiply() throws error';

trap{multiply(2)};
like $trap->stderr, qr/Validation failed for 'Num' with value undef/,
  'multiply(2) throws error';

is multiply(2,2), 4, 'multiply(2, 2) returns 4';

ok 1 and done_testing;

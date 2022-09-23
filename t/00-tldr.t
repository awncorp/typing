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

sub main::number::check {
  ((!defined $_[0] || ref $_[0]) ? (0, 'Not a number') : (1, ''))
}

sub main::number::make {
  ($_[0], main::number::check($_[0]))
}

trap{multiply()};
like $trap->stderr, qr/No valid type handlers/, 'No valid type handlers';

typing::set_spaces('main', 'main');

trap{multiply()};
like $trap->stderr, qr/Not a number/, 'multiply() throws "Not a number"';

trap{multiply(2)};
like $trap->stderr, qr/Not a number/, 'multiply(2) throws "Not a number"';

is multiply(2,2), 4, 'multiply(2, 2) returns 4';

ok 1 and done_testing;

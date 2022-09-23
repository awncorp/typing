package main;

use 5.018;

use strict;
use warnings;
use typing;

use Test::More;
use Test::Trap;

use Specio::Library::Builtins 't';

# this can be done on import of the Specio based library
typing::set_resolver('main', ['main', 'resolver']);

sub resolver {
  local $@; ($_[2], eval{t('Num')->($_[2]) || 1} ? 1 : 0, "$@")
}

sub multiply :Function(number, number) {
  my ($lvalue, $rvalue) = &_;

  return $lvalue * $rvalue;
}

trap{multiply()};
like $trap->stderr, qr/Validation failed for type named Num/,
  'multiply() throws error';

trap{multiply(2)};
like $trap->stderr, qr/Validation failed for type named Num/,
  'multiply(2) throws error';

is multiply(2,2), 4, 'multiply(2, 2) returns 4';

ok 1 and done_testing;

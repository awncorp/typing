package typing;

no strict 'refs';

require Carp;
require Scalar::Util;

our $attrexpr = qr/^(method|function|return)\((.*)\)$/i;
our $reporter = [__PACKAGE__, 'run_reporter'];
our $resolver = [__PACKAGE__, 'run_resolver'];

# :)
sub import {
  export((caller)[0], $_[0], $_) for qw(_ MODIFY_CODE_ATTRIBUTES)
}

# accepts: ()
# returns: (...results)
sub _() {
  processor((caller(1))[0], signature(get_codename((caller(1))[3])), [@_])
}

# accepts: (package, type)
# returns: void
sub die_invalid {
  Carp::carp(join ' ', 'No valid type handlers:', map {@$_ ? (@$_) : ('(None)')} [get_packages(@_)])
}

# accepts: (codename or coderef)
# returns: (...results)
sub dispatch {
  (&{$_[0]}(@_[1..$#_]))
}

# accepts: (caller, package, subname)
# returns: coderef or falsy
sub export {
  *{"$_[0]::$_[2]"} = get_coderef(@_[1,2]) if !get_coderef(@_[0,2])
}

# accepts: (codename)
# returns: (package, subname)
sub get_codename {
  ($_[0] =~ /(.*)::(.+)/)
}

# accepts: (package, subname)
# returns: coderef or falsy
sub get_coderef {
  UNIVERSAL::can(@_)
}

# accepts: (package, coderef)
# returns: (result)
sub get_function {
  ${get_namespace($_[0], "\Ufunctions")}{get_refaddr($_[1])}
}

# accepts: (package, coderef, ...arguments)
# returns: (result)
sub set_function {
  ${get_namespace($_[0], "\Ufunctions")}{get_refaddr($_[1])} = [@_[2..$#_]]
}

# accepts: (package)
# returns: (codename)
sub get_maker {
  get_namespace($_[0], 'make')
}

# accepts: (package, coderef)
# returns: (result)
sub get_method {
  ${get_namespace($_[0], "\Umethods")}{get_refaddr($_[1])}
}

# accepts: (package, coderef, ...arguments)
# returns: (result)
sub set_method {
  ${get_namespace($_[0], "\Umethods")}{get_refaddr($_[1])} = [@_[2..$#_]]
}

# accepts: (...arguments)
# returns: (namespace)
sub get_namespace {
  join('::', @_)
}

# accepts: (package, type)
# returns: (codename)
sub get_package {
  get_coderef($_, 'make') && return $_ for (get_packages(@_))
}

# accepts: (package, type)
# returns: (...namespaces)
sub get_packages {
  (map get_namespace($_, ($_[1] || ())), get_spaces($_[0]))
}

# accepts: (reference)
# returns: (address)
sub get_refaddr {
  Scalar::Util::refaddr($_[0])
}

# accepts: (package, coderef)
# returns: (result)
sub get_return {
  ${get_namespace($_[0], "\Ureturns")}{get_refaddr($_[1])}
}

# accepts: (package, coderef, ...arguments)
# returns: (result)
sub set_return {
  ${get_namespace($_[0], "\Ureturns")}{get_refaddr($_[1])} = [@_[2..$#_]]
}

# accepts: (package)
# returns: (reporter)
sub get_reporter {
  ${get_namespace(__PACKAGE__, "\Ureporters")}{$_[0]} || $reporter
}

# accepts: (package, reporter)
# returns: (reporter)
sub set_reporter {
  ${get_namespace(__PACKAGE__, "\Ureporters")}{$_[0]} = $_[1]
}

# accepts: (package)
# returns: (resolver)
sub get_resolver {
  ${get_namespace(__PACKAGE__, "\Uresolvers")}{$_[0]} || $resolver
}

# accepts: (package, type)
# returns: 1 or 0
sub has_resolver {
  ((${get_resolver($_[0])}[0] ne __PACKAGE__) || get_package(@_)) ? 1 : 0
}

# accepts: (package, resolver)
# returns: (resolver)
sub set_resolver {
  ${get_namespace(__PACKAGE__, "\Uresolvers")}{$_[0]} = $_[1]
}

# accepts: (stashname)
# returns: (coderef)
sub get_stashref {
  get_coderef(__PACKAGE__, join('_', 'get', lc($_[0])))
}

# accepts: (stashname)
# returns: (coderef)
sub set_stashref {
  get_coderef(__PACKAGE__, join('_', 'set', lc($_[0])))
}

# accepts: (package)
# returns: (...types)
sub get_spaces {
  (@{get_namespace($_[0], "\Utypes")})
}

# accepts: (package, namespace)
# returns: (...types)
sub set_spaces {
  (@{get_namespace($_[0], "\Utypes")} = (@{get_namespace($_[0], "\Utypes")}, @_[1..$#_]))
}

# accepts: (attrstring)
# returns: (...results)
sub parse {
  (map {split/,\s*/} ($_[0] =~ $attrexpr))
}

# accepts: (package, types, arguments)
# returns: (...results)
sub processor {
  @{$_[1]} ? (map validate($_[0], get_best_elem($_[1], $_), ${$_[2]}[$_]), get_best_range(@_[1,2])) : (@{$_[2]})
}

# accepts: (arrayref, index)
# returns: (result)
sub get_best_elem {
  (${$_[0]}[$_[1]] || ${$_[0]}[$#{$_[0]}])
}

# accepts: (arrayref, arrayref)
# returns: (...results)
sub get_best_range {
  (0..($#{$_[1]} > $#{$_[0]} ? $#{$_[1]} : $#{$_[0]}))
}

# accepts: (package, code, kind, ...types)
# returns: (...results)
sub register {
  dispatch(set_stashref($_[2]), $_[0], $_[1], @_[3..$#_])
}

# accepts: (...arguments)
# returns: (...results)
sub rejects {
  grep !/$attrexpr/, @_
}

# accepts: (value, valid?, explanation)
# returns: (value, valid?, explanation) or void
sub reporter {
  dispatch(get_namespace(@{get_reporter($_[0])}), @_)
}

# accepts: (package, type, value)
# returns: (value, valid?, explanation)
sub resolve_or_report {
  reporter(resolver(@_))
}

# accepts: (package, type, value)
# returns: (value, valid?, explanation)
sub resolver {
  dispatch(get_namespace(@{get_resolver($_[0])}), @_)
}

# accepts: (package, kind, coderef)
# returns: (types)
sub retrieve {
  dispatch(get_stashref($_[1]), $_[0], get_coderef($_[0], $_[2]))
}

# accepts: (value, valid?, explanation)
# returns: value or void
sub run_reporter {
  $_[1] ? $_[0] : Carp::carp($_[2])
}

# accepts: (package, type, value)
# returns: (value, valid?, explanation)
sub run_resolver {
  dispatch(get_maker(get_package(@_)), $_[2])
}

# accepts: (package, type)
# returns: (types)
sub signature {
  retrieve($_[0], 'function', $_[1]) || retrieve($_[0], 'method', $_[1]) || []
}

# accepts: (package, type, value)
# returns: value or void
sub validate {
  has_resolver(@_) ? (resolve_or_report(@_))[0] : die_invalid(@_)
}

# accepts: (package, code, @attributes)
# returns: (@garbage)
sub MODIFY_CODE_ATTRIBUTES {
  register($_[0], $_[1], parse($_)) for grep parse($_), @_[2..$#_]; rejects(@_[2..$#_])
}

1;

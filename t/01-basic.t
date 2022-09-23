package main;

use 5.018;

use strict;
use warnings;
use typing;

use Test::More;
use Test::Trap;

sub tf1 :Function() {
  [@_]
}

sub tf2 :Function() {
  [&_]
}

sub tf3 :Function(string) {
  [&_]
}

sub tf4 :Function(string, number) {
  [&_]
}

sub tm1 :Method() {
  [@_]
}

sub tm2 :Method() {
  [&_]
}

sub tm3 :Method(string) {
  [&_]
}

sub tm4 :Method(string, number) {
  [&_]
}

sub tr1 :Return() {
  [@_]
}

sub tr2 :Return() {
  [&_]
}

sub tr3 :Return(string) {
  [&_]
}

sub tr4 :Return(string, number) {
  [&_]
}

sub main::string::check {
  ((!defined $_[0] || ref $_[0]) ? (0, 'Not a string') : (1, ''))
}

sub main::string::make {
  ($_[0], main::string::check($_[0]))
}

sub main::number::check {
  ((!defined $_[0] || ref $_[0]) ? (0, 'Not a number') : (1, ''))
}

sub main::number::make {
  ($_[0], main::number::check($_[0]))
}

subtest 'exports', sub {
  can_ok 'main', '_';
  can_ok 'main', 'MODIFY_CODE_ATTRIBUTES';
  is_deeply [&_], [], '&_ outside of a sub okay';
};

subtest 'parses', sub {
  is_deeply [typing::parse('Function(string)')], ['Function', 'string'], 'parses Function(string)';
  is_deeply [typing::parse('Function(string, number)')], ['Function', 'string', 'number'], 'parses Function(string, number)';
  is_deeply [typing::parse('Function(string, BigRat, MyApp::Object)')], ['Function', 'string', 'BigRat', 'MyApp::Object'], 'parses Function(string, BigRat, MyApp::Object)';
  is_deeply [typing::parse('Function(string, MyApp::Object, ArrayRef[CodeRef])')], ['Function', 'string', 'MyApp::Object', 'ArrayRef[CodeRef]'], 'parses Function(string, MyApp::Object, ArrayRef[CodeRef])';
  is_deeply [typing::parse('Function(MyApp::Object, MyApp::ArrayRef[CodeRef])')], ['Function', 'MyApp::Object', 'MyApp::ArrayRef[CodeRef]'], 'parses Function(MyApp::Object, MyApp::ArrayRef[CodeRef])';
  is_deeply [typing::parse('Method(string)')], ['Method', 'string'], 'parses Method(string)';
  is_deeply [typing::parse('Method(string, number)')], ['Method', 'string', 'number'], 'parses Method(string, number)';
  is_deeply [typing::parse('Method(string, BigRat, MyApp::Object)')], ['Method', 'string', 'BigRat', 'MyApp::Object'], 'parses Method(string, BigRat, MyApp::Object)';
  is_deeply [typing::parse('Method(string, MyApp::Object, ArrayRef[CodeRef])')], ['Method', 'string', 'MyApp::Object', 'ArrayRef[CodeRef]'], 'parses Method(string, MyApp::Object, ArrayRef[CodeRef])';
  is_deeply [typing::parse('Method(MyApp::Object, MyApp::ArrayRef[CodeRef])')], ['Method', 'MyApp::Object', 'MyApp::ArrayRef[CodeRef]'], 'parses Method(MyApp::Object, MyApp::ArrayRef[CodeRef])';
  is_deeply [typing::parse('Return(string)')], ['Return', 'string'], 'parses Return(string)';
  is_deeply [typing::parse('Return(string, number)')], ['Return', 'string', 'number'], 'parses Return(string, number)';
  is_deeply [typing::parse('Return(string, BigRat, MyApp::Object)')], ['Return', 'string', 'BigRat', 'MyApp::Object'], 'parses Return(string, BigRat, MyApp::Object)';
  is_deeply [typing::parse('Return(string, MyApp::Object, ArrayRef[CodeRef])')], ['Return', 'string', 'MyApp::Object', 'ArrayRef[CodeRef]'], 'parses Return(string, MyApp::Object, ArrayRef[CodeRef])';
  is_deeply [typing::parse('Return(MyApp::Object, MyApp::ArrayRef[CodeRef])')], ['Return', 'MyApp::Object', 'MyApp::ArrayRef[CodeRef]'], 'parses Return(MyApp::Object, MyApp::ArrayRef[CodeRef])';
};

subtest 'rejects', sub {
  is_deeply [typing::rejects('Example')], ['Example'], 'rejects Example';
  is_deeply [typing::rejects('Example(string)')], ['Example(string)'], 'rejects Example(string)';
};

subtest 'sub tf1 :Function()', sub {
  is_deeply tf1(), [], 'tf1()';
  is_deeply tf1(1..4), [1..4], 'tf1(1..4)';
};

subtest 'sub tf2 :Function()', sub {
  is_deeply tf2(), [], 'tf2()';
  is_deeply tf2(1..4), [1..4], 'tf2(1..4)';
};

subtest 'sub tf3 :Function(string)', sub {
  trap{tf3()};
  like $trap->stderr, qr/No valid type handlers/, 'No valid type handlers';
  typing::set_spaces('main', 'main');
  trap{tf3()};
  like $trap->stderr, qr/Not a string/, 'tf3() throws "Not a string"';
  is_deeply tf3('hello'), ['hello'], 'tf3("hello") returns ["hello"]';
  is_deeply tf3(12345), [12345], 'tf3(12345) returns [12345]';
  trap{tf3({})};
  like $trap->stderr, qr/Not a string/, 'tf3({}) throws "Not a string"';
};

subtest 'sub tf4 :Function(string, number)', sub {
  trap{tf4()};
  like $trap->stderr, qr/Not a string/, 'tf4() throws "Not a string"';
  trap{tf4('hello')};
  like $trap->stderr, qr/Not a number/, 'tf4("hello") throws "Not a number"';
  trap{tf4('hello', {})};
  like $trap->stderr, qr/Not a number/, 'tf4("hello", {}) throws "Not a number"';
  is_deeply tf4('hello', 12345), ['hello', 12345], 'tf4("hello", 12345) returns ["hello", 12345]';
  is_deeply tf4('hello', 12345, 67890), ['hello', 12345, 67890], 'tf4("hello", 12345, 67890) returns ["hello", 12345, 67890]';
  trap{tf4('hello', 12345, {})};
  like $trap->stderr, qr/Not a number/, 'tf4("hello", 12345, {}) throws "Not a number"';
};

subtest 'sub tm1 :Method()', sub {
  is_deeply tm1(), [], 'tm1()';
  is_deeply tm1(1..4), [1..4], 'tm1(1..4)';
};

subtest 'sub tm2 :Method()', sub {
  is_deeply tm2(), [], 'tm2()';
  is_deeply tm2(1..4), [1..4], 'tm2(1..4)';
};

subtest 'sub tm3 :Method(string)', sub {
  trap{tm3()};
  like $trap->stderr, qr/Not a string/, 'tm3() throws "Not a string"';
  is_deeply tm3('hello'), ['hello'], 'tm3("hello") returns ["hello"]';
  is_deeply tm3(12345), [12345], 'tm3(12345) returns [12345]';
  trap{tm3({})};
  like $trap->stderr, qr/Not a string/, 'tm3({}) throws "Not a string"';
};

subtest 'sub tm4 :Method(string, number)', sub {
  trap{tm4()};
  like $trap->stderr, qr/Not a string/, 'tm4() throws "Not a string"';
  trap{tm4('hello')};
  like $trap->stderr, qr/Not a number/, 'tm4("hello") throws "Not a number"';
  trap{tm4('hello', {})};
  like $trap->stderr, qr/Not a number/, 'tm4("hello", {}) throws "Not a number"';
  is_deeply tm4('hello', 12345), ['hello', 12345], 'tm4("hello", 12345) returns ["hello", 12345]';
  is_deeply tm4('hello', 12345, 67890), ['hello', 12345, 67890], 'tm4("hello", 12345, 67890) returns ["hello", 12345, 67890]';
  trap{tm4('hello', 12345, {})};
  like $trap->stderr, qr/Not a number/, 'tm4("hello", 12345, {}) throws "Not a number"';
};

subtest 'sub tr1 :Return()', sub {
  is_deeply tr1(), [], 'tr1()';
  is_deeply tr1(1..4), [1..4], 'tr1(1..4)';
};

subtest 'sub tr2 :Return()', sub {
  is_deeply tr2(), [], 'tr2()';
  is_deeply tr2(1..4), [1..4], 'tr2(1..4)';
};

subtest 'sub tr3 :Return(string)', sub {
  is_deeply tr3(), [], 'tr3()';
  is_deeply tr3(1..4), [1..4], 'tr3(1..4)';
  typing::set_spaces('main', 'main');
  is_deeply tr3('hello'), ['hello'], 'tr3("hello") returns ["hello"]';
  is_deeply tr3(12345), [12345], 'tr3(12345) returns [12345]';
};

subtest 'sub tr4 :Return(string, number)', sub {
  is_deeply tr3(), [], 'tr3()';
  is_deeply tr3(1..4), [1..4], 'tr3(1..4)';
  is_deeply tr4('hello'), ['hello'], 'tr4("hello")';
  is_deeply tr4('hello', {}), ['hello', {}], 'tr4("hello", {})';
  is_deeply tr4('hello', 12345), ['hello', 12345], 'tr4("hello", 12345) returns ["hello", 12345]';
  is_deeply tr4('hello', 12345, 67890), ['hello', 12345, 67890], 'tr4("hello", 12345, 67890) returns ["hello", 12345, 67890]';
};

ok 1 and done_testing;

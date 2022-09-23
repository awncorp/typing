# TOPIC

My Perl Weekly Challenge

# TITLE

100% Backwards-compatible pure Perl optionally typable subroutine signatures for Perl 5

# CONTENT

All this talk about [types, objects, and systems](https://dev.to/iamalnewkirk/types-objects-and-systems-oh-my-27hk), got me to thinking, _"what would it take to create a 100% backwards-compatible pure Perl proof-of-concept for optionally typable subroutine signatures"_. I mean really, how hard could it be? So I started sketching out some ideas and here's what I came up with:

```perl
use typing;

sub greet :Function(string, number) :Return() {
  my ($name, $count) = &_;

  print "Hi $name, you have $count messages waiting ...\n";
}
```

This final sketch felt very Perlish and I had an inkling that I might be able to tie all the concepts being used together, and I did. It actually works, and it's fast. Let's break down what's actually happening here.

```perl
use typing;
```

I don't particularly like or care about the name, I had to call it something, the code is about resolving types, so I called it _"typing"_. When you import the package the framework installs two magic symbols. Oh, yes, btw, once I made it all work, I decided to extend it so that any type or object system could hook into it to allow the resolution of their own types using this system, so yes, it's a framework.

```perl
sub greet :Function(string, number) :Return();
```

The _"greet"_ subroutine is just a plain ole subroutine. No source filter, no Perl keyword API, no XS, no high-magic. Here we're using old school "attributes" to annotate the subroutine and denote whether it's a function or method, and whether it has a return value or not.

```perl
sub greet :Method(object, string) :Return(object);
```

Declaring a subroutine as a method doesn't do anything special. No automagic unpacking, no implied/inferred first argument. The same is true for the "return" declaration. In fact, the annotations aren't involved in the execution of your program unless to you use the magic _"unpacker"_ function.

```perl
# use this ...
my ($name, $count) = &_;

# instead of this ...
my ($name, $count) = @_;
```

This works due to a little-known Perl trick that only most neck-beardiest of Perl hackers understand (and me), which is what happens when you call a subroutine using the ampersand without any arguments, i.e. you can operate on the caller's argument list. By naming the function `_`, and requiring the use of the ampersand, we've created a cute little analogy to the `@_` variable.

```perl
sub greet :Function(string, number) :Return() {
  my ($name, $count) = &_;
  # ...
}
```

Here's what's happening. The "unpacker" function gets the typed argument list for the calling subroutine, i.e. it gets its signature, then it iterates over the arguments calling the configured validator for each type expression specified at each position in the argument list.

```perl
greet() # error
greet({}) # error
greet('bob') # error
greet('bob', 2) # sweet :)
```

But what happens if you provide more arguments than the signature has type expressions for? The system is designed to use the last type specified to validate all out-of-bounds arguments, which means `greet('bob', 2..10)` works and passes the type checks, but `greet('bob', 2, 'bob', 2)` doesn't because the second `'bob'` isn't a number. Make sense? Right, but what about the framework bit? First, let's see what it looks like to hook into the framework as a one-off:

```perl
use typing;

typing::set_spaces('main', 'main');

sub main::string::make {
  # must return (value, valid?, explanation)
  ($_[0], 1, '')
}

sub greet :Function(string) {
  my ($name) = &_;
  print "Hi $name\n";
}
```

This example is one of the simplest hooks. The `set_spaces` function says, the caller is the "main" package, and we should look for types under the _"main"_ namespace by prefixing the type name with _"main"_ and looking for a subroutine called "make". The _"make"_ subroutine must return a list in the form of `(value, valid?, explanation)`. This approach expects each type to correspond to a package (with a _"make"_ routine), but maybe you like the type library/registry approach. Another way to hook into the system is to bring your own resolver:

```perl
use typing;

typing::set_resolver('main', ['main', 'resolver']);

sub resolver {
  # accepts (package, type-expr, value)
  # returns (value, valid?, explanation)
  # maybe you'll do something like $registry->get(type-expr)->validate(value)
  ($_[0], 1, '')
}

sub greet :Function(string) {
  my ($name) = &_;
  print "Hi $name\n";
}
```

This example is uses the `set_resolver` function and says, the caller is the _"main"_ package, and we should resolve **all** types in the _"main"_ package using the `main::resolver` subroutine. The resolver must return a list in the form of `(value, valid?, explanation)`. But wait, there's more, ... we can use the framework's API to get the subroutine metadata to further automate our programs, for example:

```perl
use typing;

typing::retrieve('main', 'method', 'greet')
# [
#   'MyApp::Object',
#   'string',
#   'number'
# ]

typing::retrieve('main', 'return', 'greet')
# [
#   'MyApp::Object'
# ]

sub greet :Function(MyApp::Object, string, number) :Return(MyApp::Object) {
  # ...
}
```

I was actually suppoesd to be working on a completely different project, but this idea captivated me, and so I lost a couple of days of productivity :\

## Sources

**Type libraries**

[MooseX::Types](https://metacpan.org/pod/MooseX::Types)

[Type::Tiny](https://metacpan.org/pod/Type::Tiny)

[Specio](https://metacpan.org/pod/Specio)

**Subroutine signatures**

[Function::Parameters](https://metacpan.org/pod/Function::Parameters)

[Method::Signatures](https://metacpan.org/pod/Method::Signatures)

[registry/routines](https://metacpan.org/pod/routines)

## End Quote

"Software is like art and the only justification you need for creating it is, 'because I felt like it'" - Andy Wardley

## Authors

Awncorp, `awncorp@cpan.org`

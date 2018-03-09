# Using RubyBridge

This document contains notes on using `RubyBridge`.  For installation tips
see [the README](index.html).
* [How to use the framework](#general-usage)
* [How to do various Ruby tasks](#how-to)
* [Error handling approach](#error-handling)
* [Concurrency and multi-threading](#concurrency)
* [Health warning](#caveats-and-gotchas)
* [Using the libruby API](#using-the-cruby-api)

## General Usage

The Ruby VM is initialized when you first try to use it and shut down when the
process ends.  Load Ruby code using `RbBridge.load(filename:wrap:)` or
`RbBridge.require(filename:)`.  Or just run some Ruby code and get the result
using `RbBridge.eval(ruby:)`.  There already is a global instance of `RbBridge`
called `Ruby` so the code looks like:

```swift
import RubyBridge

do {
    let result = try Ruby.eval(ruby: "'a' * 4")
    print(result)
} catch {
}
```

Create objects using `RbObject.init(ofClass:args:kwArgs:)`.  Pass Swift types
or `RbObject`s to the `args` parameter.

Use `RbObject.call(_:args:kwArgs)` [link: `RbObjectAccess.call(_:args:kwArgs)`]
to call methods on the object.  See `RbObjectAccess` for more object
operations.  Again pass Swift types or `RbObject`s in the `args` parameter.

Use optional initializers to convert from `RbObject`s back to Swift types, or
implicitly/explicitly access `RbObject.description` if you just want `String`.

```swift
import RubyBridge

do {
    try Ruby.require(filename: "academy")
    let student = try RbObject(ofClass: "Academy::Student",
                               kwArgs: [("name", "Betty")])
    if let bettyGpa = try Double(student.get("gpa")) {
        processScore(gpa: bettyGpa)
    }
} catch {
}
```

## How to ...

### Pass a symbol as an argument

Use `RbSymbol`.  Ruby:
```ruby
res = obj.meth(:value)
```
RubyBridge:
```swift
let res = obj.call("meth", args: [RbSymbol("value")])
```

### Access class variables

Use `RbObjectAccess.getClassVar(_:)` **on the class**: RubyBridge goes like the
Ruby API not Ruby as written.  Ruby:
```ruby
class MyClass
  @@count = 0
  def initialize
    @@count += 1
  end
end
```
RubyBridge:
```swift
let myClass = try Ruby.getClass("MyClass")
let count = try myClass.getClassVar("@@count")
```

### Run finalizers before process exit

If you want to stop using Ruby and get on with something else, and
never come back to Ruby in the process, use `RbBridge.cleanup()`.

### Can't do yet
* Arrays Hashes Sets
* Ranges
* Rational Complex
* Symbol as blocks
* Code as block

## Error Handling

RubyBridge is very explicit about failure points.  Any Ruby method call can
raise an exception instead of terminating normally and this is reflected in the
throwable nature of most of the interesting RubyBridge methods.

Normally when writing Ruby scripts one doesn't care about this and just lets
the program crash, which happens very rarely after the debugging phase.  If you
are using RubyBridge though, there is presumably a lot more happening for you
and your users than the Ruby stuff -- otherwise you'd be writing Ruby, not
Swift.  I feel it does not make sense for a subsystem like this to decide how to
handle errors, so RubyBridge propagates all errors ([except when it doesn't]
(#caveats-and-gotchas)).

And `try!` is always available for quick don't-care-about-errors environments.

### Errors + Exceptions

All errors thrown are `RbError` which is an enum of various interface errors
detected by RubyBridge and one case `RbError.rubyException` that covers all
Ruby exceptions.

RubyBridge remembers the last few `RbError`s that were generated and stores
them in the publicly available `RbError.history`.

### `nil` failures

Converting Ruby values to Swift types works differently: it happens using
failable initializers such as `String.init(_:)`.  These can fail for a variety
of reasons.  When they do, RubyBridge still internally generates an `RbError`
and stores a copy in `RbError.history` even though it is not thrown.  This
means you can diagnose why a conversion failed:

```swift
guard let score = Float(scoreObj) else {
    print("Failed to get score back from Ruby: \(RbError.history.mostRecent)")
    return
}
```

### Failable Adapter

`RbFailableAccess` is a non-throwing adapter for `RbObject` and `RbBridge` that
returns `nil` when there is an error.  All it does is `try?` the
corresponding throwing method, meaning that the details of the failure are
available in `RbError.history`.

This is a steal of rough approach (the name is my fault) from the Python DML
sandbox with an eye to adding direct member lookup/callable to RubyBridge --
Swift subscripts can't throw.

I'm not sure this is better than just writing `try?` which at least makes it
very difficult for readers to ignore the possibility of errors.

## Concurrency

*more details to understand*

Do not access RubyBridge APIs from more than one thread ever.

## Caveats and Gotchas

Certain `RbObject` methods forward to Ruby calls and crash (`fatalError()`)
if Ruby fails / the object doesn't support the method.  It's up to you to be
sure the Ruby objects you're dealing with are of the right type.  See
`RbObject` for more information on which these methods are.

Running arbitrary Ruby code is a bad idea unless the process itself is
sandboxed - there are no restrictions on what the Ruby VM can do including
call `exit!`.

## Using the CRuby API

The [CRuby](https://github.com/johnfairh/CRuby) package provides access to as
much of the `libruby` API as makes it through the importer.  You can use this
in conjunction with RubyBridge to access more of the API than RubyBridge itself
provides.

Each `RbObject` wraps one `VALUE` keeping it safe from garbage collection.  You
can access that `VALUE` using `RbObject.withRubyValue(call:)`.

RubyBridge caches intern'ed Ruby strings - you can access the cache using
`RbBridge.getID(for:)`.

Note that when you call the Ruby API and Ruby raises an exception, the process
immediately crashes unless you are running inside `rb_protect()` or equivalent.

### References

* [Ruby C API Guide](http://silverhammermba.github.io/emberb/) - great guide to
  the API.
* [Ruby Hacking Guide](http://ruby-hacking-guide.github.io) - in-depth on how
  Ruby (an old version of) works.
* [Incremental GC in Ruby](https://blog.heroku.com/incremental-gc) - very
  interesting overview of GC pre + @ 2.2.
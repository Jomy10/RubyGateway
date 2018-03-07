<!--
RubyBridge
README.md
Distributed under the MIT license, see LICENSE.
-->

# RubyBridge

[![CI](https://travis-ci.org/johnfairh/RubyBridge.svg?branch=master)](https://travis-ci.org/johnfairh/RubyBridge)
[![codecov](https://codecov.io/gh/johnfairh/RubyBridge/branch/master/graph/badge.svg)](https://codecov.io/gh/johnfairh/RubyBridge)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<!--
![Pod](https://cocoapod-badges.herokuapp.com/v/RubyBridge/badge.png)
![Platforms](https://cocoapod-badges.herokuapp.com/p/RubyBridge/badge.png)
![License](https://cocoapod-badges.herokuapp.com/l/RubyBridge/badge.png)
-->

Embed Ruby in Swift: load Gems, run Ruby scripts, get results.

RubyBridge is a framework built on the Ruby C API that lets Swift programs
running on macOS or Linux painlessly and safely run and interact with Ruby
programs.  It's easy to pass Swift datatypes into Ruby and turn Ruby objects
back into Swift types.

This project is [young](TODO.md): biggest missing features right now
are collection types and calling Swift code from Ruby.

## Examples

- rouge

- object type thing

## Documentation

* User guide forthcoming!
* [API documentation](https://johnfairh.github.io/RubyBridge) online.
* Or in the docs/ folder of a local copy of the project.
* Docset for Dash at [docs/docsets/RubyBridge.tgz](https://johnfairh.github.io/RubyBridge/docsets/RubyBridge.tgz).

## Requirements

* Swift 4 or later, from swift.org or Xcode 9.2.
* macOS (tested on 10.13.3) or Linux (tested on Ubuntu Xenial/16.04 on x86_64)
* Ruby 2.0 or later including development files:
  * For macOS, this comes with Xcode.
  * For Linux you may need to install a -dev package depending on how your Ruby
    is installed.

## Installation

For macOS, if you are happy to use the system Ruby, you just need to include the
RubyBridge framework as a dependency.  If you are building on Linux or want to
use a different Ruby then you also need to configure CRuby.

### Getting the framework

Carthage for macOS:
```
github "johnfairh/RubyBridge"
```

Swift package manager for macOS or Linux:
```
.package(url: "https://github.com/johnfairh/RubyBridge", from: "0.1.0")
```

CocoaPods in the works.

### Configuring CRuby

CRuby is the glue between RubyBridge and your Ruby installation.  It is a
[separate github project](https://github.com/johnfairh/CRuby) but RubyBridge
includes it as submodule so you do not install or require it separately.

By default it points to the macOS system Ruby.  Follow the [CRuby usage
instructions](https://github.com/johnfairh/CRuby/README.md#usage) to change
this.  For example on Linux using [Brightbox Ruby](https://www.brightbox.com/docs/ruby/ubuntu/)
2.5:
```shell
sudo apt-get install ruby2.5 ruby2.5-dev pkg-config
mkdir MyProject
swift package init
vi Package.swift    # add RubyBridge as a dependency (NOT CRuby)
echo "import RubyBridge; print(Ruby.versionDescription)" > Sources/MyProject/MyProject.swift
swift package edit CRuby
Packages/CRuby/cfg-cruby --mode pkg-config --name ruby-2.5
PKG_CONFIG_PATH=$(pwd)/Packages/CRuby:$PKG_CONFIG_PATH swift run
```

## Contributions

Welcome: open an issue / johnfairh@gmail.com 

## License

Distributed under the MIT license.

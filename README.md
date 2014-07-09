# BuilderDSL
[![Build Status](https://travis-ci.org/interval-braining/builder_dsl.png)](https://travis-ci.org/interval-braining/builder_dsl)
[![Coverage Status](https://coveralls.io/repos/interval-braining/builder_dsl/badge.png)](https://coveralls.io/r/interval-braining/builder_dsl)
[![Code Climate](https://codeclimate.com/github/interval-braining/builder_dsl.png)](https://codeclimate.com/github/interval-braining/builder_dsl)
[![Dependency Status](https://gemnasium.com/interval-braining/builder_dsl.png)](https://gemnasium.com/interval-braining/builder_dsl)

Simple DSL for defining Builder classes with customized DSLs.

## Installation

Add this line to your application's Gemfile:

    gem 'builder_dsl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install builder_dsl

## Usage

BuilderDSL makes it easy to create customized DSLs for building all variety of
objects. At its simplest, a builder is any Class or Module that implements a
build function.

```ruby
  CustomBuilder.build(*args) do |stuff|

  end
```

```ruby

  # Uses default definition builder
  BuilderDSL.define do
    # stuff
  end


  # Uses custom builder to define new builder. Additional args are passed to
  # the build method of the definition_builder_class.
  BuilderDSL.define(definition_builder_class, :foo) do
    # stuff
  end
```

## Configuration


## Contributing

1. Fork it ( https://github.com/interval-braining/builder_dsl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

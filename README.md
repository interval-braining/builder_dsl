# BuildingBlocks
[![Build Status](https://travis-ci.org/interval-braining/building_blocks.png)](https://travis-ci.org/interval-braining/building_blocks)
[![Coverage Status](https://coveralls.io/repos/interval-braining/building_blocks/badge.png)](https://coveralls.io/r/interval-braining/building_blocks)
[![Code Climate](https://codeclimate.com/github/interval-braining/building_blocks.png)](https://codeclimate.com/github/interval-braining/building_blocks)
[![Dependency Status](https://gemnasium.com/interval-braining/building_blocks.png)](https://gemnasium.com/interval-braining/building_blocks)

Simple DSL for defining Builder classes with customized DSLs.

## Installation

Add this line to your application's Gemfile:

    gem 'building_blocks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install building_blocks

## Usage

BuildingBlocks makes it easy to create customized DSLs for building all variety of
objects. At its simplest, a builder is any Class or Module that implements a
build function.

```ruby
  CustomBuilder.build(*args) do |stuff|

  end
```

```ruby

  # Uses default definition builder
  BuildingBlocks.define do
    # stuff
  end


  # Uses custom builder to define new builder. Additional args are passed to
  # the build method of the definition_builder_class.
  BuildingBlocks.define(definition_builder_class, :foo) do
    # stuff
  end
```

## Configuration


## Contributing

1. Fork it ( https://github.com/interval-braining/building_blocks/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

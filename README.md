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

BuildingBlocks strives to make it easy to create customizable block-based DSLs
for building all variety of objects.

This is achieved through the use of Builder objects. At their core, Builders are
any object that defines a `build` method that takes in a block and returns an
Object. How that block is used and what Object is returned can depend greatly on
the Builder being used. In some cases the block could be ignored entirely. In
other cases the Object returned could be a JSON string. It all depends on the
Builder.

Because Builders are just Plain Old Ruby Objects, there are no restrictions on
how Builders can be defined or what they can accomplish during their build
process. However, since there are a few common patterns employed by most
Builders, BuildingBlocks offers a Buillder Builder that allows for defining
Builder objects using a simple DSL.

### BuilderBuilder DSL
Though BuildingBlocks is not itself a Builder, it does implement a `build`
method that delegates all calls to the configured
`BuildingBlocks.default_builder`. By default the `default_builder` is configured
to use `BuildingBlocks::Builders::BuilderBuilder`, a sort of meta-Builder in that
it's a Builder that also happens to build other valid Builders.

```ruby
  # Creating a new builder class using the default builder DSL
  Point = Struct.new(:x, :y)
  PointBuilder = BuildingBlocks.build do
    resource_class Point
    attribute :x
    attribute :y
  end

  # Creating a new Point instance using PointBuilder
  # Both the block arg, builder, and self are the PointBuilder instance
  point = PointBuilder.build do |builder|
    x 1
    y 1
  end
  # => #<struct Point x=1, y=1>


  # A more complex example of the default builder DSL
  class Circle
    attr_accessor :radius
    attr_reader :center

    def center=(point)
      raise ArgumentError, 'Bad point' unless point.is_a?(Point)
      @center = point
    end
  end

  CircleBuilder = BuildingBlocks.build do
    resource_class Circle
    attribute :radius
    builder :center, :center=, PointBuilder
    delegate :x, :x=, :center
    delegate :y, :y=, :center
  end

  circle = CircleBuilder.build do |c|
    radius 5
    center do |m|
      x 5
      y 5
    end

    # Override the previously set value for y
    y 1
  end
  # => #<Circle @center=#<struct Point x=5, y=1>, @radius=5>
```

More information on the default builder definition DSL can be found in the
[docs](http://rubydoc.info/gems/building_blocks/0.0.1/frames)

## Contributing

1. Fork it ( https://github.com/interval-braining/building_blocks/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

require 'building_blocks/version'
require 'building_blocks/builders/builder_builder'

# Primary BuildingBlocks object providing an interface to build/define other
# builders using builders that build new builder objects.
module BuildingBlocks
  # The default builder used for defining new builders when {build build}
  # is invoked.
  # @see build
  # @see BuildingBlocks::Builders::BuilderBuilder
  DEFAULT_DEFINITION_BUILDER = BuildingBlocks::Builders::BuilderBuilder

  # Returns the object currently configured for use when defining new builders
  # using {build build}. If a custom value has not been configured the
  # {DEFAULT_DEFINITION_BUILDER default definition builder} is returned.
  # @return [#build] The builder to be used for defining new builders when
  #   {build build} is invoked.
  # @see build
  # @see DEFAULT_DEFINITION_BUILDER
  def self.default_definition_builder
    return @default_definition_builder || DEFAULT_DEFINITION_BUILDER
  end

  # Sets the class that is used when defining new builders when using
  # {build build}. If a value of `nil` or `false` is provided the
  # {DEFAULT_DEFINITION_BUILDER default definition builder} will be used.
  # @param [#build] builder The object to be used when defining new builders
  #   when using {build build}.
  # @raise [ArgumentError] Raised if the object provided does not implement
  #   a #build method and is neither nil nor false.
  # @return [#build] The builder argument provided is returned.
  # @see DEFAULT_DEFINITION_BUILDER
  # @see build
  def self.default_definition_builder=(builder)
    if !!builder && !builder.respond_to?(:build)
      raise ArgumentError, 'Expected object that responds to #build'
    end
    @default_definition_builder = builder
  end

  # Defines/builds a new builder object using the `definition_builder` object
  # provided or the {default_definition_builder default definition builder}. Any
  # additional `args` provided will be passed unmodified to the `build` method
  # of the `definition_builder`. If a block is given it will also be passed to
  # the `definition_builder` unmodified.
  # @param [#build] definition_builder Custom definition builder to use for
  #   for this definition. If no value is supplied the
  #   {DEFAULT_DEFINITION_BUILDER default definition builder} is used.
  # @return [Object] The result of invoking `build` on the
  #   `definition_builder` (often an instance of the `definition_builder`).
  # @see default_definition_builder
  def self.build(definition_builder = self.default_definition_builder, *args)
    block_given? ? definition_builder.build(*args, &Proc.new) : definition_builder.build(*args)
  end

  # Namespace for builder classes
  module Builders; end
end

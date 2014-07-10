require 'forwardable'
require 'building_blocks/version'
require 'building_blocks/builders/builder_builder'

# Primary BuildingBlocks object providing an interface to build/define other
# builders using builders that build new builder objects.
module BuildingBlocks

  class << self
    extend Forwardable
    def_delegator :default_builder, :build
  end

  # The default builder used for defining new builders when {build build}
  # is invoked.
  # @see build
  # @see BuildingBlocks::Builders::BuilderBuilder
  DEFAULT_DEFINITION_BUILDER = BuildingBlocks::Builders::BuilderBuilder

  # Returns the object currently configured for use when defining new builders
  # using {build build}. If a custom value has not been configured the
  # {DEFAULT_DEFINITION_BUILDER default builder} is returned.
  # @return [#build] The builder to be used for defining new builders when
  #   {build build} is invoked.
  # @see build
  # @see DEFAULT_DEFINITION_BUILDER
  def self.default_builder
    return @default_builder || DEFAULT_DEFINITION_BUILDER
  end

  # Sets the class that is used when defining new builders when using {build
  # build} to the provided **builder**. If a value of `nil` or `false` is
  # provided the {DEFAULT_DEFINITION_BUILDER default builder} will be
  # used.
  # @param [#build] builder The object to be used when defining new builders
  #   when using {build build}.
  # @raise [ArgumentError] Raised if the object provided does not implement
  #   a #build method and is neither nil nor false.
  # @return [#build] The builder argument provided is returned.
  # @see DEFAULT_DEFINITION_BUILDER
  # @see build
  def self.default_builder=(builder)
    if !!builder && !builder.respond_to?(:build)
      raise ArgumentError, 'Expected object that responds to #build'
    end
    @default_builder = builder
  end

  # Namespace for builder classes
  module Builders; end

  # @!method self.build(*args, &block)
  #   Builds a new object using the the {default_builder default builder}. Any
  #   **args** or **block** provided are delegated directly to the `build` method
  #   of the {default_builder default builder}.
  #   @return [Object] The result of invoking `build` on the
  #     {#default_builder default builder}.
  #   @see default_builder
end

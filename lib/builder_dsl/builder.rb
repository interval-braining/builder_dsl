require 'builder_dsl/builder/dsl'

module BuilderDSL
  class Builder
    class << self
      attr_writer :initialize_with
      attr_accessor :resource_class
      attr_writer :default_definition_builder
    end

    extend DSL

    DEFAULT_INITIALIZE_WITH = lambda { |instance| resource_class.new }
    DEFAULT_DEFINITION_BUILDER = BuilderDSL::Builders::BuilderBuilder

    def self.default_definition_builder
      return @default_definition_builder || DEFAULT_DEFINITION_BUILDER
    end


    def self.define(definition_builder = self.default_definition_builder, *args)
      block_given? ? definition_builder.build(*args, &Proc.new) : definition_builder.build
    end


    def self.new
      if self == ::BuilderDSL::Builder
        block_given? ? Class.new(self, &Proc.new) : Class.new(self)
      else
        instance = instance_eval(&(self.initialize_with || DEFAULT_INITIALIZE_WITH))
        builder = super(instance)
        builder.instance_eval(&Proc.new) if block_given?
        instance
      end
    end

    def self.initialize_with
      @initialize_with = Proc.new if block_given?
      @initialize_with
    end

    private
    # Given {::new}, can't ever be initialized externally
    def initialize(instance)
      @instance = instance
    end
  end
end

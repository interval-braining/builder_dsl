require 'builder_dsl/builder/dsl'

module BuilderDSL
  class Builder
    class << self
      attr_writer :initialize_with
      attr_accessor :resource_class
    end

    extend DSL

    DEFAULT_INITIALIZE_WITH = lambda { |instance| resource_class.new }

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

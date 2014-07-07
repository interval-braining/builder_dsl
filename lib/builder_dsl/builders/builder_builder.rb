require 'forwardable'

module BuilderDSL
  module Builders
    # Builder that builds other Builders using minimal DSL
    class BuilderBuilder

      def self.build
        klass = Class.new
        klass.extend(ClassInstanceMethods)
        klass.send(:include, InstanceMethods)
        klass.module_eval(&Proc.new) if block_given?
        klass
      end

      module ClassInstanceMethods
        include Forwardable

        DEFAULT_INITIALIZE_WITH = lambda { |instance| resource_class.new }

        def attribute(attr_name, receiver_method = :"#{attr_name}=", receiver = nil)
          delegate(attr_name, receiver_method, receiver)
          return attr_name.to_sym
        end

        def build
          instance = instance_eval(&self.initialize_with)
          builder = new(instance)
          builder.instance_eval(&Proc.new) if block_given?
          instance
        end

        def builder(attr_name, receiver_method = "#{attr_name}=", builder_class = nil, receiver = nil)
          if block_given? ^ builder_class.nil?
            raise ArgumentError, 'Either a builder class or a builder definition is required'
          elsif block_given?
            builder_class = BuilderDSL.define(&Proc.new)
          end

          if receiver.is_a?(Proc)
            receiver_proc = receiver
          elsif receiver.is_a?(Symbol) || receiver.is_a?(String)
            receiver_proc = instance_eval("lambda { |i| @instance.#{receiver} }")
          else
            receiver_proc = lambda { |i| @instance }
          end

          define_builder_method(attr_name, receiver_method, builder_class, receiver_proc)
        end

        def delegate(attr_name, receiver_method = attr_name, receiver = nil)
          receiver = receiver.nil? || receiver.empty? ? :@instance : :"@instance.#{receiver}"
          def_delegator(receiver, receiver_method, attr_name)
          attr_name.to_sym
        end

        def initialize_with
          @initialize_with = Proc.new if block_given?
          @initialize_with || DEFAULT_INITIALIZE_WITH
        end

        def initialize_with=(initializer)
          unless initializer.is_a?(Proc)
            raise ArgumentError, "Expected proc initializer, got #{initializer.class.name}"
          end
          @initialize_with = initializer
        end

        def resource_class(klass = nil)
          @resource_class = klass unless klass.nil?
          @resource_class
        end

        def resource_class=(klass)
          @resource_class = klass
        end

        private

        # Handles the wiring required to invoke a builder when **attr_name** is
        # invoked.
        def define_builder_method(attr_name, receiver_method, builder_class, receiver_proc)
          define_method(attr_name) do |existing_object = nil, &block|
            begin
              if block.nil? ^ !!existing_object
                raise ArgumentError, 'Either a static instance or a builder proc is required'
              end
              receiver = instance_eval(&receiver_proc)
              instance = block.nil? ? existing_object : builder_class.build(&block)
              receiver.send(receiver_method, instance)
              instance
            rescue Exception
              $@.delete_if{|s| %r"#{Regexp.quote(__FILE__)}"o =~ s}
              ::Kernel::raise
            end
          end
        end
      end

      module InstanceMethods
        def initialize(instance)
          @instance = instance
        end

        def instance
          return @instance
        end

      end

    end
  end
end

require 'test_helper'

module BuildingBlocks
  module Builders
    class BuilderBuilderTest < MiniTest::Test

      context 'BuilderBuilder class methods' do

        should 'generate a new Builder class without block given' do
          builder = BuilderBuilder.build
          assert_kind_of Class, builder
          assert builder.ancestors.include?(BuildingBlocks::Builders::BuilderBuilder::InstanceMethods)
        end


        should 'generate a new Builder class with block given' do
          new_block_arg = new_self = nil
          # Validates block form
          builder = BuilderBuilder.build do |subclass|
            # Leave marker of instance evaluation
            define_singleton_method(:builder_evaluated) { true }
            # Test usage of block argument
            subclass.resource_class = Hash
            # Set up variables for evaluation back in the test
            new_self = self
            new_block_arg = subclass
          end

          # Validate DSL context variables
          assert_equal builder, new_block_arg
          assert_equal builder, new_self

          # Validate assignments and markers
          assert_equal Hash, builder.resource_class
          assert_equal true, builder.builder_evaluated
        end

      end


      context 'BuilderBuilder generated Builder class methods' do

        setup do
          @struct = struct = Struct.new(:key, :value)
          @dict_builder = BuildingBlocks.define do
            resource_class struct
            attribute(:key)
            attribute(:value)
          end
          @builder = BuildingBlocks.define
        end


        context '::attribute' do

          should 'raise ArgumentError unless attribute name provided' do
            assert_raises(ArgumentError) { BuildingBlocks.define { attribute } }
          end


          should 'delegate calls to attr_name to receiver via receiver_method' do
            @builder.expects(:def_delegator).with(:'@instance.c', :b, :a,)
            @builder.attribute(:a, :b, :c)
          end


          should 'delegate to attr_name= on receiver by default' do
            @builder.expects(:def_delegator).with(:@instance, :a=, :a,)
            @builder.attribute(:a)
          end


          should 'delegate directly to the @instance by default' do
            @builder.expects(:def_delegator).with(:@instance, :a=, :a)
            @builder.attribute(:a)
          end


          should 'return the Symbol form of the provided attr_name' do
            result = @builder.attribute(:a)
            assert_equal :a, result
          end

        end


        context '::builder' do

          should 'raise an error unless a Builder class xor proc is provided' do
            assert_raises(ArgumentError) do
              BuildingBlocks.define { builder(:foo) }
            end

            dict_builder = @dict_builder
            assert_raises(ArgumentError) do
              BuildingBlocks.define { builder(:foo, :foo=, dict_builder) { |i| } }
            end
          end


          should 'raise an error unless an attr_name is provided' do
            assert_raises(ArgumentError) { BuildingBlocks.define { builder } }
          end


          should 'return the Symbol form of the provided attr_name' do
            dict_builder = @dict_builder
            result = @builder.builder(:foo, :value=, dict_builder)
            assert_equal :foo, result
          end


          should 'take a custom receiver method name' do
            dict_builder, struct = @dict_builder, @struct
            builder = BuildingBlocks.define do
              resource_class struct
              builder(:foo, :value=, dict_builder)
            end
            instance = builder.build { foo { key(:a); value(:b) } }
            assert_equal :a, instance.value.key
            assert_equal :b, instance.value.value
          end


          should 'take a custom receiver proc' do
            dict_builder, struct = @dict_builder, @struct
            builder = BuildingBlocks.define do
              resource_class struct
              builder(:foo, :value=, dict_builder, lambda { |i| String })
            end
            String.expects(:value=)
            builder.build { foo { key(:a); value(:b) } }
          end


          should 'should accept a proc that is a Builder definition' do
            struct = @struct
            builder = BuildingBlocks.define do
              resource_class struct
              builder(:foo, :value=) do |i|
                resource_class struct
                attribute :bar, :key=
              end
            end
            instance = builder.build { foo { bar :a } }
            assert_equal :a, instance.value.key
          end


          should 'accept a custom builder class' do
            dict_builder, struct = @dict_builder, @struct
            db = dict_builder.build
            dict_builder.expects(:build).returns(db)
            builder = BuildingBlocks.define do
              resource_class struct
              builder(:foo, :value=, dict_builder)
            end
            instance = builder.build { foo { |i| } }
            assert_equal db, instance.value
          end


          should 'accept a custom receiver identifier' do
            dict_builder, struct = @dict_builder, @struct
            builder = BuildingBlocks.define do
              resource_class struct
              builder(:value, :value=, dict_builder)
              builder(:foo, :value=, dict_builder, :value)
            end
            instance = builder.build do
              value { key(:a) }
              foo { |i| value(:b) }
            end
            assert_equal :b, instance.value.value.value
          end

        end


        context '::delegate' do

          should 'raise ArgumentError unless method_name provided' do
            assert_raises(ArgumentError) { @builder.delegate }
          end


          should 'create a delegator to @instance.receiver.receiver_method aliased to method_name' do
            @builder.expects(:def_delegator).with(:'@instance.receiver', :receiver_method, :method_name)
            @builder.delegate(:method_name, :receiver_method, :receiver)
          end


          should 'create a delegator to @instance.receiver_method aliased to method_name by default' do
            @builder.expects(:def_delegator).with(:@instance, :receiver_method, :method_name)
            @builder.delegate(:method_name, :receiver_method)
          end


          should 'create a delegator to @instance.method_name aliased to method_name by default' do
            @builder.expects(:def_delegator).with(:@instance, :method_name, :method_name)
            @builder.delegate(:method_name)
          end


          should 'return the symbol identifier form of attr_name' do
            assert_equal :method_name, @builder.delegate('method_name')
          end

        end


        context '::new' do

          should 'accept a block and evaluate the block on the builder instance' do
            struct = @dict_builder.build do
              key :a
              value 'a'
            end
            assert_equal :a, struct.key
            assert_equal 'a', struct.value
          end


          should 'return the generated instance when no block given' do
            the_struct = @struct.new
            the_struct.key = :a
            the_struct.value = 'a'
            @struct.expects(:new).returns(the_struct)

            struct = @dict_builder.build
            assert_equal :a, struct.key
            assert_equal 'a', struct.value
          end


          should 'utilize a custom initialize_with proc if available' do
            @dict_builder.initialize_with do |builder|
              instance = resource_class.new
              instance.key = :b
              instance.value = 'b'
              instance
            end

            struct = @dict_builder.build
            assert_equal :b, struct.key
            assert_equal 'b', struct.value
          end

        end


        context '::initialize_with' do

          setup do
            @initializer = lambda { |i| Hash.new }
            @dict_builder.initialize_with(&@initializer)
          end


          should 'set @initialize_with if given a block' do
            assert_equal @dict_builder.initialize_with, @initializer
            assert_equal @dict_builder.instance_variable_get(:@initialize_with), @initializer
          end


          should 'return @initialize_with if no block given' do
            assert_equal @dict_builder.instance_variable_get(:@initialize_with), @dict_builder.initialize_with
          end

        end


        context '::initialize_with=' do

          setup do
            @initializer = lambda { |i| Hash.new }
          end


          should 'raise an error if a non-proc is provided' do
            assert_raises(ArgumentError) do
              @dict_builder.initialize_with = :foo
            end
          end


          should 'set @initialize_with if given a proc' do
            @dict_builder.initialize_with = @initializer
            assert_equal @dict_builder.initialize_with, @initializer
            assert_equal @dict_builder.instance_variable_get(:@initialize_with), @initializer
          end

        end


        context '::resource_class' do

          should 'return the current resource_class when no arguments are given' do
            assert_equal nil, @builder.resource_class
            @builder.resource_class = @struct
            assert_equal @struct, @builder.resource_class
          end


          should 'set the current resource_class when an argument is given' do
            @builder.resource_class(@struct)
            assert_equal @struct, @builder.resource_class
          end


          should 'set and return the argument given when given an argument' do
            assert_equal @struct, @builder.resource_class(@struct)
          end

        end


        context '::resource_class=' do

          should 'set the current resource_class' do
            @builder.resource_class = @struct
            assert_equal @struct, @builder.resource_class
          end


          should 'return the argument given' do
            assert_equal @struct, @builder.resource_class = @struct
          end

        end

      end


      context 'BuilderBuilder generated Builder class instance methods' do

        setup do
          @struct = struct = Struct.new(:key, :value)
          @dict_builder = BuildingBlocks.define do
            resource_class struct
            attribute(:key)
            attribute(:value)
          end
        end


        context '::builder generated instance method' do

          setup do
            dict_builder, struct = @dict_builder, @struct
            @builder_instance = BuildingBlocks.define do
              resource_class struct
              builder(:foo, :value=, dict_builder)
            end
          end


          should 'raise ArgumentError if given static instance and block or neither' do
            assert_raises(ArgumentError) { @builder_instance.build { foo } }
            assert_raises(ArgumentError) do
              @builder_instance.build { foo(true) {|i| } }
            end
          end


          should 'pass a static instance to the receiver method of the receiver' do
            instance = @builder_instance.build { foo(true) }
            assert_equal true, instance.value
          end


          should 'evaluate builder definition and send instance to the receiver method of receiver' do
            instance = @builder_instance.build { foo { value(true) } }
            assert_equal true, instance.value.value
          end

        end


        context '#initialize' do

          should 'require an instance' do
            assert_raises(ArgumentError) { @dict_builder.new }
            struct = @struct.new(:k, :v)
            builder = @dict_builder.new(struct)
            assert_equal struct, builder.instance
          end

        end


        context '#instance' do

          should 'return the object instance being built' do
            struct = @struct.new(:k, :v)
            builder = @dict_builder.new(struct)
            assert_equal struct, builder.instance
          end

        end

      end

    end
  end
end

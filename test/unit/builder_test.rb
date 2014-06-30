require 'test_helper'

module BuilderDSL
  class BuilderTest < MiniTest::Test

    context 'Builder class methods' do

      should 'generate a new Builder class without block given' do
        builder = Builder.new
        assert_kind_of Class, builder
        assert builder.ancestors.include?(Builder)
      end


      should 'generate a new Builder class with block given' do
        new_block_arg = new_self = nil
        # Validates block form
        builder = Builder.new do |subclass|
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


    context 'Builder class instance methods' do

      setup do
        @struct = struct = Struct.new(:key, :value)
        @builder = BuilderDSL.define do
          resource_class struct
          attribute :key
          attribute :value
        end
      end


      context '::new' do

        should 'accept a block and evaluate the block on the builder instance' do
          struct = @builder.new do
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

          struct = @builder.new
          assert_equal :a, struct.key
          assert_equal 'a', struct.value
        end


        should 'utilize a custom initialize_with proc if available' do
          @builder.initialize_with do |builder|
            instance = resource_class.new
            instance.key = :b
            instance.value = 'b'
            instance
          end

          struct = @builder.new
          assert_equal :b, struct.key
          assert_equal 'b', struct.value
        end

      end


      context '::initialize_with' do

        should 'set @initialize_with if given a block' do
          initializer = lambda { |i| Hash.new }
          @builder.initialize_with(&initializer)
          assert_equal @builder.initialize_with, initializer
          assert_equal @builder.instance_variable_get(:@initialize_with), initializer
        end


        should 'return @initialize_with if no block given' do
          assert_equal @builder.instance_variable_get(:@initialize_with), @builder.initialize_with
        end

      end

    end

  end
end

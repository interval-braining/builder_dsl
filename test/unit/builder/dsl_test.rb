require 'test_helper'

module BuilderDSL
  class Builder
    class DSLTest < MiniTest::Test

      context 'DSL methods' do

        setup do
          @struct = struct = Struct.new(:key, :value)
          @dict_builder = BuilderDSL.define do
            resource_class struct
            attribute(:key)
            attribute(:value)
          end
          @builder = builder = BuilderDSL.define
          @meta = BuilderDSL.send(:meta_builder)
          @lambda = lambda {|i| builder}
        end


        context '#attribute' do

          should 'raise ArgumentError unless attribute name provided' do
            assert_raises(ArgumentError) { BuilderDSL.define { attribute } }
          end


          should 'delegate calls to attr_name to receiver via receiver_method' do
            @meta.expects(:initialize_with).returns(@lambda)
            @builder.expects(:def_delegator).with(:'@instance.c', :b, :a,)
            BuilderDSL.define { attribute(:a, :b, :c) }
          end


          should 'delegate to attr_name= on receiver by default' do
            @meta.expects(:initialize_with).returns(@lambda)
            @builder.expects(:def_delegator).with(:@instance, :a=, :a,)
            BuilderDSL.define { attribute(:a) }
          end


          should 'delegate directly to the @instance by default' do
            @meta.expects(:initialize_with).returns(@lambda)
            @builder.expects(:def_delegator).with(:@instance, :a=, :a)
            BuilderDSL.define { attribute(:a) }
          end

        end


        context '#builder' do

          should 'raise an error unless a Builder class xor proc is provided' do
            assert_raises(ArgumentError) do
              BuilderDSL.define { builder(:foo) }
            end

            dict_builder = @dict_builder
            assert_raises(ArgumentError) do
              BuilderDSL.define { builder(:foo, :foo=, dict_builder) { |i| } }
            end
          end


          should 'raise an error unless an attr name is provided' do
            assert_raises(ArgumentError) { BuilderDSL.define { builder } }
          end


          should 'take a custom receiver method name' do
            dict_builder, struct = @dict_builder, @struct
            builder = BuilderDSL.define do
              resource_class struct
              builder(:foo, :value=, dict_builder)
            end
            instance = builder.new { foo { key(:a); value(:b) } }
            assert_equal :a, instance.value.key
            assert_equal :b, instance.value.value
          end


          should 'should accept a proc that is a Builder definition' do
            struct = @struct
            builder = BuilderDSL.define do
              resource_class struct
              builder(:foo, :value=) do |i|
                resource_class struct
                attribute :bar, :key=
              end
            end
            instance = builder.new { foo { bar :a } }
            assert_equal :a, instance.value.key
          end


          should 'accept a custom builder class' do
            dict_builder, struct = @dict_builder, @struct
            db = dict_builder.new
            dict_builder.expects(:new).returns(db)
            builder = BuilderDSL.define do
              resource_class struct
              builder(:foo, :value=, dict_builder)
            end
            instance = builder.new { foo { |i| } }
            assert_equal db, instance.value
          end


          should 'accept a custom receiver identifier' do
            dict_builder, struct = @dict_builder, @struct
            builder = BuilderDSL.define do
              resource_class struct
              builder(:value, :value=, dict_builder)
              builder(:foo, :value=, dict_builder, :value)
            end
            instance = builder.new do
              value { key(:a) }
              foo { |i| value(:b) }
            end
            assert_equal :b, instance.value.value.value
          end


          context 'builder generated instance method' do

            setup do
              dict_builder, struct = @dict_builder, @struct
              @builder_instance = BuilderDSL.define do
                resource_class struct
                builder(:foo, :value=, dict_builder)
              end
            end


            should 'raise ArgumentError if given static instance and block or neither' do
              assert_raises(ArgumentError) { @builder_instance.new { foo } }
              assert_raises(ArgumentError) do
                @builder_instance.new { foo(true) {|i| } }
              end
            end


            should 'pass a static instance to the receiver method of the receiver' do
              instance = @builder_instance.new { foo(true) }
              assert_equal true, instance.value
            end


            should 'evaluate builder definition and send instance to the receiver method of receiver' do
              instance = @builder_instance.new { foo { value(true) } }
              assert_equal true, instance.value.value
            end

          end

        end


        context '#delegate' do

          should 'raise ArgumentError unless method_name provided' do
            assert_raises(ArgumentError) do
              BuilderDSL.define do
                delegate
              end
            end
          end


          should 'create a delegator to @instance.receiver.receiver_method aliased to method_name' do
            @meta.expects(:initialize_with).returns(@lambda)
            @builder.expects(:def_delegator).with(:'@instance.receiver', :receiver_method, :method_name)
            BuilderDSL.define do
              delegate(:method_name, :receiver_method, :receiver)
            end
          end


          should 'create a delegator to @instance.receiver_method aliased to method_name by default' do
            @meta.expects(:initialize_with).returns(@lambda)
            @builder.expects(:def_delegator).with(:@instance, :receiver_method, :method_name)
            BuilderDSL.define do
              delegate(:method_name, :receiver_method)
            end
          end


          should 'create a delegator to @instance.method_name aliased to method_name by default' do
            @meta.expects(:initialize_with).returns(@lambda)
            @builder.expects(:def_delegator).with(:@instance, :method_name, :method_name)
            BuilderDSL.define do
              delegate(:method_name)
            end
          end

        end

      end

    end
  end
end

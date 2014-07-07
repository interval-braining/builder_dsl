require 'test_helper'

class BuilderDSLTest < MiniTest::Test

  DEFAULT_DEF_BUILDER = BuilderDSL::DEFAULT_DEFINITION_BUILDER

  context 'BuilderDSL' do

    should 'be defined' do
      assert BuilderDSL
    end


    context 'Factory methods' do

      context '::define' do

        setup do
          @builder = BuilderDSL.define
        end


        should 'return a default Builder instance when no block given' do
          assert_kind_of Class, @builder
          assert @builder.ancestors.include?(BuilderDSL::Builders::BuilderBuilder::InstanceMethods)
        end


        should 'return an evaluated Builder instance when block is given' do
          struct = Struct.new(:key, :value)

          dict_builder = BuilderDSL.define do |b|
            resource_class struct
            attribute :key
            attribute :value
          end

          struct_dict_builder = BuilderDSL.define do |i|
            resource_class struct
            attribute(:key)
            builder(:value, :value=, dict_builder)
            delegate(:inner_value, :value=, 'value')
          end

          dict = dict_builder.build do |b|
            key(:a)
            value(:b)
          end
          assert_equal :a, dict.key
          assert_equal :b, dict.value

            struct_dict = struct_dict_builder.build do |b|
              key(:c)
              value do
                key(:d)
              end
              inner_value(:e)
            end
          assert_equal :c, struct_dict.key
          assert_equal :d, struct_dict.value.key
          assert_equal :e, struct_dict.value.value
        end

      end

    end


    context 'configuration' do

      setup do
        @original_config = BuilderDSL.default_definition_builder
        @simple_builder = Class.new do
          attr_accessor :args, :block
          def self.build(*args)
            instance = new
            instance.block = Proc.new if block_given?
            instance.args = args
            instance
          end
        end
      end


      teardown do
        BuilderDSL.default_definition_builder = @original_config
      end


      context '::default_definition_builder' do

        should 'return @default_defintion_builder or DEFAULT_DEFINITION_BUILDER' do
          BuilderDSL.default_definition_builder = nil
          assert_equal BuilderDSL.default_definition_builder, DEFAULT_DEF_BUILDER
          BuilderDSL.default_definition_builder = @simple_builder
          assert_equal BuilderDSL.default_definition_builder, @simple_builder
        end

      end


      context '::default_definition_builder=' do

        [nil, false].each do |value|
          should "accept #{value.inspect} to reset the default_definition_builder" do
            BuilderDSL.default_definition_builder = @simple_builder
            assert_equal BuilderDSL.default_definition_builder, @simple_builder
            BuilderDSL.default_definition_builder = value
            assert_equal BuilderDSL.default_definition_builder, DEFAULT_DEF_BUILDER
          end
        end


        should 'raise an error if the proivded object does not respond to #build' do
          BuilderDSL.default_definition_builder = nil
          assert_equal BuilderDSL.default_definition_builder, DEFAULT_DEF_BUILDER
          assert_raises(ArgumentError) do
            BuilderDSL.default_definition_builder = Class.new
          end
        end


        should 'set the default_definition_builder' do
          BuilderDSL.default_definition_builder = nil
          assert_equal BuilderDSL.default_definition_builder, DEFAULT_DEF_BUILDER
          BuilderDSL.default_definition_builder = @simple_builder
          assert_equal BuilderDSL.default_definition_builder, @simple_builder
        end

      end

    end

  end

end

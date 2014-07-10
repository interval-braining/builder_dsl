require 'test_helper'

class BuildingBlocksTest < MiniTest::Test

  DEFAULT_BUILDER = BuildingBlocks::DEFAULT_DEFINITION_BUILDER

  context 'BuildingBlocks' do

    should 'be defined' do
      assert BuildingBlocks
    end


    context 'Factory methods' do

      context '::build' do

        setup do
          @builder = BuildingBlocks.build
        end


        should 'return a default Builder instance when no block given' do
          assert_kind_of Class, @builder
          assert @builder.ancestors.include?(BuildingBlocks::Builders::BuilderBuilder::InstanceMethods)
        end


        should 'return an evaluated Builder instance when block is given' do
          struct = Struct.new(:key, :value)

          dict_builder = BuildingBlocks.build do |b|
            resource_class struct
            attribute :key
            attribute :value
          end

          struct_dict_builder = BuildingBlocks.build do |i|
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
        @original_config = BuildingBlocks.default_builder
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
        BuildingBlocks.default_builder = @original_config
      end


      context '::default_builder' do

        should 'return @default_defintion_builder or DEFAULT_DEFINITION_BUILDER' do
          BuildingBlocks.default_builder = nil
          assert_equal BuildingBlocks.default_builder, DEFAULT_BUILDER
          BuildingBlocks.default_builder = @simple_builder
          assert_equal BuildingBlocks.default_builder, @simple_builder
        end

      end


      context '::default_builder=' do

        [nil, false].each do |value|
          should "accept #{value.inspect} to reset the default_builder" do
            BuildingBlocks.default_builder = @simple_builder
            assert_equal BuildingBlocks.default_builder, @simple_builder
            BuildingBlocks.default_builder = value
            assert_equal BuildingBlocks.default_builder, DEFAULT_BUILDER
          end
        end


        should 'raise an error if the proivded object does not respond to #build' do
          BuildingBlocks.default_builder = nil
          assert_equal BuildingBlocks.default_builder, DEFAULT_BUILDER
          assert_raises(ArgumentError) do
            BuildingBlocks.default_builder = Class.new
          end
        end


        should 'set the default_builder' do
          BuildingBlocks.default_builder = nil
          assert_equal BuildingBlocks.default_builder, DEFAULT_BUILDER
          BuildingBlocks.default_builder = @simple_builder
          assert_equal BuildingBlocks.default_builder, @simple_builder
        end

      end

    end

  end

end

require 'test_helper'

class BuilderDSLTest < MiniTest::Test

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
          begin
              value do
                key(:d)
              end
          rescue => e
            binding.pry
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

      context '::default_definition_builder' do

        should 'return @default_defintion_builder or DEFAULT_DEFINITION_BUILDER' do
          original = BuilderDSL.default_definition_builder

          BuilderDSL.default_definition_builder = nil
          assert_equal BuilderDSL.default_definition_builder, BuilderDSL::DEFAULT_DEFINITION_BUILDER
          BuilderDSL.default_definition_builder = Hash.new
          assert_equal BuilderDSL.default_definition_builder, Hash.new

          BuilderDSL.default_definition_builder = original
        end

      end

    end

  end

end

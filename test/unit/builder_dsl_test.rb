require 'test_helper'

class BuilderDSLTest < MiniTest::Test

  context 'BuilderDSL' do

    should 'be defined' do
      assert BuilderDSL
    end

  end


  context 'Factory methods' do

    context '::define' do

      setup do
        @builder = BuilderDSL.define
      end


      should 'return a default Builder instance when no block given' do
        assert_kind_of Class, @builder
        assert @builder.ancestors.include?(BuilderDSL::Builder)
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

        dict = dict_builder.new do |b|
          key(:a)
          value(:b)
        end
        assert_equal :a, dict.key
        assert_equal :b, dict.value

        struct_dict = struct_dict_builder.new do |b|
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


    context '::meta_builder' do

      setup do
        @builder = BuilderDSL.send(:meta_builder)
      end


      should 'have resource_class of Builder' do
        assert_equal BuilderDSL::Builder, @builder.resource_class
      end


      should 'define attribute for resource_class' do
        builder = @builder.new do
          resource_class Hash
        end
        assert_equal Hash, builder.resource_class
      end


      should 'delegate calls to #attribute to Builder instance' do
        builder = @builder.new
        @builder.resource_class.expects(:initialize_with).returns(lambda { |i| builder })
        builder.expects(:attribute).with(:a)

        @builder.new { |i| attribute(:a) }
      end


      should 'delegate calls to #builder to Builder instance' do
        builder = @builder.new
        @builder.resource_class.expects(:initialize_with).returns(lambda { |i| builder })
        builder.expects(:builder).with(:builder_attr)

        @builder.new { |i| builder(:builder_attr) }
      end


      should 'delegate calls to #delegate to Builder instance' do
        builder = @builder.new
        @builder.resource_class.expects(:initialize_with).returns(lambda { |i| builder })
        builder.expects(:delegate).with(:attr)

        @builder.new { |i| delegate(:attr) }
      end

    end

  end

end

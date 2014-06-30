module BuilderDSL
  module FactoryMethods

    def define
      block_given? ? meta_builder.new(&Proc.new) : meta_builder.new
    end

    private
    def meta_builder
      @meta_builder ||= begin
        meta_builder = Builder.new do
          self.resource_class = Builder
          attribute(:resource_class)
          delegate(:attribute)
          delegate(:builder)
          delegate(:delegate)
        end
        meta_builder
      end
    end
  end
end

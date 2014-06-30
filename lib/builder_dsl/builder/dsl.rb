module BuilderDSL
  class Builder
    module DSL
      include Forwardable

      def attribute(attr_name, receiver_method = :"#{attr_name}=", receiver = nil)
        delegate(attr_name, receiver_method, receiver)
      end

      def builder(attr_name, receiver_method = "#{attr_name}=", builder_class = nil, receiver = nil)
        if block_given? ^ builder_class.nil?
          raise ArgumentError, 'Either a builder class or a builder definition is required'
        elsif block_given?
          builder_class = BuilderDSL.define(&Proc.new)
        end

        if receiver.nil? || receiver == ''
          receiver_proc = lambda { |i| @instance }
        elsif receiver.is_a?(Symbol) || receiver.is_a?(String)
          receiver_proc = instance_eval("lambda { |i| @instance.#{receiver} }")
        end

        define_method(attr_name) do |static_instance = nil, &block|
          begin
            if block.nil? ^ !!static_instance
              raise ArgumentError, 'Either a static instance or a builder proc is required'
            end
            receiver = instance_eval(&receiver_proc) if receiver_proc
            instance = block.nil? ? static_instance : builder_class.new(&block)
            receiver.send(receiver_method, instance)
          rescue Exception
            $@.delete_if{|s| %r"#{Regexp.quote(__FILE__)}"o =~ s}
            ::Kernel::raise
          end
        end
      end

      def delegate(method_name, receiver_method = method_name, receiver = nil)
        receiver = receiver.nil? || receiver.empty? ? :@instance : :"@instance.#{receiver}"
        def_delegator(receiver, receiver_method, method_name)
      end
    end
  end
end

module Mocktail
  class RedefinesSingletonMethods
    def initialize
      @handles_dry_call = HandlesDryCall.new
    end

    def redefine(type)
      type_replacement = TopShelf.instance.type_replacement_for(type)
      return unless type_replacement.replacement_methods.nil?

      type_replacement.original_methods = type.singleton_methods.map { |name|
        type.method(name)
      } - [type_replacement.replacement_new]

      handles_dry_call = @handles_dry_call
      type_replacement.replacement_methods = type_replacement.original_methods.map { |original_method|
        type.singleton_class.send(:undef_method, original_method.name)
        type.define_singleton_method original_method.name, ->(*args, **kwargs, &block) {
          if TopShelf.instance.singleton_methods_replaced?(type)
            handles_dry_call.handle(Call.new(
              singleton: true,
              double: type,
              original_type: type,
              dry_type: type,
              method: original_method.name,
              original_method: original_method,
              args: args,
              kwargs: kwargs,
              block: block
            ))
          else
            original_method.call(*args, **kwargs, &block)
          end
        }
        type.singleton_method(original_method.name)
      }
    end
  end
end

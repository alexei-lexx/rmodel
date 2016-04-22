module LazyRegistry
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def register(name)
      define_method name do
        @lazy_registry ||= {}
        if @lazy_registry.key?(name)
          @lazy_registry[name]
        else
          @lazy_registry[name] = block_given? ? yield : nil
        end
      end
    end
  end
end

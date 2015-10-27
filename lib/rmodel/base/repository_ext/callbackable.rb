module Rmodel::Base
  module RepositoryExt
    module Callbackable

      def self.included(base)
        base.extend ClassMethods
      end

      def self.prepended(base)
        base.extend ClassMethods
      end

      def insert(object)
        run_callbacks :before_insert, object
        super
        run_callbacks :after_insert, object
      end

      def update(object)
        run_callbacks :before_update, object
        super
        run_callbacks :after_update, object
      end

      def remove(object)
        run_callbacks :before_remove, object
        super
        run_callbacks :after_remove, object
      end

      private

      def run_callbacks(chain_name, object)
        chain = self.class.callbacks_chain.try(:[], chain_name) || []
        chain.each do |callable_or_method_name|
          if callable_or_method_name.respond_to?(:call)
            callable_or_method_name.call(object)
          else
            send callable_or_method_name, object
          end
        end
      end

      module ClassMethods
        attr_accessor :callbacks_chain

        [
          :before_insert, :after_insert,
          :before_update, :after_update,
          :before_remove, :after_remove
        ].each do |chain_name|
          define_method chain_name do |method_name = nil, &block|
            add_to_callbacks_chain(chain_name, method_name || block)
          end
        end

        private

        def add_to_callbacks_chain(chain_name, callable_or_method_name)
          self.callbacks_chain ||= {}
          self.callbacks_chain[chain_name] ||= []
          self.callbacks_chain[chain_name] << callable_or_method_name
        end
      end
    end
  end
end

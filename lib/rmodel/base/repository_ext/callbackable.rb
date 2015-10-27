module Rmodel::Base
  module RepositoryExt
    module Callbackable

      def self.prepended(base)
        base.extend ClassMethods
      end

      def insert(object)
        run_callbacks :before_insert, object
        super
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

        def before_insert(method_name = nil, &block)
          add_to_callbacks_chain(:before_insert, method_name || block)
        end

        def after_insert(&block)
        end

        def before_update(&block)
        end

        def after_update(&block)
        end

        def before_remove(&block)
        end

        def after_remove(&block)
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

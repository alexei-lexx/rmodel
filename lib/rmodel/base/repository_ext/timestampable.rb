module Rmodel
  module Base
    module RepositoryExt
      module Timestampable
        def insert_one(object)
          object.created_at = Time.now if able_to_set_created_at?(object)
          super
        end

        def update(object)
          object.updated_at = Time.now if able_to_set_updated_at?(object)
          super
        end

        private

        def able_to_set_created_at?(object)
          object.respond_to?(:created_at=) &&
            object.respond_to?(:created_at) &&
            object.created_at.nil?
        end

        def able_to_set_updated_at?(object)
          object.respond_to?(:updated_at=)
        end
      end
    end
  end
end

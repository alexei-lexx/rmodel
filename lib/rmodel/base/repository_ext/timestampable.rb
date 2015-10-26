module Rmodel::Base
  module RepositoryExt
    module Timestampable
      def insert(object)
        if object.respond_to?(:created_at) && object.respond_to?(:created_at=)
          object.created_at ||= Time.now
        end
        super
      end

      def update(object)
        if object.respond_to?(:updated_at) && object.respond_to?(:updated_at=)
          object.updated_at = Time.now
        end
        super
      end
    end
  end
end

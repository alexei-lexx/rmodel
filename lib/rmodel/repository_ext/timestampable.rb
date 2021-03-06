module Rmodel
  module RepositoryExt
    module Timestampable
      def insert_one(object)
        time = now
        object.created_at = time if able_to_set_created_at?(object)
        object.updated_at = time if able_to_set_updated_at?(object)
        super
      end

      def update(object)
        object.updated_at = now if able_to_set_updated_at?(object)
        super
      end

      private

      def able_to_set_created_at?(object)
        object.respond_to?(:created_at=) && object.created_at.nil?
      end

      def able_to_set_updated_at?(object)
        object.respond_to?(:updated_at=)
      end

      def now
        Time.try(:current) || Time.now
      end
    end
  end
end

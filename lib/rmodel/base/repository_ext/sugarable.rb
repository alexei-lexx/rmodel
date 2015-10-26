module Rmodel::Base
  module RepositoryExt
    module Sugarable
      def find!(id)
        find(id) or raise Rmodel::NotFound.new(self, { id: id })
      end

      def save(object)
        if object.id.nil?
          insert(object)
        else
          update(object)
        end
      end
    end
  end
end

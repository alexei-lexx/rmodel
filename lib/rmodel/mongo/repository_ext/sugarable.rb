module Rmodel::Mongo
  module RepositoryExt
    module Sugarable
      def find!(id)
        find(id) or raise Rmodel::NotFound.new(self, { id: id })
      end
    end
  end
end

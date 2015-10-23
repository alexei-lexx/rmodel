require 'origin'

module Rmodel::Mongo
  module RepositoryExt
    class Query
      include Enumerable

      class Queryable
        include Origin::Queryable
      end

      def initialize(repo, parent_queryable = nil)
        @repo = repo
        @queryable = parent_queryable || Queryable.new
      end

      def each(&block)
        @repo.execute_query(@queryable).each(&block)
        self
      end
    end
  end
end

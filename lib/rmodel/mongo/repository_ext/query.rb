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

      def method_missing(method, *args, &block)
        if @repo.class.scopes.has_key?(method)
          new_queriable = @queryable.instance_eval &@repo.class.scopes[method]
          Query.new(@repo, new_queriable)
        else
          super
        end
      end

      def each(&block)
        @repo.execute_query(@queryable).each(&block)
        self
      end
    end
  end
end

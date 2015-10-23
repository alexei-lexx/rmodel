require 'origin'

module Rmodel::Mongo
  module RepositoryExt
    class Query
      include Enumerable

      class Queryable
        include Origin::Queryable
      end

      def initialize(repo, queryable = nil)
        @repo = repo
        @queryable = queryable || Queryable.new
      end

      def each(&block)
        @repo.execute_query(@queryable.selector, @queryable.options).each(&block)
        self
      end

      def self.define_scope(name, &block)
        define_method name do |*args|
          new_queryable = @queryable.instance_exec(*args, &block)
          self.class.new(@repo, new_queryable)
        end
      end
    end
  end
end

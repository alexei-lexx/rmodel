module Rmodel
  module Base
    class QueryBuilder
      include Enumerable

      def initialize(repo, query)
        @repo = repo
        @query = query
      end

      def each(&block)
        @repo.find_by_query(@query).each(&block)
        self
      end

      def remove
        @repo.remove_by_query(@query)
      end

      def destroy
        @repo.destroy_by_query(@query)
      end

      def scope(&block)
        new_query = @query.instance_eval(&block)
        self.class.new(@repo, new_query)
      end

      def self.define_scope(name, &block)
        define_method name do |*args|
          new_query = @query.instance_exec(*args, &block)
          self.class.new(@repo, new_query)
        end
      end
    end
  end
end

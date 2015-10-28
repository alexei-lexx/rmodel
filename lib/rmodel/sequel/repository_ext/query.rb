require 'origin'

module Rmodel::Sequel
  module RepositoryExt
    class Query
      include Enumerable

      def initialize(repo, dataset)
        @repo = repo
        @dataset = dataset
      end

      def each(&block)
        @repo.find_by_query(@dataset).each(&block)
        self
      end

      def remove
        @dataset.delete
      end

      def self.define_scope(name, &block)
        define_method name do |*args|
          new_dataset = @dataset.instance_exec(*args, &block)
          self.class.new(@repo, new_dataset)
        end
      end
    end
  end
end

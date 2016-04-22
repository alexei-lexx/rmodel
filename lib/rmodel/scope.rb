module Rmodel
  class Scope
    include Enumerable

    attr_reader :raw_query

    def initialize(repo, raw_query)
      @repo = repo
      @raw_query = raw_query
    end

    def each(&block)
      @repo.find_all(self).each(&block)
    end

    def delete_all
      @repo.delete_all(self)
    end

    def destroy_all
      @repo.destroy_all(self)
    end

    def self.define_scope(name, &block)
      define_method name do |*args|
        new_raw_query = @raw_query.instance_exec(*args, &block)
        self.class.new(@repo, new_raw_query)
      end
    end
  end
end

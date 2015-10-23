module Rmodel
  class NotFound < StandardError
    def initialize(repo_klass, criteria)
      super("#{repo_klass.class.name} can't find an object by #{criteria}")
    end
  end
end

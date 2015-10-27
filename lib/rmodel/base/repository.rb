require 'rmodel/base/repository_ext/sugarable'
require 'rmodel/base/repository_ext/timestampable'

module Rmodel::Base
  class Repository
    include RepositoryExt::Sugarable

    def self.inherited(subclass)
      subclass.send :prepend, RepositoryExt::Timestampable
    end
  end
end

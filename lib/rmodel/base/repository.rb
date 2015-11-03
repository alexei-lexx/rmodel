require 'rmodel/base/repository_ext/sugarable'
require 'rmodel/base/repository_ext/timestampable'
require 'rmodel/base/repository_ext/queryable'

module Rmodel::Base
  class Repository
    include RepositoryExt::Sugarable
    include RepositoryExt::Queryable

    def insert(*args)
      if args.length == 1
        if args.first.is_a?(Array)
          args.first.each do |object|
            insert_one(object)
          end
        else
          insert_one(args.first)
        end
      else
        args.each do |object|
          insert_one(object)
        end
      end
    end

    def remove(object)
      warn '#remove is deprecated, use #destroy instead'
      destroy(object)
    end

    def self.inherited(subclass)
      subclass.send :prepend, RepositoryExt::Timestampable
    end
  end
end

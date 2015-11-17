require 'rmodel/base/repository_ext/sugarable'
require 'rmodel/base/repository_ext/timestampable'
require 'rmodel/base/repository_ext/queryable'

module Rmodel::Base
  class Repository
    include RepositoryExt::Sugarable
    include RepositoryExt::Queryable

    def initialize(mapper)
      @mapper = mapper || self.class.declared_mapper ||
                self.class.mapper_by_convention or
                raise ArgumentError.new('Mapper can not be guessed')
    end

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

    class << self
      def inherited(subclass)
        subclass.send :prepend, RepositoryExt::Timestampable
      end

      attr_reader :declared_mapper

      def mapper(mapper_klass)
        @declared_mapper = mapper_klass.new
      end

      def mapper_by_convention
        if name =~ /(.*)Repository$/
          ActiveSupport::Inflector.constantize($1 + 'Mapper').new
        end
      rescue NameError
        nil
      end
    end
  end
end

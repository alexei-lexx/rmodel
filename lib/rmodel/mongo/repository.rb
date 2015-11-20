require 'rmodel/mongo/repository_ext/queryable'

module Rmodel
  module Mongo
    class Repository < Rmodel::Base::Repository
      include RepositoryExt::Queryable

      def initialize(client = nil, collection = nil, mapper = nil)
        super(:mongo, client, mapper)

        @collection = collection || self.class.declared_collection ||
                      self.class.collection_by_convention
        fail ArgumentError, 'Collection can not be guessed' unless @collection

        @source = Source.new(@client, @collection)
      end

      def find(id)
        query.scope { where(_id: id) }.first
      end

      class << self
        attr_reader :declared_collection

        def collection(name)
          @declared_collection = name
        end

        def collection_by_convention
          return unless name =~ /(.*)Repository$/
          model_name = Regexp.last_match(1)
          ActiveSupport::Inflector.tableize(model_name).to_sym
        end
      end
    end
  end
end

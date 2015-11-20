module Rmodel
  module Mongo
    class Repository < Rmodel::Base::Repository
      def initialize(connection = nil, collection = nil, mapper = nil)
        connection ||= self.class.declared_connection_name || :default
        collection ||= self.class.declared_collection ||
                       self.class.collection_by_convention

        super Source.new(connection, collection), mapper
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

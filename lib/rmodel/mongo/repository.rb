module Rmodel
  module Mongo
    class Repository < Rmodel::Base::Repository
      def initialize(connection = nil, collection = nil, mapper = nil)
        connection_name = self.class.declared_connection_name || :default
        connection ||= Rmodel.setup.connection(connection_name)
        collection ||= self.class.declared_collection ||
                       self.class.collection_by_convention

        super Source.new(connection, collection), mapper
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

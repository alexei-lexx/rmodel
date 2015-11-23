module Rmodel
  module Sequel
    class Repository < Rmodel::Base::Repository
      def initialize(connection = nil, table = nil, mapper = nil)
        connection_name = self.class.declared_connection_name || :default
        connection ||= Rmodel.setup.connection(connection_name)
        table ||= self.class.declared_table || self.class.table_by_convention

        super Source.new(connection, table), mapper
      end

      class << self
        attr_reader :declared_table

        def table(name)
          @declared_table = name
        end

        def table_by_convention
          return unless name =~ /(.*)Repository$/
          model_name = Regexp.last_match(1)
          ActiveSupport::Inflector.tableize(model_name).to_sym
        end
      end
    end
  end
end

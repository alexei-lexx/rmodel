module Rmodel
  module Sequel
    class Repository < Rmodel::Base::Repository
      def initialize(client = nil, table = nil, mapper = nil)
        client = client || self.class.declared_client_name || :default
        table = table || self.class.declared_table ||
                self.class.table_by_convention

        super Source.new(client, table), mapper
      end

      def find(id)
        query.scope { where(id: id) }.first
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

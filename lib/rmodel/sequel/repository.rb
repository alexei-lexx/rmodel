require 'sequel'
require 'rmodel/sequel/repository_ext/queryable'

module Rmodel
  module Sequel
    class Repository < Rmodel::Base::Repository
      include RepositoryExt::Queryable

      def initialize(client = nil, table = nil, mapper = nil)
        super(:sequel, client, mapper)

        @table = table || self.class.declared_table ||
                 self.class.table_by_convention
        fail ArgumentError, 'Table can not be guessed' unless @table
      end

      def find(id)
        result = @client[@table].where(id: id).first
        result && @mapper.deserialize(result)
      end

      def insert_one(object)
        id = @client[@table].insert(@mapper.serialize(object, true))
        object.id ||= id
      end

      def update(object)
        @client[@table].where(id: object.id)
          .update(@mapper.serialize(object, false))
      end

      def destroy(object)
        @client[@table].where(id: object.id).delete
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

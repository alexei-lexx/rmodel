require 'sequel'
require 'rmodel/sequel/repository_ext/queryable'

module Rmodel::Sequel
  class Repository < Rmodel::Base::Repository
    include RepositoryExt::Queryable

    def initialize(client = nil, table = nil, mapper = nil)
      @client = client || Rmodel.setup.establish_sequel_client(self.class.client_name || :default) or
                raise ArgumentError.new('Client driver is not setup')

      @table = table || self.class.setting_table ||
               self.class.table_by_convention or
               raise ArgumentError.new('Table can not be guessed')

      @mapper = mapper || self.class.declared_mapper ||
                self.class.mapper_by_convention or
                raise ArgumentError.new('Mapper can not be guessed')
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
      @client[@table].where(id: object.id).update(@mapper.serialize(object, false))
    end

    def destroy(object)
      @client[@table].where(id: object.id).delete
    end

    class << self
      attr_reader :client_name, :setting_table, :declared_mapper

      def client(name)
        @client_name = name
      end

      def table(name)
        @setting_table = name
      end

      def table_by_convention
        if name =~ /(.*)Repository$/
          ActiveSupport::Inflector.tableize($1).to_sym
        end
      end

      def mapper_by_convention
        if name =~ /(.*)Repository$/
          ActiveSupport::Inflector.constantize($1 + 'Mapper').new
        end
      rescue NameError
        nil
      end

      def mapper(mapper_klass)
        @declared_mapper = mapper_klass.new
      end
    end
  end
end

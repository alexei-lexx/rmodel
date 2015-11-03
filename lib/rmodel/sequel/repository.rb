require 'sequel'
require 'rmodel/sequel/repository_ext/queryable'

module Rmodel::Sequel
  class Repository < Rmodel::Base::Repository
    include RepositoryExt::Queryable

    def initialize(client = nil, table = nil, factory = nil)
      @client = client || Rmodel.setup.establish_sequel_client(self.class.client_name || :default) or
                raise ArgumentError.new('Client driver is not setup')

      @table = table || self.class.setting_table ||
               self.class.table_by_convention or
               raise ArgumentError.new('Table can not be guessed')

      @factory = factory || self.class.setting_factory or
                 raise ArgumentError.new('Factory can not be guessed')
    end

    def find(id)
      result = @client[@table].where(id: id).first
      result && @factory.to_object(result)
    end

    def insert(object)
      id = @client[@table].insert(@factory.toHash(object, true))
      object.id ||= id
    end

    def update(object)
      @client[@table].where(id: object.id).update(@factory.toHash(object, false))
    end

    def destroy(object)
      @client[@table].where(id: object.id).delete
    end

    class << self
      attr_reader :client_name, :setting_table, :setting_factory

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

      def simple_factory(klass, *attributes)
        @setting_factory = SimpleFactory.new(klass, *attributes)
      end
    end
  end
end

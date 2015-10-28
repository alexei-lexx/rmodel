require 'sequel'
require 'rmodel/base/repository'

module Rmodel::Sequel
  class Repository < Rmodel::Base::Repository

    def initialize(client, table, factory)
      @client = client
      @table = table
      @factory = factory
    end

    def find(id)
      result = @client[@table].where(id: id).first
      result && @factory.fromHash(result)
    end

    def insert(object)
      id = @client[@table].insert(@factory.toHash(object, true))
      object.id ||= id
    end

    def update(object)
      @client[@table].where(id: object.id).update(@factory.toHash(object, false))
    end

    def remove(object)
      @client[@table].where(id: object.id).delete
    end
  end
end

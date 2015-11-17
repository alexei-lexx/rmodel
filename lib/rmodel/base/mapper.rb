module Rmodel::Base
  class Mapper
    def initialize
      if model.nil?
        raise ArgumentError.new('Model was not declared')
      end
      self.primary_key = :id
    end

    private

    attr_accessor :primary_key

    def model
      self.class.declared_model || self.class.model_by_convention
    end

    class << self
      attr_reader :declared_model

      def model(klass)
        @declared_model = klass
      end

      def model_by_convention
        if name =~ /(.*)Mapper$/
          ActiveSupport::Inflector.constantize($1).new
        end
      rescue NameError
        nil
      end
    end
  end
end

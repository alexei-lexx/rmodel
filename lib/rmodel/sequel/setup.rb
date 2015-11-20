module Rmodel
  module Sequel
    module Setup
      def establish_sequel_connection(name)
        config = @connections_config[name]
        config && establish_connection(name) { ::Sequel.connect(config) }
      end
    end
  end
end

module Rmodel
  class Setup
    include Rmodel::Sequel::Setup
  end
end

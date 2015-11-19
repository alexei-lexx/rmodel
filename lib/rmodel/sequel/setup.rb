module Rmodel
  module Sequel
    module Setup
      def establish_sequel_client(name)
        config = @clients_config[name]
        config && establish_client(name) { ::Sequel.connect(config) }
      end
    end
  end
end

module Rmodel
  class Setup
    include Rmodel::Sequel::Setup
  end
end

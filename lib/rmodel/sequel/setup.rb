module Rmodel::Sequel
  module Setup
    def establish_sequel_client(name)
      config = @clients_config[name]
      config && establish_client(name) { Sequel.connect(config) }
    end
  end
end

class Rmodel::Setup
  include Rmodel::Sequel::Setup
end

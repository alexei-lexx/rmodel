module Rmodel::Mongo
  module Setup
    def establish_mongo_client(name)
      config = @clients_config[name]
      if config
        options = config.dup
        options.delete :hosts

        establish_client(name) { Mongo::Client.new(config[:hosts], options) }
      end
    end
  end
end

class Rmodel::Setup
  include Rmodel::Mongo::Setup
end

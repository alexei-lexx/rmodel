module Rmodel
  module Mongo
    module Setup
      def establish_mongo_client(name)
        config = @clients_config[name]
        return unless config

        options = config.dup
        options.delete :hosts

        establish_client(name) { ::Mongo::Client.new(config[:hosts], options) }
      end
    end
  end
end

module Rmodel
  class Setup
    include Rmodel::Mongo::Setup
  end
end

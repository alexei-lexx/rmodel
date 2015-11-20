module Rmodel
  module Mongo
    module Setup
      def establish_mongo_connection(name)
        config = @connections_config[name]
        return unless config

        options = config.dup
        options.delete :hosts

        establish_connection(name) do
          ::Mongo::Client.new(config[:hosts], options)
        end
      end
    end
  end
end

module Rmodel
  class Setup
    include Rmodel::Mongo::Setup
  end
end

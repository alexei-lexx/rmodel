require 'singleton'

module Rmodel
  class Setup
    include Singleton

    def initialize
      @connections_config = {}
      @established_connections = {}
    end

    def connection(name, config)
      @connections_config[name] = config
    end

    def clear
      @connections_config.clear
      @established_connections.clear
    end

    private

    def establish_connection(name)
      @established_connections[name] ||= yield
    end
  end

  def self.setup(&block)
    Setup.instance.instance_eval(&block) if block
    Setup.instance
  end
end

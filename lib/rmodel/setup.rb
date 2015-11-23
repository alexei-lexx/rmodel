require 'singleton'

module Rmodel
  class Setup
    include Singleton

    def initialize
      @connections_config = {}
      @established_connections = {}
    end

    def connection(name, &block)
      if block_given?
        @connections_config[name] = block
      else
        establish_connection(name)
      end
    end

    def clear
      @connections_config.clear
      @established_connections.clear
    end

    private

    def establish_connection(name)
      return nil unless @connections_config[name]
      @established_connections[name] ||= @connections_config[name].call
    end
  end

  def self.setup(&block)
    Setup.instance.instance_eval(&block) if block
    Setup.instance
  end
end

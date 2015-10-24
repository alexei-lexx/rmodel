require 'singleton'

module Rmodel
  class Setup
    include Singleton

    def initialize
      @clients_config = {}
      @established_clients = {}
    end

    def client(name, config)
      @clients_config[name] = config
    end

    def clear
      @clients_config.clear
    end

    private

    def establish_client(name)
      @established_clients[name] ||= yield
    end
  end

  def self.setup(&block)
    if block
      Setup.instance.instance_eval &block
    end
    Setup.instance
  end
end

require 'singleton'

module Rmodel
  class Setup
    include Singleton

    def initialize
      @clients = {}
    end

    attr_reader :clients

    def client(name, config)
      @clients[name] = config
    end

    def clear
      @clients.clear
    end
  end

  def self.setup(&block)
    if block
      Setup.instance.instance_eval &block
    end
    Setup.instance
  end
end

module Rmodel
  class UniHash < SimpleDelegator
    def initialize(hash, key_op)
      super(hash)
      @key_op = key_op
    end

    def [](key)
      super(key.public_send(@key_op))
    end

    def []=(key, value)
      super(key.public_send(@key_op), value)
    end
  end
end

module Rmodel::Sessions
  attr_reader :sessions

  def self.extended(base)
    base.instance_variable_set('@sessions', {})
  end
end

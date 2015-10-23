require 'rmodel/version'
require 'rmodel/setup'
require 'rmodel/sessions'
require 'rmodel/errors'
require 'rmodel/mongo/simple_factory'
require 'rmodel/mongo/repository'

module Rmodel
  extend Rmodel::Sessions
end

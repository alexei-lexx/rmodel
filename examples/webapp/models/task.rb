require 'active_model'

class Task
  include ActiveModel::Validations

  attr_accessor :id, :title, :created_at, :updated_at

  validates :title, presence: true
end

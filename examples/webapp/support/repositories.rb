require './examples/webapp/support/sources'
require './examples/webapp/support/mappers'

module Repositories
  include LazyInjector
  include Sources
  include Mappers

  register :task_repo do
    TaskRepository.new(task_source, task_mapper)
  end
end

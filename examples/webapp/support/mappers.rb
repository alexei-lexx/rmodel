require 'lazy_injector'

module Mappers
  include LazyInjector

  register :task_mapper do
    Rmodel::Mongo::Mapper.new(Task)
                         .define_attribute(:title)
                         .define_timestamps
  end
end

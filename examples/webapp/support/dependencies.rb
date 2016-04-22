require './examples/webapp/support/lazy_registry'

module Dependencies
  include LazyRegistry

  register :task_repo do
    TaskRepository.new(task_source, task_mapper)
  end

  register :db do
    Mongo::Client.new(['localhost'], database: 'test')
  end

  register :task_source do
    Rmodel::Mongo::Source.new(db, :tasks)
  end

  register :task_mapper do
    Rmodel::Mongo::Mapper.new(Task)
                         .define_attribute(:title)
                         .define_timestamps
  end
end

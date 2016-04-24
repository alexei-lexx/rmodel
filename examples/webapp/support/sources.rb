require 'lazy_injector'

module Sources
  include LazyInjector

  register :db do
    Mongo::Client.new(['localhost'], database: 'test')
  end

  register :task_source do
    Rmodel::Mongo::Source.new(db, :tasks)
  end
end

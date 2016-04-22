require 'sinatra'
require './lib/rmodel'
require './examples/webapp/models/task'
require './examples/webapp/repositories/task_repository'

DB = Mongo::Client.new(['localhost'], database: 'test')
task_source = Rmodel::Mongo::Source.new(DB, :tasks)

task_mapper = Rmodel::Mongo::Mapper.new(Task)
                                   .define_attribute(:title)
                                   .define_timestamps

task_repo = TaskRepository.new(task_source, task_mapper)

get '/' do
  tasks = task_repo.fetch

  tasks = if params[:sort_by] == 'title'
            tasks.by_title
          elsif params[:sort_by] == 'recency'
            tasks.by_recency
          else
            tasks.by_title
          end

  erb :index, locals: { tasks: tasks.to_a }
end

post '/' do
  task = Task.new
  task.title = params['title']

  if task.valid?
    task_repo.save(task)
    redirect to "/?sort_by=#{params[:sort_by]}"
  else
    tasks = task_repo.fetch.to_a
    erb :index, locals: { tasks: tasks }
  end
end

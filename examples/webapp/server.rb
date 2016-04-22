require 'sinatra'
require './lib/rmodel'
require './examples/webapp/models/task'
require './examples/webapp/repositories/task_repository'
require './examples/webapp/support/dependencies'

include Dependencies

get '/' do
  tasks = task_repo.sorted(params[:sort_by])
  erb :index, locals: { tasks: tasks }
end

post '/' do
  task = Task.new
  task.title = params[:title]

  if task.valid?
    task_repo.save(task)
    redirect to "/?sort_by=#{params[:sort_by]}"
  else
    tasks = task_repo.sorted(params[:sort_by])
    erb :index, locals: { tasks: tasks }
  end
end

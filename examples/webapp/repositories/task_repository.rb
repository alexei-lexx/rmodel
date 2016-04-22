class TaskRepository < Rmodel::Repository
  scope(:by_title) { order_by(:title.asc) }
  scope(:by_recency) { order_by(:created_at.desc) }
end

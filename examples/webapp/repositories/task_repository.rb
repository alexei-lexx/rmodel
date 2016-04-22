class TaskRepository < Rmodel::Repository
  scope(:by_title) { order_by(:title.asc) }
  scope(:by_recency) { order_by(:created_at.desc) }

  def sorted(sort_by)
    if sort_by == 'title'
      fetch.by_title
    elsif sort_by == 'recency'
      fetch.by_recency
    else
      fetch.by_title
    end
  end
end

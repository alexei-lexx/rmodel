require 'rmodel'

DB = Sequel.connect(adapter: 'sqlite', database: 'rmodel_test.sqlite3')

DB.drop_table? :orders, :ordered_items
DB.create_table :orders do
  primary_key :id
  Time :created_at
  Float :total_price
end
DB.create_table :ordered_items do
  primary_key :id
  Integer :order_id
  String :product
end

Order = Struct.new(:id, :created_at, :total_price, :items)
OrderedItem = Struct.new(:product, :id, :order_id)

class OrderedItemMapper < Rmodel::Sequel::Mapper
  attributes :order_id, :product
end

class OrderMapper < Rmodel::Sequel::Mapper
  attributes :created_at, :total_price
end

class OrderRepository < Rmodel::Repository
  source do
    Rmodel::Sequel::Source.new(DB, :orders)
  end
  mapper OrderMapper
end

repo = OrderRepository.new

order = Order.new
order.total_price = 100
order.items = [
  OrderedItem.new('Guitar'),
  OrderedItem.new('Drums')
]

repo.insert(order)

p repo.find(order.id)

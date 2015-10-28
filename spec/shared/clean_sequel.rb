RSpec.shared_context 'clean sequel database' do
  let(:sequel_conn) { Sequel.sqlite('rmodel_test.sqlite3') }

  before(:all) do
    Mongo::Logger.logger.level = Logger::ERROR
    sequel_conn = Sequel.sqlite('rmodel_test.sqlite3')
    sequel_conn.drop_table?(:users, :things)
  end

  after { sequel_conn.drop_table?(:users, :things) }
end

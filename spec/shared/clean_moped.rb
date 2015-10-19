RSpec.shared_context 'clean mongodb database' do
  before(:all) do
    Mongo::Logger.logger.level = Logger::ERROR
    @mongo_client = Mongo::Client.new([ '127.0.0.1:27017' ], database: 'rmodel_test')
    @mongo_client.database.drop
  end
  after { @mongo_client.database.drop }
end

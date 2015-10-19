RSpec.shared_context 'clean mongodb database' do
  let(:mongo_session) { Mongo::Client.new([ '127.0.0.1:27017' ], database: 'rmodel_test') }

  before(:all) do
    Mongo::Logger.logger.level = Logger::ERROR
    mongo_session = Mongo::Client.new([ '127.0.0.1:27017' ], database: 'rmodel_test')
    mongo_session.database.drop
  end
  after { mongo_session.database.drop }
end

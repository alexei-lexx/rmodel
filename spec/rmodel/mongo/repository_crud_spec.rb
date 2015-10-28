RSpec.describe Rmodel::Mongo::Repository do
  it_behaves_like 'repository crud' do
    include_context 'clean mongo database'

    before do
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
    end
  end

  let(:factory) { Rmodel::Mongo::SimpleFactory.new(Thing, :name) }
  subject { ThingRepository.new(mongo_session, :things, factory) }
  let(:unique_constraint_error) { Mongo::Error::OperationFailure }

  def insert_record(id, columns)
    record = columns.dup
    record['_id'] = id
    mongo_session[:things].insert_one(record)
  end
end

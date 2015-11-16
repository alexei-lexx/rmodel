RSpec.describe Rmodel::Mongo::Repository do
  include_context 'clean mongo database'

  before do
    stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
  end

  it_behaves_like 'repository crud' do
    let(:mapper) { Rmodel::Mongo::SimpleMapper.new(Thing, :name) }
    subject { ThingRepository.new(mongo_session, :things, mapper) }
    let(:unique_constraint_error) { Mongo::Error::OperationFailure }

    def insert_record(id, doc)
      mongo_session[:things].insert_one(doc.merge('_id' => id))
    end
  end

  it_behaves_like 'sugarable repository' do
    subject do
      mapper = Rmodel::Mongo::SimpleMapper.new(Thing, :name)
      ThingRepository.new(mongo_session, :things, mapper)
    end
  end

  it_behaves_like 'timestampable repository' do
    let(:repo_w_timestamps) do
      mapper = Rmodel::Mongo::SimpleMapper.new(Thing, :name, :created_at, :updated_at)
      ThingRepository.new(mongo_session, :things, mapper)
    end

    let(:repo_wo_timestamps) do
      mapper = Rmodel::Mongo::SimpleMapper.new(Thing, :name)
      ThingRepository.new(mongo_session, :things, mapper)
    end
  end
end

RSpec.describe Rmodel::Mongo::Repository do
  it_behaves_like 'repository crud' do
    include_context 'clean mongo database'

    before do
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
    end

    let(:mapper) { Rmodel::Mongo::SimpleMapper.new(Thing, :name) }
    subject { ThingRepository.new(mongo_session, :things, mapper) }
    let(:unique_constraint_error) { Mongo::Error::OperationFailure }

    def insert_record(id, columns)
      record = columns.dup
      record['_id'] = id
      mongo_session[:things].insert_one(record)
    end
  end

  it_behaves_like 'sugarable repository' do
    include_context 'clean mongo database'

    before do
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
    end

    subject do
      mapper = Rmodel::Mongo::SimpleMapper.new(Thing, :name)
      ThingRepository.new(mongo_session, :things, mapper)
    end
  end

  it_behaves_like 'timestampable repository' do
    include_context 'clean mongo database'

    before do
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
    end

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

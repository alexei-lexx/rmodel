RSpec.describe Rmodel::Mongo::Repository do
  include_context 'clean mongo database'

  shared_examples 'definitions' do
    before do
      stub_const 'ThingRepository', Class.new(Rmodel::Mongo::Repository)
      stub_const 'ThingMapper', Class.new(Rmodel::Mongo::Mapper)
      class ThingMapper
        model Thing
        attributes :name
      end
    end

    subject { ThingRepository.new(mongo_session, :things, ThingMapper.new) }
  end

  it_behaves_like 'repository crud' do
    include_context 'definitions'
    let(:unique_constraint_error) { Mongo::Error::OperationFailure }

    def insert_record(id, doc)
      mongo_session[:things].insert_one(doc.dup.merge('_id' => id))
    end
  end

  it_behaves_like 'sugarable repository' do
    include_context 'definitions'
  end

  it_behaves_like 'timestampable repository' do
    before do
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
    end

    let(:repo_w_timestamps) do
      stub_const 'MapperWithTimestamps', Class.new(Rmodel::Mongo::Mapper)
      class MapperWithTimestamps
        model Thing
        attributes :name, :created_at, :updated_at
      end

      ThingRepository.new(mongo_session, :things, MapperWithTimestamps.new)
    end

    let(:repo_wo_timestamps) do
      stub_const 'MapperWithOutTimestamps', Class.new(Rmodel::Mongo::Mapper)
      class MapperWithOutTimestamps
        model Thing
        attributes :name
      end

      ThingRepository.new(mongo_session, :things, MapperWithOutTimestamps.new)
    end
  end
end

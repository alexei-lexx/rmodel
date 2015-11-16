RSpec.describe Rmodel::Sequel::Repository do
  include_examples 'clean sequel database'

  shared_examples 'definitions' do
    before do
      stub_const 'ThingRepository', Class.new(Rmodel::Sequel::Repository)
      stub_const 'ThingMapper', Class.new(Rmodel::Sequel::Mapper)
      class ThingMapper
        model Thing
        attributes :name
      end
    end
    subject { ThingRepository.new(sequel_conn, :things, ThingMapper.new) }
  end

  it_behaves_like 'repository crud' do
    before { create_database }
    include_context 'definitions'
    let(:unique_constraint_error) { Sequel::UniqueConstraintViolation }

    def insert_record(id, record)
      sequel_conn[:things].insert(record.dup.merge(id: id))
    end
  end

  it_behaves_like 'sugarable repository' do
    before { create_database }
    include_context 'definitions'
  end

  it_behaves_like 'timestampable repository' do
    before { create_database(true) }
    before do
      stub_const('ThingRepository', Class.new(Rmodel::Sequel::Repository))
    end

    let(:repo_w_timestamps) do
      stub_const 'ThingMapperWithTimestamps', Class.new(Rmodel::Sequel::Mapper)
      class ThingMapperWithTimestamps
        model Thing
        attributes :name, :created_at, :updated_at
      end

      ThingRepository.new(sequel_conn, :things, ThingMapperWithTimestamps.new)
    end

    let(:repo_wo_timestamps) do
      stub_const 'ThingMapperWithOutTimestamps', Class.new(Rmodel::Sequel::Mapper)
      class ThingMapperWithOutTimestamps
        model Thing
        attributes :name
      end

      ThingRepository.new(sequel_conn, :things, ThingMapperWithOutTimestamps.new)
    end
  end

  def create_database(timestamps = false)
    sequel_conn.create_table(:things) do
      primary_key :id
      String :name
      if timestamps
        Time :created_at
        Time :updated_at
      end
    end
  end
end

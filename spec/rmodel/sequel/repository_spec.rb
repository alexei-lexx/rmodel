RSpec.describe Rmodel::Sequel::Repository do
  include_examples 'clean sequel database'

  shared_examples 'definitions' do
    before do
      stub_const('ThingRepository', Class.new(Rmodel::Sequel::Repository))
    end
    let(:mapper) { Rmodel::Sequel::SimpleMapper.new(Thing, :name) }
    subject { ThingRepository.new(sequel_conn, :things, mapper) }
  end

  it_behaves_like 'repository crud' do
    before { create_database }
    include_context 'definitions'
    let(:unique_constraint_error) { Sequel::UniqueConstraintViolation }

    def insert_record(id, record)
      sequel_conn[:things].insert(record.dup().merge(id: id))
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
      mapper = Rmodel::Sequel::SimpleMapper.new(Thing, :name, :created_at, :updated_at)
      ThingRepository.new(sequel_conn, :things, mapper)
    end

    let(:repo_wo_timestamps) do
      mapper = Rmodel::Sequel::SimpleMapper.new(Thing, :name)
      ThingRepository.new(sequel_conn, :things, mapper)
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

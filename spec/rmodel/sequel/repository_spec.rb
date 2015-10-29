RSpec.describe Rmodel::Sequel::Repository do
  it_behaves_like 'repository crud' do
    include_examples 'clean sequel database'

    before do
      create_database
      stub_const('ThingRepository', Class.new(Rmodel::Sequel::Repository))
    end

    let(:factory) { Rmodel::Sequel::SimpleFactory.new(Thing, :name) }
    subject { ThingRepository.new(sequel_conn, :things, factory) }
    let(:unique_constraint_error) { Sequel::UniqueConstraintViolation }

    def insert_record(id, columns)
      record = columns.dup
      record[:id] = id
      sequel_conn[:things].insert(record)
    end
  end

  it_behaves_like 'sugarable repository' do
    include_examples 'clean sequel database'

    before do
      create_database
      stub_const('ThingRepository', Class.new(Rmodel::Sequel::Repository))
    end

    subject do
      factory = Rmodel::Sequel::SimpleFactory.new(Thing, :name)
      ThingRepository.new(sequel_conn, :things, factory)
    end
  end

  it_behaves_like 'timestampable repository' do
    include_examples 'clean sequel database'

    before do
      create_database(true)
      stub_const('ThingRepository', Class.new(Rmodel::Sequel::Repository))
    end

    let(:repo_w_timestamps) do
      factory = Rmodel::Sequel::SimpleFactory.new(Thing, :name, :created_at, :updated_at)
      ThingRepository.new(sequel_conn, :things, factory)
    end

    let(:repo_wo_timestamps) do
      factory = Rmodel::Sequel::SimpleFactory.new(Thing, :name)
      ThingRepository.new(sequel_conn, :things, factory)
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
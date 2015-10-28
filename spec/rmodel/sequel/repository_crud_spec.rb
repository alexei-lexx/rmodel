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

  def create_database
    sequel_conn.create_table(:things) do
      primary_key :id
      String :name
    end
  end
end

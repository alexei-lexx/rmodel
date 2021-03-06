RSpec.describe 'Repository with Sequel' do
  include_examples 'clean sequel database'

  shared_examples 'definitions' do
    let(:source) { Rmodel::Sequel::Source.new(sequel_conn, :things) }
    let(:mapper_klass) { Rmodel::Sequel::Mapper }
  end

  it_behaves_like 'repository crud' do
    before { create_database }

    include_context 'definitions'
    let(:unique_constraint_error) { Sequel::UniqueConstraintViolation }
  end

  it_behaves_like 'sugarable repository' do
    before { create_database }
    include_context 'definitions'
  end

  it_behaves_like 'timestampable repository' do
    before { create_database(true) }
    include_context 'definitions'
  end

  it_behaves_like 'initialization' do
    before { create_database }
    include_context 'definitions'
  end

  it_behaves_like 'scopable repository' do
    include_context 'definitions'

    def create_database
      sequel_conn.create_table(:things) do
        primary_key :id
        Integer :a
        Integer :b
      end
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

  it_behaves_like 'injectable repository' do
    before { create_database }
    include_context 'definitions'
  end
end

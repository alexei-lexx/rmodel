RSpec.describe 'Repository with MongoDB' do
  include_context 'clean mongo database'

  shared_examples 'definitions' do
    let(:source) { Rmodel::Mongo::Source.new(mongo_session, :things) }
    let(:mapper_klass) { Rmodel::Mongo::Mapper }
  end

  it_behaves_like 'repository crud' do
    include_context 'definitions'
    let(:unique_constraint_error) { Mongo::Error::OperationFailure }
  end

  it_behaves_like 'sugarable repository' do
    include_context 'definitions'
  end

  it_behaves_like 'timestampable repository' do
    include_context 'definitions'
  end

  it_behaves_like 'initialization' do
    include_context 'definitions'
  end

  it_behaves_like 'queryable repository' do
    include_context 'definitions'
  end
end

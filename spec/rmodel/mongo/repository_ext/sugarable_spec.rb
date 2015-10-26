RSpec.describe Rmodel::Mongo::Repository do
  include_context 'clean Mongo database'

  before do
    stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
  end

  let(:factory) { Rmodel::Mongo::SimpleFactory.new(Thing, :name) }
  subject { ThingRepository.new(mongo_session, :things, factory) }

  include_examples 'sugarable repository'
end

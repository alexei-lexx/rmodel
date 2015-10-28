RSpec.describe Rmodel::Mongo::Repository do
  include_examples 'sugarable repository' do
    include_context 'clean mongo database'

    before do
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
    end

    subject do
      factory = Rmodel::Mongo::SimpleFactory.new(Thing, :name)
      ThingRepository.new(mongo_session, :things, factory)
    end
  end
end

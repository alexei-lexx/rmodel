RSpec.describe Rmodel::Mongo::Repository do
  include_examples 'callbackable repository' do
    include_context 'clean mongo database'

    before do
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
    end

    subject do
      ThingRepository.new(mongo_session, :things, ThingMapper.new)
    end
  end
end

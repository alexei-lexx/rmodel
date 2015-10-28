RSpec.describe Rmodel::Mongo::Repository do
  include_examples 'timestampable repository' do
    include_context 'clean mongo database'

    before do
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository))
    end

    let(:repo_w_timestamps) do
      factory = Rmodel::Mongo::SimpleFactory.new(Thing, :name, :created_at, :updated_at)
      ThingRepository.new(mongo_session, :things, factory)
    end

    let(:repo_wo_timestamps) do
      factory = Rmodel::Mongo::SimpleFactory.new(Thing, :name)
      ThingRepository.new(mongo_session, :things, factory)
    end
  end
end

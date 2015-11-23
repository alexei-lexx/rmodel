RSpec.describe Rmodel::Mongo::Repository do
  let(:source) do
    Rmodel::Mongo::Source.new(connection, :things)
  end
  before do
    stub_const 'ThingMapper', Class.new(Rmodel::Mongo::Mapper)
    stub_const 'ThingRepository', Class.new(Rmodel::Mongo::Repository)
  end

  it_behaves_like 'initialization'
end

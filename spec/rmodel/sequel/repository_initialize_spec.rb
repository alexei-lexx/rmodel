RSpec.describe Rmodel::Sequel::Repository do
  let(:source) do
    Rmodel::Sequel::Source.new(connection, :things)
  end
  before do
    stub_const 'ThingMapper', Class.new(Rmodel::Sequel::Mapper)
    stub_const 'ThingRepository', Class.new(Rmodel::Sequel::Repository)
  end

  it_behaves_like 'initialization'
end

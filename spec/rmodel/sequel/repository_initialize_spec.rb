RSpec.describe 'Repository with Sequel' do
  let(:source) do
    Rmodel::Sequel::Source.new(connection, :things)
  end
  before do
    stub_const 'ThingMapper', Class.new(Rmodel::Sequel::Mapper)
    stub_const 'ThingRepository', Class.new(Rmodel::Base::Repository)
  end

  it_behaves_like 'initialization'
end

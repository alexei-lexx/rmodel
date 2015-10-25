RSpec.describe Rmodel::Mongo::Repository do
  include_context 'clean Mongo database'

  describe Rmodel::Mongo::RepositoryExt::Sugarable do
    before do
      stub_const('Thing', Struct.new(:id, :name))
      stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository) {
        simple_factory Thing, :name
      })
    end

    subject(:repo) { ThingRepository.new }

    describe '#find!' do
      context 'when an existent id is given' do
        before { repo.insert(Thing.new(1)) }

        it 'returns the right instance' do
          expect(repo.find!(1)).not_to be_nil
        end
      end

      context 'when a non-existent id is given' do
        it 'raises NotFound' do
          expect {
            repo.find!(1)
          }.to raise_error Rmodel::NotFound
        end
      end
    end
  end
end

RSpec.describe Rmodel::Mongo::Repository do
  describe Rmodel::Mongo::RepositoryExt::Timestampable do
    subject(:repo) { ThingRepository.new }

    context 'when the entity object has attributes created_at and updated_at' do
      before do
        stub_const('Thing', Struct.new(:id, :name, :created_at, :updated_at))
        stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository) {
          simple_factory Thing, :name, :created_at, :updated_at
        })
      end

      context 'when we insert(object)' do
        context 'and the object.created_at is already set' do
          let(:thing) { Thing.new(nil, 'chair', Time.now) }

          it 'doesnt change the value of created_at' do
            set_created_at = thing.created_at
            repo.insert(thing)
            expect(thing.created_at).to eq set_created_at
          end
        end

        context 'and the object.created_at is not set yet' do
          let(:thing) { Thing.new(nil, 'chair') }

          it 'sets the value of created_at' do
            repo.insert(thing)
            expect(thing.created_at).not_to be_nil
          end
        end
      end

      context 'when we update(object)' do
        let(:thing) { Thing.new(nil, 'chair') }
        before { repo.insert(thing) }

        it 'sets the value of created_at' do
          thing.name = 'table'
          repo.update(thing)
          expect(thing.updated_at).not_to be_nil
        end
      end
    end

    context 'when the entity has no attributes :created_at and updated_at' do
      before do
        stub_const('Thing', Struct.new(:id, :name))
        stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository) {
          simple_factory Thing, :name
        })
      end
      let(:thing) { Thing.new(nil, 'chair') }

      context 'when we insert(object)' do
        it 'does nothing special' do
          repo.insert(thing)
          expect(thing.respond_to?(:created_at)).to be false
        end
      end

      context 'when we update(object)' do
        before { repo.insert(thing) }

        it 'does nothing special' do
          thing.name = 'table'
          repo.update(thing)
          expect(thing.respond_to?(:updated_at)).to be false
        end
      end
    end
  end
end

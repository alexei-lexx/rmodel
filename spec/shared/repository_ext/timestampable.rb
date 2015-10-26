RSpec.shared_examples 'timestampable repository' do
  describe Rmodel::Base::RepositoryExt::Timestampable do
    context 'when the entity object has attributes created_at and updated_at' do
      before do
        stub_const('Thing', Struct.new(:id, :name, :created_at, :updated_at))
      end

      subject { repo_w_timestamps }

      context 'when we insert(object)' do
        context 'and the object.created_at is already set' do
          let(:thing) { Thing.new(nil, 'chair', Time.now) }

          it 'doesnt change the value of created_at' do
            set_created_at = thing.created_at
            subject.insert(thing)
            expect(thing.created_at).to eq set_created_at
          end
        end

        context 'and the object.created_at is not set yet' do
          let(:thing) { Thing.new(nil, 'chair') }

          it 'sets the value of created_at' do
            subject.insert(thing)
            expect(thing.created_at).not_to be_nil
          end
        end
      end

      context 'when we update(object)' do
        let(:thing) { Thing.new(nil, 'chair') }
        before { subject.insert(thing) }

        it 'sets the value of created_at' do
          thing.name = 'table'
          subject.update(thing)
          expect(thing.updated_at).not_to be_nil
        end
      end
    end

    context 'when the entity has no attributes :created_at and updated_at' do
      before do
        stub_const('Thing', Struct.new(:id, :name))
      end

      let(:thing) { Thing.new(nil, 'chair') }
      subject { repo_wo_timestamps }

      context 'when we insert(object)' do
        it 'does nothing special' do
          subject.insert(thing)
          expect(thing.respond_to?(:created_at)).to be false
        end
      end

      context 'when we update(object)' do
        before { subject.insert(thing) }

        it 'does nothing special' do
          thing.name = 'table'
          subject.update(thing)
          expect(thing.respond_to?(:updated_at)).to be false
        end
      end
    end
  end
end

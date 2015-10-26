RSpec.shared_examples 'sugarable repository' do
  describe Rmodel::Base::RepositoryExt::Sugarable do
    before do
      stub_const('Thing', Struct.new(:id, :name))
    end

    describe '#find!' do
      context 'when an existent id is given' do
        before { subject.insert(Thing.new(1)) }

        it 'returns the right instance' do
          expect(subject.find!(1)).not_to be_nil
        end
      end

      context 'when a non-existent id is given' do
        it 'raises NotFound' do
          expect {
            subject.find!(1)
          }.to raise_error Rmodel::NotFound
        end
      end
    end

    describe 'save' do
      let(:thing) { Thing.new }

      context 'when a new object is given' do
        it 'gets inserted' do
          subject.save(thing)
          expect(subject.find(thing.id)).not_to be_nil
        end
      end

      context 'when an existent object is given' do
        before { subject.insert(thing) }

        it 'gets updated' do
          thing.name = 'chair'
          subject.save(thing)
          expect(subject.find(thing.id).name).to eq 'chair'
        end
      end
    end
  end
end

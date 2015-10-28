RSpec.shared_examples 'repository crud' do
  before do
    stub_const('Thing', Struct.new(:id, :name))
  end

  describe '#find' do
    before { insert_record(id: 1, name: 'chair') }

    context 'when an existent id is given' do
      it 'returns the instance of correct type' do
        expect(subject.find(1)).to be_an_instance_of Thing
      end

      it 'returns the correct attributes' do
        expect(subject.find(1).name).to eq 'chair'
      end
    end

    context 'when a non-existent id is given' do
      it 'returns nil' do
        expect(subject.find(2)).to be_nil
      end
    end
  end

  describe '#insert' do
    context 'when the id is not provided' do
      let(:thing) { Thing.new(nil, 'chair') }

      it 'sets the id before insert' do
        subject.insert(thing)
        expect(thing.id).not_to be_nil
      end

      it 'persists the object' do
        subject.insert(thing)
        expect(subject.find(thing.id).name).to eq 'chair'
      end
    end

    context 'when the id is provided' do
      let(:thing) { Thing.new(1000, 'chair') }

      it 'uses the existent id' do
        subject.insert(thing)
        expect(thing.id).to eq 1000
      end
    end

    context 'when the given id already exists' do
      let(:thing) { Thing.new }
      before { subject.insert(thing) }

      it 'raises the error' do
        expect { subject.insert(thing) }.to raise_error unique_constraint_error
      end
    end
  end

  describe '#update' do
    let(:thing) { Thing.new(nil) }

    before do
      subject.insert(thing)
      thing.name = 'chair'
    end

    it 'updates the record' do
      subject.update(thing)
      expect(subject.find(thing.id).name).to eq 'chair'
    end
  end

  describe '#remove' do
    let(:thing) { Thing.new }
    before { subject.insert(thing) }

    it 'removes the record' do
      subject.remove(thing)
      expect(subject.find(thing.id)).to be_nil
    end
  end
end

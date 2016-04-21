RSpec.shared_examples 'sugarable repository' do
  before { stub_const('Thing', Struct.new(:id, :name)) }

  let(:mapper) { mapper_klass.new(Thing).define_attributes(:name) }

  subject { Rmodel::Repository.new(source, mapper) }

  describe '#find!(id)' do
    context 'when an existent id is given' do
      before { subject.insert(Thing.new(1)) }

      it 'returns the right instance' do
        expect(subject.find!(1)).not_to be_nil
      end
    end

    context 'when a non-existent id is given' do
      it 'raises NotFound' do
        expect { subject.find!(1) }.to raise_error Rmodel::NotFound
      end
    end
  end

  describe '#insert(object1, object2, ...)' do
    context 'when one object is provided' do
      it 'inserts one object' do
        subject.insert(Thing.new)
        expect(subject.query.count).to eq 1
      end
    end

    context 'when an array of objects is provided' do
      it 'inserts all objects' do
        subject.insert([Thing.new, Thing.new])
        expect(subject.query.count).to eq 2
      end
    end

    context 'when objects are provided as many arguments' do
      it 'inserts all objects' do
        subject.insert(Thing.new, Thing.new)
        expect(subject.query.count).to eq 2
      end
    end
  end

  describe '#save' do
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

  describe '#remove_all' do
    before do
      3.times { subject.insert(Thing.new) }
    end

    it 'removes all objects' do
      subject.remove_all
      expect(subject.query.count).to eq 0
    end
  end

  describe '#destroy_all' do
    before do
      3.times { subject.insert(Thing.new) }
    end

    it 'removes all objects' do
      subject.destroy_all
      expect(subject.query.count).to eq 0
    end

    it 'calls #destroy for each object' do
      expect(subject).to receive(:destroy).exactly(3).times
      subject.destroy_all
    end
  end
end

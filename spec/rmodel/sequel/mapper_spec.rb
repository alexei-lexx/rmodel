RSpec.describe Rmodel::Sequel::Mapper do
  before do
    stub_const 'User', Struct.new(:id, :name, :age)
  end

  subject { described_class.new(User).define_attributes(:name, :age) }

  describe '#deserialize(hash)' do
    it 'returns an instance of the appropriate class' do
      expect(subject.deserialize({})).to be_an_instance_of User
    end

    it 'sets the attributes correctly' do
      object = subject.deserialize(name: 'John', age: 20)

      expect(object.name).to eq 'John'
      expect(object.age).to eq 20
    end

    context 'when _id is given' do
      it 'sets the #id correctly' do
        object = subject.deserialize(id: 1)
        expect(object.id).to eq 1
      end
    end
  end

  describe '#serialize(object, id_included)' do
    it 'returns an instance of Hash' do
      hash = subject.serialize(User.new(1, 'John', 20), true)
      expect(hash).to be_an_instance_of Hash
    end

    it 'sets the keys correctly' do
      hash = subject.serialize(User.new(1, 'John', 20), true)

      expect(hash[:name]).to eq 'John'
      expect(hash[:age]).to eq 20
    end

    context 'when id_included = true' do
      it 'sets the id' do
        hash = subject.serialize(User.new(1), true)
        expect(hash[:id]).to eq 1
      end
    end

    context 'when id_included = false' do
      it 'doesnt set the id' do
        hash = subject.serialize(User.new(1), false)
        expect(hash.key?(:id)).to be false
      end
    end
  end

  it_behaves_like 'base mapper'
end

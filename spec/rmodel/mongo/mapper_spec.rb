RSpec.describe Rmodel::Mongo::Mapper do
  before do
    stub_const 'User', Struct.new(:id, :name, :age, :address, :phones)
    stub_const 'Address', Struct.new(:id, :city, :street)
    stub_const 'Phone', Struct.new(:id, :number)

    stub_const 'UserMapper', Class.new(described_class)
    stub_const 'AddressMapper', Class.new(described_class)
    stub_const 'PhoneMapper', Class.new(described_class)

    class UserMapper
      model User
      attributes :name, :age
      attribute :address, AddressMapper.new
      attribute :phones, Rmodel::Mongo::ArrayMapper.new(PhoneMapper.new)
    end

    class AddressMapper
      model Address
      attributes :city, :street
    end

    class PhoneMapper
      model Phone
      attributes :number
    end
  end

  subject { UserMapper.new }

  describe '#deserialize(hash)' do
    it 'returns an instance of the appropriate class' do
      expect(subject.deserialize({})).to be_an_instance_of User
    end

    it 'sets the attributes correctly' do
      object = subject.deserialize({ 'name' => 'John', 'age' => 20 })

      expect(object.name).to eq 'John'
      expect(object.age).to eq 20
    end

    it 'leaves not specified attributes out' do
      object = subject.deserialize({ 'name' => 'John' })
      expect(object.age).to be_nil
    end

    context 'when _id is given' do
      it 'sets the #id correctly' do
        object = subject.deserialize({ '_id' => 1 })
        expect(object.id).to eq 1
      end
    end

    context 'when an embedded hash is given' do
      let(:hash) do
        {
          'address' => {
            '_id' => 10,
            'city' => 'NY',
            'street' => '1st Avenue'
          }
        }
      end
      let(:object) { subject.deserialize(hash) }

      it 'creates the embedded object of the appropriate type' do
        expect(object.address).to be_an_instance_of Address
      end

      it 'sets the attributes of the embedded object correctly' do
        expect(object.address.id).to eq 10
        expect(object.address.city).to eq 'NY'
        expect(object.address.street).to eq '1st Avenue'
      end
    end

    context 'when an embedded array is given' do
      let(:hash) do
        {
          'phones' => [
            { '_id' => 100, 'number' => '+1111' },
            { '_id' => 101, 'number' => '+2222' }
          ]
        }
      end
      let(:object) { subject.deserialize(hash) }

      it 'creates the embedded array of objects of the appropriate type' do
        expect(object.phones).to be_an_instance_of Array
        expect(object.phones.length).to eq 2
      end

      it 'sets the attributes of the embedded array correctly' do
        expect(object.phones[0].id).to eq 100
        expect(object.phones[0].number).to eq '+1111'

        expect(object.phones[1].id).to eq 101
        expect(object.phones[1].number).to eq '+2222'
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

      expect(hash['name']).to eq 'John'
      expect(hash['age']).to eq 20
    end

    context 'when id_included = true' do
      it 'sets the _id' do
        hash = subject.serialize(User.new(1), true)
        expect(hash['_id']).to eq 1
      end
    end

    context 'when id_included = false' do
      it 'doesnt set the _id' do
        hash = subject.serialize(User.new(1), false)
        expect(hash.has_key?('_id')).to be false
      end
    end

    context 'when an embedded object is given' do
      let(:object) do
        user = User.new(1, 'John', 20)
        user.address = Address.new(10, 'NY', '1st Avenue')
        user
      end
      let(:hash) { subject.serialize(object, true) }

      it 'creates the embedded hash correctly' do
        expect(hash['address']['_id']).to eq 10
        expect(hash['address']['city']).to eq 'NY'
        expect(hash['address']['street']).to eq '1st Avenue'
      end
    end

    context 'when an embedded array of objects is given' do
      let(:object) do
        user = User.new
        user.phones = [ Phone.new(100, '+1111'), Phone.new(101, '+2222') ]
        user
      end
      let(:hash) { subject.serialize(object, true) }

      it 'creates the embedded array correctly' do
        expect(hash['phones'].length).to eq 2
      end
    end
  end
end

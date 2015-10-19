RSpec.describe Rmodel::Mongodb::SimpleFactory do
  context 'when the User(id, name, email) class is defined' do
    before { stub_const('User', Struct.new(:id, :name, :email)) }

    subject(:factory) { Rmodel::Mongodb::SimpleFactory.new(User, :name, :email) }

    describe '#fromHash' do
      context 'when the hash with _id, name and email is given' do
        let(:hash) { { '_id' => 1, 'name' => 'John', 'email' => 'john@example.com' } }
        let(:result) { factory.fromHash(hash) }

        it 'returns an instance of User' do
          expect(result).to be_an_instance_of User
        end

        it 'sets the attributes correctly' do
          expect(result.name).to eq 'John'
          expect(result.email).to eq 'john@example.com'
        end

        it 'sets the User#id correctly' do
          expect(result.id).to eq 1
        end
      end
    end

    describe '#toHash' do
      let(:user) { User.new(1, 'John', 'john@example.com') }
      context 'when id_included is false' do
        let(:result) { factory.toHash(user, false) }

        it 'returns an instance of Hash' do
          expect(result).to be_an_instance_of Hash
        end

        it 'sets the keys correctly' do
          expect(result['name']).to eq 'John'
          expect(result['email']).to eq 'john@example.com'
        end

        it 'has no the "_id" key' do
          expect(result.has_key?('_id')).to be false
        end
      end

      context 'when id_included is true' do
        let(:result) { factory.toHash(user, true) }

        it 'sets the "_id" key' do
          expect(result['_id']).to eq 1
        end
      end
    end
  end
end

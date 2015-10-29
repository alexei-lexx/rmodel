RSpec.describe Rmodel::Mongo::SimpleFactory do
  context 'when the Thing(id, name, price) class is defined' do
    before { stub_const('Thing', Struct.new(:id, :name, :price)) }

    subject(:factory) { described_class.new(Thing, :name, :price) }

    describe '#fromHash' do
      context 'when the hash with _id, name and price is given' do
        let(:hash) { { '_id' => 1, 'name' => 'chair', 'price' => 100 } }
        let(:result) { factory.fromHash(hash) }

        it 'returns an instance of Thing' do
          expect(result).to be_an_instance_of Thing
        end

        it 'sets the attributes correctly' do
          expect(result.name).to eq 'chair'
          expect(result.price).to eq 100
        end

        it 'sets the Thing#id correctly' do
          expect(result.id).to eq 1
        end
      end
    end

    describe '#toHash' do
      let(:thing) { Thing.new(1, 'chair', 100) }
      context 'when id_included is false' do
        let(:result) { factory.toHash(thing, false) }

        it 'returns an instance of Hash' do
          expect(result).to be_an_instance_of Hash
        end

        it 'sets the keys correctly' do
          expect(result['name']).to eq 'chair'
          expect(result['price']).to eq 100
        end

        it 'has no the "_id" key' do
          expect(result.has_key?('_id')).to be false
        end
      end

      context 'when id_included is true' do
        let(:result) { factory.toHash(thing, true) }

        it 'sets the "_id" key' do
          expect(result['_id']).to eq 1
        end
      end
    end
  end
end

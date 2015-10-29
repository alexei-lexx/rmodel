RSpec.describe Rmodel::Mongo::SimpleFactory do
  context 'when the Thing(id, name, price, parts, owner) class is defined' do
    before do
      stub_const('Thing', Struct.new(:id, :name, :price, :parts, :owner))
      stub_const('Part', Struct.new(:id, :name))
      stub_const('Owner', Struct.new(:id, :full_name))
    end

    subject do
      described_class.new(Thing, :name, :price) do
        embeds_many :parts, Rmodel::Mongo::SimpleFactory.new(Part, :name)
        embeds_one :owner, Rmodel::Mongo::SimpleFactory.new(Owner, :full_name)
      end
    end

    describe '#fromHash(hash)' do
      let(:result) { subject.fromHash(hash) }

      context 'when the hash with _id, name and price is given' do
        let(:hash) { { '_id' => 1, 'name' => 'chair', 'price' => 100 } }

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

        it 'leaves <many embedded> nil' do
          expect(result.parts).to be_nil
        end

        it 'leaves <one embedded> nil' do
          expect(result.owner).to be_nil
        end
      end

      context 'when the hash contains many parts' do
        let(:hash) do
          {
            'parts' => [
              { '_id' => 1, 'name' => 'back' },
              { '_id' => 2, 'name' => 'leg' }
            ]
          }
        end

        it 'maps subdocuments to <many embedded>' do
          expect(result.parts.length).to eq 2
          expect(result.parts[0]).to be_an_instance_of Part
          expect(result.parts[0].id).to eq 1
          expect(result.parts[0].name).to eq 'back'
          expect(result.parts[1]).to be_an_instance_of Part
          expect(result.parts[1].id).to eq 2
          expect(result.parts[1].name).to eq 'leg'
        end
      end

      context 'when the hash contains one owner' do
        let(:hash) do
          { 'owner' => { '_id' => 3, 'full_name' => 'John Doe' } }
        end

        it 'maps subdocument to <one embedded>' do
          expect(result.owner).to be_an_instance_of Owner
          expect(result.owner.id).to eq 3
          expect(result.owner.full_name).to eq 'John Doe'
        end
      end
    end

    describe '#toHash(object, id_included)' do
      let(:thing) { Thing.new(1, 'chair', 100) }

      context 'when id_included is false' do
        let(:result) { subject.toHash(thing, false) }

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
        let(:result) { subject.toHash(thing, true) }

        it 'sets the "_id" key' do
          expect(result['_id']).to eq 1
        end
      end

      context 'when the object has <many embedded>' do
        let(:thing) do
          Thing.new(1, 'chair', 100, [ Part.new(1, 'back'), Part.new(2, 'leg') ])
        end
        let(:result) { subject.toHash(thing, true) }

        it 'maps <many embedded> to subdocuments' do
          expect(result['parts'].length).to eq 2
          expect(result['parts'][0]['_id']).to eq 1
          expect(result['parts'][0]['name']).to eq 'back'
          expect(result['parts'][1]['_id']).to eq 2
          expect(result['parts'][1]['name']).to eq 'leg'
        end
      end

      context 'when the object has <one embedded>' do
        let(:thing) do
          Thing.new(1, 'chair', 100, nil, Owner.new(3, 'John Doe'))
        end
        let(:result) { subject.toHash(thing, true) }

        it 'maps <one embedded> to the subdocument' do
          expect(result['owner']['_id']).to eq 3
          expect(result['owner']['full_name']).to eq 'John Doe'
        end
      end
    end

    describe '#initialize(..., &block)' do
      context 'when a block is given' do
        it 'passes self to the block' do
          tmp = nil
          factory = described_class.new(Thing, :name) do
            tmp = self
          end
          expect(tmp).to be factory
        end
      end
    end
  end
end

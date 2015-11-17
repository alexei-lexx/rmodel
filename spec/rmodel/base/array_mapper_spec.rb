RSpec.describe Rmodel::Base::ArrayMapper do
  before do
    stub_const 'Thing', Struct.new(:id, :name)
    stub_const 'ThingMapper', Class.new(Rmodel::Mongo::Mapper)

    class ThingMapper
      model Thing
      attributes :name
    end
  end

  subject { described_class.new(ThingMapper.new) }

  describe '#deserialize(array)' do
    it 'returns an array of instances of the appropriate class' do
      objects = subject.deserialize([ {}, {} ])

      expect(objects.length).to eq 2
      objects.each do |object|
        expect(object).to be_an_instance_of Thing
      end
    end

    context 'when nil is given' do
      it 'returns nil' do
        expect(subject.deserialize(nil)).to be_nil
      end
    end
  end

  describe '#serialize(objects, id_included)' do
    it 'returns an instance of Array' do
      array = subject.serialize([ Thing.new(1, 'chair'), Thing.new(2, 'table') ], true)

      expect(array.length).to eq 2
      array.each do |entry|
        expect(entry['_id']).not_to be_nil
        expect(entry['name']).not_to be_nil
      end
    end

    context 'when nil is given' do
      it 'returns nil' do
        expect(subject.serialize(nil, true)).to be_nil
      end
    end
  end
end

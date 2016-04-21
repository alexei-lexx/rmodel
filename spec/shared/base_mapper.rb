require 'active_support/hash_with_indifferent_access'

RSpec.shared_examples 'base mapper' do
  describe '#initialize' do
    context 'when the Thing model is given' do
      before { stub_const 'Thing', Class.new }
      subject { described_class.new(Thing) }

      it 'creates instances of Thing' do
        expect(subject.deserialize({})).to be_instance_of Thing
      end
    end
  end

  describe '#define_timestamps' do
    context 'on serialization' do
      before do
        stub_const 'Thing', Struct.new(:created_at, :updated_at)
      end

      subject { described_class.new(Thing).define_timestamps }

      let(:thing) { Thing.new(Time.now, Time.now) }

      let(:serialized) do
        hash = subject.serialize(thing, false)
        ActiveSupport::HashWithIndifferentAccess.new(hash)
      end

      it 'adds created_at to a hash' do
        expect(serialized).to have_key(:created_at)
      end

      it 'adds updated_at to a hash' do
        expect(serialized).to have_key(:updated_at)
      end
    end
  end
end

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
end

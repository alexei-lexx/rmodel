RSpec.shared_examples 'base mapper' do
  describe '#initialize' do
    context 'when the model is not declared' do
      before do
        stub_const 'UserMapper', Class.new(described_class)
      end

      context 'but the model class exists' do
        before { stub_const 'User', Struct.new(:id) }

        it 'is guessed by convention' do
          expect {
            subject
          }.not_to raise_error
        end
      end

      context 'and the model class does not exist' do
        before { hide_const('User') }

        it 'raises an error' do
          expect {
            subject
          }.to raise_error ArgumentError
        end
      end
    end
  end
end

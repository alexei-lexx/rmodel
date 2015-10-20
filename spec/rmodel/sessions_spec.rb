RSpec.describe Rmodel do
  describe '.sessions' do
    before { Rmodel.sessions.clear }

    describe '#[]' do
      context 'when the session was already set' do
        before { Rmodel.sessions[:default] = 'Default connection' }

        context 'when an existent key is given' do
          it 'returns the right value' do
            expect(Rmodel.sessions[:default]).to eq 'Default connection'
          end
        end

        context 'when an unknown key is given' do
          it 'returns nil' do
            expect(Rmodel.sessions[:another]).to be_nil
          end
        end
      end

      context 'when the session was not set' do
        it 'returns nil' do
          expect(Rmodel.sessions[:default]).to be_nil
        end
      end
    end
  end
end

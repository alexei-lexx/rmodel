RSpec.describe Rmodel do
  describe '.setup' do
    before { Rmodel::Setup.instance.clear }
    context 'when no block is passed' do
      it 'returns Rmodel::Setup.instance' do
        expect(Rmodel.setup).to equal Rmodel::Setup.instance
      end
    end

    context 'when the block is passed' do
      it 'returns Rmodel::Setup.instance' do
        expect(Rmodel.setup).to equal Rmodel::Setup.instance
      end

      it 'runs setup methods within the block' do
        Rmodel.setup do
          client :default, {}
        end
        expect(Rmodel::Setup.instance.clients[:default]).to eq({})
      end
    end
  end

  describe Rmodel::Setup do
    subject { Rmodel::Setup.instance }

    describe '#new' do
      it 'raises the NoMethodError' do
        expect { Rmodel::Setup.new }.to raise_error NoMethodError
      end
    end

    describe '#client(name, config)' do
      it 'makes config available via #clients[name]' do
        subject.client :default, { host: 'localhost' }
        expect(subject.clients[:default]).to eq( host: 'localhost' )
      end
    end

    describe '#clear' do
      context 'when one client is set' do
        before { subject.client :default, { host: 'localhost' } }

        it 'removes all clients' do
          subject.clear
          expect(subject.clients).to be_empty
        end
      end
    end
  end
end

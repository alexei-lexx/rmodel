RSpec.describe Rmodel do
  describe '.setup' do
    before { Rmodel::Setup.instance.clear }
    context 'when no block is passed' do
      it 'returns Rmodel::Setup.instance' do
        expect(Rmodel.setup).to equal Rmodel::Setup.instance
      end
    end

    context 'when the block is passed' do
      let(:connections_config) do
        Rmodel::Setup.instance.instance_variable_get('@connections_config')
      end

      it 'returns Rmodel::Setup.instance' do
        expect(Rmodel.setup).to equal Rmodel::Setup.instance
      end

      it 'runs setup methods within the block' do
        Rmodel.setup do
          connection :default, {}
        end
        expect(connections_config[:default]).to eq({})
      end
    end
  end

  describe Rmodel::Setup do
    subject { Rmodel::Setup.instance }
    let(:connections_config) do
      subject.instance_variable_get('@connections_config')
    end

    describe '#new' do
      it 'raises the NoMethodError' do
        expect { Rmodel::Setup.new }.to raise_error NoMethodError
      end
    end

    describe '#connection(name, config)' do
      it 'makes config available via #connections[name]' do
        subject.connection :default, host: 'localhost'
        expect(connections_config[:default]).to eq(host: 'localhost')
      end
    end

    describe '#clear' do
      context 'when one connection is set' do
        before { subject.connection :default, host: 'localhost' }

        it 'removes all connections' do
          subject.clear
          expect(connections_config).to be_empty
        end
      end
    end
  end
end

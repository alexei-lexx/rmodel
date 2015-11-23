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
          connection :default do
            # init connection
          end
        end
        expect(connections_config[:default]).not_to be_nil
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

    describe '#connection(name[, &block])' do
      before { Rmodel::Setup.instance.clear }

      context 'when the block is given' do
        it 'saves the connection config for later' do
          subject.connection(:default) { Object.new }
          expect(connections_config[:default]).to be_an_instance_of Proc
        end
      end

      context 'when no block is given' do
        context 'and the connection was set before' do
          before do
            subject.connection(:default) { Object.new }
          end

          it 'returns the appropriate connection object' do
            expect(subject.connection(:default)).to be_an_instance_of Object
          end
        end

        context 'and the connection was not set before' do
          it 'returns nil' do
            expect(subject.connection(:default)).to be_nil
          end
        end
      end
    end

    describe '#clear' do
      context 'when one connection is set' do
        before { subject.connection(:default) {} }

        it 'removes all connections' do
          subject.clear
          expect(connections_config).to be_empty
        end
      end
    end
  end
end

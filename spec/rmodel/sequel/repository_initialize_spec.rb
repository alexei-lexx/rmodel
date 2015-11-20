RSpec.describe Rmodel::Sequel::Repository do
  before do
    stub_const 'Thing', Struct.new(:id, :name)

    stub_const 'ThingMapper', Class.new(Rmodel::Sequel::Mapper)
    class ThingMapper
      model Thing
      attributes :name
    end

    stub_const 'ThingRepository', Class.new(Rmodel::Sequel::Repository)
    class ThingRepository
      attr_reader :source, :mapper

      def connection
        source.instance_variable_get(:@connection)
      end

      def table
        source.instance_variable_get(:@table)
      end
    end
  end

  describe '.connection(name)' do
    after { Rmodel.setup.clear }
    conn_options = { adapter: 'sqlite', database: 'rmodel_test.sqlite3' }

    subject { ThingRepository.new(nil, :things, ThingMapper.new) }

    context 'when it is called with an existent name' do
      before do
        Rmodel.setup do
          connection :sequel, conn_options
        end

        class ThingRepository
          connection :sequel
        end
      end

      it 'sets the appropriate #connection' do
        expect(subject.connection).to be_a_kind_of Sequel::Database
      end
    end

    context 'when it is called with a non-existent name' do
      before do
        class ThingRepository
          connection :sequel
        end
      end

      it 'makes #initialize raise the ArgumentError' do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context 'when it is not called' do
      context 'when the :default connection is set' do
        before do
          Rmodel.setup do
            connection :default, conn_options
          end
        end

        it 'sets #connection to be default' do
          expect(subject.connection).to be_a_kind_of Sequel::Database
        end
      end

      context 'when the :default connection is not set' do
        it 'makes #initialize raise the ArgumentError' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '.table(name)' do
    subject { ThingRepository.new(Object.new, nil, ThingMapper.new) }

    context 'when the :people table is given' do
      before do
        class ThingRepository
          table :people
        end
      end

      it 'uses the :people' do
        expect(subject.table).to eq :people
      end
    end

    context 'when no table is given' do
      it 'gets the right name by convention' do
        expect(subject.table).to eq :things
      end
    end
  end

  describe '.mapper(mapper_klass)' do
    subject { ThingRepository.new(Object.new, :things, nil) }

    context 'when it is called' do
      before do
        class ThingRepository
          mapper ThingMapper
        end
      end

      it 'sets the appropriate #mapper' do
        expect(subject.mapper).to be_an_instance_of ThingMapper
      end
    end

    context 'when it is not called' do
      context 'and the mapper class is defined' do
        it 'gets the right class by convention' do
          expect(subject.mapper).to be_an_instance_of ThingMapper
        end
      end

      context 'and the mapper class is not defined' do
        before { hide_const('ThingMapper') }

        it 'make #initialize raise an error' do
          expect do
            ThingRepository.new(Object.new, :users)
          end.to raise_error ArgumentError
        end
      end
    end
  end

  describe '#initialize(connection, collection, mapper)' do
    context 'when all constructor arguments are passed' do
      it 'works!' do
        expect do
          ThingRepository.new(Object.new, :users, ThingMapper.new)
        end.not_to raise_error
      end
    end
  end
end

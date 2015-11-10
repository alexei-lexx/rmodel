RSpec.describe Rmodel::Sequel::Repository do
  before do
    stub_const('Thing', Struct.new(:id, :name))
    stub_const('ThingRepository', Class.new(Rmodel::Sequel::Repository))
    ThingRepository.send :attr_reader, :client, :table, :mapper
  end
  let(:mapper) { Rmodel::Sequel::SimpleMapper.new(Thing, :name) }

  describe '.client(name)' do
    conn_options = { adapter: 'sqlite', database: 'rmodel_test.sqlite3' }

    subject { ThingRepository.new(nil, :things, mapper) }

    context 'when it is called with an existent name' do
      before do
        Rmodel.setup do
          client :not_default, conn_options
        end

        ThingRepository.class_eval do
          client :not_default
        end
      end
      after { Rmodel::setup.clear }

      it 'sets the appropriate #client' do
        expect(subject.client).to be_a_kind_of Sequel::Database
      end
    end

    context 'when it is called with a non-existent name' do
      before do
        ThingRepository.class_eval do
          client :not_default
        end
      end

      it 'makes #initialize raise the ArgumentError' do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context 'when it is not called' do
      context 'when the :default client is set' do
        before do
          Rmodel.setup do
            client :default, conn_options
          end
        end
        after { Rmodel::setup.clear }

        it 'sets #client to be default' do
          expect(subject.client).to be_a_kind_of Sequel::Database
        end
      end

      context 'when the :default client is not set' do
        it 'makes #initialize raise the ArgumentError' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '.table(name)' do
    subject { ThingRepository.new(Object.new, nil, mapper) }

    context 'when the :people table is given' do
      before do
        ThingRepository.class_eval do
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

  describe '.simple_mapper(klass, attribute1, attribute2, ...)' do
    subject { ThingRepository.new(Object.new, :things) }

    context 'when it is called' do
      before do
        ThingRepository.class_eval do
          simple_mapper Thing, :name, :email
        end
      end

      it 'sets the appropriate #mapper' do
        expect(subject.mapper).to be_an_instance_of Rmodel::Sequel::SimpleMapper
      end
    end

    context 'when it is not called' do
      it 'make #initialize raise an error' do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#initialize(client, collection, mapper)' do
    context 'when all constructor arguments are passed' do
      it 'works!' do
        expect {
          ThingRepository.new(Object.new, :users, mapper)
        }.not_to raise_error
      end
    end
  end
end

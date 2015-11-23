RSpec.describe Rmodel::Mongo::Repository do
  before do
    Mongo::Logger.logger.level = Logger::ERROR

    stub_const 'User', Struct.new(:id, :name, :email)

    stub_const 'UserMapper', Class.new(Rmodel::Mongo::Mapper)
    class UserMapper
      model User
      attributes :name, :email
    end

    stub_const 'UserRepository', Class.new(Rmodel::Mongo::Repository)
    class UserRepository
      attr_reader :source, :mapper

      def connection
        source.instance_variable_get(:@connection)
      end

      def collection
        source.instance_variable_get(:@collection)
      end
    end
  end

  describe '.connection(name)' do
    after { Rmodel.setup.clear }

    subject { UserRepository.new(nil, :users, UserMapper.new) }

    context 'when it is called with an existent name' do
      before do
        Rmodel.setup do
          connection(:mongo) { Mongo::Client.new(['localhost']) }
        end

        class UserRepository
          connection :mongo
        end
      end

      it 'sets the appropriate #connection' do
        expect(subject.connection).to be_an_instance_of Mongo::Client
      end
    end

    context 'when it is called with a non-existent name' do
      before do
        class UserRepository
          connection :mongo
        end
      end

      it 'makes #connection raise the ArgumentError' do
        expect { subject.connection }.to raise_error ArgumentError
      end
    end

    context 'when it is not called' do
      context 'when the :default connection is set' do
        before do
          Rmodel.setup do
            connection(:default) { Mongo::Client.new(['localhost']) }
          end
        end

        it 'sets #connection to be default' do
          expect(subject.connection).to be_an_instance_of Mongo::Client
        end
      end

      context 'when the :default connection is not set' do
        it 'makes #connection raise the ArgumentError' do
          expect { subject.connection }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '.collection(name)' do
    subject { UserRepository.new(Object.new, nil, UserMapper.new) }

    context 'when the :people collection is given' do
      before do
        class UserRepository
          collection :people
        end
      end

      it 'uses the :people' do
        expect(subject.collection).to eq :people
      end
    end

    context 'when no collection is given' do
      it 'gets the right name by convention' do
        expect(subject.collection).to eq :users
      end
    end
  end

  describe '.mapper(mapper_klass)' do
    subject { UserRepository.new(Object.new, :users, nil) }

    context 'when it is called' do
      before do
        class UserRepository
          mapper UserMapper
        end
      end

      it 'sets the appropriate #mapper' do
        expect(subject.mapper).to be_an_instance_of UserMapper
      end
    end

    context 'when it is not called' do
      context 'and the mapper class is defined' do
        it 'gets the right class by convention' do
          expect(subject.mapper).to be_an_instance_of UserMapper
        end
      end

      context 'and the mapper class is not defined' do
        before { hide_const('UserMapper') }

        it 'make #initialize raise an error' do
          expect do
            UserRepository.new(Object.new, :users)
          end.to raise_error ArgumentError
        end
      end
    end
  end

  describe '#initialize(connection, collection, mapper)' do
    context 'when all constructor arguments are passed' do
      it 'works!' do
        expect do
          UserRepository.new(Object.new, :users, UserMapper.new)
        end.not_to raise_error
      end
    end
  end
end

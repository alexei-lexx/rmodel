RSpec.describe Rmodel::Mongo::Repository do
  before do
    Rmodel.setup.clear
    stub_const('User', Struct.new(:id, :name, :email))
  end

  subject { UserRepository.new }

  describe '.client(name)' do
    before do
      Rmodel::Setup.send :public, :client
    end
    context 'when it is called with an existent name' do
      before do
        Rmodel.setup do
          client :mongo, { hosts: [ 'localhost' ] }
        end

        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
          client :mongo
          simple_factory User, :name, :email
          attr_reader :client
        })
      end

      it 'sets the appropriate #client' do
        expect(subject.client).to be_an_instance_of Mongo::Client
      end
    end

    context 'when it is called with a non-existent name' do
      before do
        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
          client :mongo
          simple_factory User, :name, :email
          attr_reader :client
        })
      end

      it 'makes #client raise the ArgumentError' do
        expect { subject.client }.to raise_error ArgumentError
      end
    end

    context 'when it is not called' do
      before do
        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
          simple_factory User, :name, :email
          attr_reader :client
        })
      end

      context 'when the :default client is set' do
        before do
          Rmodel.setup do
            client :default, { hosts: [ 'localhost' ] }
          end
        end

        it 'sets #client to be default' do
          expect(subject.client).to be_an_instance_of Mongo::Client
        end
      end

      context 'when the :default client is not set' do
        it 'makes #client raise the ArgumentError' do
          expect { subject.client }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '.collection(name)' do
    before do
      Rmodel.setup do
        client :default, { hosts: [ 'localhost' ] }
      end
    end

    context 'when the :people collection is given' do
      before do
        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
          collection :people
          simple_factory User, :name, :email
          attr_reader :collection
        })
      end

      it 'uses the :people' do
        expect(subject.collection).to eq :people
      end
    end

    context 'when no collection is given' do
      before do
        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
          simple_factory User, :name, :email
          attr_reader :collection
        })
      end

      it 'gets the right name by convention' do
        expect(subject.collection).to eq :users
      end
    end
  end

  describe '.simple_factory(klass, attribute1, attribute2, ...)' do
    before do
      Rmodel.setup do
        client :default, { hosts: [ 'localhost' ] }
      end
    end

    context 'when it is called' do
      before do
        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
          simple_factory User, :name, :email
          attr_reader :factory
        })
      end

      it 'sets the appropriate #factory' do
        expect(subject.factory).to be_an_instance_of Rmodel::Mongo::SimpleFactory
      end
    end

    context 'when it is not called' do
      before do
        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository))
      end

      it 'make #initialize raise an error' do
        expect {
          UserRepository.new
        }.to raise_error ArgumentError
      end
    end
  end
end

RSpec.describe Rmodel::Mongo::Repository do
  before { stub_const('User', Struct.new(:id, :name, :email)) }
  let(:factory) { Rmodel::Mongo::SimpleFactory.new(User, :name, :email) }

  describe '.client(name)' do
    before { Rmodel.setup.clear }
    subject { UserRepository.new }

    context 'when it is called with an existent name' do
      before do
        Rmodel.setup do
          client :mongo, { hosts: [ 'localhost' ] }
        end

        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
          client :mongo
          simple_factory User, :name, :email
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

  describe '#initialize' do
    describe 'how to get the collection' do
      context 'when the :people collection is defined by class macro .collection' do
        before do
          stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
            collection :people
          })
        end

        context 'and also the :clients collection is passed to the constructor' do
          subject(:repo) { UserRepository.new(:clients, factory) }

          it 'users the :clients' do
            expect(repo.collection).to eq :clients
          end
        end

        context 'and no collection is passed to the constructor' do
          subject(:repo) { UserRepository.new(nil, factory) }

          it 'users the :people' do
            expect(repo.collection).to eq :people
          end
        end
      end

      context 'when no collection is defined by class macro .collection' do
        before do
          stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository))
        end

        context 'but the :clients collection is passed to the constructor' do
          subject(:repo) { UserRepository.new(:clients, factory) }

          it 'users the :clients' do
            expect(repo.collection).to eq :clients
          end
        end

        context 'and no collection is passed to the constructor' do
          subject(:repo) { UserRepository.new(nil, factory) }

          it 'gets the right name by convention' do
            expect(repo.collection).to eq :users
          end
        end
      end
    end

    describe 'how to get the factory' do
      context 'when the A factory is defined by class macro .simple_factory' do
        before do
          stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
            simple_factory User, :name, :email
          })
        end
        let(:factory_a) { UserRepository.setting_factory }

        context 'and the B factory is passed to the constructor' do
          let(:factory_b) { factory }
          subject(:repo) { UserRepository.new(:users, factory_b) }

          it 'uses the B factory' do
            expect(repo.factory).to equal factory_b
          end
        end

        context 'and no factory is passed to the constructor' do
          subject(:repo) { UserRepository.new(:users, nil) }

          it 'uses the A factory' do
            expect(repo.factory).to equal factory_a
          end
        end
      end

      context 'when no factory is defined by class macro .simple_factory' do
        before do
          stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository))
        end

        context 'but the B factory is passed to the constructor' do
          let(:factory_b) { factory }
          subject(:repo) { UserRepository.new(:users, factory_b) }

          it 'uses the B factory' do
            expect(repo.factory).to equal factory_b
          end
        end

        context 'and no factory is passed to the constructor' do
          it 'raises an error' do
            expect {
              UserRepository.new(:users, nil)
            }.to raise_error ArgumentError
          end
        end
      end
    end

    context 'when the collection adn factory are defined by class macroses' do
      before do
        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
          simple_factory User, :name, :email
        })
      end

      context 'and no arguments are passed to the constructor' do
        it 'works!' do
          expect { UserRepository.new }.not_to raise_error
        end
      end
    end
  end
end

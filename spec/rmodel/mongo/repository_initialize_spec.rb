RSpec.describe Rmodel::Mongo::Repository do
  before { Rmodel.sessions.clear }
  before { stub_const('User', Struct.new(:id, :name, :email)) }
  let(:factory) { Rmodel::Mongo::SimpleFactory.new(User, :name, :email) }

  describe '#initialize' do
    describe 'how to guess the session' do
      let(:session_a) { stub_session }
      let(:session_b) { stub_session }
      let(:session_d) { stub_session }

      before { Rmodel.sessions[:session_a] = session_a }

      context 'when the A session is defined by class macro .session' do
        before do
          stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
            session :session_a
          })
        end

        context 'and also the B session is passed to the constructor' do
          subject(:repo) { UserRepository.new(session_b, :users, factory) }

          it 'uses the B' do
            expect(repo.session).to equal session_b
          end
        end

        context 'and no session is passed to the constructor' do
          subject(:repo) { UserRepository.new(nil, :users, factory) }

          it 'uses the A' do
            expect(repo.session).to equal session_a
          end
        end
      end

      context 'when no session is defined by class macro .session' do
        before do
          stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository))
        end

        context 'but the B session is passed to the constructor' do
          subject(:repo) { UserRepository.new(session_b, :users, factory) }

          it 'uses the B' do
            expect(repo.session).to equal session_b
          end
        end

        context 'and no session is passed to the constructor' do
          subject(:repo) { UserRepository.new(nil, :users, factory) }

          it 'raises an error' do
            expect {
              UserRepository.new(nil, :users, factory)
            }.to raise_error ArgumentError
          end
        end

        context 'but there is the :default session set up' do
          before { Rmodel.sessions[:default] = session_d }
          subject(:repo) { UserRepository.new(nil, :users, factory) }

          it 'uses the :default session' do
            expect(repo.session).to equal session_d
          end
        end
      end
    end

    describe 'how to get the collection' do
      context 'when the :people collection is defined by class macro .collection' do
        before do
          stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository) {
            collection :people
          })
        end

        context 'and also the :clients collection is passed to the constructor' do
          subject(:repo) { UserRepository.new(stub_session, :clients, factory) }

          it 'users the :clients' do
            expect(repo.collection).to eq :clients
          end
        end

        context 'and no collection is passed to the constructor' do
          subject(:repo) { UserRepository.new(stub_session, nil, factory) }

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
          subject(:repo) { UserRepository.new(stub_session, :clients, factory) }

          it 'users the :clients' do
            expect(repo.collection).to eq :clients
          end
        end

        context 'and no collection is passed to the constructor' do
          subject(:repo) { UserRepository.new(stub_session, nil, factory) }

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
          subject(:repo) { UserRepository.new(stub_session, :users, factory_b) }

          it 'uses the B factory' do
            expect(repo.factory).to equal factory_b
          end
        end

        context 'and no factory is passed to the constructor' do
          subject(:repo) { UserRepository.new(stub_session, :users, nil) }

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
          subject(:repo) { UserRepository.new(stub_session, :users, factory_b) }

          it 'uses the B factory' do
            expect(repo.factory).to equal factory_b
          end
        end

        context 'and no factory is passed to the constructor' do
          it 'raises an error' do
            expect {
              UserRepository.new(stub_session, :users, nil)
            }.to raise_error ArgumentError
          end
        end
      end
    end
  end

  def stub_session
    dbl = double
    allow(dbl).to receive(:[])
    dbl
  end
end

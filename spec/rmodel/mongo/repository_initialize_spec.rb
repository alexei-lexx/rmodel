RSpec.describe Rmodel::Mongo::Repository do
  before { Rmodel.sessions.clear }
  before { stub_const('User', Struct.new(:id, :name, :email)) }

  let(:session_a) { stub_session }
  let(:session_b) { stub_session }
  let(:session_d) { stub_session }
  let(:factory) { Rmodel::Mongo::SimpleFactory.new(User, :name, :email) }

  before { Rmodel.sessions[:session_a] = session_a }

  describe '#initialize' do

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

      context 'and the B session is not passed to the constructor' do
        subject(:repo) { UserRepository.new(nil, :users, factory) }

        it 'uses the A' do
          expect(repo.session).to equal session_a
        end
      end
    end

    context 'when the A session is not defined by class macro .session' do
      before do
        stub_const('UserRepository', Class.new(Rmodel::Mongo::Repository))
      end

      context 'but the B session is passed to the constructor' do
        subject(:repo) { UserRepository.new(session_b, :users, factory) }

        it 'uses the B' do
          expect(repo.session).to equal session_b
        end
      end

      context 'and the B session is not passed to the constructor' do
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

  def stub_session
    dbl = double
    allow(dbl).to receive(:[])
    dbl
  end
end

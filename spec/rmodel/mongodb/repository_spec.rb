RSpec.describe Rmodel::Mongodb::Repository do
  include_context 'clean moped'

  context 'when the User(id, name, email) class is defined' do
    let(:user_klass) { Struct.new(:id, :name, :email) }

    let(:session) { Moped::Session.new([ "127.0.0.1:27017" ]) }
    let(:factory) { Rmodel::Mongodb::SimpleFactory.new(user_klass, :name, :email) }
    before { session.use 'rmodel_test' }
    subject(:repo) { Rmodel::Mongodb::Repository.new(session, :users, factory) }

    describe '#find' do
      context 'when an existent id is given' do
        before do
          session[:users].insert(_id: 1, name: 'John', email: 'john@example.com')
        end

        it 'returns the correct instance of User' do
          user = repo.find(1)
          expect(user).to be_an_instance_of user_klass
        end
      end

      context 'when a non-existent id is given' do
        it 'returns nil' do
          expect(repo.find(1)).to be_nil
        end
      end
    end
  end
end

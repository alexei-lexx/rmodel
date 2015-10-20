RSpec.describe Rmodel::Mongo::Repository do
  include_context 'clean Mongo database'

  context 'when the User(id, name, email) class is defined' do
    before { stub_const('User', Struct.new(:id, :name, :email)) }

    let(:factory) { Rmodel::Mongo::SimpleFactory.new(User, :name, :email) }
    subject(:repo) { Rmodel::Mongo::Repository.new(mongo_session, :users, factory) }

    describe '#find' do
      context 'when an existent id is given' do
        before do
          mongo_session[:users].insert_one(_id: 1, name: 'John', email: 'john@example.com')
        end

        it 'returns the correct instance of User' do
          user = repo.find(1)
          expect(user).to be_an_instance_of User
        end
      end

      context 'when a non-existent id is given' do
        it 'returns nil' do
          expect(repo.find(1)).to be_nil
        end
      end
    end

    describe '#insert' do
      context 'when the user has no id' do
        let(:user) { User.new(nil, 'John', 'john@example.com') }

        it 'sets the id before insert' do
          repo.insert(user)
          expect(user.id).not_to be_nil
        end

        it 'persists the user' do
          repo.insert(user)
          found = mongo_session[:users].find(name: 'John', email: 'john@example.com').count
          expect(found).to eq 1
        end
      end

      context 'when the user has the id' do
        let(:user) { User.new(1, 'John', 'john@example.com') }

        it 'uses the existent id' do
          repo.insert(user)
          expect(user.id).to eq 1
        end
      end

      context 'when the given id already exists' do
        let(:user) { User.new(nil, 'John', 'john@example.com') }
        before { repo.insert(user) }

        it 'raises the error' do
          expect { repo.insert(user) }.to raise_error Mongo::Error::OperationFailure
        end
      end
    end

    describe '#update' do
      let(:user) { User.new(nil, 'John', 'john@example.com') }

      before do
        repo.insert(user)
        user.name = 'John Smith'
      end

      it 'updates the record' do
        repo.update(user)
        found = mongo_session[:users].find(name: 'John Smith').count
        expect(found).to eq 1
      end
    end

    describe '#remove' do
      let(:user) { User.new(nil, 'John', 'john@example.com') }
      before { repo.insert(user) }

      it 'removes the record' do
        repo.remove(user)
        found = mongo_session[:users].find(name: 'John').count
        expect(found).to eq 0
      end
    end
  end
end
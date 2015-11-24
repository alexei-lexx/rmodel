RSpec.describe Rmodel::Mongo::Source do
  include_context 'clean mongo database'

  subject { Rmodel::Mongo::Source.new(mongo_session, :things) }

  describe '#initialize(connection, collection)'

  describe 'find(id)' do
    context 'when an existent id is given' do
      before do
        mongo_session[:things].insert_one('_id' => 1, 'name' => 'chair')
      end

      it 'returns the doc' do
        doc = subject.find(1)
        expect(doc['name']).to eq 'chair'
      end
    end

    context 'when a non-existent id is given' do
      it 'returns nil' do
        expect(subject.find(1)).to be_nil
      end
    end
  end

  describe 'insert(doc)' do
    context 'when the _id is not set' do
      let(:inserted_id) { subject.insert('name' => 'chair') }

      it 'returns the new _id' do
        expect(inserted_id).not_to be_nil
      end

      it 'saves the doc' do
        found = mongo_session[:things].find('_id' => inserted_id).first
        expect(found['name']).to eq 'chair'
      end
    end

    context 'when the _id is set' do
      context 'when the _id is already occupied' do
        before do
          mongo_session[:things].insert_one('_id' => 1)
        end

        it 'throws the error' do
          expect do
            subject.insert('_id' => 1)
          end.to raise_error Mongo::Error::OperationFailure
        end
      end

      context 'when the _id is not occupied' do
        it 'returns the same id' do
          id = subject.insert('_id' => 1)
          expect(id).to eq 1
        end
      end
    end
  end

  describe 'update(id, doc)' do
    before do
      subject.insert('_id' => 1, 'name' => 'chair')
    end

    it 'updates the doc' do
      subject.update(1, 'name' => 'table')
      expect(subject.find(1)['name']).to eq 'table'
    end
  end

  describe 'delete(id)' do
    before do
      subject.insert('_id' => 1)
    end

    it 'deletes the doc' do
      subject.delete(1)
      expect(subject.find(1)).to be_nil
    end
  end

  describe 'build_query' do
    it 'returns the object what includes methods of Origin::Queryable' do
      expect(subject.build_query).to respond_to :aliases, :where, :group
    end
  end

  describe 'exec_query(query)' do
    before do
      3.times { subject.insert({}) }
    end

    it 'returns docs' do
      docs = subject.exec_query(subject.build_query)
      expect(docs.to_a.length).to eq 3
    end
  end

  describe 'delete_by_query(query)' do
    before do
      3.times { subject.insert({}) }
    end

    it 'deletes docs' do
      subject.delete_by_query(subject.build_query)
      found = subject.exec_query(subject.build_query)
      expect(found.to_a).to be_empty
    end
  end
end

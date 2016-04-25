RSpec.describe Rmodel::Sequel::Source do
  include_context 'clean sequel database'
  before { create_database }

  subject { Rmodel::Sequel::Source.new(sequel_conn, :things) }

  describe '#initialize(connection, table)'

  describe 'find(id)' do
    context 'when an existent id is given' do
      before do
        sequel_conn[:things].insert(id: 1, name: 'chair')
      end

      it 'returns the tuple' do
        tuple = subject.find(1)
        expect(tuple[:name]).to eq 'chair'
      end
    end

    context 'when a non-existent id is given' do
      it 'returns nil' do
        expect(subject.find(1)).to be_nil
      end
    end
  end

  describe 'insert(tuple)' do
    context 'when the id is not set' do
      let(:inserted_id) { subject.insert(name: 'chair') }

      it 'returns the new id' do
        expect(inserted_id).not_to be_nil
      end

      it 'saves the tuple' do
        found = sequel_conn[:things].where(id: inserted_id).first
        expect(found[:name]).to eq 'chair'
      end
    end

    context 'when the id is set' do
      context 'when the id is already occupied' do
        before do
          sequel_conn[:things].insert(id: 1)
        end

        it 'throws the error' do
          expect do
            subject.insert(id: 1)
          end.to raise_error Sequel::UniqueConstraintViolation
        end
      end

      context 'when the id is not occupied' do
        it 'returns the same id' do
          id = subject.insert(id: 1)
          expect(id).to eq 1
        end
      end
    end
  end

  describe 'update(id, doc)' do
    before do
      subject.insert(id: 1, name: 'chair')
    end

    it 'updates the doc' do
      subject.update(1, name: 'table')
      expect(subject.find(1)[:name]).to eq 'table'
    end
  end

  describe 'delete(id)' do
    before do
      subject.insert(id: 1)
    end

    it 'deletes the doc' do
      subject.delete(1)
      expect(subject.find(1)).to be_nil
    end
  end

  describe 'build_query' do
    it 'returns the instance of Sequel::Dataset' do
      expect(subject.build_query).to respond_to :select
      expect(subject.build_query).to respond_to :order
    end
  end

  describe 'exec_query(query)' do
    before do
      3.times { subject.insert({}) }
    end

    it 'returns tuples' do
      docs = subject.exec_query(subject.build_query)
      expect(docs.to_a.length).to eq 3
    end
  end

  describe 'delete_by_query(query)' do
    before do
      3.times { subject.insert({}) }
    end

    it 'deletes tuples' do
      subject.delete_by_query(subject.build_query)
      found = subject.exec_query(subject.build_query)
      expect(found.to_a).to be_empty
    end
  end

  def create_database
    sequel_conn.create_table(:things) do
      primary_key :id
      String :name
    end
  end
end

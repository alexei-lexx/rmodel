RSpec.describe Rmodel::Sequel::Repository do
  include_context 'clean sequel database'

  before do
    create_database
    stub_const('Thing', Struct.new(:id, :a, :b))
    stub_const('ThingRepository', Class.new(Rmodel::Sequel::Repository))
  end

  subject do
    factory = Rmodel::Sequel::SimpleFactory.new(Thing, :a, :b)
    ThingRepository.new(sequel_conn, :things, factory)
  end

  before do
    subject.insert(Thing.new(nil, 2, 3))
    subject.insert(Thing.new(nil, 2, 4))
    subject.insert(Thing.new(nil, 5, 6))
  end

  describe '.scope' do
    context 'when a scope w/o arguments is defined' do
      before do
        ThingRepository.class_eval do
          scope :a_equals_2 do
            where(a: 2)
          end
        end
      end

      it 'works!' do
        expect(subject.query.a_equals_2.count).to eq 2
      end

      it 'returns an array of instances of the appropriate class' do
        expect(subject.query.a_equals_2.first).to be_an_instance_of Thing
      end
    end

    context 'when a scope w/ arguments is defined' do
      before do
        ThingRepository.class_eval do
          scope :a_equals do |n|
            where(a: n)
          end
        end
      end

      it 'works!' do
        expect(subject.query.a_equals(2).count).to eq 2
      end
    end

    context 'when two scopes are defined and chained' do
      before do
        ThingRepository.class_eval do
          scope :a_equals do |n|
            where(a: n)
          end

          scope :b_equals do |n|
            where(b: n)
          end
        end
      end

      it 'works!' do
        expect(subject.query.a_equals(2).b_equals(4).count).to eq 1
      end
    end

    context 'when an unknown scope is used' do
      it 'raises the NoMethodError' do
        expect {
          subject.query.something
        }.to raise_error NoMethodError
      end
    end
  end

  describe '.query' do
    describe '#remove' do
      context 'when no scope is given' do
        it 'removes all objects' do
          subject.query.remove
          expect(subject.query.count).to eq 0
        end
      end

      context 'when the scope filters 2 objects from 3' do
        before do
          ThingRepository.class_eval do
            scope :a_equals_2 do
              where(a: 2)
            end
          end
        end

        it 'removes 2 objects' do
          subject.query.a_equals_2.remove
          expect(subject.query.count).to eq 1
        end
      end
    end

    describe '#destroy' do
      context 'when no scope is given' do
        it 'destroys all objects' do
          subject.query.destroy
          expect(subject.query.count).to eq 0
        end

        it 'calls #destroy for each object' do
          expect(subject).to receive(:destroy).exactly(3).times
          subject.query.destroy
        end
      end

      context 'when the scope filters 2 objects from 3' do
        before do
          ThingRepository.class_eval do
            scope :a_equals_2 do
              where(a: 2)
            end
          end
        end

        it 'destroys 2 objects' do
          subject.query.a_equals_2.destroy
          expect(subject.query.count).to eq 1
        end

        it 'calls #destroy for each object' do
          expect(subject).to receive(:destroy).exactly(2).times
          subject.query.a_equals_2.destroy
        end
      end
    end
  end

  def create_database
    sequel_conn.create_table(:things) do
      primary_key :id
      Integer :a
      Integer :b
    end
  end
end

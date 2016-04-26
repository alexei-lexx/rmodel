RSpec.shared_examples 'scopable repository' do
  before do
    stub_const 'Thing', Struct.new(:id, :a, :b)
    stub_const 'ThingRepository', Class.new(Rmodel::Repository)

    # Use the same scope syntax for Mongo and Sequel
    class ThingRepository
      scope :a_equals_2 do
        where(a: 2)
      end

      scope :a_equals do |n|
        where(a: n)
      end

      scope :b_equals do |n|
        where(b: n)
      end
    end
  end

  let(:mapper) { mapper_klass.new(Thing).define_attributes(:a, :b) }
  let(:one_thing) { Thing.new(nil, 2, 3) }

  subject { ThingRepository.new(source, mapper) }

  before do
    create_database if defined?(create_database)

    subject.insert(one_thing)
    subject.insert(Thing.new(nil, 2, 4))
    subject.insert(Thing.new(nil, 5, 6))
  end

  describe '.scope' do
    context 'when a scope w/o arguments is defined' do
      it 'works!' do
        expect(subject.fetch.a_equals_2.count).to eq 2
      end

      it 'returns an array of instances of the appropriate class' do
        expect(subject.fetch.a_equals_2.first).to be_an_instance_of Thing
      end
    end

    context 'when a scope w/ arguments is defined' do
      it 'works!' do
        expect(subject.fetch.a_equals(2).count).to eq 2
      end
    end

    context 'when two scopes are defined and chained' do
      it 'works!' do
        expect(subject.fetch.a_equals(2).b_equals(4).count).to eq 1
      end
    end

    context 'when an unknown scope is used' do
      it 'raises the NoMethodError' do
        expect { subject.fetch.something }.to raise_error NoMethodError
      end
    end
  end

  describe '#fetch' do
    describe '#delete_all' do
      context 'when no scope is given' do
        it 'removes all objects' do
          subject.fetch.delete_all
          expect(subject.fetch.count).to eq 0
        end
      end

      context 'when the scope filters 2 objects from 3' do
        it 'removes 2 objects' do
          subject.fetch.a_equals_2.delete_all
          expect(subject.fetch.count).to eq 1
        end
      end
    end

    describe '#destroy_all' do
      context 'when no scope is given' do
        it 'destroys all objects' do
          subject.fetch.destroy_all
          expect(subject.fetch.count).to eq 0
        end

        it 'calls #destroy for each object' do
          expect(subject).to receive(:destroy).exactly(3).times
          subject.fetch.destroy_all
        end
      end

      context 'when the scope filters 2 objects from 3' do
        it 'destroys 2 objects' do
          subject.fetch.a_equals_2.destroy_all
          expect(subject.fetch.count).to eq 1
        end

        it 'calls #destroy for each object' do
          expect(subject).to receive(:destroy).exactly(2).times
          subject.fetch.a_equals_2.destroy_all
        end
      end
    end

    describe '#find' do
      context 'when an existent id is given' do
        it 'returns a proper object' do
          found = subject.fetch.find(one_thing.id)
          expect(found.id).to eq one_thing.id
        end
      end

      context 'when a non-existent id is given' do
        it 'returns nil' do
          found = subject.fetch.find('wrong-id')
          expect(found).to be_nil
        end
      end
    end
  end

  describe '#delete_all' do
    context 'when no scope is given' do
      it 'deletes all objects' do
        subject.delete_all
        expect(subject.fetch.count).to eq 0
      end
    end
  end

  describe '#destroy_all' do
    context 'when no scope is given' do
      it 'deletes all objects' do
        subject.destroy_all
        expect(subject.fetch.count).to eq 0
      end

      it 'calls #destroy for each object' do
        expect(subject).to receive(:destroy).exactly(3).times
        subject.destroy_all
      end
    end
  end
end

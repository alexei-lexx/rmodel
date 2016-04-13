RSpec.shared_examples 'timestampable repository' do
  before do
    stub_const('ThingRepository', Class.new(Rmodel::Repository))
  end

  let(:mapper) { mapper_klass.new(Thing).define_attribute(:name) }

  subject { ThingRepository.new(source, mapper) }

  context 'when the entity object has attributes created_at and updated_at' do
    before do
      stub_const('Thing', Struct.new(:id, :name, :created_at, :updated_at))
      mapper.define_attributes(:created_at, :updated_at)
    end

    context 'when we insert(object)' do
      context 'and the object.created_at is already set' do
        let(:thing) { Thing.new(nil, 'chair', Time.now) }

        it 'doesnt change the value of created_at' do
          set_created_at = thing.created_at
          subject.insert(thing)
          expect(thing.created_at).to eq set_created_at
        end
      end

      context 'and the object.created_at is not set yet' do
        let(:thing) { Thing.new(nil, 'chair') }

        before { subject.insert(thing) }

        it 'sets the value of created_at' do
          expect(thing.created_at).not_to be_nil
        end

        it 'saves the created_at in a database' do
          expect(subject.find(thing.id).created_at).not_to be_nil
        end
      end
    end

    context 'when we update(object)' do
      let(:thing) { Thing.new(nil, 'chair') }

      before do
        subject.insert(thing)
        thing.name = 'table'
        subject.update(thing)
      end

      it 'sets the value of updated_at' do
        expect(thing.updated_at).not_to be_nil
      end

      it 'saves the updated_at in a database' do
        expect(subject.find(thing.id).updated_at).not_to be_nil
      end
    end

    context 'when the Time.current method exists' do
      let(:thing) { Thing.new }

      before do
        stub_const 'Time', Time
        def Time.current
          now
        end
        allow(Time).to receive(:current)

        subject.insert(thing)
      end

      it 'uses it on insert' do
        expect(thing.created_at).not_to be_nil
        expect(Time).to have_received(:current)
      end

      it 'uses it on update' do
        subject.update(thing)

        expect(thing.updated_at).not_to be_nil
        expect(Time).to have_received(:current).twice
      end
    end
  end

  context 'when the entity has no attributes :created_at and updated_at' do
    before do
      stub_const('Thing', Struct.new(:id, :name))
    end

    let(:thing) { Thing.new(nil, 'chair') }

    context 'when we insert(object)' do
      it 'does nothing special' do
        subject.insert(thing)
        expect(thing.respond_to?(:created_at)).to be false
      end
    end

    context 'when we update(object)' do
      before { subject.insert(thing) }

      it 'does nothing special' do
        thing.name = 'table'
        subject.update(thing)
        expect(thing.respond_to?(:updated_at)).to be false
      end
    end
  end
end

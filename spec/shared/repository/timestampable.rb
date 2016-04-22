RSpec.shared_examples 'timestampable repository' do
  let(:mapper) { mapper_klass.new(Thing).define_attribute(:name) }

  subject { Rmodel::Repository.new(source, mapper) }

  context 'when the entity object has timestamp attributes' do
    before do
      stub_const('Thing', Struct.new(:id, :name, :created_at, :updated_at))
      mapper.define_attributes(:created_at, :updated_at)
    end

    context 'when we insert(object)' do
      context 'and created_at is already set' do
        let(:thing) { Thing.new(nil, 'chair', Time.now) }

        it "doesn't change the value of created_at" do
          set_created_at = thing.created_at
          subject.insert(thing)
          expect(thing.created_at).to eq set_created_at
        end
      end

      context 'and created_at is not set yet' do
        let(:thing) { Thing.new }

        before { subject.insert(thing) }

        it 'sets the value of created_at' do
          expect(thing.created_at).not_to be_nil
        end

        it 'saves created_at in the database' do
          expect(subject.find(thing.id).created_at).not_to be_nil
        end
      end
    end

    context 'when we update(object)' do
      let(:thing) { Thing.new }

      before do
        subject.insert(thing)
        thing.name = 'chair'
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
      end

      context 'on insert' do
        before { subject.insert(thing) }

        it 'calls Time.current' do
          expect(Time).to have_received(:current)
        end
      end

      context 'on update' do
        before do
          subject.insert(thing)
          subject.update(thing)
        end

        it 'calls Time.current' do
          expect(Time).to have_received(:current).twice
        end
      end
    end
  end

  context 'when the entity has no attributes created_at and updated_at' do
    before { stub_const 'Thing', Struct.new(:id, :name) }

    let(:thing) { Thing.new }

    it "doesn't raise errors" do
      expect do
        subject.insert(thing)
        thing.name = 'chair'
        subject.update(thing)
      end.not_to raise_error
    end
  end

  context 'when the repo class is inherited' do
    before do
      stub_const('Thing', Struct.new(:id, :name, :created_at, :updated_at))
      mapper.define_attributes(:created_at, :updated_at)
      stub_const 'ThingRepository', Class.new(Rmodel::Repository)
    end

    subject { ThingRepository.new(source, mapper) }

    context 'on insert' do
      let(:thing) { Thing.new }

      before { subject.insert(thing) }

      it 'sets the created_at' do
        found = subject.find(thing.id)
        expect(found.created_at).not_to be_nil
      end
    end

    context 'on update' do
      let(:thing) { Thing.new }

      before do
        subject.insert(thing)
        thing.name = 'chair'
        subject.update(thing)
      end

      it 'sets the updated_at' do
        found = subject.find(thing.id)
        expect(found.updated_at).not_to be_nil
      end
    end
  end
end

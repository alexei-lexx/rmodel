RSpec.shared_examples 'initialization' do
  before do
    stub_const 'Thing', Struct.new(:id, :name)

    stub_const 'ThingMapper', Class.new(base_mapper_klass)
    class ThingMapper
      model Thing
      attributes :name
    end

    stub_const 'ThingRepository', Class.new(Rmodel::Repository)
    class ThingRepository
      attr_reader :source, :mapper
    end
  end

  let(:connection) { Object.new }
  let(:mapper) { ThingMapper.new }

  describe '.source(&block)' do
    subject { ThingRepository.new(nil, ThingMapper.new) }

    context 'when it is called' do
      before do
        source_instance = source
        ThingRepository.class_eval do
          source { source_instance }
        end
      end

      it 'sets the appropriate #source' do
        expect(subject.source).not_to be_nil
      end
    end

    context 'when it is not called' do
      it 'make #initialize raise an error' do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe '.mapper(mapper_klass)' do
    subject { ThingRepository.new(connection, nil) }

    context 'when it is called' do
      before do
        class ThingRepository
          mapper ThingMapper
        end
      end

      it 'sets the appropriate #mapper' do
        expect(subject.mapper).to be_an_instance_of ThingMapper
      end
    end

    context 'when it is not called' do
      context 'and the mapper class is defined' do
        it 'gets the right class by convention' do
          expect(subject.mapper).to be_an_instance_of ThingMapper
        end
      end

      context 'and the mapper class is not defined' do
        before { hide_const('ThingMapper') }

        it 'make #initialize raise an error' do
          expect do
            ThingRepository.new(connection, nil)
          end.to raise_error ArgumentError
        end
      end
    end
  end

  describe '#initialize(connection, collection, mapper)' do
    context 'when all constructor arguments are passed' do
      it 'works!' do
        expect do
          ThingRepository.new(connection, mapper)
        end.not_to raise_error
      end
    end
  end
end

RSpec.shared_examples 'initialization' do
  before do
    stub_const 'Thing', Struct.new(:id, :name)

    stub_const 'ThingMapper', Class.new(base_mapper_klass)
    class ThingMapper
      attributes :name
    end

    stub_const 'ThingRepository', Class.new(Rmodel::Repository)
    class ThingRepository
      attr_reader :source, :mapper
    end
  end

  let(:source) { Object.new }
  let(:mapper) { ThingMapper.new(Thing) }

  describe '#initialize(source, collection, mapper)' do
    context 'when all constructor arguments are passed' do
      it 'works!' do
        expect do
          ThingRepository.new(source, mapper)
        end.not_to raise_error
      end
    end

    context 'when source is nil' do
      it 'raises the error' do
        expect do
          ThingRepository.new(nil, mapper)
        end.to raise_error(ArgumentError)
      end
    end

    context 'when mapper is nil' do
      it 'raises the error' do
        expect do
          ThingRepository.new(source, nil)
        end.to raise_error(ArgumentError)
      end
    end
  end
end

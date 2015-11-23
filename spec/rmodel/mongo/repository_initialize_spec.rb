RSpec.describe Rmodel::Mongo::Repository do
  let(:connection) { Object.new }
  let(:source) do
    Rmodel::Mongo::Source.new(connection, :things)
  end
  let(:mapper) { ThingMapper.new }

  before do
    Mongo::Logger.logger.level = Logger::ERROR

    stub_const 'Thing', Struct.new(:id, :name)

    stub_const 'ThingMapper', Class.new(Rmodel::Mongo::Mapper)
    class ThingMapper
      model Thing
      attributes :name, :email
    end

    stub_const 'ThingRepository', Class.new(Rmodel::Mongo::Repository)
    class ThingRepository
      attr_reader :source, :mapper
    end
  end

  describe '.source(&block)' do
    subject { ThingRepository.new(nil, mapper) }

    context 'when it is called' do
      before do
        source_instance = source
        ThingRepository.class_eval do
          source { source_instance }
        end
      end

      it 'sets the appropriate #source' do
        expect(subject.source).to be_an_instance_of Rmodel::Mongo::Source
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

  describe '#initialize(source, mapper)' do
    context 'when all constructor arguments are passed' do
      it 'works!' do
        expect do
          ThingRepository.new(source, mapper)
        end.not_to raise_error
      end
    end
  end
end

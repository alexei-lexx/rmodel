RSpec.shared_examples 'injectable repository' do
  describe '.injector' do
    it 'is a module' do
      expect(Rmodel::Repository.injector).to be_a Module
    end

    it 'returns the same instance each time' do
      expected_injector = Rmodel::Repository.injector
      expect(Rmodel::Repository.injector).to equal expected_injector
    end
  end

  before do
    stub_const 'Thing', Struct.new(:id, :name)
    stub_const 'MyRepository', Class.new(Rmodel::Repository)

    a_source = source
    mapper = mapper_klass.new(Thing).define_attribute(:name)

    MyRepository.class_eval do
      define_method :initialize do
        super(a_source, mapper)
      end

      def custom_method; end
    end
  end

  let(:repository) do
    MyRepository.injector.instance_variable_get('@repository').__target_object__
  end

  context "when it's included in a class" do
    before do
      stub_const 'Host', Class.new

      class Host
        include MyRepository.injector
      end
    end

    context 'when no method is called' do
      before { allow(MyRepository).to receive(:new) }

      it "doesn't instantiate the repository" do
        expect(MyRepository).not_to have_received(:new)
      end
    end

    describe '.find' do
      it 'is delegated to the repository' do
        expect(repository).to receive(:find).with(1)
        Host.find(1)
      end
    end

    describe '.fetch' do
      it 'is delegated to the repository' do
        expect(repository).to receive(:fetch)
        Host.fetch
      end
    end

    describe '.custom_method' do
      it 'is delegated to the repository' do
        expect(repository).to receive(:custom_method)
        Host.custom_method
      end
    end
  end

  context 'when it extends an object' do
    let(:tester) { Object.new }

    before { tester.extend MyRepository.injector }

    describe '.find' do
      it 'is delegated to the repository' do
        expect(repository).to receive(:find).with(1)
        tester.find(1)
      end
    end

    describe '.custom_method' do
      it 'is delegated to the repository' do
        expect(repository).to receive(:custom_method)
        tester.custom_method
      end
    end
  end
end

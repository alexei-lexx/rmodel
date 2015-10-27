RSpec.shared_examples 'callbackable repository' do
  describe Rmodel::Base::RepositoryExt::Callbackable do
    before do
      stub_const('Thing', Struct.new(:id, :name))
      ThingRepository.class_eval do
        include Rmodel::Base::RepositoryExt::Callbackable
      end
    end

    describe '.before_insert' do
      let(:thing) { Thing.new }

      context 'when a block is given' do
        before do
          ThingRepository.class_eval do
            before_insert do |thing|
              thing.name = 'set before insert'
            end
          end
        end

        it 'works' do
          subject.insert(thing)
          expect(thing.name).to eq 'set before insert'
          expect(subject.query.first.id).to eq thing.id
        end
      end

      context 'when a method name is given' do
        before do
          ThingRepository.class_eval do
            before_insert :set_name

            private

            def set_name(thing)
              thing.name = 'set before insert'
            end
          end
        end

        it 'works' do
          subject.insert(thing)
          expect(thing.name).to eq 'set before insert'
          expect(subject.query.first.id).to eq thing.id
        end
      end
    end
  end
end

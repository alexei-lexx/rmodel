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
      let(:just_inserted) { subject.query.first }

      context 'when a block is given' do
        before do
          ThingRepository.class_eval do
            before_insert do |thing|
              thing.name = 'set before insert'
            end
          end
          subject.insert(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set before insert'
          expect(just_inserted.name).to eq 'set before insert'
        end
      end

      context 'when a method name is given' do
        before do
          ThingRepository.class_eval do
            before_insert :set_name

            def set_name(thing)
              thing.name = 'set before insert'
            end
          end
          subject.insert(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set before insert'
          expect(just_inserted.name).to eq 'set before insert'
        end
      end
    end

    describe '.after_insert' do
      let(:thing) { Thing.new }
      let(:just_inserted) { subject.query.first }

      context 'when a block is given' do
        before do
          ThingRepository.class_eval do
            after_insert do |thing|
              thing.name = 'set after insert'
            end
          end
          subject.insert(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set after insert'
          expect(just_inserted.name).to be_nil
        end
      end

      context 'when a method name is given' do
        before do
          ThingRepository.class_eval do
            after_insert :set_name

            def set_name(thing)
              thing.name = 'set after insert'
            end
          end
          subject.insert(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set after insert'
          expect(just_inserted.name).to be_nil
        end
      end
    end

    describe '.before_update' do
      let(:thing) { Thing.new }
      before { subject.insert(thing) }
      let(:just_updated) { subject.query.first }

      context 'when a block is given' do
        before do
          ThingRepository.class_eval do
            before_update do |thing|
              thing.name = 'set before update'
            end
          end
          subject.update(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set before update'
          expect(just_updated.name).to eq 'set before update'
        end
      end

      context 'when a method name is given' do
        before do
          ThingRepository.class_eval do
            before_update :set_name

            def set_name(thing)
              thing.name = 'set before update'
            end
          end
          subject.update(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set before update'
          expect(just_updated.name).to eq 'set before update'
        end
      end
    end

    describe '.after_update' do
      let(:thing) { Thing.new }
      before { subject.insert(thing) }
      let(:just_updated) { subject.query.first }

      context 'when a block is given' do
        before do
          ThingRepository.class_eval do
            after_update do |thing|
              thing.name = 'set after update'
            end
          end
          subject.update(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set after update'
          expect(just_updated.name).to be_nil
        end
      end

      context 'when a method name is given' do
        before do
          ThingRepository.class_eval do
            after_update :set_name

            def set_name(thing)
              thing.name = 'set after update'
            end
          end
          subject.update(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set after update'
          expect(just_updated.name).to be_nil
        end
      end
    end

    describe '.before_remove' do
      let(:thing) { Thing.new }
      before { subject.insert(thing) }
      let(:total_count) { subject.query.count }

      context 'when a block is given' do
        before do
          ThingRepository.class_eval do
            before_remove do |thing|
              thing.name = 'set before remove'
            end
          end
          subject.remove(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set before remove'
          expect(total_count).to eq 0
        end
      end

      context 'when a method name is given' do
        before do
          ThingRepository.class_eval do
            before_remove :set_name

            def set_name(thing)
              thing.name = 'set before remove'
            end
          end
          subject.remove(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set before remove'
          expect(total_count).to eq 0
        end
      end
    end

    describe '.after_remove' do
      let(:thing) { Thing.new }
      before { subject.insert(thing) }
      let(:total_count) { subject.query.count }

      context 'when a block is given' do
        before do
          ThingRepository.class_eval do
            after_remove do |thing|
              thing.name = 'set after remove'
            end
          end
          subject.remove(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set after remove'
          expect(total_count).to eq 0
        end
      end

      context 'when a method name is given' do
        before do
          ThingRepository.class_eval do
            after_remove :set_name

            def set_name(thing)
              thing.name = 'set after remove'
            end
          end
          subject.remove(thing)
        end

        it 'works' do
          expect(thing.name).to eq 'set after remove'
          expect(total_count).to eq 0
        end
      end
    end
  end
end

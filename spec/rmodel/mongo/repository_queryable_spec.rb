RSpec.describe Rmodel::Mongo::Repository do
  include_context 'clean Mongo database'

  before do
    Rmodel.sessions[:default] = mongo_session
    stub_const('Thing', Struct.new(:id, :a, :b))
    stub_const('ThingRepository', Class.new(Rmodel::Mongo::Repository) {
      simple_factory Thing, :a, :b
    })
  end

  let(:repo) { ThingRepository.new }

  before do
    repo.insert(Thing.new(nil, 2, 3))
    repo.insert(Thing.new(nil, 2, 4))
    repo.insert(Thing.new(nil, 5, 6))
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
        expect(repo.query.a_equals_2.count).to eq 2
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
        expect(repo.query.a_equals(2).count).to eq 2
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
        expect(repo.query.a_equals(2).b_equals(4).count).to eq 1
      end
    end

    context 'when an unknown scope is used' do
      it 'raises the NoMethodError' do
        expect {
          repo.query.something
        }.to raise_error NoMethodError
      end
    end
  end
end
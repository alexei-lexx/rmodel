RSpec.shared_context 'clean moped' do
  before(:all) { DatabaseCleaner[:moped].clean_with(:truncation) }
  before { DatabaseCleaner[:moped].start }
  after { DatabaseCleaner[:moped].clean }
end

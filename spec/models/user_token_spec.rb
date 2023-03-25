require 'rails_helper'

RSpec.describe UserToken, type: :model, model: true do
  context 'db columns' do
    it { should have_db_column(:token).of_type(:string) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should belong_to(:user) }
  end
end

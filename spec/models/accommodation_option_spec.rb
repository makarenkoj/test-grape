require 'rails_helper'

RSpec.describe AccommodationOption, type: :model do
  context 'db columns' do
    it { should have_db_column(:accommodation_id).of_type(:integer) }
    it { should have_db_column(:option_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should belong_to(:accommodation) }
    it { should belong_to(:option) }
  end
end

require 'rails_helper'

RSpec.describe City, type: :model do
  context 'db columns' do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:country_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should belong_to(:country) }
  end

  describe 'validations' do
    context 'name' do
      let(:city) { build :city, name: name }

      context 'when a name is valid' do
        let(:name) { 'kyiv' }

        it { expect(city).to be_valid }
      end

      context 'when a name is not valid' do
        let(:name) { 'tt' }

        it { expect(city).not_to be_valid }
      end
    end

    context 'validates filds' do
      it { should validate_presence_of(:name) }
    end
  end
end

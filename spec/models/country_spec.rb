require 'rails_helper'

RSpec.describe Country, type: :model do
  context 'db columns' do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should have_many(:cities).dependent(:destroy) }
  end

  describe 'validations' do
    context 'name' do
      let(:country) { build :country, name: name }

      context 'when a name is valid' do
        let(:name) { 'ukraine' }

        it { expect(country).to be_valid }
      end

      context 'when a name is not valid' do
        let(:name) { 'r' }

        it { expect(country).not_to be_valid }
      end
    end

    context 'validates filds' do
      it { should validate_presence_of(:name) }
      it { should validate_uniqueness_of(:name) }
    end
  end
end

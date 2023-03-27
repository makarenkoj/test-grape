require 'rails_helper'

RSpec.describe Accommodation, type: :model do
  context 'db columns' do
    it { should have_db_column(:title).of_type(:string) }
    it { should have_db_column(:type).of_type(:string) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:city_id).of_type(:integer) }
    it { should have_db_column(:phone_number).of_type(:string) }
    it { should have_db_column(:address).of_type(:string) }
    it { should have_db_column(:price).of_type(:integer) }
    it { should have_db_column(:room).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should have_many(:accommodation_options).dependent(:destroy) }
    it { should have_many(:options).through(:accommodation_options) }
    it { should have_many(:bookings).dependent(:destroy) }
    it { should belong_to(:city) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    context 'validates filds' do
      it { should validate_presence_of(:title) }
      it { should validate_presence_of(:type) }
      it { should validate_presence_of(:phone_number) }
      it { should validate_presence_of(:address) }
      it { should validate_presence_of(:price) }

      it 'should allow valid values' do
        Accommodation::TYPES.each_key do |key|
          should allow_value(key).for(:type)
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe User, type: :model, model: true do
  context 'db columns' do
    it { should have_db_column(:email).of_type(:string) }
    it { should have_db_column(:username).of_type(:string) }
    it { should have_db_column(:role).of_type(:string) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should have_many(:user_tokens).dependent(:destroy) }
    it { should have_many(:accommodations).dependent(:destroy) }
    it { should have_many(:bookings).dependent(:destroy) }
  end

  describe 'validations' do
    context 'password' do
      let(:user) { build :user, password: password }

      context 'when a password is valid' do
        let(:password) { '12345678Qq!' }
        it { expect(user).to be_valid }
      end

      context 'when a password is not valid' do
        let(:password) { 'password' }
        it { expect(user).not_to be_valid }
      end

      it 'password complexity' do
        should allow_value('12345678Qq!')
          .for(:password)
          .with_message(I18n.t('errors.user.attributes.password'))
      end
    end

    context 'username' do
      let(:user) { build :user, username: username }

      context 'when a username is valid' do
        let(:username) { 'mega-volt' }

        it { expect(user).to be_valid }
      end

      context 'when a username is not valid' do
        let(:username) { 'meg' }

        it { expect(user).not_to be_valid }
      end
    end

    context 'validates filds' do
      subject { build(:user) }

      it { should validate_presence_of(:username) }
      it { should validate_presence_of(:role) }
      it { should validate_presence_of(:email) }
  
      it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
      it { should validate_uniqueness_of(:username) }

      it 'should allow valid values' do
        User::ROLES.each_key do |key|
          should allow_value(key).for(:role)
        end
      end
    end
  end
end

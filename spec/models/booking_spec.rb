require 'rails_helper'

RSpec.describe Booking, type: :model do
  context 'db columns' do
    it { should have_db_column(:accommodation_id).of_type(:integer) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:start_date).of_type(:datetime) }
    it { should have_db_column(:end_date).of_type(:datetime) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should belong_to(:accommodation) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    context 'datetime' do
      context 'when a satrt date and end date is valid' do
        it 'booking for today only' do
          booking = build(:booking, start_date: Time.current.to_date, end_date: Time.current.to_date)

          expect(booking).to be_valid
        end

        it 'booking for 5 days' do
          booking = build(:booking, start_date: (Time.current + 1.days).to_date, end_date: (Time.current + 6.days).to_date)

          expect(booking).to be_valid
        end
      end

      context 'when a satrt date and end date is invalid' do
        it 'booking for yesteday' do
          expect do
            create(:booking, start_date: (Time.current - 1.days).to_date, end_date: (Time.current - 1.days).to_date)
          end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Datetime Can't be less than today")
        end

        it 'booking start -5 days and end tommorow' do
          expect do
            create(:booking, start_date: (Time.current - 5.days).to_date, end_date: (Time.current + 2.days).to_date)
          end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Datetime Can't be less than today")
        end

        it 'end day less than start' do
          expect do
            create(:booking, start_date: (Time.current + 5.days).to_date, end_date: (Time.current + 1.days).to_date)
          end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Datetime Start date cannot be greater than the end date')
        end

        it 'date blank' do
          expect do
            create(:booking, start_date: nil, end_date: nil)
          end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Start date can't be blank, End date can't be blank")
        end

        it 'brokenn date' do
          expect do
            create(:booking, start_date: 'nil', end_date: 'nil')
          end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Start date can't be blank, End date can't be blank")
        end
      end
    end
  end
end

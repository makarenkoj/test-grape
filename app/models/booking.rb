class Booking < ApplicationRecord
  belongs_to :accommodation

  validates :start_date, :end_date, presence: true
  validate :datetime_validation

  private

  def datetime_validation
    return unless start_date.present? && end_date.present?
    return errors.add(:datetime, I18n.t('errors.date.today')) if start_date.to_date < Time.current.to_date || end_date.to_date < Time.current.to_date
    return errors.add(:datetime, I18n.t('errors.date.start_date')) if start_date > end_date
  end
end

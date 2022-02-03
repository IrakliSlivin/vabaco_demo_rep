# frozen_string_literal: true

class Pharmacy < ApplicationRecord
  belongs_to :provider
  has_one :pharmacy_area_code
  has_many :pharmacy_schedules

  validates :pharmacy_code, presence: true, length: { maximum: 50 }, uniqueness: { scope: :provider_id }
end

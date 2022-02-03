# frozen_string_literal: true

class DeliveryCompany < ApplicationRecord
  has_one :delivery_company_price

  mount_uploader :logo, DeliveryCompanyLogoUploader
end

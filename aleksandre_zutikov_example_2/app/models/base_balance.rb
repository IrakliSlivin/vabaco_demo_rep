# frozen_string_literal: true

class BaseBalance < ApplicationRecord
  include OperationNumeratorHelper
  before_create :set_number

  belongs_to :base_balance_status, class_name: 'Enum::BaseBalanceStatus'
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true
  belongs_to :finished_by, class_name: 'User', optional: true

  has_many :base_balance_items

  scope :active, -> { where(deleted: false) }
end

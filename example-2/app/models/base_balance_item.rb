# frozen_string_literal: true

class BaseBalanceItem < ApplicationRecord
  belongs_to :base_balance
  belongs_to :warehouse
  belongs_to :location
  belongs_to :item
  belongs_to :operation_log, class_name: 'Balance::OperationLog', optional: true

  validates :execution_date, presence: true

  scope :pending_execution, -> { where(executed: false) }
end

# frozen_string_literal: true

class BaseBalanceBlueprint < Blueprinter::Base
  identifier :id

  view :normal do
    fields :number, :operation_date, :quantity, :amount, :comment, :finished_at, :deleted, :created_at, :updated_at

    association :base_balance_status, blueprint: DictionaryBlueprint, view: :import
    association :created_by, blueprint: UserBlueprint, view: :author
    association :updated_by, blueprint: UserBlueprint, view: :author
    association :finished_by, blueprint: UserBlueprint, view: :author
  end
end

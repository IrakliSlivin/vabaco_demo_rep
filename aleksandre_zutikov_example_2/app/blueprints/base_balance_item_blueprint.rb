# frozen_string_literal: true

class BaseBalanceItemBlueprint < Blueprinter::Base
  identifier :id

  view :normal do
    fields :execution_date, :serial_batch, :manufacture_date, :shelf_life, :quantity, :amount, :base_balance_id

    association :warehouse, blueprint: DictionaryBlueprint, view: :import_with_code
    association :location, blueprint: DictionaryBlueprint, view: :import_with_code
    association :item, blueprint: ItemBlueprint, view: :import
  end
end

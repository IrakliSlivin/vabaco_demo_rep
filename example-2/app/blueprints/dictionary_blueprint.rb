# frozen_string_literal: true

class DictionaryBlueprint < Blueprinter::Base
  identifier :id

  view :import do
    fields :name
  end

  view :import_with_code do
    fields :name, :code
  end

  view :normal do
    include_view :import
  end

end

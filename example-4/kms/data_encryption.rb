class ActiveRecord::Base

  def self.data_encryption(*columns)
    attr_reader *columns

    columns.each do |column|
      self.base_class.class_eval do
        define_method column do
          value = value_from_instance(column)
          return value if value.present?
          decrypt_data(column)
        end
      end
    end

    before_save do
      Components::HsmCallService.new(self, columns, :encrypt).request
    end
  end

  private
  def value_from_instance(column)
    (self.instance_variable_get "@#{column}".to_sym) || self.attributes[column.to_s]
  end

  def decrypt_data(column)
    return if self.attributes["#{column}_encrypted".to_s].nil?
    Components::HsmCallService.new(self, column, :decrypt).request
  end
end
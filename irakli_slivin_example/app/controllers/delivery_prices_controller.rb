# frozen_string_literal: true

class DeliveryPricesController < ApplicationController

  before_action :validate_authentication

  def delivery_price
    service = MedicamentDeliveryPriceService.new(delivery_price_params, current_customer)
    result = service.price
    rest_respond_service(result)
  end

  private

  def delivery_price_params
    params.permit(:pharmacy_id, :delivery_company_id, :delivery_location_id, :medication_price)
  end
end
# frozen_string_literal: true

class MedicamentDeliveryPriceService

  def initialize(params, current_customer)
    @params = params
    @current_customer = current_customer
  end

  def price
    find_delivery_company
    delivery_provider_price
    calculate_delivery_price
  end

  private

  def find_delivery_company
    @delivery_company = DeliveryCompany.find(@params[:delivery_company_id])
  end

  def delivery_provider_price
    @delivery_price_data =
      Middleware::DeliveryService.new.order_price(params[:delivery_company_id], params[:delivery_location_id])
  end

  def calculate_delivery_price
    delivery_company_price = DeliveryCompanyPrice.find_by(delivery_company_id: @delivery_company_id)
    provider_price = @delivery_price_data[:amount].to_f/100

    if delivery_company_price.use_default_price
      # Always use default price
      delivery_price = delivery_company_price.default_price
    else
      price_in_range = DeliveryDistance.find_price(delivery_company_price.id, distance)

      if price_in_range
        # Delivery is at set distance
        delivery_price = price_in_range.price
      elsif distance <= delivery_company_price.distance_limit_for_price
        # Delivery is close, set default price
        delivery_price = delivery_company_price.default_price
      else
        # Delivery is far away, set maximum between prices
        delivery_price = [provider_price, delivery_company_price.default_price].max
      end
    end

    {
      delivery_price: delivery_price,
      additional_fee: additional_fee(delivery_company_price)
    }
  end

  def additional_fee(delivery_company_price)
    return unless @params[:medication_price] < delivery_company_price.minimum_medication_price

    (delivery_company_price.minimum_medication_price - @params[:medication_price]).round(2)
  end

  def distance
    customer_addresses = ActiveRecord::Base::sanitize_sql_array ['LEFT JOIN customer_addresses on customer_addresses.id = :id',
                                                                 {id: @params[:delivery_location_id]}]

    Pharmacy.select('ROUND( (MIN((point(coalesce(pharmacy.longitude, 0),
                              coalesce(pharmacy.latitude,0)) <@>
                              point(coalesce(customer_addresses.longitude, 0),
                              coalesce(customer_addresses.latitude, 0)))) * 1.60934)::decimal, 2) as distance')
            .where('pharmacy.id': @params[:pharmacy_id])
            .joins(customer_addresses).first.distance
  end
end
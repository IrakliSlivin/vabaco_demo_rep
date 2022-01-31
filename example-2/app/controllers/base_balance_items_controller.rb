# frozen_string_literal: true

class BaseBalanceItemsController < ApplicationController
  def index
    result = BaseBalances::ItemService.new(index_params, @current_user).index

    list_respond_service(result, BaseBalanceItemBlueprint, :normal)
  end

  def create
    service = BaseBalances::ItemService.new(record_item_params, @current_user)
    result = service.create

    rest_respond_service(result, BaseBalanceItemBlueprint, :normal)
  end

  def update
    service = BaseBalances::ItemService.new(record_item_params, @current_user)
    result = service.update

    rest_respond_service(result, BaseBalanceItemBlueprint, :normal)
  end

  def destroy
    service = BaseBalances::ItemService.new(record_item_params, @current_user)
    result = service.destroy

    rest_respond_service(result)
  end

  private

  def record_item_params
    params.permit(
      :id, :warehouse_id, :location_id, :item_id, :execution_date, :serial_batch,
      :manufacture_date, :shelf_life, :quantity, :amount, :base_balance_id
    )
  end

  def index_params
    params.permit(:base_balance_id, :page, :page_limit, filters: [:column, :value, value: []])
  end
end

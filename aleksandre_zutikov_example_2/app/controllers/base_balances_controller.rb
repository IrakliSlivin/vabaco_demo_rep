# frozen_string_literal: true

class BaseBalancesController < ApplicationController
  include GridOptions

  def create
    service = BaseBalances::GeneralService.new(record_params, current_user)
    result = service.create
    rest_respond_service(result, BaseBalanceBlueprint, :normal)
  end

  def show
    service = BaseBalances::GeneralService.new(record_params, current_user)
    result = service.show
    rest_respond_service(result, BaseBalanceBlueprint, :normal)
  end

  def update
    service = BaseBalances::GeneralService.new(record_params, current_user)
    result = service.update
    rest_respond_service(result, BaseBalanceBlueprint, :normal)
  end

  def destroy
    service = BaseBalances::GeneralService.new(record_params, current_user)
    service.destroy
    rest_respond_service
  end

  def process_operation
    service = BaseBalances::GeneralService.new(record_params, current_user)
    result = service.process_operation
    rest_respond_service(result, BaseBalanceBlueprint, :normal)
  end

  def list
    get_default_list(List::BaseBalanceGrid)
    rest_respond_service(@list)
  end

  def grid_options
    result = init_grid_options(List::BaseBalanceGrid)
    rest_respond_service(result)
  end

  private

  def record_params
    params.permit(:id, :comment)
  end
end

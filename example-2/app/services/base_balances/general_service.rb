# frozen_string_literal: true

module BaseBalances
  class GeneralService
    attr_reader :params, :current_user, :current_date, :topic

    def initialize(params, current_user)
      @params = params
      @current_user = current_user
      @current_date = DateTime.now.in_time_zone('Tbilisi')
      @topic = :base_balances
    end

    def create
      check_permissions!(:_add)

      record = BaseBalance.new(params)
      record.base_balance_status = Enum::BaseBalanceStatus.value(:current)
      record.operation_date = current_date
      record.created_by = current_user
      record.updated_by = current_user
      record.save!

      record
    end

    def update
      check_permissions!(:_edit)

      find_record

      check_current_status!

      @record.assign_attributes(params)
      @record.updated_by = current_user
      @record.save!

      @record
    end

    def show
      check_permissions!(:_view)

      find_record

      @record
    end

    def destroy
      check_permissions!(:_delete)

      find_record

      check_current_status!

      @record.update!(deleted: true)
    end

    def process_operation
      check_permissions!(:_edit)
      check_current_status!

      find_record

      update_finished_status!
      perform_operation

      @record
    end

    private

    def check_permissions!(operation)
      UserPermissionsService.new(current_user, topic).allowed(operation)
    end

    def check_current_status!
      status_value = @record.base_balance_status.id_name

      raise I18n.t('custom.errors.base_balances.current_status_check') unless status_value == 'current'
    end

    def find_record
      @record = BaseBalance.find(params[:id])
    end

    def update_finished_status!
      status = Enum::BaseBalanceStatus.value(:finished)

      @record.update!(base_balance_status: status, finished_at: current_date)
    end

    def perform_operation
      BaseBalances::ProcessOperationWorker.perform_async(@record.id)
    end
  end
end

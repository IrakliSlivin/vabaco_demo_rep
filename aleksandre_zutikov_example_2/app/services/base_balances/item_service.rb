# frozen_string_literal: true

module BaseBalances
  class ItemService
    attr_reader :params, :current_user, :topic

    def initialize(params, current_user)
      @params = params
      @current_user = current_user
      @topic = :base_balances
    end

    def index
      scope =
        BaseBalanceItem
        .preload(:warehouse, :location, :item)
        .where(base_balance_id: params[:base_balance_id])
        .order('base_balance_items.created_at DESC')
        .page(params[:page]).per(params[:page_limit])

      BaseBalanceItemsQuery.new(scope: scope).call(params[:filters])
    end

    def create
      check_permissions!(:_edit)

      base_balance = BaseBalance.find(params[:base_balance_id])

      ActiveRecord::Base.transaction do
        @record = BaseBalanceItem.create!(params)

        update_base_balance_sums!(base_balance)
      end

      @record
    end

    def update
      check_permissions!(:_edit)

      find_record

      ActiveRecord::Base.transaction do
        @record.update!(params)

        update_base_balance_sums!(@record.base_balance)
      end

      @record
    end

    def destroy
      check_permissions!(:_edit)

      find_record

      ActiveRecord::Base.transaction do
        @record.destroy!

        update_base_balance_sums!(@record.base_balance)
      end
    end

    private

    def find_record
      @record = BaseBalanceItem.find(params[:id])
    end

    def check_permissions!(operation)
      UserPermissionsService.new(current_user, topic).allowed(operation)
    end

    def update_base_balance_sums!(base_balance)
      base_balance.amount = BaseBalanceItem.sum(:amount)
      base_balance.quantity = BaseBalanceItem.sum(:quantity)
      base_balance.save!
    end
  end
end

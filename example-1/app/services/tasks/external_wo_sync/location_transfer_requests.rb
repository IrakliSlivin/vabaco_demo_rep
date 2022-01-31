# frozen_string_literal: true

module Tasks
  module ExternalWoSync
    class LocationTransferRequests
      def records
        Balance::OperationLog
          .select("
            external_wo_requests.id,
            external_wo_requests.operation_id,
            external_wo_requests.external_wo_request_data_id,
            operation_logs.id AS current_operation_log_id,
            operation_logs.warehouse_id,
            operation_logs.location_id,
            operation_logs.item_id,
            operation_logs.serial,
            external_wo_requests.quantity,
            external_wo_requests.amount,
            external_wo_requests.created_at,
            external_wo_requests.external_entry_item_guid,
            external_wo_requests.external_entry_name,
            external_wo_requests.processed,
            external_wo_requests.transfer_location_code,
            l.id AS transfer_location_id,
            (external_wo_request_data.request_data -> 'external_user_id') AS external_user_id
          ")
          .joins("INNER JOIN external_wo_requests ON operation_logs.operation_id = external_wo_requests.id AND operation_logs.operation_type = 'ExternalWo::Request'")
          .joins("LEFT JOIN locations l ON l.code = external_wo_requests.transfer_location_code AND l.warehouse_id = operation_logs.warehouse_id")
          .joins("INNER JOIN external_wo_request_data ON external_wo_request_data.id = external_wo_requests.external_wo_request_data_id")
          .joins("INNER JOIN external_wo_operations operation ON operation.id = external_wo_requests.operation_id")
          .where('operation.id_name = :id_name', id_name: 'location_transfer_item')
          .where('external_wo_requests.processed = ?', false)
          .order('external_wo_requests.created_at')
      end

      def location_transfers_attrs(request, user)
        status = Enum::LocationTransferStatus.value('issued_received')

        {
          location_transfer_status_id: status&.id,
          issuing_warehouse_id: request.warehouse_id,
          issuing_location_id: request.location_id,
          receiving_location_id: request.transfer_location_id,
          quantity: request.quantity * -1,
          total_amount: request.amount * -1,
          created_by_id: user.id,
          updated_by_id: user.id,
          issued_received_at: request.created_at,
          issued_received_by_id: user.id,
          created_at: request.created_at,
          updated_at: request.created_at,
          operation_guid: request.external_entry_item_guid,
          entry_name: request.external_entry_name
        }
      end

      def location_transfers_item_attrs(request, user)
        {
          item_id: request.item_id,
          serial_batch: request.serial,
          issue_date: request.created_at,
          expiration_date: request.created_at,
          quantity: request.quantity * -1,
          amount: request.amount * -1,
          created_by_id: user.id,
          updated_by_id: user.id,
          created_at: request.created_at,
          updated_at: request.created_at
        }
      end

      def external_user_id(request)
        request.external_user_id
      end

      def sync_wo_items!(request, user)
        current_request = ExternalWo::Request.find(request.id)

        if request.transfer_location_code.blank?
          current_request.update!(processed: true, operation_log_id: request.current_operation_log_id)
        else
          attrs = location_transfers_attrs(request, user)
          item_attrs = location_transfers_item_attrs(request, user)

          record = LocationTransfer.new(attrs)
          record.location_transfer_items.build(item_attrs)

          ActiveRecord::Base.transaction do
            record.save!
            current_request.update!(processed: true, operation_log_id: request.current_operation_log_id)
          end
        end
      rescue => e
        Rails.logger.warn("SYNC_WO_ITEMS_ERROR: #{request.id} - #{e}")
      end
    end
  end
end
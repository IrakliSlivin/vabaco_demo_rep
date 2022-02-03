# frozen_string_literal: true

module Tasks
  module ExternalWoSync
    class WriteOffRequests
      def records
        ExternalWo::Request
          .select('
          external_wo_requests.id,
          external_wo_requests.operation_id,
          external_wo_requests.external_wo_request_data_id,
          opl.id AS current_operation_log_id,
          opl.warehouse_id,
          opl.location_id,
          opl.item_id,
          opl.serial,
          external_wo_requests.quantity,
          external_wo_requests.amount,
          external_wo_requests.created_at,
          external_wo_requests.external_entry_item_guid,
          external_wo_requests.external_entry_name,
          external_wo_requests.processed
        ')
          .includes(:external_wo_request_data, :operation)
          .joins("INNER JOIN operation_logs opl ON opl.operation_id = external_wo_requests.id AND opl.operation_type = 'ExternalWo::Request'")
          .unprocessed.write_off_and_returned_items.order('external_wo_requests.created_at')
      end

      def write_off_attrs(request, user)
        written_off_status = fetch_written_off_status(request.operation&.id_name)

        {
          write_off_status_id: written_off_status&.id,
          write_off_warehouse_id: request.warehouse_id,
          write_off_location_id: request.location_id,
          quantity: request.quantity,
          total_amount: request.amount,
          created_by_id: user.id,
          updated_by_id: user.id,
          written_off_at: request.created_at,
          written_off_by_id: user.id,
          created_at: request.created_at,
          updated_at: request.created_at,
          operation_guid: request.external_entry_item_guid,
          entry_name: request.external_entry_name
        }
      end

      def write_off_item_attrs(request, user)
        {
          item_id: request.item_id,
          serial_batch: request.serial,
          issue_date: request.created_at,
          expiration_date: request.created_at,
          quantity: request.quantity,
          amount: request.amount,
          created_by_id: user.id,
          updated_by_id: user.id,
          created_at: request.created_at,
          updated_at: request.created_at
        }
      end

      def external_user_id(request)
        request.external_wo_request_data.request_data.dig('external_user_id')
      end

      def sync_wo_items!(request, user)
        current_request = ExternalWo::Request.find(request.id)

        attrs = write_off_attrs(request, user)
        item_attrs = write_off_item_attrs(request, user)

        record = WriteOff.new(attrs)
        record.write_off_items.build(item_attrs)

        ActiveRecord::Base.transaction do
          record.save!
          current_request.update!(processed: true, operation_log_id: request.current_operation_log_id)
        end
      rescue => e
        Rails.logger.warn("SYNC_WO_ITEMS_ERROR: #{request.id} - #{e}")
      end

      private

      def fetch_written_off_status(operation)
        case operation
        when 'write_off_item'
          Enum::WriteOffStatus.value('written_off')
        when 'return_item'
          Enum::WriteOffStatus.value('returned')
        else
          #
        end
      end
    end
  end
end
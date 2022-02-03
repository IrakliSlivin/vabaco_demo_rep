# frozen_string_literal: true

module Tasks
  module ExternalWoSync
    class ProcessWoRequestsService
      class << self
        def call(request_type)
          request_type.records.in_batches do |requests|
            requests.each do |request|
              user = fetch_user(request_type.external_user_id(request))

              next if user.blank?

              request_type.sync_wo_items!(request, user)
            end
          end
        end

        def fetch_user(external_user_id)
          User.find_by(external_user_id: external_user_id)
        end
      end
    end
  end
end
# frozen_string_literal: true

namespace :external_wo do
  desc 'Sync unprocessed write off requests'
  task sync_unprocessed_write_off_requests: :environment do
    Tasks::ExternalWoSync::ProcessWoRequestsService.call(Tasks::ExternalWoSync::WriteOffRequests.new)
  end

  desc 'Sync unprocessed location transfer requests'
  task sync_unprocessed_location_transfer_requests: :environment do
    Tasks::ExternalWoSync::ProcessWoRequestsService.call(Tasks::ExternalWoSync::LocationTransferRequests.new)
  end
end
# frozen_string_literal: true

class DeliveryCompanyLogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def size_range
    0..4.megabytes
  end

  version :small do
    process resize_to_fill: [170, 204]
  end

  def extension_whitelist
    %w(jpg jpeg png)
  end
end



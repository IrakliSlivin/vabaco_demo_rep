# frozen_string_literal: true

module Responder
  extend ActiveSupport::Concern

  def rest_respond_service(object = nil, serializer = nil, view = nil)
    success_respond_json(json_object(object, serializer, view))
  end

  included do
    rescue_from Exception, StandardError do |ex|
      error_respond_json([ex])
    end

    rescue_from ActiveRecord::RecordInvalid do |ex|
      error_respond_json(ex.record.errors.full_messages)
    end

    rescue_from ActiveRecord::StatementInvalid do |ex|
      error_respond_json([ex.message])
    end

    rescue_from Exceptions::UnauthorizedException do |ex|
      error_respond_json([ex.message], :forbidden)
    end
  end

  private

  def success_respond_json(json_object)
    render json: json_object, status: :ok
  end

  def error_respond_json(errors, status = :bad_request, code = nil)
    render json: { errors: errors, code: code }, status: status
  end

  def json_object(object, serializer = nil, view = nil, options = nil)
    return unless object
    return object unless serializer
    serializer.render_as_hash(object, view: view, params: options)
  end

end

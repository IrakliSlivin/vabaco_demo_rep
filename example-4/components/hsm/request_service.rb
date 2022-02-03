require 'rest-client'
module Components
  module Hsm
    class RequestService
      include Umg::ErrorsFormat
      include RestClient

      attr_accessor :response_code, :errors

      def initialize(instance, attributes, key_id, service, method = :post)
        @url = HSM_URL
        @instance = instance
        @attributes = attributes
        @key_id = key_id
        @service = service
        @method = method

        @headers = { Authorization: "Bearer " + hsm_access_token }
      end

      def encrypt
        encryption_object_payload
        hsm_service_request
        encrypted_object
      end

      def decrypt
        decryption_objects_payload
        hsm_service_request
        decrypted_objects
      end

      private
      def hsm_service_request
        response = RestClient::Request.execute(method: :post, url: @url + @service.to_s, timeout: HSM_TIMEOUT, headers: @headers, payload: @payload)
        @result = JSON.parse(response.body).deep_symbolize_keys
      end

      def encryption_object_payload
        encrypt_params = {}
        @attributes.each do |attribute|
          encrypt_params[attribute] = @instance.instance_variable_get "@#{attribute}".to_sym
        end

        @payload = { obj: encrypt_params, key_id: @key_id }
      end

      def decryption_objects_payload
        decryption_params, encrypted_attributes = [], ['id']
        @attributes.each {|attr| encrypted_attributes << attr.to_s + '_encrypted' }
        @instance.each do |instance|
          decryption_params << instance.slice(*encrypted_attributes)
        end
        @payload = { obj: decryption_params, key_id: @key_id }
      end

      def encrypted_object
        @instance.assign_attributes(@result[:encrypted_data])
        [@instance, @result[:key_id]]
      end

      def decrypted_objects
        @instance.each { |instance| set_attributes(instance) }
        @instance
      end

      def set_attributes(instance)
        @result[:decrypted_data].each do |result|
          if result[:id].to_i == instance.id
            instance.assign_attributes(result)
          end
        end
      end

      def hsm_access_token
        AuthService.new.generate_token
      end
    end
  end
end

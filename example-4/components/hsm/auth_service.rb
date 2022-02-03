module Components
  module Hsm
    class AuthService

      attr_accessor :redis_channel

      def initialize
        @redis_channel = 'hsm_access_token'
      end

      def generate_token
        token = $redis_helper.get(@redis_channel)
        return token if token

        payload = generate_payload
        jwt_token = encode(payload)
        $redis_helper.set(@redis_channel, jwt_token)
        $redis_helper.expireat(@redis_channel, payload[:exp])
        jwt_token
      end


      private
      def generate_payload
        {
            uuid: SecureRandom.uuid,
            expired_at: Time.now + HSM_JWT_TOKEN_EXPIRATION_HR.hours,
            exp: (Time.now + HSM_JWT_TOKEN_EXPIRATION_HR.hours).to_i
        }
      end

      def encode(payload)
        JWT.encode(payload, secret_key, 'HS256', { typ: 'JWT' })
      end

      def secret_key
        Rails.application.credentials.hsm_jwt_secret_key
      end
    end
  end
end
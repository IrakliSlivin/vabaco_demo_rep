# frozen_string_literal: true

module Encryption
  class MsgEncryptor
    attr_accessor :key

    def initialize(user_key)
      @key = user_key
    end

    delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

    def encrypt(value)
      encrypt_and_sign(value)
    end

    def decrypt(value)
      decrypt_and_verify(value)
    end

    private
    def encryptor
      ActiveSupport::MessageEncryptor.new(@key)
    end
  end
end




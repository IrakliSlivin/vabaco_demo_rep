module Encryption
  class AbstractEncryption
    include Encryption::Encryptable

    attr_accessor :obj, :attributes, :user_key

    def initialize(params, user_key)
      @obj = params[:obj]
      @attributes = params[:attributes]
      @user_key = user_key
    end

    def encrypt_data
      attributes_encrypted @obj, @user_key
    end

    def decrypt_data
      attributes_decrypted @obj, @user_key
    end

    def encrypt
      attr_encrypted @obj, @user_key
    end

    def decrypt
      attr_decrypted @obj, @user_key, @attributes
    end
  end
end
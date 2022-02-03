module Encryption
  module Encryptable extend ActiveSupport::Concern

  def attributes_encrypted(obj, user_key)
    encrypted_hash = {}
    obj.each do |key, value|
      encrypted_hash["#{key}_encrypted".to_sym] = MsgEncryptor.new(user_key).encrypt(value)
    end
    encrypted_hash
  end

  def attributes_decrypted(obj, user_key)
    decrypted_object_list = []
    obj.each do |object|
      decrypted_object_list << decrypt_object(object, user_key)
    end
    decrypted_object_list
  end

  def attr_encrypted(obj, user_key)
    MsgEncryptor.new(user_key).encrypt(obj.values.first)
  end

  def attr_decrypted(obj, user_key, attribute)
    obj[attribute] = MsgEncryptor.new(user_key).decrypt(obj["#{attribute}_encrypted".to_sym])
    obj
  end

  private

  def decrypt_object(object, user_key)
    decrypted_object = {}
    object.each  do |k, _v|
      if k.eql?(:id)
        decrypted_object[:id] = object[k]
      else
        decrypted_object[k.to_s.gsub(/_encrypted/, '')] = MsgEncryptor.new(user_key).decrypt(_v).force_encoding('UTF-8')
      end
    end
    decrypted_object
  end

  end
end
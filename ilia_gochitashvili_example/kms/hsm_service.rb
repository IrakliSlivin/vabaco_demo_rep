# frozen_string_literal: true

class HsmService

  attr_accessor :errors, :status_code, :params, :user_key, :encrypted_data, :decrypted_data, :key_id

  def initialize(params)
    @params = params.as_json.deep_symbolize_keys
    @key_id = params[:key_id]
    @errors = []
    @status_code = 200
  end

  def encrypt
    get_user_key
    return if @errors.any?

    @encrypted_data = Encryption::AbstractEncryption.new(params, @user_key).encrypt_data
  rescue => e
    check_errors(e.to_s)
  end

  def decrypt_list
    validate
    get_user_key
    return if @errors.any?

    @decrypted_data = Encryption::AbstractEncryption.new(params, @user_key).decrypt_data
  rescue => e
    check_errors(e.to_s)
  end

  private
  def get_user_key
    find_or_create_user_key
    return_user_key
  end

  def find_or_create_user_key
    @user_data = @key_id.nil? ? create_user_key : UserKey.find_by(id: @key_id)
  end

  def create_user_key
    UserKey.create(key: generate_user_key)
  rescue => e
    check_errors(e.to_s)
  end

  def return_user_key
    validate_user_key
    return if @errors.any?

    @key_id = @user_data.id
    @user_key = @user_data.key
  end

  def validate_user_key
    if @user_data&.key.nil?
      @errors << I18n.t('user_key_is_empty')
    end
  end

  def validate
    unless @key_id.present?
      @errors << I18n.t('user_id_is_empty')
    end
  end

  def check_errors(error_message)
    @errors << {
        error_msg: error_message
    }
  end

  def generate_user_key
    KeyGeneratorService.new(@key_id).generate_key
  end

end
  # frozen_string_literal: true



  begin
    resend_api_key = Rails.application.credentials.dig(:resend_api_key)

  rescue ActiveSupport::EncryptedFile::MissingKeyError
    nil
  end

if resend_api_key.present?
  Resend.api_key = resend_api_key
end

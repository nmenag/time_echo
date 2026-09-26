# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :ip_address
  attribute :user_agent
end

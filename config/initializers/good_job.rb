if Rails.env.production? || Rails.env.staging?
  Rails.logger = JsonLogFormatter.build(STDOUT)
end

class MagicLinkForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def submit
    return false unless valid?

    Auth::MagicLinkService.generate_and_send(email)
    true
  end
end

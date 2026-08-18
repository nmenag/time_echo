class LetterForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :email, :string
  attribute :content, :string
  attribute :deliver_at, :datetime
  attribute :language, :string, default: -> { I18n.locale.to_s }

  attribute :prediction_city, :string
  attribute :prediction_salary, :string
  attribute :prediction_relationship, :string
  attribute :prediction_career, :string
  attribute :prediction_achievement, :string
  attribute :prediction_happiness, :string, default: "7"

  attribute :happiness_level, :integer, default: 5
  attribute :anxiety_level, :integer, default: 5
  attribute :motivation_level, :integer, default: 5

  validates :title, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :content, presence: true
  validates :deliver_at, presence: true
  validate :deliver_at_must_be_in_future

  validates :happiness_level, presence: true, numericality: { only_integer: true, in: 1..10 }
  validates :anxiety_level, presence: true, numericality: { only_integer: true, in: 1..10 }
  validates :motivation_level, presence: true, numericality: { only_integer: true, in: 1..10 }

  attr_reader :letter

  def save
    return false unless valid?

    Letter.transaction do
      @letter = Letter.new(
        title: title,
        email: email,
        content: content,
        deliver_at: deliver_at,
        language: language.presence || I18n.locale.to_s,
        status: "pending"
      )

      @letter.build_emotional_snapshot(
        happiness_level: happiness_level,
        anxiety_level: anxiety_level,
        motivation_level: motivation_level
      )

      build_prediction("city", prediction_city)
      build_prediction("salary", prediction_salary)
      build_prediction("relationship", prediction_relationship)
      build_prediction("career", prediction_career)
      build_prediction("achievement", prediction_achievement)
      build_prediction("happiness", prediction_happiness)

      @letter.save!

      Analytics::TrackEventService.call("letter_created", { email: email })
      Analytics::TrackEventService.call("emotional_snapshot_completed", { email: email })
      if any_predictions?
        Analytics::TrackEventService.call("predictions_completed", { email: email })
      end

      true
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  private

  def build_prediction(category, text)
    return if text.blank?
    @letter.predictions.build(category: category, prediction: text)
  end

  def any_predictions?
    [ prediction_city, prediction_salary, prediction_relationship, prediction_career, prediction_achievement ].any?(&:present?)
  end

  def deliver_at_must_be_in_future
    if deliver_at.present? && deliver_at <= Time.current
      errors.add(:deliver_at, "must be in the future")
    end
  end
end

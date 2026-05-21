class UserTimelineQuery
  def self.call(email, relation = Letter.all)
    new(email, relation).call
  end

  def initialize(email, relation = Letter.all)
    @email = email
    @relation = relation
  end

  def call
    @relation.for_email(@email).includes(:predictions, :emotional_snapshot).order(deliver_at: :asc)
  end
end

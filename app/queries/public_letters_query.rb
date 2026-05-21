class PublicLettersQuery
  def self.call(relation = Letter.all)
    new(relation).call
  end

  def initialize(relation = Letter.all)
    @relation = relation
  end

  def call
    @relation.published
  end
end

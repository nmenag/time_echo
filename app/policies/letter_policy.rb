class LetterPolicy
  attr_reader :user_email, :letter

  def initialize(user_email, letter)
    @user_email = user_email
    @letter = letter
  end

  def show?
    return true if letter.public? && letter.delivered?

    user_email.present? && letter.email == user_email
  end
end

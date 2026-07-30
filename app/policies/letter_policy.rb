class LetterPolicy
  attr_reader :user_email, :letter

  def initialize(user_email, letter)
    @user_email = user_email
    @letter = letter
  end

  def show?
    user_email.present? && letter.email == user_email
  end
end

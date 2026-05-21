class LetterPolicy
  attr_reader :user_email, :letter

  def initialize(user_email, letter)
    @user_email = user_email
    @letter = letter
  end

  # Check if the user is authorized to read the letter
  def show?
    # 1. Anyone can view a public letter after it has been delivered
    return true if letter.public? && letter.delivered?

    # 2. Otherwise, only the owner who wrote it can view it
    user_email.present? && letter.email == user_email
  end
end

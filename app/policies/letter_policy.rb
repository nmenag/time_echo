# frozen_string_literal: true

class LetterPolicy
  attr_reader :user_email, :letter

  def initialize(user_email, letter)
    @user_email = user_email
    @letter = letter
  end

  def show?
    owner?
  end

  def archive?
    owner?
  end

  def restore?
    owner?
  end

  private

  def owner?
    user_email.present? && letter.email == user_email
  end
end

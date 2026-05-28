require "test_helper"

class LettersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @letter_params = {
      letter_form: {
        title: "My Future self",
        email: "test@example.com",
        content: "Hello from the past!",
        deliver_at: 1.year.from_now.to_s,
        public: "1",
        happiness_level: "7",
        anxiety_level: "3",
        motivation_level: "8",
        prediction_city: "Bogotá",
        prediction_salary: "$50,000",
        prediction_relationship: "single",
        prediction_career: "Developer",
        prediction_achievement: "run a marathon"
      }
    }
  end

  test "should get new letter form" do
    get new_letter_path
    assert_response :success
  end

  test "should create letter when not logged in" do
    assert_difference -> { Letter.count } => 1, -> { EmotionalSnapshot.count } => 1, -> { Prediction.count } => 6 do
      post letters_path, params: @letter_params
    end
    assert_redirected_to success_letters_path
  end

  test "should create letter when logged in" do
    # Log in by setting session
    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    assert_difference -> { Letter.count } => 1 do
      post letters_path, params: {
        letter_form: {
          title: "Logged in letter",
          content: "Content",
          deliver_at: 1.year.from_now.to_s,
          happiness_level: "5",
          anxiety_level: "5",
          motivation_level: "5"
        }
      }
    end
    assert_redirected_to success_letters_path
    assert_equal "user@example.com", Letter.last.email
  end

  test "should show countdown for pending letter via signed id" do
    letter = Letter.new(
      title: "Pending Letter",
      email: "test@example.com",
      content: "Hello!",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    letter.save!(validate: false)

    get letter_path(letter.signed_id)
    assert_response :success
    assert_select "h1", text: I18n.t("letters.show_locked_title")
  end

  test "should show content for delivered letter if public" do
    letter = Letter.new(
      title: "Delivered Letter",
      email: "test@example.com",
      content: "Opened Capsule Content",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered",
      public: true
    )
    letter.save!(validate: false)

    get letter_path(letter)
    assert_response :success
    assert_match "Opened Capsule Content", response.body
  end

  test "should redirect private letter for unauthorized viewer" do
    letter = Letter.new(
      title: "Private Letter",
      email: "owner@example.com",
      content: "Private Content",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered",
      public: false
    )
    letter.save!(validate: false)

    get letter_path(letter)
    assert_redirected_to root_path
  end

  test "should allow viewing private letter when logged in as owner" do
    post login_path, params: { magic_link_form: { email: "owner@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    letter = Letter.new(
      title: "Private Letter",
      email: "owner@example.com",
      content: "Private Content",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered",
      public: false
    )
    letter.save!(validate: false)

    get letter_path(letter)
    assert_response :success
    assert_match "Private Content", response.body
  end

  test "should update predictions reality" do
    # Authenticate
    post login_path, params: { magic_link_form: { email: "owner@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    letter = Letter.new(
      title: "My letter",
      email: "owner@example.com",
      content: "Content",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered"
    )
    letter.save!(validate: false)
    letter.create_emotional_snapshot!(happiness_level: 5, anxiety_level: 5, motivation_level: 5)
    pred = letter.predictions.create!(category: "city", prediction: "Rome")

    post update_predictions_letter_path(letter), params: {
      reveal_happiness: "8",
      reveal_anxiety: "2",
      reveal_motivation: "9",
      predictions: {
        pred.id.to_s => {
          reality: "Milan",
          matched: "0"
        }
      }
    }

    assert_redirected_to letter_path(letter)
    letter.reload
    assert_equal 8, letter.reveal_happiness
    assert_equal 2, letter.reveal_anxiety
    assert_equal 9, letter.reveal_motivation

    pred.reload
    assert_equal "Milan", pred.reality
    assert_not pred.matched?
  end
end

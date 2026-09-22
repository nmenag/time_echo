require "test_helper"

class LettersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @letter_params = {
      letter_form: {
        title: "My Future self",
        email: "test@example.com",
        content: "Hello from the past! I hope this message finds you in great spirits, thriving and healthy.",
        deliver_at: 1.year.from_now.to_s,
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
    assert_difference -> { Letter.count } => 1, -> { EmotionalSnapshot.count } => 1, -> { Prediction.count } => 5 do
      post letters_path, params: @letter_params, headers: { "HTTP_ACCEPT_LANGUAGE" => "es" }
    end
    assert_redirected_to success_letters_path
    assert_equal "es", Letter.last.language
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
          content: "Logged in reflection about my goals, personal aspirations, and expectations for the upcoming year.",
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

  test "should redirect to login for letter show when not logged in" do
    letter = Letter.new(
      title: "Pending Letter",
      email: "test@example.com",
      content: "Hello!",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    letter.save!(validate: false)

    get letter_path(letter.signed_id)
    assert_redirected_to login_path
    assert_equal letter_path(letter.signed_id), session[:return_to]
  end

  test "should show countdown for pending letter via signed id when logged in as owner" do
    post login_path, params: { magic_link_form: { email: "test@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

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

  test "should redirect private letter for unauthorized viewer" do
    post login_path, params: { magic_link_form: { email: "stranger@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    letter = Letter.new(
      title: "Private Letter",
      email: "owner@example.com",
      content: "Private Content",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered"
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
      status: "delivered"
    )
    letter.save!(validate: false)

    get letter_path(letter)
    assert_response :success
    assert_match "Private Content", response.body
  end

  test "should get index when logged in" do
    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    get dashboard_path
    assert_response :success
  end

  test "should render new when create fails when logged in" do
    post login_path, params: { magic_link_form: { email: "user@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    struct_fail = Struct.new(:success?, :form).new(false, LetterForm.new)
    original_call = Letters::CreateService.method(:call)
    Letters::CreateService.define_singleton_method(:call, ->(*) { struct_fail })

    post letters_path, params: @letter_params
    assert_response :unprocessable_entity
  ensure
    Letters::CreateService.define_singleton_method(:call, original_call.to_proc)
  end

  test "should redirect unauthorized viewing other user's letter when logged in" do
    post login_path, params: { magic_link_form: { email: "other@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    letter = Letter.new(
      title: "Private Letter",
      email: "owner@example.com",
      content: "Private Content",
      deliver_at: 1.day.ago,
      delivered_at: 1.day.ago,
      status: "delivered"
    )
    letter.save!(validate: false)

    struct_unauth = Struct.new(:success?, :error).new(false, :unauthorized)
    original_call = Letters::AccessService.method(:call)
    Letters::AccessService.define_singleton_method(:call, ->(*) { struct_unauth })

    get letter_path(letter)
    assert_redirected_to root_path
  ensure
    Letters::AccessService.define_singleton_method(:call, original_call.to_proc)
  end

  test "should redirect with alert when letter is not found" do
    post login_path, params: { magic_link_form: { email: "owner@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    struct_not_found = Struct.new(:success?, :error).new(false, :not_found)
    original_call = Letters::AccessService.method(:call)
    Letters::AccessService.define_singleton_method(:call, ->(*) { struct_not_found })

    get letter_path("nonexistent_id")
    assert_redirected_to root_path
    assert_equal I18n.t("flash.private_or_inaccessible"), flash[:alert]
  ensure
    Letters::AccessService.define_singleton_method(:call, original_call.to_proc)
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

  test "should redirect to login for destroy when not logged in" do
    letter = Letter.new(
      title: "Pending Letter",
      email: "test@example.com",
      content: "Hello!",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    letter.save!(validate: false)

    delete letter_path(letter)
    assert_redirected_to login_path
    assert_equal "pending", letter.reload.status
  end

  test "should soft-delete letter and redirect to dashboard when logged in as owner" do
    post login_path, params: { magic_link_form: { email: "owner@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    letter = Letter.new(
      title: "Letter to Delete",
      email: "owner@example.com",
      content: "Delete me",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    letter.save!(validate: false)

    delete letter_path(letter)
    assert_redirected_to dashboard_path
    assert_equal I18n.t("flash.letter_archived"), flash[:notice]
    assert_equal "archived", letter.reload.status

    get dashboard_path
    assert_response :success
    assert_match I18n.t("letters.archived_section_title"), response.body
    assert_match "Letter to Delete", response.body
  end

  test "should redirect with alert when destroying letter of another user" do
    post login_path, params: { magic_link_form: { email: "stranger@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    letter = Letter.new(
      title: "Victim's Letter",
      email: "victim@example.com",
      content: "Do not touch",
      deliver_at: 1.year.from_now,
      status: "pending"
    )
    letter.save!(validate: false)

    delete letter_path(letter)
    assert_redirected_to dashboard_path
    assert_equal I18n.t("flash.unauthorized_action"), flash[:alert]
    assert_equal "pending", letter.reload.status
  end

  test "should redirect with alert when destroying nonexistent letter" do
    post login_path, params: { magic_link_form: { email: "owner@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    delete letter_path("nonexistent_id")
    assert_redirected_to dashboard_path
    assert_equal I18n.t("flash.private_or_inaccessible"), flash[:alert]
  end

  test "should redirect with alert when attempting to archive delivered letter" do
    post login_path, params: { magic_link_form: { email: "owner@example.com" } }
    token = SessionToken.last.token
    get magic_login_path(token)

    letter = Letter.new(
      title: "Delivered Letter",
      email: "owner@example.com",
      content: "Delivered",
      deliver_at: 1.year.ago,
      delivered_at: 1.year.ago,
      status: "delivered"
    )
    letter.save!(validate: false)

    delete letter_path(letter)
    assert_redirected_to dashboard_path
    assert_equal I18n.t("flash.cannot_archive_delivered"), flash[:alert]
    assert_equal "delivered", letter.reload.status
  end
end

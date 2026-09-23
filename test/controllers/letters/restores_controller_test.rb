# frozen_string_literal: true

require "test_helper"

module Letters
  class RestoresControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = "owner@example.com"
    end

    test "redirects to login when unauthenticated" do
      letter = Letter.new(
        title: "Archived Letter",
        email: @user,
        content: "Content",
        scheduled_at: 1.year.from_now,
        status: "archived"
      )
      letter.save!(validate: false)

      post letters_restore_letter_path(letter)
      assert_redirected_to login_path
      assert_equal "archived", letter.reload.status
    end

    test "restores letter and redirects to dashboard when logged in as owner" do
      post login_path, params: { magic_link_form: { email: @user } }
      token = SessionToken.last.token
      get magic_login_path(token)

      letter = Letter.new(
        title: "Archived Letter",
        email: @user,
        content: "Content",
        scheduled_at: 1.year.from_now,
        status: "archived"
      )
      letter.save!(validate: false)

      post letters_restore_letter_path(letter)
      assert_redirected_to dashboard_path
      assert_equal I18n.t("flash.letter_restored"), flash[:notice]
      assert_equal "pending", letter.reload.status
    end

    test "redirects with alert when restoring another user's letter" do
      post login_path, params: { magic_link_form: { email: "stranger@example.com" } }
      token = SessionToken.last.token
      get magic_login_path(token)

      letter = Letter.new(
        title: "Other's Letter",
        email: "victim@example.com",
        content: "Content",
        scheduled_at: 1.year.from_now,
        status: "archived"
      )
      letter.save!(validate: false)

      post letters_restore_letter_path(letter)
      assert_redirected_to dashboard_path
      assert_equal I18n.t("flash.unauthorized_action"), flash[:alert]
      assert_equal "archived", letter.reload.status
    end

    test "redirects with alert when restoring nonexistent letter" do
      post login_path, params: { magic_link_form: { email: @user } }
      token = SessionToken.last.token
      get magic_login_path(token)

      post letters_restore_letter_path("nonexistent_id")
      assert_redirected_to dashboard_path
      assert_equal I18n.t("flash.private_or_inaccessible"), flash[:alert]
    end

    test "redirects with alert when restoring letter that is not archived" do
      post login_path, params: { magic_link_form: { email: @user } }
      token = SessionToken.last.token
      get magic_login_path(token)

      letter = Letter.new(
        title: "Delivered Letter",
        email: @user,
        content: "Content",
        scheduled_at: 1.year.ago,
        delivered_at: 1.year.ago,
        status: "delivered"
      )
      letter.save!(validate: false)

      post letters_restore_letter_path(letter)
      assert_redirected_to dashboard_path
      assert_equal I18n.t("flash.cannot_restore"), flash[:alert]
      assert_equal "delivered", letter.reload.status
    end
  end
end

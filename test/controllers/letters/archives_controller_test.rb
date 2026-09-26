# frozen_string_literal: true

require "test_helper"

module Letters
  class ArchivesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = "owner@example.com"
    end

    test "redirects to login when unauthenticated" do
      letter = Letter.new(
        title: "Letter to Archive",
        email: @user,
        content: "Content",
        scheduled_at: 1.year.from_now,
        status: "pending"
      )
      letter.save!(validate: false)

      post letters_archive_path(letter)
      assert_redirected_to login_path
      assert_equal "pending", letter.reload.status
    end

    test "archives letter and redirects to dashboard when logged in as owner" do
      post login_path, params: { magic_link_form: { email: @user } }
      token = SessionToken.last.token
      get magic_login_path(token)

      letter = Letter.new(
        title: "Letter to Archive",
        email: @user,
        content: "Content",
        scheduled_at: 1.year.from_now,
        status: "pending"
      )
      letter.save!(validate: false)

      assert_difference -> { AuditLog.for_action("letter.archived").count } => 1 do
        post letters_archive_path(letter)
      end
      assert_redirected_to dashboard_path
      assert_equal I18n.t("flash.letter_archived"), flash[:notice]
      assert_equal "archived", letter.reload.status
    end

    test "redirects with alert when archiving another user's letter" do
      post login_path, params: { magic_link_form: { email: "stranger@example.com" } }
      token = SessionToken.last.token
      get magic_login_path(token)

      letter = Letter.new(
        title: "Other's Letter",
        email: "victim@example.com",
        content: "Content",
        scheduled_at: 1.year.from_now,
        status: "pending"
      )
      letter.save!(validate: false)

      post letters_archive_path(letter)
      assert_redirected_to dashboard_path
      assert_equal I18n.t("flash.unauthorized_action"), flash[:alert]
      assert_equal "pending", letter.reload.status
    end

    test "redirects with alert when archiving nonexistent letter" do
      post login_path, params: { magic_link_form: { email: @user } }
      token = SessionToken.last.token
      get magic_login_path(token)

      post letters_archive_path("nonexistent_id")
      assert_redirected_to dashboard_path
      assert_equal I18n.t("flash.private_or_inaccessible"), flash[:alert]
    end

    test "redirects with alert when archiving letter that is delivered" do
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

      post letters_archive_path(letter)
      assert_redirected_to dashboard_path
      assert_equal I18n.t("flash.cannot_archive_delivered"), flash[:alert]
      assert_equal "delivered", letter.reload.status
    end
  end
end

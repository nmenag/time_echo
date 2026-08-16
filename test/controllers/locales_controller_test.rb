require "test_helper"

class LocalesControllerTest < ActionDispatch::IntegrationTest
  test "should set locale in session and redirect back" do
    post locales_path, params: { locale: "en" }

    assert_equal "en", session[:locale]
    assert_redirected_to root_url
  end

  test "should clear locale from session and redirect back" do
    post locales_path, params: { locale: "es" }
    follow_redirect!
    assert_equal "es", session[:locale]

    delete locale_url(id: 1)
    follow_redirect!
    assert_nil session[:locale]
  end
end

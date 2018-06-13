require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  test 'should login an user' do
    post :create, user_session: {
      username: users(:jeff).username,
      password: 'secretive'
    }
    assert_redirected_to '/dashboard'
  end

  test 'should redirect to create new account if username doesnt exist' do
    post :create, user_session: {
      username: 'nobody',
      password: 'blablabla'
    }
    assert_redirected_to '/login'
    assert_equal 'There is nobody in our system by that name, are you sure you have the right username?', flash[:warning]
  end

  test 'login user with an email' do
    post :create, user_session: {
      username: users(:jeff).email,
      password: 'secretive'
    }
    assert_redirected_to '/dashboard'
  end

  test 'should login and redirect to corresct url' do
    session[:return_to] = '/post?tags=question:question&template=question'
    post :create, user_session: {
      username: users(:jeff).username,
      password: 'secretive'
    }
    assert_redirected_to '/post?tags=question:question&template=question'
  end

  test 'should choose I18n in settings controller, then display correct language login message on log in' do
    available_testing_locales.each do |lang|
      old_controller = @controller
      @controller = SettingsController.new

      # set locale in cookie
      get :change_locale, locale: lang.to_s

      @controller = old_controller

      post :create, user_session: {
        username: users(:jeff).username,
        password: 'secretive'
      }

      assert_redirected_to '/dashboard'
      assert_equal I18n.t('user_sessions_controller.logged_in'), flash[:notice]
    end
  end

  test 'sign up and login via provider basic flow' do
    assert_not_nil OmniAuth.config.mock_auth[:google_oauth2]
    #Omniauth hash is present
    request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:google_oauth2]
    assert_not_nil request.env['omniauth.auth']
    #Sign Up for a new user
    post :create
    assert_equal "You have successfully signed in. Please change your password via a link sent to you via a mail",  flash[:notice]
    #Log Out
    post :destroy
    #auth hash is present so login via a provider
    post :create
    assert_equal "Signed in!",  flash[:notice]
  end
end

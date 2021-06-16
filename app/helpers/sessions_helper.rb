module SessionsHelper
  def log_in(user) # Logs in the given user.
    session[:user_id] = user.id
  end

  def remember(user) # Remembers a user in a persistent session.
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user # Returns the user corresponding to the remember token cookie.
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)

      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in? # Returns true if the user is logged in, false otherwise.
    !current_user.nil?
  end

  def log_out # Logs out the current user.
    session.delete( :user_id)
    @current_user = nil
  end
end

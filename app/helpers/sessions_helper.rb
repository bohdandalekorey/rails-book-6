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

  def current_user?(user) # Returns true if the given user is the current user.
    user && user == current_user
  end

  def logged_in? # Returns true if the user is logged in, false otherwise.
    !current_user.nil?
  end

  def forget(user) #Forgets a persistent session.
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out # Logs out the current user.
    forget(current_user)
    session.delete( :user_id)
    @current_user = nil
  end

  def redirect_back_or(default) # Redirects to stored location (or to the default).
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location # Stores the URL trying to be accessed.
    session[:forwarding_url] = request.original_url if request.get?
  end
end

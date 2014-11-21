class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorize
  before_filter :set_i18n_locale_from_params

  protected

  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        I18n.locale = params[:locale]
      else
        flash.now[:notice] = "#{params[:locale]} translation not available_locales"
        logger.error flash.now[:notice]
      end
    end
  end

  def default_url_options
    { locale: I18n.locale }
  end

  private

  def authorize
    unless User.find_by_id(session[:user_id]) or User.count.zero?
      if request.format == Mime::HTML
        redirect_to login_url, notice: "Please log in"
      else
        authenticate_or_request_with_http_basic do |username, password|
          user = User.find_by_name(username)
          if user and user.authenticate(password)
            session[:user_id] = user.id
          else
            render status: 403, text: "login failed"
          end
        end
      end
    end
  end

  def current_cart
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create
    session[:cart_id] = cart.id
    cart
  end
end

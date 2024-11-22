class WelcomeController < ApplicationController
  def index
  end

  def new
  end

  def sign_in
    # TODO: remove numbers etc
    cookies[:user_name] = params[:user_name]
    redirect_to books_path
  end
end

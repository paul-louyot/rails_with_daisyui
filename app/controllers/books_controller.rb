class BooksController < ApplicationController
  http_basic_authenticate_with name: Rails.application.credentials.admin_name,
                               password: Rails.application.credentials.admin_password,
                               only: [ :create, :new ]
  before_action :set_user
  before_action :check_authentication, only: [ :claim, :unclaim ]
  before_action :set_book!, only: [ :claim, :unclaim ]
  after_action only: :claim do
    Turbo::StreamsChannel.broadcast_replace_later_to("books",
      target: "claim_#{helpers.dom_id(@book)}",
      partial: "books/claimed",
      locals: { book: @book }
    )
  end
  after_action only: :unclaim do
    Turbo::StreamsChannel.broadcast_replace_later_to("books",
      target: "claimed_#{helpers.dom_id(@book)}",
      partial: "books/claim",
      locals: { book: @book }
    )
  end

  class AuthenticationError < StandardError
  end

  class AuthorizationError < StandardError
  end

  def index
    redirect_to new_session_path and return unless @is_authenticated

    @books = Book.all
  end

  def create
    params[:message].split("\n").each do |line|
      title, author = line.split(",")
      Book.find_or_create_by!(title: title, author: author)
    end
    redirect_to books_path
  end

  def claim
    raise StandardError if @book.is_claimed?

    @book.update!(user_name: @user_name)
    render partial: "form", locals: { book: @book, can_unclaim: @book.is_claimed_by?(@user_name) }
  rescue
    render partial: "error", locals: { book: @book }
  end

  def unclaim
    raise AuthorizationError unless @book.is_claimed_by?(@user_name)

    @book.update!(user_name: nil)
    render partial: "form", locals: { book: @book, can_unclaim: @book.is_claimed_by?(@user_name) }
  end

  def new
  end

  private

  def set_book!
    @book = Book.find_by!(id: params[:id])
  end

  def set_user
    @user_name = cookies[:user_name]
    @is_authenticated = @user_name.present?
  end

  def check_authentication
    raise AuthenticationError unless @user_name.present?
  end
end

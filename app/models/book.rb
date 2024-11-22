class Book < ApplicationRecord
  before_update :sanitize_user_name

  def is_claimed?
    user_name.present?
  end

  def is_claimed_by?(name)
    name == user_name
  end

  private

  def sanitize_user_name
    self.user_name = ActionController::Base.helpers.sanitize(user_name)
  end
end

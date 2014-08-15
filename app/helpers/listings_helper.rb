module ListingsHelper
  def listing_owner? user
    current_user == user
  end
end

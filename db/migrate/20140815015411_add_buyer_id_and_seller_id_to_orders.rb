class AddBuyerIdAndSellerIdToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :buyer, index: true
    add_reference :orders, :seller, index: true
  end
end

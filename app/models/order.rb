class Order < ActiveRecord::Base
  belongs_to :listing
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'

  validates :address, :city, :state, :buyer_id, :seller_id, presence: true

  scope :recent, -> { order('created_at DESC') }
  scope :purchases, ->(user) { where(buyer: user) }
  scope :sales, ->(user) { where(seller: user) }
end

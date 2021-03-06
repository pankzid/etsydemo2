class Listing < ActiveRecord::Base
  if Rails.env.development?
    has_attached_file :image, :styles => {
                      :medium => "360x",
                      :small => "200x",
                      :thumb => "100x100>" },
                      :default_url => "default.jpg"
  else
    has_attached_file :image, :styles => {
                      :medium => "360x",
                      :small => "200x",
                      :thumb => "100x100>" },
                      :default_url => "default.jpg",
                      :storage => :dropbox,
                      :dropbox_credentials => Rails.root.join("config/dropbox.yml"),
                      :path => ":style/:id_:filename"
  end

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  validates :name, :description, :price, :user_id,
            presence: true
  validates :price, numericality: { greater_than: 0 }

  scope :recent, ->{ order('created_at DESC') }
  scope :seller, ->(user){ where(user: user) }

  belongs_to :user
  has_many :orders, dependent: :destroy
end

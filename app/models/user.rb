class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable
    
    has_many :shizens, dependent: :destroy
    validates :name, presence: true
    validates :profile, length: { maximum: 200 }
    has_many :likes, dependent: :destroy
    has_many :liked_shizens, through: :likes, source: :shizen
    has_many :comments, dependent: :destroy
    has_many :messages, dependent: :destroy
    has_many :entries, dependent: :destroy
    has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
    has_many :followings, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower
    has_one_attached :image
    scope :active, -> { where(active: "true") }

  def already_liked?(shizen)
  self.likes.exists?(shizen_id: shizen.id)
  end
  
  def follow(user)
    active_relationships.create(followed_id: user.id)
  end
  
  def unfollow(user)
    active_relationships.find_by(followed_id: user.id).destroy
  end
  
  def following?(user)
  followings.include?(user)
  end
end
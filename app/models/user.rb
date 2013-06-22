class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :scoresheets, :dependent => :destroy, autosave: true

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  validates_presence_of :name

end

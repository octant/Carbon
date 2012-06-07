class Location < ActiveRecord::Base
  has_many :networks
  has_many :personalities, :through => :networks
  has_many :devices, :through => :personalities
end

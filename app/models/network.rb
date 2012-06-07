class Network < ActiveRecord::Base
  belongs_to :location
  has_many :personalities
  
  scope :orphans, where(:location_id => nil)
  
  def to_s
    network_identifier
  end
end

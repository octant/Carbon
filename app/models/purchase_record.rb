class PurchaseRecord < ActiveRecord::Base
  has_many :devices
  
  def name
    id
  end
end

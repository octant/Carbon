class List < ActiveRecord::Base
  has_and_belongs_to_many :personalities
  
  validates :name, :presence => true, :uniqueness => true
end

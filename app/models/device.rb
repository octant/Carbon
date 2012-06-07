class Device < ActiveRecord::Base
  belongs_to :purchase_record
  has_many :personalities
  
  validates :serial_number, :presence => true, :uniqueness => true
  validates :asset_tag, :uniqueness => true, :allow_blank => true
  
  scope :active, where(:status => 'Active')
  scope :inactive, where(:status => 'Inactive')
  scope :eol, where(:status => 'EOL')
  scope :reactivated, joins(:personalities).where("status != ?", 'Active')
  scope :other, where("status NOT IN (?)", ['Active', 'Inactive', 'EOL'])
  
  def to_s
    serial_number
  end
end

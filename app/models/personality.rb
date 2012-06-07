class Personality < ActiveRecord::Base
  belongs_to :device
  belongs_to :network
  has_one :location, :through => :network
  has_and_belongs_to_many :vulnerabilities
  
  default_scope :order => 'name ASC'
  scope :orphans, where(:device_id => nil)
  scope :nameless, where("ip LIKE ? AND name LIKE ?", "192.168.%.___", "%-%-%-%")
  scope :missing_1_week, where("updated_at < ?", 1.week.ago)
  scope :missing_1_month, where("updated_at < ?", 1.month.ago)
  scope :servers, joins(:device).where("devices.kind = ? or devices.kind = ?", "Server", "Virtual Datacenter")
end

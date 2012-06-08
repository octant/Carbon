ActiveAdmin.register Personality do
  scope :all
  scope :orphans, :default => true
  scope :nameless
  scope :missing_1_week
  scope :missing_1_month
  scope :servers
  
  filter :name
  filter :ip
  filter :last_seen

  index do
    column :name do |personality|
      link_to personality.name, admin_personality_path(personality)
    end
    column :ip
    column :last_seen
    column "Actions" do |personality|
      link_to "Edit", edit_admin_personality_path(personality), :target => '_blank'
    end
    
  end

  show do
    panel "Personality Details" do
      attributes_table_for personality do
        row :name
        row :ip
        row :last_seen
        row :created_at
      end
    end

    if personality.location
      panel "Location" do
        attributes_table_for personality.location do
          row :name do
            link_to personality.location.name,
            admin_location_path(personality.location)
          end
          row :address
        end
      end
    end
    
    if personality.device
      panel "Associated Device Details" do
        attributes_table_for personality.device do
          row :kind
          row :manufacturer
          row :model
          row :serial_number do
            link_to personality.device.serial_number,
            admin_device_path(personality.device)
          end
          row :asset_tag
          row :status
        end
      end
    end

    panel "Vulnerabilities" do
      table_for personality.vulnerabilities.priority.order("severity DESC") do
        column :severity
        column "QID", :qid do |vuln|
          link_to vuln.qid, admin_vulnerability_path(vuln)
        end
        column :title
      end
    end
    
  end

  form do |f|
    f.inputs "Details" do
      f.input :device, :collection => Device.order(:serial_number).all
      f.input :network
      f.input :name
      f.input :ip
    end

    f.buttons
  end
end

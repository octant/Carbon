ActiveAdmin.register List do
  filter :name
  filter :description
  
  index do
    column :name do |list|
      link_to list.name, admin_list_path(list)
    end
    column :description
  end
  
  show do
    panel "List Details" do
      attributes_table_for list do
        row :name
        row :description
      end
    end
    
    panel "Personalities" do
      table_for list.personalities do
        column :name do |personality|
          link_to personality.name, admin_personality_path(personality)
        end
        column :device do |personality|
          link_to personality.device, admin_device_path(personality.device) if personality.device
        end
        column "High Priority" do |personality|
          personality.vulnerabilities.high_priority.size
        end
        column "Low Priority" do |personality|
          personality.vulnerabilities.low_priority.size
        end
        column "No Patch" do |personality|
          personality.vulnerabilities.unfixable.size
        end
      end
    end      
  end
end

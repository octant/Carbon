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
    
    
    list.personalities.order("name DESC").each do |personality|
      panel personality.name do
        
        attributes_table_for personality do
          row :ip
          row :last_seen
        end
        
        h4 "Vulnerabilities - High Priority"
        table_for personality.vulnerabilities.high_priority do
          column "QID", :qid do |vuln|
            link_to vuln.qid, admin_vulnerability_path(vuln)
          end
          column :title
        end
        
        h4 "Vulnerabilities - Low Priority"
        table_for personality.vulnerabilities.low_priority do
          column "QID", :qid do |vuln|
            link_to vuln.qid, admin_vulnerability_path(vuln)
          end
          column :title
        end
        
      end
    end
      
  end
end

ActiveAdmin.register Vulnerability do
  filter :qid
  filter :title
  filter :severity
  filter :fixable, :as => :select
  filter :pci, :as => :select
  
  scope :priority, :default => true
  scope :all
  
  index do
    column :severity
    column "QID", :qid do |vuln|
      link_to vuln.qid, admin_vulnerability_path(vuln)
    end
    column :title
    column (:fixable) {|vuln| status_tag "#{vuln.fixable}", vuln.fixable ? :ok : :error}
  end
  
  show do
    h3 "#{vulnerability.title} [#{vulnerability.severity}]"
    
    panel "Solution" do
      simple_format vulnerability.solution
    end
    
    panel "Diagnosis" do
      simple_format vulnerability.diagnosis
    end
    
    panel "Consequence" do
      simple_format vulnerability.consequence
    end
    
    panel "Installs Affected" do
      table_for vulnerability.personalities do
        column :name do |personality|
          link_to personality.name, admin_personality_path(personality)
        end
      end
    end
  end
end

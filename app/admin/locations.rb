ActiveAdmin.register Location do
  filter :name
  filter :address
  filter :status

  index do
    column :name do |location|
      link_to location.name, admin_location_path(location)
    end
    column :address
    column (:status)  {|location| status_tag location.status, location.status == 'Active'? :ok : :error}
  end

  show do
    panel "Location Details" do
      attributes_table_for location do
        row :name
        row :address
      end
    end

    panel "Networks" do
      table_for location.networks do
        column :network_identifier
        column :network_mask
        column :default_gateway
      end
    end

    panel "Personalities (#{location.personalities.size})" do
      table_for location.personalities.order(:name) do
        column "Type" do |p|
          p.device ? p.device.kind : ""
        end
        column "Make/Model" do |p|
          p.device ? "#{p.device.manufacturer} #{p.device.model}" : ""
        end
        column "Serial Number" do |p|
          p.device ? (link_to p.device.serial_number,
          admin_device_path(p.device)) : ""
        end
        column :name do |p|
          link_to p.name, admin_personality_path(p)
        end
        column :ip
        column "Last Seen", :updated_at
      end
    end
  end
end

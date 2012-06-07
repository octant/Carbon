ActiveAdmin.register Network do
  filter :network_identifier
  filter :network_mask
  filter :default_gateway

  index do
    column :network_identifier do |network|
      link_to network.network_identifier, admin_network_path(network)
    end
    column :network_mask
    column :default_gateway

  end

  show do
    panel "Network Details" do
      attributes_table_for network do
        row :network_identifier
        row :network_mask
        row :default_gateway
      end
    end

    panel "Location" do
      attributes_table_for network.location do
        row :name
        row :address
      end
    end

    panel "Personalities (#{network.personalities.size})" do
      table_for network.personalities.order(:name) do
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

ActiveAdmin.register Device do
  scope :all
  scope :active, :default => true
  scope :inactive
  scope :eol
  scope :reactivated
  scope :other
  
  filter :kind, :label => "Type"
  filter :manufacturer
  filter :model
  filter :serial_number
  filter :asset_tag
  filter :status
  
  index do
    column "Type", :kind
    column :manufacturer
    column :model
    column :serial_number do |device|
      link_to device.serial_number, admin_device_path(device)
    end
    column :asset_tag
    column (:status) do |device|
      status_tag(device.status, device.status == 'Active' ? :ok : :error)
    end
  end

  show do
    panel "Device Details" do
      attributes_table_for device do
        row :manufacturer
        row :model
        row :serial_number
        row :asset_tag
        row (:status) {|device| status_tag device.status, device.status == 'Active'? :ok : :error}
      end
    end

    panel "Purchase Record" do
      if device.purchase_record
        attributes_table_for device.purchase_record do
          row :description
          row :purchased
        end
      end
    end

    unless device.personalities.empty?
      panel "Location" do
        attributes_table_for device.personalities.order(:updated_at).first.location do
          row :name
          row :address
        end
      end

      panel "Personalities" do
        table_for device.personalities do
          column :name
          column :ip
          column "Last Seen", :updated_at
        end
      end
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :purchase_record
      f.input :kind, :label => "Type"
      f.input :manufacturer
      f.input :model
      f.input :serial_number
      f.input :asset_tag
      f.input :status
    end
    f.buttons
  end
end

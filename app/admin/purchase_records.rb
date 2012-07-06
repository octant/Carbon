ActiveAdmin.register PurchaseRecord, {:sort_order => :purchased} do
  filter :description
  filter :purchased
  index do
    column :id
    column :description do |purchase|
      link_to purchase.description, admin_purchase_record_path(purchase)
    end
    column :purchased
  end

  show do
    panel "Purchase Record Details" do
      attributes_table_for purchase_record do
        row :description
        row :purchased
      end
    end

    panel "Devices (#{purchase_record.devices.size})" do
      table_for purchase_record.devices do
        column "Type", :kind
        column :asset_tag
        column :manufacturer
        column :model
        column :serial_number do |device|
          link_to device.serial_number, admin_device_path(device)
        end

      end
    end

  end

  form do |f|
    f.inputs "Details" do
      f.input :description
      f.input :purchased, :as => :datepicker
    end

    f.buttons
  end
end

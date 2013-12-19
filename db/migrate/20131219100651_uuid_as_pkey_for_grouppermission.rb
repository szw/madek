class UuidAsPkeyForGrouppermission < ActiveRecord::Migration
  def up

    remove_column :grouppermissions, :id
    add_column :grouppermissions, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE grouppermissions ADD PRIMARY KEY (id)]

    remove_column :userpermissions, :id
    add_column :userpermissions, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE userpermissions ADD PRIMARY KEY (id)]

    remove_column :keywords, :id
    add_column :keywords, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE keywords ADD PRIMARY KEY (id)]

    remove_column :meta_key_definitions, :id
    add_column :meta_key_definitions, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE meta_key_definitions ADD PRIMARY KEY (id)]

    remove_column :previews, :id
    add_column :previews, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE previews ADD PRIMARY KEY (id)]

    remove_column :permission_presets, :id
    add_column :permission_presets, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE permission_presets ADD PRIMARY KEY (id)]

  
  end
end

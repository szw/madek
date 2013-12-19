class UuidAsPkeyForGroups < ActiveRecord::Migration
  def up

    add_column :groups, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'

    add_column :grouppermissions, :group_uuid, :uuid
    execute %[ UPDATE grouppermissions
                SET group_uuid = groups.uuid 
                FROM groups
                WHERE groups.id = grouppermissions.group_id ] 
    remove_column :grouppermissions, :group_id 
    rename_column :grouppermissions, :group_uuid, :group_id
    add_index :grouppermissions, :group_id

    add_column :meta_data_meta_departments, :meta_department_uuid, :uuid
    execute %[ UPDATE meta_data_meta_departments
                SET meta_department_uuid = groups.uuid 
                FROM groups
                WHERE groups.id = meta_data_meta_departments.meta_department_id ] 
    remove_column :meta_data_meta_departments, :meta_department_id 
    rename_column :meta_data_meta_departments, :meta_department_uuid, :meta_department_id
    add_index :meta_data_meta_departments, :meta_department_id

    add_column :groups_users, :group_uuid, :uuid
    execute %[ UPDATE groups_users
                SET group_uuid = groups.uuid 
                FROM groups
                WHERE groups.id = groups_users.group_id ] 
    remove_column :groups_users, :group_id 
    rename_column :groups_users, :group_uuid, :group_id
    add_index :groups_users, :group_id

    remove_column :groups, :id
    rename_column :groups, :uuid, :id
    execute %[ALTER TABLE groups ADD PRIMARY KEY (id)]

    add_foreign_key :grouppermissions, :groups, dependent: :delete
    add_foreign_key :groups_users, :groups, dependent: :delete
    add_foreign_key :meta_data_meta_departments, :groups, column: :meta_department_id, dependent: :delete

  end
end

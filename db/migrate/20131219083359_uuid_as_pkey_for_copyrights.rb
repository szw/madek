class UuidAsPkeyForCopyrights < ActiveRecord::Migration
  def up

    add_column :copyrights, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'

    add_column :copyrights, :parent_uuid, :uuid
    execute %[ UPDATE copyrights 
                SET parent_uuid = cp.uuid 
                FROM copyrights as cp
                WHERE copyrights.parent_id = cp.parent_id] 
    remove_column :copyrights, :parent_id
    rename_column :copyrights, :parent_uuid, :parent_id

    add_column :meta_data, :copyright_uuid, :uuid
    execute %[ UPDATE meta_data
                SET copyright_uuid = copyrights.uuid 
                FROM copyrights
                WHERE copyrights.id = meta_data.copyright_id ] 
    remove_column :meta_data, :copyright_id 
    rename_column :meta_data, :copyright_uuid, :copyright_id
    add_index :meta_data, :copyright_id

    remove_column :copyrights, :id

    rename_column :copyrights, :uuid, :id
    execute %[ALTER TABLE copyrights ADD PRIMARY KEY (id)]

    add_foreign_key :copyrights, :copyrights, column: :parent_id
    add_foreign_key :meta_data, :copyrights, dependent: :delete 

  end
end

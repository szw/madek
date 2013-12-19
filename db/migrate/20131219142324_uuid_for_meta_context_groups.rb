class UuidForMetaContextGroups < ActiveRecord::Migration
  def up
    add_column :meta_context_groups, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'

    add_column :meta_contexts, :meta_context_group_uuid, :uuid
    execute %[ UPDATE meta_contexts
                SET meta_context_group_uuid = meta_context_groups.uuid 
                FROM meta_context_groups
                WHERE meta_context_groups.id = meta_contexts.meta_context_group_id ] 
    remove_column :meta_contexts, :meta_context_group_id 
    rename_column :meta_contexts, :meta_context_group_uuid, :meta_context_group_id
    add_index :meta_contexts, :meta_context_group_id

    remove_column :meta_context_groups, :id
    rename_column :meta_context_groups, :uuid, :id
    execute %[ALTER TABLE meta_context_groups ADD PRIMARY KEY (id)]

    add_foreign_key :meta_contexts, :meta_context_groups, options: 'ON DELETE SET NULL'

  end
end

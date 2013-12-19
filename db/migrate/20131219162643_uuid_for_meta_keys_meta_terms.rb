class UuidForMetaKeysMetaTerms < ActiveRecord::Migration
  def up
    remove_column :meta_keys_meta_terms, :id
    add_column :meta_keys_meta_terms, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE meta_keys_meta_terms ADD PRIMARY KEY (id)]
  end
end

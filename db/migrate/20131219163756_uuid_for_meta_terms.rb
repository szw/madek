class UuidForMetaTerms < ActiveRecord::Migration
  def up
    add_column :meta_terms, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'

    add_column :keywords, :meta_term_uuid, :uuid
    execute %[ UPDATE keywords
                SET meta_term_uuid = meta_terms.uuid 
                FROM meta_terms
                WHERE meta_terms.id = keywords.meta_term_id ] 
    remove_column :keywords, :meta_term_id 
    rename_column :keywords, :meta_term_uuid, :meta_term_id
    add_index :keywords, :meta_term_id
    change_column :keywords, :meta_term_id, :uuid, null: :false

    add_column :meta_keys_meta_terms, :meta_term_uuid, :uuid
    execute %[ UPDATE meta_keys_meta_terms
                SET meta_term_uuid = meta_terms.uuid 
                FROM meta_terms
                WHERE meta_terms.id = meta_keys_meta_terms.meta_term_id ] 
    remove_column :meta_keys_meta_terms, :meta_term_id 
    rename_column :meta_keys_meta_terms, :meta_term_uuid, :meta_term_id
    add_index :meta_keys_meta_terms, :meta_term_id
    change_column :meta_keys_meta_terms, :meta_term_id, :uuid, null: false

    add_column :meta_contexts, :description_uuid, :uuid
    execute %[ UPDATE meta_contexts
                SET description_uuid = meta_terms.uuid 
                FROM meta_terms
                WHERE meta_terms.id = meta_contexts.description_id] 
    remove_column :meta_contexts, :description_id
    rename_column :meta_contexts, :description_uuid, :description_id
    add_index :meta_contexts, :description_id

    add_column :meta_contexts, :label_uuid, :uuid
    execute %[ UPDATE meta_contexts
                SET label_uuid = meta_terms.uuid 
                FROM meta_terms
                WHERE meta_terms.id = meta_contexts.label_id] 
    remove_column :meta_contexts, :label_id
    rename_column :meta_contexts, :label_uuid, :label_id
    add_index :meta_contexts, :label_id
    change_column :meta_contexts, :label_id, :uuid, null: false


    add_column :meta_key_definitions, :description_uuid, :uuid
    execute %[ UPDATE meta_key_definitions
                SET description_uuid = meta_terms.uuid 
                FROM meta_terms
                WHERE meta_terms.id = meta_key_definitions.description_id] 
    remove_column :meta_key_definitions, :description_id
    rename_column :meta_key_definitions, :description_uuid, :description_id
    add_index :meta_key_definitions, :description_id

    add_column :meta_key_definitions, :label_uuid, :uuid
    execute %[ UPDATE meta_key_definitions
                SET label_uuid = meta_terms.uuid 
                FROM meta_terms
                WHERE meta_terms.id = meta_key_definitions.label_id] 
    remove_column :meta_key_definitions, :label_id
    rename_column :meta_key_definitions, :label_uuid, :label_id
    add_index :meta_key_definitions, :label_id

    add_column :meta_key_definitions, :hint_uuid, :uuid
    execute %[ UPDATE meta_key_definitions
                SET hint_uuid = meta_terms.uuid 
                FROM meta_terms
                WHERE meta_terms.id = meta_key_definitions.hint_id] 
    remove_column :meta_key_definitions, :hint_id
    rename_column :meta_key_definitions, :hint_uuid, :hint_id
    add_index :meta_key_definitions, :hint_id

    add_column :meta_data_meta_terms, :meta_term_uuid, :uuid
    execute %[ UPDATE meta_data_meta_terms
                SET meta_term_uuid = meta_terms.uuid 
                FROM meta_terms
                WHERE meta_terms.id = meta_data_meta_terms.meta_term_id] 
    remove_column :meta_data_meta_terms, :meta_term_id
    rename_column :meta_data_meta_terms, :meta_term_uuid, :meta_term_id
    add_index :meta_data_meta_terms, :meta_term_id
    change_column :meta_data_meta_terms, :meta_term_id, :uuid, null: false

    remove_column :meta_terms, :id
    rename_column :meta_terms, :uuid, :id
    execute %[ALTER TABLE meta_terms ADD PRIMARY KEY (id)]

    add_foreign_key :keywords, :meta_terms, dependent: :delete
    add_foreign_key :meta_keys_meta_terms, :meta_terms, dependent: :delete
    add_foreign_key :meta_contexts, :meta_terms, column: :description_id
    add_foreign_key :meta_contexts, :meta_terms, column: :label_id
    add_foreign_key :meta_key_definitions, :meta_terms, column: :description_id
    add_foreign_key :meta_key_definitions, :meta_terms, column: :label_id
    add_foreign_key :meta_key_definitions, :meta_terms, column: :hint_id
    add_foreign_key :meta_data_meta_terms, :meta_terms 

  end
end

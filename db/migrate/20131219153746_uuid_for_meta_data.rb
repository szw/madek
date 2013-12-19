class UuidForMetaData < ActiveRecord::Migration
  def up
    add_column :meta_data, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'

    add_column :keywords, :meta_datum_uuid, :uuid
    execute %[ UPDATE keywords
                SET meta_datum_uuid = meta_data.uuid 
                FROM meta_data
                WHERE meta_data.id = keywords.meta_datum_id ] 
    remove_column :keywords, :meta_datum_id 
    rename_column :keywords, :meta_datum_uuid, :meta_datum_id
    add_index :keywords, :meta_datum_id

    add_column :meta_data_meta_terms, :meta_datum_uuid, :uuid
    execute %[ UPDATE meta_data_meta_terms
                SET meta_datum_uuid = meta_data.uuid 
                FROM meta_data
                WHERE meta_data.id = meta_data_meta_terms.meta_datum_id ] 
    remove_column :meta_data_meta_terms, :meta_datum_id 
    rename_column :meta_data_meta_terms, :meta_datum_uuid, :meta_datum_id
    add_index :meta_data_meta_terms, :meta_datum_id
    add_index :meta_data_meta_terms, [:meta_datum_id, :meta_term_id], unique: true

    add_column :meta_data_people, :meta_datum_uuid, :uuid
    execute %[ UPDATE meta_data_people
                SET meta_datum_uuid = meta_data.uuid 
                FROM meta_data
                WHERE meta_data.id = meta_data_people.meta_datum_id ] 
    remove_column :meta_data_people, :meta_datum_id 
    rename_column :meta_data_people, :meta_datum_uuid, :meta_datum_id
    add_index :meta_data_people, :meta_datum_id
    add_index :meta_data_people, [:meta_datum_id, :person_id], unique: true

    add_column :meta_data_users, :meta_datum_uuid, :uuid
    execute %[ UPDATE meta_data_users
                SET meta_datum_uuid = meta_data.uuid 
                FROM meta_data
                WHERE meta_data.id = meta_data_users.meta_datum_id ] 
    remove_column :meta_data_users, :meta_datum_id 
    rename_column :meta_data_users, :meta_datum_uuid, :meta_datum_id
    add_index :meta_data_users, :meta_datum_id
    add_index :meta_data_users, [:meta_datum_id, :user_id], unique: true

    add_column :meta_data_meta_departments, :meta_datum_uuid, :uuid
    execute %[ UPDATE meta_data_meta_departments
                SET meta_datum_uuid = meta_data.uuid 
                FROM meta_data
                WHERE meta_data.id = meta_data_meta_departments.meta_datum_id ] 
    remove_column :meta_data_meta_departments, :meta_datum_id 
    rename_column :meta_data_meta_departments, :meta_datum_uuid, :meta_datum_id
    add_index :meta_data_meta_departments, :meta_datum_id
    add_index :meta_data_meta_departments, [:meta_datum_id, :meta_department_id], \
      unique: true, name: 'index_meta_data_meta_dep_on_meta_datum_id_and_meta_dep_id'

    remove_column :meta_data, :id 
    rename_column :meta_data, :uuid, :id
    execute %[ALTER TABLE meta_data ADD PRIMARY KEY (id)]

    add_foreign_key :keywords, :meta_data, dependent: :delete
    add_foreign_key :meta_data_meta_terms, :meta_data, dependent: :delete
    add_foreign_key :meta_data_people, :meta_data, dependent: :delete
    add_foreign_key :meta_data_users, :meta_data, dependent: :delete
    add_foreign_key :meta_data_meta_departments, :meta_data, dependent: :delete

  end

end

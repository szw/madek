class UuidForPeople < ActiveRecord::Migration

  def prepare_table table_name 
    add_column table_name, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'
  end

  def migrate_table table_name 
    remove_column table_name, :id
    rename_column table_name, :uuid, :id
    execute %[ALTER TABLE #{table_name} ADD PRIMARY KEY (id)]
  end

  def migrate_foreign_key foreign_key_table_name, referenced_table_name
    column_name= "#{referenced_table_name.singularize}_id"
    tmp_column= "#{column_name}_tmp"
    foreign_key_column= "#{referenced_table_name}.uuid"

    add_column foreign_key_table_name, tmp_column, :uuid
    execute %[ UPDATE #{foreign_key_table_name}
                SET #{tmp_column} = #{foreign_key_column}
                FROM #{referenced_table_name}
                WHERE #{referenced_table_name}.id = #{foreign_key_table_name}.#{referenced_table_name.singularize}_id ] 
    remove_column foreign_key_table_name, column_name
    rename_column foreign_key_table_name, tmp_column, column_name
    add_index foreign_key_table_name, column_name
    change_column foreign_key_table_name, column_name, :uuid, null: :false
  end


  def up

    prepare_table 'people'

    migrate_foreign_key 'users', 'people'
    migrate_foreign_key 'meta_data_people', 'people'
    add_index 'meta_data_people', [:meta_datum_id,:person_id], unique: true

    migrate_table 'people'

    add_foreign_key 'users','people'
    add_foreign_key 'meta_data_people', 'people'

  end
end

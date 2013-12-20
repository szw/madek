require Rails.root.join "db","migrate","uuid_migration_helper"

class UuidAsPkeyForMetaEverything < ActiveRecord::Migration

  include ::UuidMigrationHelper

  def up

    #
    # meta_terms
    #

    prepare_table 'meta_terms'

    migrate_foreign_key 'keywords', 'meta_terms'
    migrate_foreign_key 'meta_contexts', 'meta_terms', false, 'label_id'
    migrate_foreign_key 'meta_contexts', 'meta_terms', true, 'description_id'
    migrate_foreign_key 'meta_data_meta_terms', 'meta_terms'
    migrate_foreign_key 'meta_key_definitions', 'meta_terms', true, 'description_id'
    migrate_foreign_key 'meta_key_definitions', 'meta_terms', true, 'hint_id'
    migrate_foreign_key 'meta_key_definitions', 'meta_terms', true, 'label_id'
    migrate_foreign_key 'meta_keys_meta_terms', 'meta_terms'

    migrate_table 'meta_terms'

    add_foreign_key 'keywords', 'meta_terms', dependent: 'delete'
    add_foreign_key 'meta_contexts', 'meta_terms', column: 'description_id', options: 'ON DELETE SET NULL'
    add_foreign_key 'meta_contexts', 'meta_terms', column: 'label_id'
    add_foreign_key 'meta_data_meta_terms', 'meta_terms', dependent: 'delete'
    add_foreign_key 'meta_key_definitions', 'meta_terms', column: 'description_id', options: 'ON DELETE SET NULL'
    add_foreign_key 'meta_key_definitions', 'meta_terms', column: 'hint_id', options: 'ON DELETE SET NULL'
    add_foreign_key 'meta_key_definitions', 'meta_terms', column: 'label_id', options: 'ON DELETE SET NULL' 
    add_foreign_key 'meta_keys_meta_terms', 'meta_terms'

    raise 'NOT YET' 
  end
end

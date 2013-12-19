class UuidAsPkeyForMediaFile < ActiveRecord::Migration
  def up
    add_column :media_files, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'

    add_column :previews, :media_file_uuid, :uuid
    execute %[ UPDATE previews
                SET media_file_uuid = media_files.uuid 
                FROM media_files
                WHERE media_files.id = previews.media_file_id ] 
    remove_column :previews, :media_file_id 
    rename_column :previews, :media_file_uuid, :media_file_id
    add_index :previews, :media_file_id

    add_column :zencoder_jobs, :media_file_uuid, :uuid
    execute %[ UPDATE zencoder_jobs
                SET media_file_uuid = media_files.uuid 
                FROM media_files
                WHERE media_files.id = zencoder_jobs.media_file_id ] 
    remove_column :zencoder_jobs, :media_file_id 
    rename_column :zencoder_jobs, :media_file_uuid, :media_file_id
    add_index :zencoder_jobs, :media_file_id

    remove_column :media_files, :id 
    rename_column :media_files, :uuid, :id
    execute %[ALTER TABLE media_files ADD PRIMARY KEY (id)]

    add_foreign_key :previews, :media_files
    add_foreign_key :zencoder_jobs, :media_files, dependent: :delete
  end
end

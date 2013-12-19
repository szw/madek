class UuidAsPkeyForEditSessions < ActiveRecord::Migration
  def up
    remove_column :edit_sessions, :id
    add_column :edit_sessions, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE edit_sessions ADD PRIMARY KEY (id)]
  end
end

class UuidAsPkeyForMediaResourceArcs < ActiveRecord::Migration
  def up
    remove_column :media_resource_arcs, :id
    add_column :media_resource_arcs, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    execute %[ALTER TABLE media_resource_arcs ADD PRIMARY KEY (id)]
  end
end

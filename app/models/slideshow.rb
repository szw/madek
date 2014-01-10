class Slideshow
  attr_reader :media_set, :current_user, :order, :asc

  def initialize(media_set, order, current_user = nil)
    @media_set    = media_set
    @current_user = current_user
    self.order    = order
  end

  def contents
    @contents ||= fetch_contents
  end

  def order=(value)
    case value.to_s.downcase
    when /\A(created|updated)_at\z/
      @asc   = false
      @order = value.to_s.downcase.to_sym
    when /\Aname|title\z/
      @asc   = true
      @order = :name
    else
      @asc   = false
      @order = :created_at
    end
  end

  private

  def fetch_contents
    media_sets        = fetch_children(:media_sets)
    media_entries_ids = fetch_children(:media_entries).pluck("media_resources.id")

    media_files       = MediaFile.where(media_entry_id: media_entries_ids)

    contents          = []

    media_files.each do |mf|
      media_entry = media_set.child_media_resources.find(mf.media_entry_id)

      contents << {
        content_type: mf.content_type,
        id:           mf.media_entry_id,
        name:         media_entry.title,
        copyright:    media_entry.meta_data.select { |md| md[:meta_key_id] == "copyright notice" }.first.string,
        filename:     mf.filename,
        created_at:   media_entry.created_at,
        updated_at:   media_entry.updated_at
      }
    end

    media_sets.each do |set|
      contents << {
        content_type: "media_set",
        id:           set.id,
        name:         set.title,
        copyright:    "",
        created_at:   set.created_at,
        updated_at:   set.updated_at
      }
    end

    contents.sort! { |a, b| a[order] <=> b[order] }
    contents.reverse! unless asc

    contents
  end

  def fetch_children(source)
    children = media_set.child_media_resources.send(source)
    children = children.accessible_by_user(current_user, :view) if current_user
    children
  end
end

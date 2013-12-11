# -*- encoding : utf-8 -*-
 
class MetaDatumString < MetaDatum

  def to_s
    v = value
    if v.is_a?(Hash) # NOTE this is not recursive
      v.map {|x,y| "#{x.to_s.classify}: #{y}"}.join(', ')
    else
      v.to_s
    end
  end

  def value(user=nil)
    case meta_key.label
      when "uploaded at"
        media_resource.created_at #old# .to_formatted_s(:date_time)
      when "copyright usage"
        copyright = media_resource.try(:meta_data).try(:get,"copyright status").try(:value) || Copyright.default
        copyright.usage(read_attribute(:string))
      when "copyright url"
        copyright = media_resource.try(:meta_data).try(:get,"copyright status").try(:value) || Copyright.default 
        copyright.url(read_attribute(:string))
      when "public access"
        media_resource.is_public?
      when "media type"
        media_resource.media_type
      when "parent media_resources"
        {:media_sets => media_resource.parent_sets.accessible_by_user(user,:view).count}
      # TODO problem with FilterSet ???
      when "child media_resources"
        {:media_sets => media_resource.child_media_resources.media_sets.accessible_by_user(user,:view).count,
         :media_entries => media_resource.child_media_resources.media_entries.accessible_by_user(user,:view).count} if media_resource.is_a?(MediaSet)
      else
        string
    end
  end

  def value=(new_value)
    self.string = new_value
  end
  
end

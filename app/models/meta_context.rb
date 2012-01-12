# -*- encoding : utf-8 -*-
#=MetaContext
# A MetaContext is a representation of a set of meta-data requirements for a particular domain.
# for example, we start with a base set ("Core") that has approximately 7 definitions.
# Further contexts may 'inherit' from the Core defintions (actually, it's a nested set)
# MetaContexts were originally intended to provide assistance selecting the right keys to be exported to a given external system
# However, they are quite flexible, and may also be used for managing meta-data upon import.
class MetaContext < ActiveRecord::Base
  
  has_many :meta_key_definitions, :dependent => :destroy
  has_many :meta_keys, :through => :meta_key_definitions, :order => :position

  validates_presence_of :name

  # NOTE the overridden method MUST come BEFORE the serialize statement or IT WILL FAIL ON LINUX!!
  def meta_field=(hash = {})
    f = meta_field || MetaField.new
    f.update_attributes(hash)
    write_attribute(:meta_field, f)
  end
  serialize     :meta_field, MetaField

##################################################################

  scope :for_interface, where(:is_user_interface => true)
  scope :for_import_export, where(:is_user_interface => false)

##################################################################

  def to_s
    "#{meta_field.try(:label)}"
  end

  def description
    "#{meta_field.try(:description)}"
  end

  def next_position
    meta_key_definitions.maximum(:position).try(:next).to_i
  end

##################################################################

  # TODO dry with Media::Set#abstract  
  def abstract(current_user = nil, min_media_entries = nil)
    accessible_media_entry_ids = media_entries(current_user).map(&:id)
    min_media_entries ||= accessible_media_entry_ids.size.to_f * 50 / 100
    meta_key_ids = meta_keys.where(:is_dynamic => nil).map(&:id) # TODO get all related meta_key_ids ?? 

    h = {} #1005# TODO upgrade to Ruby 1.9 and use ActiveSupport::OrderedHash.new
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :resource_type => "MediaEntry", :resource_id => accessible_media_entry_ids)
    mds.each do |md|
      h[md.meta_key_id] ||= [] # TODO md.meta_key
      h[md.meta_key_id] << md.value
    end
    h.delete_if {|k, v| v.size < min_media_entries }
    h.each_pair {|k, v| h[k] = v.flatten.group_by {|x| x}.delete_if {|k, v| v.size < min_media_entries }.keys }
    h.delete_if {|k, v| v.blank? }
    #1005# return h.collect {|k, v| meta_data.build(:meta_key_id => k, :value => v) }
    b = []
    h.each_pair {|k, v| b[meta_key_ids.index(k)] = MetaDatum.new(:meta_key_id => k, :value => v) }
    return b.compact
  end

  # TODO dry with Media::Set#used_meta_term_ids  
  def used_meta_term_ids(current_user = nil)
    meta_key_ids = meta_keys.for_meta_terms.map(&:id)

    mds = if current_user
      accessible_media_entry_ids = MediaResource.accessible_by_user(current_user).media_entries.map(&:id)
      MetaDatum.where(:meta_key_id => meta_key_ids, :resource_type => "MediaEntry", :resource_id => accessible_media_entry_ids)
    else
      MetaDatum.where(:meta_key_id => meta_key_ids)
    end

    mds.collect(&:value).flatten.uniq.compact
  end

  # chainable query
  def media_entries(current_user = nil)
    sql = if current_user
      MediaResource.accessible_by_user(current_user).media_entries.
        joins("INNER JOIN meta_data ON (media_resources.id, media_resources.type) = (meta_data.resource_id, meta_data.resource_type)")
    else
      MediaEntry.joins(:meta_data)
    end
    sql.group("meta_data.resource_id, meta_data.resource_type").where(:meta_data => {:meta_key_id => meta_key_ids})
  end

##################################################################

  def self.defaults
    [media_content, media_object, copyright, zhdk_bereich]
  end

  def self.method_missing(*args)
    # TODO identity_map for MetaContext similar to MetaKey ??
    # @contexts ||= {} # doesn't reflect updated meta_keys position order
    @contexts = {}
    @contexts[args.first] ||= where(:name => args.first.to_s).first
    @contexts[args.first] || super
  end

end

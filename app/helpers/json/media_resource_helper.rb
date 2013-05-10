# -*- encoding : utf-8 -*-

module Json
  module MediaResourceHelper

    def hash_for_media_resource(media_resource, with = nil)
      h = {
        id: media_resource.id,
        type: media_resource.type.underscore
      }
      
      if with ||= nil
        [:user_id, :created_at, :updated_at].each do |k|
          h[k] = media_resource.send(k) if with[k]
        end
      
        if with[:image]
          size = with[:image][:size] || :small # TODO :small_125 ??
          h[:image] = case with[:image][:as]
            when "base64"
              media_resource.get_media_file(current_user).try(:thumb_base64, size)
            else # default return is a url to the image
              image_media_resource_path(media_resource, :size => size)
          end            
        end
        
        if with[:meta_data]
          h[:meta_data] = []
          if meta_context_names = with[:meta_data][:meta_context_names]
            @cache_contexts ||= {}
            meta_context_names.each do |name|
              @cache_contexts[name] ||= MetaContext.send(name)
              h[:meta_data] += hash_for media_resource.meta_data.for_context(@cache_contexts[name]), {:label => {:context => @cache_contexts[name]}}
            end
          end
          if meta_key_ids = with[:meta_data][:meta_key_ids]
            h[:meta_data] += meta_key_ids.map do |name|
              md = media_resource.meta_data.get(name)
              hash_for md # NOTE we do not request labels, because are context related
            end
          end
        end
        
        if with[:media_type]
          h[:media_type] = media_resource.media_type.downcase
        end
        
        if with[:filename]
          h[:filename] = media_resource.is_a?(MediaSet) ? nil : media_resource.media_file.filename
        end

        if with[:size]
          h[:size] = media_resource.is_a?(MediaSet) ? nil : media_resource.media_file.size
        end

        if with[:is_public]
          h[:is_public] = media_resource.is_public?
        end

        if with[:is_private]
          h[:is_private] = media_resource.is_public? ? false : media_resource.is_private?(current_user)
        end

        if with[:is_editable]
          h[:is_editable] = @cache_is_editable ? @cache_is_editable.include?(media_resource.id) : current_user.authorized?(:edit, media_resource)
        end

        if with[:is_deletable]
          h[:is_deletable] = @cache_is_deletable ? @cache_is_deletable.include?(media_resource.id) : current_user.authorized?(:delete, media_resource)
        end

        if with[:is_manageable]
          h[:is_manageable] = @cache_is_manageable ? @cache_is_manageable.include?(media_resource.id) : current_user.authorized?(:manage, media_resource)
        end

        if with[:is_favorite]
          h[:is_favorite] =  @cache_is_favorite ? @cache_is_favorite.include?(media_resource.id) : current_user.favorite_ids.include?(media_resource.id)
        end
        
        if with[:parents]
          pagination = ((with[:parents].is_a? Hash) ? with[:parents][:pagination] : nil) || true
          forwarded_with = (with[:parents].is_a? Hash) ? (with[:parents][:with]||=nil) : nil
          media_resources= media_resource.parents.accessible_by_user(current_user)
          h[:parents] = hash_for_media_resources_with_pagination(media_resources, pagination, forwarded_with)
        end
      
        case media_resource.class.model_name.to_s
          when "MediaSet"
            if with[:children]
              h[:children] = begin
                # respond with media_resources children
                media_resources = media_resource.child_media_resources.accessible_by_user(current_user)
                
                case with[:children][:type]
                  when "media_entry"
                    media_resources = media_resources.media_entries
                  when "media_set"
                    media_resources = media_resources.media_sets
                end if with[:children].is_a?(Hash) and with[:children][:type]
                  
                pagination = ((with[:children].is_a? Hash) ? with[:children][:pagination] : nil) || true
                forwarded_with = (with[:children].is_a? Hash) ? (with[:children][:with]||=nil) : nil
                hash_for_media_resources_with_pagination(media_resources, pagination, forwarded_with, true)
              end
            end

          when "FilterSet"
            if with[:children]
              h[:children] = begin
                # respond with media_resources children
                media_resources = media_resource.filtered_resources(current_user)
                
                case with[:children][:type]
                  when "media_entry"
                    media_resources = media_resources.media_entries
                  when "media_set"
                    media_resources = media_resources.media_sets
                end if with[:children].is_a?(Hash) and with[:children][:type]
                  
                pagination = ((with[:children].is_a? Hash) ? with[:children][:pagination] : nil) || true
                forwarded_with = (with[:children].is_a? Hash) ? (with[:children][:with]||=nil) : nil
                hash_for_media_resources_with_pagination(media_resources, pagination, forwarded_with, true)
              end
            end
 
          
          when "MediaEntry"
            [:media_file_id].each do |k|
              h[k] = media_resource.send(k) if with[k]
            end
            #old template#
            #if with[:flags]
            #  h[:can_maybe_browse] = media_resource.meta_data.for_meta_terms.exists?
            #end
        end
      end
      
      h
    end
    
    alias :hash_for_media_entry_incomplete :hash_for_media_resource 
    alias :hash_for_media_entry :hash_for_media_resource 
    alias :hash_for_media_set :hash_for_media_resource 
    alias :hash_for_filter_set :hash_for_media_resource 

    ###########################################################################

    def hash_for_media_resources_with_pagination(media_resources, pagination, with = nil, type_totals = false)
      page = (pagination.is_a?(Hash) ? pagination[:page] : nil) || 1
      per_page = [((pagination.is_a?(Hash) ? pagination[:per_page] : nil) || PER_PAGE.first).to_i.abs, PER_PAGE.last].min
      paginated_media_resources = media_resources.page(page).per(per_page)
      
      pagination = {
        total: paginated_media_resources.total_count, 
        page: paginated_media_resources.current_page,
        per_page: per_page,
        total_pages: paginated_media_resources.total_pages
      }
      if type_totals
        pagination[:total_media_entries] = media_resources.media_entries.count 
        pagination[:total_media_sets] = media_resources.media_sets.count
      end

      ##### eager loading
      if with ||= nil
        if with[:media_type]
          paginated_media_resources = paginated_media_resources.includes(:media_file)
        end
        if with[:is_editable]
          @cache_is_editable = MediaResource.accessible_by_user(current_user, :edit).where(:id => paginated_media_resources).pluck(:id)
        end
        if with[:is_manageable]
          @cache_is_manageable = MediaResource.accessible_by_user(current_user, :manage).where(:id => paginated_media_resources).pluck(:id)
        end
        if with[:is_favorite]
          @cache_is_favorite = current_user.favorites.where(:id => paginated_media_resources).pluck(:id)
        end
      end
      #####

      {
        pagination: pagination, 
        media_resources: hash_for(paginated_media_resources, with)
      }
    end

    def hash_for_filter(media_resources, filter_types = [:media_files, :permissions, :meta_data, :media_resource_type])
      r = []

      if filter_types.include? :media_resource_type
        r << { :filter_type => "media_resources",
               :context_name => "media_resources", 
               :context_label => "Inhalte",
               :keys => [
                  { key_name: "type",
                    key_label: "Typ",
                    terms:
                      begin
                        entries = {:id => "MediaEntry", :value => "Medieneinträge", :count => media_resources.where(:type => "MediaEntry").count},
                                  {:id => "MediaSet", :value => "Sets", :count => media_resources.where(:type => "MediaSet").count},
                                  {:id => "FilterSet", :value => "Filtersets", :count => media_resources.where(:type => "FilterSet").count}
                        entries.reject! {|e| e[:count] == 0}
                        entries.sort_by{|e| e[:count]}.reverse!
                      end
                  }
               ]
             }
      end

      if filter_types.include? :media_files
        r << { :filter_type => "media_files",
               :context_name => "media_files", 
               :context_label => "Datei",
               :keys => [ {label: "Medientyp", column: "media_type"},
                          {label: "Dokumenttyp", column: "extension"}].map do |key|
                 column = key[:column]
                 { :key_name => column,
                   :key_label => key[:label],
                   :terms => begin
  
                      filters = MediaFile.
                        select("media_files.#{column} as value, count(*) as count").
                        joins(:media_entries).
                        where(:media_resources => {:id => media_resources}).
                        group("media_files.#{column}").
                        order("count DESC")
  
                      filters.map do |filter|
                        { :id => filter.value, # jpg | png | ...
                         :value => filter.value, #  jpg | png | ...
                         :count => filter.count
                        }
                     end
                   end
                 }
               end
             }
      end

      if filter_types.include? :permissions and not current_user.is_guest?
        r << { :filter_type => "permissions",
               :context_name => "permissions",      
               :context_label => "Berechtigung",     # FIXME get label from the DB
               :keys => [:owner, :group, :scope].map do |k|
                 case k
                   when :owner
                     { :key_name => k,                   
                       :key_label => "Verantwortliche Person", 
                       :terms => begin
                         owners = User.select("users.*, COUNT(media_resources.id) AS count").
                                    includes(:person).
                                    joins("INNER JOIN media_resources ON media_resources.user_id = users.id AND media_resources.id IN (#{media_resources.select("media_resources.id").to_sql}) ").
                                    group("users.id").
                                    order("count DESC")
                         owners.map do |owner|
                           { :id => owner.id,
                             :value => owner.to_s,
                             :count => owner.count
                           }
                         end
                       end
                     }
                   when :group
                     { :key_name => k,
                       :key_label => "Arbeitsgruppen", # FIXME get label from the DB
                       :terms => begin
                         groups = Group.select("groups.*, COUNT(grouppermissions.media_resource_id) AS count").
                                    joins("INNER JOIN groups_users ON groups_users.group_id = groups.id AND groups_users.user_id = #{current_user.id}").
                                    joins("INNER JOIN grouppermissions ON grouppermissions.group_id = groups.id AND grouppermissions.view = TRUE AND grouppermissions.media_resource_id IN (#{media_resources.select("media_resources.id").to_sql}) ").
                                    group("groups.id").
                                    order("count DESC, name")
                         groups.map do |group|
                           { :id => group.id,
                             :value => group.to_s,
                             :count => group.count
                           }
                         end
                       end
                     }
                   when :scope
                     { :key_name => k,
                       :key_label => "Zugriff", # FIXME get label from the DB
                       :terms => begin
                         [[:mine, _("Inhalte, für die ich verantwortlich bin")],
                          [:entrusted, _("Mir anvertraute Inhalte")],
                          [:public,_("Öffentliche Inhalte")]].map do |x,y|
                           if (c = media_resources.filter_permissions(current_user, {:scope => {:ids => [x]}}).count) > 0
                            {:id => x,
                             :value => y,
                             :count => c
                            }   
                           end
                         end.compact.sort {|a,b| [b[:count], a[:value]] <=> [a[:count], b[:value]] }
                       end
                     }
                 end
               end
             }
      end

      if filter_types.include? :meta_data
        meta_datum_object_types = ["MetaDatumMetaTerms", "MetaDatumKeywords", "MetaDatumDepartments"]
        queries = meta_datum_object_types.map do |meta_datum_object_type|
          sql_select, sql_join, sql_group = case meta_datum_object_type
            when "MetaDatumKeywords"
              [%Q(meta_terms.id, meta_terms.#{DEFAULT_LANGUAGE} as value),
               %Q(INNER JOIN keywords ON keywords.meta_datum_id = meta_data.id
                  INNER JOIN meta_terms ON keywords.meta_term_id = meta_terms.id),
               %Q(meta_terms.id)]
            when "MetaDatumDepartments"
              [%Q(groups.id, groups.name AS value),
               %Q(INNER JOIN meta_data_meta_departments ON meta_data_meta_departments.meta_datum_id = meta_data.id
                  INNER JOIN groups ON meta_data_meta_departments.meta_department_id = groups.id),
               %Q(groups.id)]
            else
              [%Q(meta_terms.id, meta_terms.#{DEFAULT_LANGUAGE} as value),
               %Q(INNER JOIN meta_data_meta_terms ON meta_data_meta_terms.meta_datum_id = meta_data.id
                  INNER JOIN meta_terms ON meta_data_meta_terms.meta_term_id = meta_terms.id),
               %Q(meta_terms.id)]
          end
          %Q( SELECT meta_contexts.name AS context_name, 
                  mt3.#{DEFAULT_LANGUAGE} AS context_label,
                  meta_keys.id AS key_name, 
                  mt2.#{DEFAULT_LANGUAGE} AS key_label,
                  COUNT(meta_data.media_resource_id) AS count,
                  meta_context_groups.position AS context_group_position,
                  meta_contexts.position AS context_position,
                  meta_key_definitions.position AS definition_position,
                  #{sql_select}
                FROM meta_contexts
                   INNER JOIN meta_context_groups ON meta_context_groups.id = meta_contexts.meta_context_group_id
                   INNER JOIN meta_key_definitions ON meta_key_definitions.meta_context_id = meta_contexts.id
                   INNER JOIN meta_terms mt2 ON meta_key_definitions.label_id = mt2.id
                   INNER JOIN meta_terms mt3 ON meta_contexts.label_id = mt3.id
                   INNER JOIN meta_keys ON meta_key_definitions.meta_key_id = meta_keys.id
                   INNER JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
                   #{sql_join}
                WHERE meta_keys.meta_datum_object_type = '#{meta_datum_object_type}'
                AND meta_data.media_resource_id IN (#{media_resources.select("media_resources.id").to_sql})
                GROUP BY #{sql_group}, meta_contexts.name, mt3.#{DEFAULT_LANGUAGE}, meta_keys.id, mt2.#{DEFAULT_LANGUAGE},
                          meta_context_groups.position, meta_contexts.position, meta_key_definitions.position )
        end
        sql = "SELECT * FROM (%s) AS t1 ORDER BY context_group_position, context_position, definition_position" % queries.join(" UNION ")
        executed_query = ActiveRecord::Base.connection.execute(sql)
        executed_query.group_by{|x| x["context_name"]}.each_pair do |k, v|
          r << { :filter_type => "meta_data",
                 :context_name => v.first["context_name"],
                 :context_label => v.first["context_label"],
                 :keys => v.group_by{|x| x["key_name"]}.map do |vv|
                   { :key_name => vv[1].first["key_name"],
                     :key_label => vv[1].first["key_label"],
                     :terms => vv[1].map do |vvv|
                       { :id => vvv["id"],
                         :value => vvv["value"],
                         :count => vvv["count"].to_i
                       }
                     end.sort {|a,b| [b[:count], a[:value]] <=> [a[:count], b[:value]] }
                   }
                 end
               }
        end
      end
        
      # remove filter with empty terms
      r.reject! do |filter|
        not filter[:keys].any?{|x| not x[:terms].blank?}
      end

      r
    end
    
    ###########################################################################

    def hash_for_media_resource_arc(media_resource_arc, with = nil)
      h = {}

      [:parent_id, :child_id, :highlight, :cover].each do |k|
        h[k] = media_resource_arc.send(k)
      end
      
      h
    end

    ###########################################################################

  end
end
      

# -*- encoding : utf-8 -*-

module MediaResourceModules
  module Filter

    KEYS = [ :accessible_action, :collection_id, :favorites, :group_id, :ids,
             :media_file,:media_files, :media_set_id, :meta_data, :not_by_user_id,
             :permissions, :public, :search, :type, :user_id,
             :query, :meta_context_names, :media_resources ] 

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods
      def get_filter_params params
        params.select do |k,v| 
          KEYS.include?(k.to_sym) 
        end.delete_if {|k,v| v.blank?}.deep_symbolize_keys
      end

      # returns a chainable collection of media_resources
      # when current_user argument is not provided, the permissions are not considered
      def filter(current_user = nil, filter = {})
        filter = filter.delete_if {|k,v| v.blank?}.deep_symbolize_keys
        raise "invalid option" unless filter.is_a?(Hash) 

        ############################################################

        filter[:ids] = by_collection(filter[:collection_id]) if current_user and filter[:collection_id]

        ############################################################
        
        resources = if current_user and filter[:favorites] == "true"
          current_user.favorites
        elsif filter[:media_set_id]
          # hacketihack media_set_id kann auch zu einem FilterSet gehören
          MediaResource.where(type: ['MediaSet','FilterSet']).find(filter[:media_set_id])\
            .included_resources_accessible_by_user(current_user,:view)
        else
          self
        end

        resources = case filter[:type]
          when "media_sets"
            r = resources.media_sets
            r
          when "media_entries"
            resources.media_entries
          when "media_entry_incompletes"
            resources.where(:type => "MediaEntryIncomplete")
          else
            types = ["MediaEntry", "MediaSet", "FilterSet"]
            types << "MediaEntryIncomplete" if filter[:ids]
            resources.where(:type => types)
        end
        
        resources = resources.accessible_by_user(current_user, (filter[:accessible_action] or :view)) if current_user

        ############################################################
      
        if media_files_filter = filter[:media_files]
          media_files_filter.each do |column,h|
            value =h[:ids].first # we can simplify here, since there can be only one extension/type
            resources = resources.media_entries. # only media entries can have media file
              joins(:media_file).
              where(:media_files => {column => value})
          end
        end


        ############################################################

        resources = resources.where(:id => filter[:ids]) if filter[:ids]

        resources = resources.search(filter[:search]) unless filter[:search].blank?

        ############################################################
        
        resources = resources.accessible_by_group(filter[:group_id],:view) if filter[:group_id]

        resources = resources.where(:user_id => filter[:user_id]) if filter[:user_id]

        # FIXME use presets and :manage permission
        resources = resources.not_by_user(filter[:not_by_user_id]) if filter[:not_by_user_id]

        resources = resources.filter_public(filter[:public]) if filter[:public]

        resources = resources.filter_permissions(current_user, filter[:permissions]) if current_user and filter[:permissions]

        ############################################################

        resources = resources.filter_media_resources(filter[:media_resources]) if filter[:media_resources]

        resources = resources.filter_meta_data(filter[:meta_data]) if filter[:meta_data]

        resources = resources.filter_media_file(filter[:media_file]) if filter[:media_file] and filter[:media_file][:content_type]

        resources = resources.filter_uploaded_by(filter[:uploader_id]) if filter[:uploader_id]

        resources = resources.filter_contexts(filter[:meta_context_names]) if filter[:meta_context_names]

        resources
      end

      # FIXME doesn't work the chaining when are private methods
      # private

      def filter_public(filter = {})
        case filter
          when "true"
            where(:view => true)
          when "false"
            where(:view => false)
        end
      end

      def filter_permissions(current_user, filter = {})
        resources = scoped
        filter.each_pair do |k,v|
          v[:ids].each do |id|
            resources = case k
              when :owner
                resources.where(:user_id => id)
              when :group
                resources.accessible_by_group(id,:view)
              when :scope
                case id.to_sym
                  when :mine
                    resources.where(:user_id => current_user)
                  when :entrusted
                    resources.entrusted_to_user(current_user,:view)
                  when :public
                    resources.filter_public("true")
                end
            end
          end
        end
        resources
      end
      
      def filter_media_resources(filter = {})
        resources = scoped
        filter.each_pair do |k,v|
          v[:ids].each do |id|
            case id
              when "MediaEntry"
                resources = resources.where("media_resources.id IN (#{resources.where(:type => "MediaEntry").select("media_resources.id").to_sql})")
              when "MediaSet"
                resources = resources.where("media_resources.id IN (#{resources.where(:type => "MediaSet").select("media_resources.id").to_sql})")
              when "FilterSet"
                resources = resources.where("media_resources.id IN (#{resources.where(:type => "FilterSet").select("media_resources.id").to_sql})")
            end
          end
        end
        resources
      end

      def filter_meta_data(filter = {})
        resources = scoped
        filter.each_pair do |k,v|
          # this is AND implementation
          v[:ids].each do |id|
            # OPTIMIZE resource.joins(etc...) directly intersecting multiple criteria doesn't work, then we use subqueries
            # FIXME switch based on the meta_key.meta_datum_object_type 
            sub = case k
              when :keywords
                s = unscoped.joins(:meta_data).
                         joins("INNER JOIN keywords ON keywords.meta_datum_id = meta_data.id")
                s = s.where(:keywords => {:meta_term_id => id}) unless id == "any"
                s
              when :"institutional affiliation"
                s = unscoped.joins(:meta_data).
                         joins("INNER JOIN meta_data_meta_departments ON meta_data_meta_departments.meta_datum_id = meta_data.id")
                s = s.where(:meta_data_meta_departments => {:meta_department_id => id}) unless id == "any"
                s
              when :"uploaded by"
                s = unscoped.
                  joins(:meta_data => :meta_key).
                  joins("INNER JOIN meta_data_users ON meta_data.id = meta_data_users.meta_datum_id").
                  where(:meta_keys => {id: "uploaded by"},
                        :meta_data_users => {:user_id => id})
                s
              else
                # OPTIMIZE accept also directly meta_key_id ?? 
                s = unscoped.joins(:meta_data => :meta_key).
                         joins("INNER JOIN meta_data_meta_terms ON meta_data_meta_terms.meta_datum_id = meta_data.id").
                         where(:meta_keys => {id: k, :meta_datum_object_type => "MetaDatumMetaTerms"})
                s = s.where(:meta_data_meta_terms => {:meta_term_id => id}) unless id == "any"
                s
            end
            # NOTE this doesn't work because is overwriting the statements:
            # resources = resources.where(:id => sub)
            resources = resources.where("media_resources.id IN (#{sub.select("media_resources.id").to_sql})")
          end
        end
        resources
      end

      def filter_media_file(options = {})
        sql = media_entries.joins("RIGHT JOIN media_files ON media_resources.id = media_files.media_entry_id")
      
        options[:content_type].each do |x|
          sql = sql.where("media_files.content_type ilike ?", "%#{x}%")
        end if options[:content_type]
        
        [:width, :height].each do |x|
          if options[x] and not options[x][:value].blank?
            operator = case options[x][:operator]
              when "gt"
                ">"
              when "lt"
                "<"
              else
                "="
            end
            sql = sql.where("media_files.#{x} #{operator} ?", options[x][:value])
          end
        end
    
        unless options[:orientation].blank?
          operator = if options[:orientation].size == 2
            "="
          else
            case options[:orientation].to_i
              when 0
                "<"
              when 1
                ">"
            end
          end
          sql = sql.where("media_files.height #{operator} media_files.width")
        end
    
        sql    
      end

      def filter_contexts(names= [])
        sub = unscoped.joins(:meta_data => {:meta_key => :meta_key_definitions})
                      .where(:meta_key_definitions => {:meta_context_name => names})
                      .joins("INNER JOIN media_resource_arcs ON media_resource_arcs.child_id = media_resources.id")
                      .joins("INNER JOIN media_sets_meta_contexts ON media_sets_meta_contexts.media_set_id = media_resource_arcs.parent_id")
                      .where(:media_sets_meta_contexts => {:meta_context_name => names})
                      .uniq
        scoped.where(:id => sub)
      end
      
    end

  end
end




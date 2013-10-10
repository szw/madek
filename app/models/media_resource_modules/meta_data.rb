# -*- encoding : utf-8 -*-
#
module MediaResourceModules
  module MetaData
    def self.included(base)
      base.class_eval do 

        has_many :meta_data, :dependent => :destroy do #working here#7 :include => :meta_key

          def get(key, build_if_not_found = true)
            key_id = if key.is_a? MetaKey
                       key.id  
                     else 
                       MetaKey.find_by_id(key).try(&:id)
                     end
            if key_id
              where(meta_key_id: key_id).first \
                || (build(:meta_key_id => key_id) if build_if_not_found)
            end
          end

          def get_value_for(key_id)
            get(key_id).to_s
          end

          def get_for_labels(labels)
            joins(:meta_key).where(:meta_keys => {:label => labels})
          end

          def concatenated
            all.map(&:to_s).join('; ')
          end

          def for_context(context = MetaContext.find("core"), build_if_not_exists = true)
            meta_keys = context.meta_keys meta_key_ids = context.meta_key_ids

            mds = where(:meta_key_id => meta_key_ids).eager_load(:meta_key)
            mds = mds.eager_load(:keywords => :meta_term) if meta_keys.map(&:label).include?("keywords")
  
            already_ids = mds.map(&:meta_key_id)
            mds += meta_keys.select{|x| x.is_dynamic? and not already_ids.include?(x.id) }.flat_map do |key|
              build(:meta_key => key)
            end
  
            if build_if_not_exists
              already_ids = mds.map(&:meta_key_id)
              mds += (meta_key_ids - already_ids).flat_map do |key_id|
                build(:meta_key_id => key_id)
              end
            end

            mds.sort_by {|md| meta_key_ids.index(md.meta_key_id) } 
          end
        end


        # accepts_nested_attributes_for :meta_data, :allow_destroy => true,
        #  :reject_if => proc { |attributes| attributes['value'].blank? and attributes['_destroy'].blank? }
        # NOTE the check on _destroy should be automatic, check Rails > 3.0.3

        def self.find_by_title(title)
          joins(:meta_data => :meta_key).where(:meta_keys => {:id=> "title"}, :meta_data => {:string => title}).first
        end

        def title
          t = meta_data.get_value_for("title")
          t = "Ohne Titel" if t.blank?
          t
        end

        def description
          t = meta_data.get_value_for("description")
        end

        def author
          t = meta_data.get_value_for("author")
        end




        def get_existing_meta_datum_by_meta_key_id id
          self.meta_data.find_by_meta_key_id(MetaKey.where(id: id).first.try(&:id))
        end

        def set_meta_data meta_data_hash
          meta_data_hash.symbolize_keys[:meta_data_attributes].each do |k,meta_datum_hash|
            # TODO deprecate meta_key_label
            meta_key_id = (meta_datum_hash[:meta_key_id] or meta_datum_hash[:meta_key_label])
            meta_key = MetaKey.find(meta_key_id)
            meta_data.where("meta_key_id = ?", meta_key_id).destroy_all
            klass = Kernel.const_get(meta_key.meta_datum_object_type)
            meta_datum= klass.create! meta_key_id: meta_key.id, media_resource_id: self.id, value: meta_datum_hash[:value]
          end
        end


        def context_valid?(context = MetaContext.find("core"))
          meta_data.for_context(context).all? {|meta_datum| meta_datum.context_valid?(context) }
        end

      end
    end
  end
end



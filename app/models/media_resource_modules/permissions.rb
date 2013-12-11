# -*- encoding : utf-8 -*-

module MediaResourceModules
  module Permissions

    def self.included(base)

      base.class_eval do

        extend(ClassMethods) # look way below

        has_many :userpermissions, :dependent => :destroy         
        has_many :grouppermissions, :dependent => :destroy
      end
    end


    def is_public?
      view?
    end

    def is_private?(user)
      (user_id == user.id and
        not is_public? and
        not userpermissions.where(:view => true).where(["user_id != ?", user]).exists? and
        not grouppermissions.where(:view => true).exists?)
    end

    def is_shared?(user)
      not is_public? and not is_private?(user)
    end


    #############################################
  
    module ClassMethods 
    end

  end
end



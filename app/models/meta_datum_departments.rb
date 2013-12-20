# -*- encoding : utf-8 -*-

class MetaDatumDepartments < MetaDatum
  has_and_belongs_to_many :meta_departments, 
    join_table: :meta_data_meta_departments,
    foreign_key: :meta_datum_id,
    association_foreign_key: :meta_department_id
 
  def to_s
    value.map(&:to_s).join("; ")
  end

  def value
    meta_departments
  end

  def value=(new_value)
    new_meta_departments = Array(new_value).map do |v|
      if v.is_a?(MetaDepartment)
        v
      elsif UUID_V4_REGEXP.match v 
        MetaDepartment.find_by id: v
      elsif v.is_a?(String)
        MetaDepartment.by_string(v).first
      else
        v
      end
    end

    #old#
    meta_departments.clear
    meta_departments << new_meta_departments.compact
    
    #new# FIXME test is failing because "Vertiefung Fotografie (DKM_FMK_BMK_VFO.alle)" is missing
=begin
    if new_meta_departments.include? nil
      raise "invalid value"
    else
      meta_departments.clear
      meta_departments << new_meta_departments
    end
=end
  end

end

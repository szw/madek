# -*- encoding : utf-8 -*-
 
class MetaDatumPeople < MetaDatum
  has_and_belongs_to_many :people, 
    join_table: :meta_data_people, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :person_id

  def to_s
    value.map(&:to_s).join("; ")
  end

  def value
    people
  end

  def value=(new_value)
    people.clear
    people << Person.split(Array(new_value)).map do |v|
        if v.is_a?(Person)
          v
        elsif v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
          Person.find_by_id(v)
        else
          first_name, last_name = Person.parse(v)
          Person.find_or_initialize_by(:first_name => first_name, :last_name => last_name) if first_name or last_name
        end
    end
  end

end



class AdherentSerializer < ActiveModel::Serializer
  attributes :id, :state, :full_name, :resident, :supelec, :rezoman, :credit_value, :room_number
end
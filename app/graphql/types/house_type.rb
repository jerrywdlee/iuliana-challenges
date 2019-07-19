module Types
  class HouseType < Types::BaseObject
    field :id, ID, null: false
    field :firstname, String, null: false
    field :lastname, String, null: false
    field :full_name, String, null: false
    # field :city_text, String, null: false
    # field :city_id, Integer, null: false
    field :city, Types::CityType, null: false
    field :num_of_people, Integer, null: false
    field :has_child, String, null: false
    field :has_child_bool, Boolean, null: false
    field :datasets, [Types::DatasetType], null: true
  end
end

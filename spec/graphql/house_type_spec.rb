require "rails_helper"

RSpec.describe "GraphQL on HouseType" do
  it "Should exec house query" do
    query = <<~GRAPHQL
      {
        house(id: 1) { firstname, lastname }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    house = House.find(1)
    expect(data.dig("house", "firstname")).to eq house.firstname
    expect(data.dig("house", "lastname")).to eq house.lastname
  end

  it "Should find city from house query" do
    query = <<~GRAPHQL
      {
        house(id: 2) { city { name } }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    city = House.find(2).city
    expect(data.dig("house", "city", "name")).to eq city.name
  end

  it "Should find houses by city" do
    city = City.all.first
    query = <<~GRAPHQL
      {
        houses(city: "#{city.name}") { id, firstname }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    house_num = city.houses.size
    expect(data["houses"].size).to eq house_num
  end

  it "Should find houses by ransack like query" do
    query = <<~GRAPHQL
      {
        houses(q: { idEq: 3 }) { id, firstname }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    house = House.find(3)
    expect(data["houses"][0]["firstname"]).to eq house.firstname
  end

  it "Should find houses by ransack in json" do
    city = City.first
    houses = city.houses
    query = <<~GRAPHQL
      {
        houses(q: "{ \\"cityNameCont\\": \\"#{city.name}\\"}") {
          id, fullName, city { name }
        }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    house = House.find(3)
    expect(data["houses"].size).to eq houses.size
    expect(data.dig("houses", 0, "city", "name")).to eq city.name
  end
end

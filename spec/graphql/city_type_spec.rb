require "rails_helper"

RSpec.describe "GraphQL on CityType" do
  it "Should find city by name" do
    city = City.all.last
    query = <<~GRAPHQL
      {
        city(name: "#{city.name}") { id, name }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    expect(data.dig("city", "id")).to eq city.id.to_s
  end

  it "Should find city by ransack like query" do
    city = House.find(1).city
    query = <<~GRAPHQL
      {
        cities(q: {housesIdEq: 1}) { id, name }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    expect(data["cities"][0]["name"]).to eq city.name
  end

  it "Should return all cities" do
    city_num = City.all.size
    query = <<~GRAPHQL
      {
        cities { id, name }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    expect(data["cities"].size).to eq city_num
  end

  it "Should find cities with multiple conditions" do
    query = <<~GRAPHQL
      {
        cities(q: {
          m: "or",
          g: [
            { name_cont: "Lon" },
            { name_cont: "Ox" },
          ]
        }) { id, name }
      }
    GRAPHQL
    data = Util.graphql_query(query)
    expect(data["cities"].size).to eq 2
  end
end

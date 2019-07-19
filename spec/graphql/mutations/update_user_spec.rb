require "rails_helper"

RSpec.describe "Create and update user by GraphQL Mutation" do
  it "Create dummy users" do
    email = "admin-user-mutation@example.org"
    pass = "12345678"
    @admin_user = User.create({
      email: email, password: pass,
      password_confirmation: pass,
      roles: ["admin"]
    })
    email = "nomal-user-mutation@example.org"
    @normal_user = User.create({
      email: email, password: pass,
      password_confirmation: pass,
      roles: ["observer"]
    })
  end

  context "Create user" do
    email = "new-user-mutation@example.org"
    role = "observer"
    query = <<~GRAPHQL
      mutation {
        newUser (
          input: {
            user: {
              email: "#{email}",
              password: "p@ssw0rd",
              roles: ["#{role}"]
            }
        }) {
          user {
            id, email, name, roles, imgUrl
          }
        }
      }
    GRAPHQL

    it "Should throw error if user is not admin" do
      context = { current_user: User.observer.first }
      expect {
        Util.graphql_query(query, context: context)
      }.to raise_error "GraphQL: Need admin user"
    end

    it "Should create new user" do
      context = { current_user: User.admin.first }
      data = nil
      expect {
        data = Util.graphql_query(query, context: context).dig("newUser", "user")
      }.to change { User.count }.by(+1)
      expect(data["email"]).to eq email
      expect(data["roles"]).to include role
      expect(User.find_by(email: email)).to be_truthy
    end

    it "Should throw error if user email doubled" do
      context = { current_user: User.admin.first }
      expect {
        Util.graphql_query(query, context: context)
      }.to raise_error "Validation failed: Email has already been taken"
    end
  end

  context "Update user" do
    it "Should throw error if user is not admin" do
      @user = User.observer.last
      roles = %w(editor observer)
      query = <<~GRAPHQL
        mutation {
          updateUser (
            input: {
              id: #{@user.id}
              user: { roles: #{roles} }
          }) {
            user {
              id, email, name, roles
            }
          }
        }
      GRAPHQL

      context = { current_user: User.observer.first }
      expect {
        Util.graphql_query(query, context: context)
      }.to raise_error "GraphQL: Need admin user"
    end

    it "Should update user" do
      @user = User.observer.last
      roles = %w(editor observer)
      query = <<~GRAPHQL
        mutation {
          updateUser (
            input: {
              id: #{@user.id}
              user: {
                password: "P@ssw0rd"
                roles: #{roles}
              }
          }) {
            user {
              id, email, name, roles
            }
          }
        }
      GRAPHQL

      context = { current_user: User.admin.first }
      data = Util.graphql_query(query, context: context)
        .dig("updateUser", "user")
      user_after = User.find(@user.id)
      expect(data["email"]).to eq user_after.email
      expect(data["name"]).to eq user_after.name
      user_after.roles.each do |role|
        expect(data["roles"]).to include role
      end
    end

    it "Should not update default_user" do
      @default_user = User.find_or_initialize_by(
        email: EasySettings.default_user.email,
      )
      if @default_user.id.blank?
        password = EasySettings.default_user.password
        @default_user.assign_attributes(
          password: password,
          password_confirmation: password,
          roles: [EasySettings.user_roles.keys.first],
        )
        @default_user.save
      end
      @default_user = User.find_by(
        email: EasySettings.default_user.email,
      )
      new_email = "default_user@example.com"
      query = <<~GRAPHQL
        mutation {
          updateUser (
            input: {
              id: #{@default_user.id}
              user: { email: "#{new_email}" }
          }) {
            user {
              id, email, name, roles
            }
          }
        }
      GRAPHQL
      context = { current_user: User.admin.first }
      expect {
        Util.graphql_query(query, context: context)
      }.to raise_error "GraphQL: Can not alt default user's email, password or roles"
    end

    it "Should not update demo_user" do
      @demo_user = User.find_or_initialize_by(
        email: EasySettings.demo_user.email,
      )
      if @demo_user.id.blank?
        password = EasySettings.demo_user.password
        @demo_user.assign_attributes(
          password: password,
          password_confirmation: password,
        )
        @demo_user.save
      end
      @demo_user = User.find_by(
        email: EasySettings.demo_user.email,
      )
      new_email = "demo_user@example.com"
      query = <<~GRAPHQL
        mutation {
          updateUser (
            input: {
              id: #{@demo_user.id}
              user: { email: "#{new_email}" }
          }) {
            user {
              id, email, name, roles
            }
          }
        }
      GRAPHQL
      context = { current_user: User.admin.first }
      expect {
        Util.graphql_query(query, context: context)
      }.to raise_error "GraphQL: Can not alt demo user's email or password"
    end
  end

  context "Delete user" do
    it "Should throw error if user is not admin" do
      query = <<~GRAPHQL
        mutation {
          deleteUser(input: {id: 3}) {
            user { id email }
          }
        }
      GRAPHQL

      context = { current_user: User.observer.first }
      expect {
        Util.graphql_query(query, context: context)
      }.to raise_error "GraphQL: Need admin user"
    end

    it "Should not delete default_user" do
      @default_user = User.find_by(
        email: EasySettings.default_user.email,
      )
      query = <<~GRAPHQL
        mutation {
          deleteUser(input: {id: #{@default_user.id}}) {
            user { id email }
          }
        }
      GRAPHQL

      context = { current_user: User.admin.first }
      expect {
        Util.graphql_query(query, context: context)
      }.to raise_error "GraphQL: Can not delete demo or default user"
    end

    it "Should delete user" do
      @user = User.find_by(
        email: "nomal-user-mutation@example.org",
      )
      query = <<~GRAPHQL
        mutation {
          deleteUser(input: {id: #{@user.id}}) {
            user { id email }
          }
        }
      GRAPHQL

      context = { current_user: User.admin.first }
      data = nil
      expect {
        data = Util.graphql_query(query, context: context)
          .dig("deleteUser", "user")
      }.to change { User.count }.by(-1)
      expect(data["email"]).to eq @user.email
      user_after = User.find_by(
        email: "nomal-user-mutation@example.org",
      )
      expect(user_after).to be_falsey
    end
  end
end

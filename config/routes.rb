Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "contents#index"
  devise_for :users, controllers: {
    sessions: "users/sessions",
  }

  resources :api, only: [] do
    collection do
      get :default_user
      get :user_info
      post :load_csv
      post :create_user
    end
  end

  # GraphiQL
  # See `config/initializers/graphiql.rb`
  constraints GraphiQLAuthenticate.new do
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  post "/graphql", to: "graphql#execute"
end

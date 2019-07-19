class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, except: [:default_user]

  def default_user
    if EasySettings.default_user.show
      render json: EasySettings.default_user
    elsif AppConfig.general[:show_demo_user]
      render json: EasySettings.demo_user
    else
      render json: {}
    end
  end

  def user_info
    user = current_user
    render json: {
      userId: user.id,
      roles: user.roles,
      avatar: user.img_url,
      name: user.name,
    }
  end

  def load_csv
    if params[:house_data_url].blank? || params[:dataset_url].blank?
      render(json: { error: "url not found" }, status: 400) && return
    end

    case params[:key]
    when "challenge-3"
      begin
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection
            .execute("TRUNCATE TABLE cities, houses, datasets")
          DataLoader.load_houses(params[:house_data_url])
          DataLoader.load_cities
          DataLoader.sync_cities_houses
          DataLoader.load_dataset(params[:dataset_url])
          render json: { result: "ok" }
        end
      rescue => e
        render json: { error: e.message }, status: 500
      end
    else
      render json: { error: "key not found" }, status: 400
    end
  end

  def create_user
    unless current_user.roles.include?("admin")
      render(json: { error: "Only Admin User Are Allowed." }, status: 400) && return
    end

    begin
      ActiveRecord::Base.transaction do
        user = User.new(
          email: params[:email],
          password: params[:password],
          password_confirmation: params[:password],
          roles: params[:roles],
        )
        user.save!
        render json: {
          id: user.id,
          roles: user.roles,
          avatar: user.img_url,
          name: user.name,
        }
      end
    rescue => e
      render json: { error: e.message }, status: 500
    end
  end

end

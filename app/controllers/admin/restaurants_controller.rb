module Admin
  class RestaurantsController < ApplicationController
    before_action :authenticate_restaurant!
    before_action :set_restaurant, except: [:index, :new, :create]
    before_action :authorize_restaurant!, except: [:index, :new, :create]

    # GET /admin/restaurants
    def index
      @restaurants = current_restaurant ? [current_restaurant] : Restaurant.all
    end

    # GET /admin/restaurants/:id
    # Dashboard with reservation statistics
    def show
      @upcoming_reservations = @restaurant.reservations.upcoming.limit(10)
      @pending_reservations = @restaurant.reservations.pending.limit(5)
    end

    # GET /admin/restaurants/:id/edit
    def edit
    end

    # PATCH /admin/restaurants/:id
    def update
      if @restaurant.update(restaurant_params)
        redirect_to admin_restaurant_path(@restaurant),
                    notice: "Restaurant was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_restaurant
      @restaurant = Restaurant.find(params[:id])
    end

    def authorize_restaurant!
      redirect_to admin_restaurants_path, alert: "Not authorized" unless current_restaurant == @restaurant
    end

    def restaurant_params
      params.require(:restaurant).permit(
        :name, :description, :address, :open_time, :close_time, :logo, photos: []
      )
    end
  end
end

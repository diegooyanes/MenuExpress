module Admin
  class RestaurantsController < ApplicationController
    before_action :authenticate_restaurant!
    before_action :require_active_subscription!, only: [:show, :edit, :update]
    before_action :set_restaurant, only: [:show, :edit, :update, :destroy, :confirm_delete, :photo]
    before_action :authorize_restaurant!, only: [:show, :edit, :update, :destroy, :confirm_delete, :photo]

    # GET /admin/restaurants
    def index
      @restaurants = [current_restaurant].compact
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
      photos = photos_params
      if @restaurant.update(restaurant_params)
        @restaurant.photos.attach(photos) if photos.present?
        redirect_to admin_restaurant_path(@restaurant),
                    notice: "Restaurant was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/restaurants/:id
    def destroy
      @restaurant.destroy
      redirect_to root_path, notice: "Restaurante eliminado."
    end

    # DELETE /admin/restaurants/:id/menu_file
    def menu_file
      return redirect_to admin_restaurant_menu_items_path(@restaurant), alert: "No hay menú para eliminar." unless @restaurant&.menu_file&.attached?

      @restaurant.menu_file.purge
      redirect_to admin_restaurant_menu_items_path(@restaurant), notice: "Menú eliminado."
    end

    # DELETE /admin/restaurants/:id/photo
    def photo
      photo = @restaurant.photos.find_by(id: params[:photo_id])
      return redirect_to edit_admin_restaurant_path(@restaurant), alert: "Foto no encontrada." unless photo

      photo.purge
      redirect_to edit_admin_restaurant_path(@restaurant), notice: "Foto eliminada."
    end

    # GET /admin/restaurants/:id/confirm_delete
    def confirm_delete
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
        :name, :description, :address, :phone_number, :open_time, :close_time,
        :logo, :cover_image, :reservations_enabled, :max_capacity, :menu_file
      )
    end

    def photos_params
      params.fetch(:restaurant, {}).fetch(:photos, []).reject(&:blank?)
    end
  end
end

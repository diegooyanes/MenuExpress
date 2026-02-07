module Admin
  class MenuItemsController < ApplicationController
    before_action :authenticate_restaurant!
    before_action :require_active_subscription!
    before_action :set_restaurant
    before_action :authorize_restaurant!
    before_action :set_menu_item, only: [:show, :edit, :update, :destroy]

    def index
      @menu_items = @restaurant.menu_items.order(:name)
    end

    def show
    end

    def new
      @menu_item = @restaurant.menu_items.build
    end

    def create
      @menu_item = @restaurant.menu_items.build(menu_item_params)
      if @menu_item.save
        redirect_to admin_restaurant_menu_items_path(@restaurant), notice: "Plato creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @menu_item.update(menu_item_params)
        redirect_to admin_restaurant_menu_items_path(@restaurant), notice: "Plato actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @menu_item.destroy
      redirect_to admin_restaurant_menu_items_path(@restaurant), notice: "Plato eliminado."
    end

    private

    def set_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def set_menu_item
      @menu_item = @restaurant.menu_items.find(params[:id])
    end

    def authorize_restaurant!
      redirect_to admin_restaurants_path, alert: "Not authorized" unless current_restaurant == @restaurant
    end

    def menu_item_params
      params.require(:menu_item).permit(:name, :description, :price, :category)
    end
  end
end

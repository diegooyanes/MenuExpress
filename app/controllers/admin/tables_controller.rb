module Admin
  class TablesController < ApplicationController
    before_action :authenticate_restaurant!
    before_action :require_active_subscription!
    before_action :set_restaurant
    before_action :authorize_restaurant!
    before_action :set_table, only: [:show, :edit, :update, :destroy]

    def index
      @tables = @restaurant.tables.order(:number)
    end

    def show
    end

    def new
      @table = @restaurant.tables.build
    end

    def create
      @table = @restaurant.tables.build(table_params)
      if @table.save
        redirect_to admin_restaurant_tables_path(@restaurant), notice: "Mesa creada correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @table.update(table_params)
        redirect_to admin_restaurant_tables_path(@restaurant), notice: "Mesa actualizada correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @table.destroy
      redirect_to admin_restaurant_tables_path(@restaurant), notice: "Mesa eliminada."
    end

    private

    def set_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    end

    def set_table
      @table = @restaurant.tables.find(params[:id])
    end

    def authorize_restaurant!
      redirect_to admin_restaurants_path, alert: "Not authorized" unless current_restaurant == @restaurant
    end

    def table_params
      params.require(:table).permit(:number, :capacity, :available)
    end
  end
end

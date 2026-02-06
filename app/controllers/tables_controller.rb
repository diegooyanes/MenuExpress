class TablesController < ApplicationController
  def index
    @restaurant = Restaurant.find(params[:restaurant_id])
    @tables = @restaurant.tables
  end
end

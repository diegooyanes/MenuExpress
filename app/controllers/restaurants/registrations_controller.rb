class Restaurants::RegistrationsController < Devise::RegistrationsController
  protected

  # After sign up, redirect restaurant to admin edit page to complete profile
  def after_sign_up_path_for(resource)
    edit_admin_restaurant_path(resource)
  end

  # After sign up without confirmation, show clear message
  def after_inactive_sign_up_path_for(resource)
    edit_admin_restaurant_path(resource)
  end
end

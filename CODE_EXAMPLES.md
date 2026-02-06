# Code Examples & Quick Reference

## Database Migrations to Run

After bundling, run these migrations:

```bash
bundle install
rails db:migrate
```

The following migrations are prepared:
1. `20260206034000_update_restaurants_for_devise.rb` - Adds Devise columns to restaurants
2. `20260206034001_update_reservations_table.rb` - Updates reservation field names

---

## Common Rails Commands

### Development
```bash
./bin/dev              # Start server with asset compilation
rails s                # Start server only
rails c                # Open Rails console
```

### Database
```bash
rails db:migrate       # Run pending migrations
rails db:rollback      # Undo last migration
rails db:reset         # Drop, create, migrate seed
rails db:seed          # Run seed file
```

### Testing
```bash
rails test                                    # Run all tests
rails test:models                             # Run model tests
rails test:integration                        # Run integration tests
```

### Generate (for future use)
```bash
rails g model ModelName field:type            # Generate model + migration
rails g scaffold ResourceName field:type     # Generate full CRUD
rails g devise:views restaurants             # Generate customizable Devise views
```

---

## Implementation Checklist

### Pre-Launch
- [ ] Run `bundle install`
- [ ] Run `rails db:migrate`
- [ ] Create a test restaurant account
- [ ] Test reservation creation (public)
- [ ] Test admin dashboard login
- [ ] Test reservation status updates
- [ ] Verify email config (if using ActionMailer)

### Optional Enhancements
- [ ] Create Devise views for custom styling
- [ ] Add ActionMailer for notifications
- [ ] Implement Pundit for authorization
- [ ] Add restaurant map display
- [ ] Create API endpoints for frontend
- [ ] Add image uploads (Active Storage)
- [ ] Implement payment system

---

## Code Snippets by Use Case

### 1. Find Restaurants with Available Tables
```ruby
Restaurant.joins(:tables)
  .where("tables.capacity >= ?", guests)
  .distinct
```

### 2. Get Pending Reservations for Today
```ruby
Reservation.where(restaurant_id: current_restaurant)
  .where(reservation_date: Date.current)
  .where(status: "pending")
  .order(:reservation_time)
```

### 3. Calculate Restaurant Occupancy
```ruby
confirmed = reservation.restaurant.reservations.confirmed.upcoming.count
pending = reservation.restaurant.reservations.pending.upcoming.count
occupancy_rate = (confirmed.to_f / confirmed + pending) * 100
```

### 4. Build Reservation with Validation
```ruby
reservation = Reservation.new(
  first_name: "John",
  last_name: "Doe",
  phone_number: "+1-555-123-4567",
  number_of_guests: 4,
  reservation_date: Date.tomorrow,
  reservation_time: Time.parse("19:00"),
  restaurant_id: @restaurant.id
)

if reservation.save
  # Auto-assign table
  reservation.update(table_id: find_available_table.id)
else
  # Show errors
  reservation.errors.full_messages
end
```

### 5. Format DateTime for Display
```ruby
# In view:
<%= reservation.reserved_datetime.strftime("%A, %B %d, %Y at %l:%M %p") %>
# Output: Wednesday, February 19, 2025 at 7:00 PM
```

### 6. Query Past Reservations
```ruby
@past_reservations = current_restaurant.reservations.past
@upcoming_reservations = current_restaurant.reservations.upcoming
```

### 7. Check if Restaurant is Logged In
```ruby
<% if restaurant_signed_in? %>
  <%= link_to "Dashboard", admin_restaurant_path(current_restaurant) %>
  <%= link_to "Logout", destroy_restaurant_session_path, method: :delete %>
<% else %>
  <%= link_to "Login", new_restaurant_session_path %>
<% end %>
```

---

## Form Helpers

### Reservation Form (Already Implemented)
```erb
<%= form_with(model: [@restaurant, @reservation], local: true) do |form| %>
  <%= form.text_field :first_name, required: true %>
  <%= form.text_field :last_name, required: true %>
  <%= form.telephone_field :phone_number, required: true %>
  <%= form.number_field :number_of_guests, min: 1, max: 20, required: true %>
  <%= form.date_field :reservation_date, min: Date.current, required: true %>
  <%= form.time_field :reservation_time, required: true %>
  <%= form.submit "Request Reservation" %>
<% end %>
```

### Status Update Form
```erb
<%= form_with(model: [:admin, @restaurant, @reservation], local: true) do |form| %>
  <%= form.select :status, 
                  [["Pending", "pending"], ["Confirmed", "confirmed"], ["Cancelled", "cancelled"]],
                  { selected: @reservation.status } %>
  <%= form.submit "Update Status" %>
<% end %>
```

---

## Path Helpers Reference

### Public Routes
```ruby
restaurants_path                              # /restaurants
restaurant_path(@restaurant)                  # /restaurants/1
restaurant_menu_items_path(@restaurant)       # /restaurants/1/menu_items
restaurant_reservations_new_path(@restaurant) # /restaurants/1/reservations/new
restaurant_reviews_path(@restaurant)          # /restaurants/1/reviews
```

### Authentication Routes
```ruby
new_restaurant_session_path        # /restaurants/sign_in
new_restaurant_registration_path   # /restaurants/sign_up
destroy_restaurant_session_path    # Logout (use with method: :delete)
edit_restaurant_password_path      # /restaurants/password/edit
```

### Admin Routes
```ruby
admin_restaurants_path                           # /admin/restaurants
admin_restaurant_path(@restaurant)               # /admin/restaurants/1
admin_restaurant_reservations_path(@restaurant)  # /admin/restaurants/1/reservations
admin_restaurant_reservation_path(@restaurant, @reservation)  # /admin/restaurants/1/reservations/5
edit_admin_restaurant_reservation_path(@restaurant, @reservation)  # Edit status
```

---

## Active Record Query Examples

### By Status
```ruby
@pending = restaurant.reservations.where(status: "pending")
@confirmed = restaurant.reservations.where(status: "confirmed")
@cancelled = restaurant.reservations.where(status: "cancelled")
```

### By Date Range
```ruby
@this_week = restaurant.reservations.where(reservation_date: Date.current..Date.current + 7.days)
@this_month = restaurant.reservations.where(reservation_date: Date.current.beginning_of_month..Date.current.end_of_month)
```

### Count & Statistics
```ruby
restaurant.reservations.count                      # Total
restaurant.reservations.upcoming.count             # Future only
restaurant.reservations.confirmed.sum(:number_of_guests)  # Total guests expected
```

### Sort & Limit
```ruby
restaurant.reservations.upcoming.order(:reservation_date).limit(10)
restaurant.reservations.past.order(reservation_date: :desc).first(20)
```

---

## Validation Examples

### Model Validations
```ruby
validates :email, uniqueness: { case_sensitive: false }
validates :phone_number, format: { with: /\A[0-9\s\-\+\(\)]+\z/ }
validates :number_of_guests, numericality: { only_integer: true, greater_than: 0 }
validates :status, inclusion: { in: %w(pending confirmed cancelled) }
```

### Custom Validations
```ruby
validate :reservation_date_cannot_be_in_past
validate :restaurant_must_be_open

def reservation_date_cannot_be_in_past
  return if reservation_date.blank?
  if reservation_date < Date.current
    errors.add(:reservation_date, "can't be in the past")
  end
end

def restaurant_must_be_open
  return if reservation_time.blank? || restaurant.blank?
  if reservation_time < restaurant.open_time || reservation_time > restaurant.close_time
    errors.add(:reservation_time, "outside restaurant hours")
  end
end
```

---

## Authentication & Authorization

### Checking Authentication in Controllers
```ruby
before_action :authenticate_restaurant!  # Redirect if not logged in

def show
  @restaurant = Restaurant.find(params[:id])
  authorize_restaurant!  # Ensure user owns this restaurant
end

private

def authorize_restaurant!
  redirect_to admin_restaurants_path, alert: "Not authorized" unless current_restaurant == @restaurant
end
```

### In Views
```erb
<% if restaurant_signed_in? %>
  <p>Welcome, <%= current_restaurant.name %></p>
  <%= link_to "Logout", destroy_restaurant_session_path, method: :delete %>
<% end %>
```

---

## Testing Examples

### Model Test
```ruby
# test/models/reservation_test.rb
class ReservationTest < ActiveSupport::TestCase
  test "valid reservation" do
    reservation = Reservation.new(
      first_name: "John",
      last_name: "Doe",
      phone_number: "555-1234",
      number_of_guests: 4,
      reservation_date: Date.tomorrow,
      reservation_time: Time.current
    )
    assert reservation.valid?
  end

  test "requires phone number" do
    reservation = Reservation.new(phone_number: nil)
    assert reservation.invalid?
    assert reservation.errors[:phone_number].present?
  end
end
```

### Controller Test
```ruby
# test/controllers/reservations_controller_test.rb
class ReservationsControllerTest < ActionDispatch::IntegrationTest
  test "can create reservation" do
    restaurant = restaurants(:one)
    post restaurant_reservations_path(restaurant), params: {
      reservation: {
        first_name: "John",
        last_name: "Doe",
        phone_number: "555-1234",
        number_of_guests: 4,
        reservation_date: Date.tomorrow,
        reservation_time: Time.current
      }
    }
    assert_response :redirect
    assert_equal 1, restaurant.reservations.count
  end
end
```

---

## Debugging Tips

### Rails Console
```bash
rails c
Restaurant.all
Restaurant.first.reservations.upcoming
current_user  # In console, use `user` instead
Restaurant.find(1).reservations.where(status: 'pending')
```

### Check Routes
```bash
rails routes | grep reservation  # Filter routes
rails routes -c restaurants      # Show routes for controller
```

### Debug in View
```erb
<%= debug @restaurant %>
<%= params.inspect %>
<%= controller.action_name %>
```

### Log SQL Queries
```ruby
ActiveRecord::Base.logger = Logger.new(STDOUT)
Restaurant.all.count  # Shows SQL in console
```

---

## Performance Tips

### N+1 Query Prevention
```ruby
# Bad - runs extra queries
@reservations = restaurant.reservations
@reservations.each { |r| r.restaurant.name }

# Good - includes restaurant in single query
@reservations = restaurant.reservations.includes(:restaurant)
```

### Pagination (Consider Adding gem 'kaminari')
```ruby
@reservations = restaurant.reservations.page(params[:page]).per(20)
```

### Caching
```ruby
@restaurants = Rails.cache.fetch("restaurants", expires_in: 1.hour) do
  Restaurant.all.load
end
```

---

## Styling Notes

All views include **inline CSS** for quick styling. For production:

1. Move CSS to `app/assets/stylesheets/`
2. Use CSS frameworks (Tailwind, Bootstrap)
3. Consider BEM methodology
4. Organize by component

Example structure:
```css
/* app/assets/stylesheets/admin/dashboard.css */
.admin-dashboard { ... }
.stat-card { ... }
.reservations-table { ... }
```

---

## Common Errors & Solutions

| Error | Solution |
|-------|----------|
| "undefined method `current_restaurant`" | Include `helper_method :current_restaurant` in ApplicationController |
| "Wrong number of arguments" | Check form path uses nested route: `[@restaurant, @reservation]` |
| "Validation error: Status is not included" | Use lowercase: `"pending"` not `"Pending"` |
| "Devise routes not working" | Ensure `devise_for :restaurants` in routes.rb |
| "Table assignment fails" | Check Table has `capacity` column |

---

## Next Steps

1. **Customize Views**: Update layouts and CSS to match branding
2. **Add ActionMailer**: Send confirmation emails
3. **Set up S3**: Store logos with Active Storage
4. **Add Admin Features**: Menu/table management views
5. **API Development**: Build JSON endpoints for mobile app
6. **Analytics**: Track reservation trends

Happy building! 🎉

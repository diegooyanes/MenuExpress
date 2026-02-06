# Route Reference Guide

## Quick Route Map

```
PUBLIC ROUTES (No Authentication Required)
══════════════════════════════════════════

GET  /                                    → Listing restaurants
     └─ RestaurantsController#index

GET  /restaurants                         → Restaurants index (same as /)
     └─ RestaurantsController#index

GET  /restaurants/:id                     → Restaurant profile page
     └─ RestaurantsController#show
     └─ Shows: name, description, location, menu, reviews, reservation form

GET  /restaurants/:restaurant_id/menu_items
     └─ MenuItemsController#index
     └─ List all menu items for restaurant

GET  /restaurants/:restaurant_id/reservations/new
     └─ ReservationsController#new
     └─ Show reservation form (no login needed)

POST /restaurants/:restaurant_id/reservations
     └─ ReservationsController#create
     └─ Create reservation, auto-assign table, status=pending
     └─ Parameters: first_name, last_name, phone_number, number_of_guests, 
                    reservation_date, reservation_time

GET  /restaurants/:restaurant_id/reservations
     └─ ReservationsController#index
     └─ List public reservations for restaurant

GET  /restaurants/:restaurant_id/reviews/new
     └─ ReviewsController#new
     └─ Show review form

POST /restaurants/:restaurant_id/reviews
     └─ ReviewsController#create
     └─ Create review
     └─ Parameters: name, rating (1-5), comment

GET  /restaurants/:restaurant_id/reviews
     └─ ReviewsController#index
     └─ List all reviews for restaurant


AUTHENTICATION ROUTES (Devise)
══════════════════════════════

GET  /restaurants/sign_up
     └─ Devise::RegistrationsController#new
     └─ Restaurant registration form

POST /restaurants
     └─ Devise::RegistrationsController#create
     └─ Create new restaurant account
     └─ Parameters: email, password

GET  /restaurants/sign_in
     └─ Devise::SessionsController#new
     └─ Restaurant login form

POST /restaurants/sign_in
     └─ Devise::SessionsController#create
     └─ Create session for restaurant
     └─ Parameters: email, password

DELETE /restaurants/sign_out
     └─ Devise::SessionsController#destroy
     └─ Logout restaurant (must use method: :delete)

GET  /restaurants/password/new
     └─ Devise::PasswordsController#new
     └─ Forgot password form

POST /restaurants/password
     └─ Devise::PasswordsController#create
     └─ Send password reset email

GET  /restaurants/password/edit
     └─ Devise::PasswordsController#edit
     └─ Reset password form (from email link)

PATCH /restaurants/password
     └─ Devise::PasswordsController#update
     └─ Process password reset


ADMIN ROUTES (Require Restaurant Login)
════════════════════════════════════════

GET  /admin/restaurants
     └─ Admin::RestaurantsController#index
     └─ List restaurants (restaurants see only their own)

GET  /admin/restaurants/:id
     └─ Admin::RestaurantsController#show
     └─ Admin dashboard with statistics
     └─ Shows: upcoming reservations, pending confirmations, stats

GET  /admin/restaurants/:id/edit
     └─ Admin::RestaurantsController#edit
     └─ Edit restaurant information form

PATCH /admin/restaurants/:id
     └─ Admin::RestaurantsController#update
     └─ Update restaurant info (name, description, address, hours, logo)

GET  /admin/restaurants/:restaurant_id/reservations
     └─ Admin::ReservationsController#index
     └─ List all reservations (upcoming & past, tabbed)

GET  /admin/restaurants/:restaurant_id/reservations/:id
     └─ Admin::ReservationsController#show
     └─ Reservation details

GET  /admin/restaurants/:restaurant_id/reservations/:id/edit
     └─ Admin::ReservationsController#edit
     └─ Update reservation status form

PATCH /admin/restaurants/:restaurant_id/reservations/:id
     └─ Admin::ReservationsController#update
     └─ Update reservation status
     └─ Parameters: status (pending, confirmed, cancelled)

GET  /admin/restaurants/:restaurant_id/menu_items
     └─ Admin::MenuItemsController#index
     └─ Menu management (for future use)

GET  /admin/restaurants/:restaurant_id/tables
     └─ Admin::TablesController#index
     └─ Table management (for future use)

GET  /admin/restaurants/:restaurant_id/reviews
     └─ Admin::ReviewsController#index
     └─ View reviews for restaurant
```

---

## HTTP Verbs Explained

| Verb | Purpose | Example |
|------|---------|---------|
| GET | Retrieve data, no side effects | View a page, search |
| POST | Create new resource | Submit form, new reservation |
| PATCH | Update existing resource | Change reservation status |
| DELETE | Remove resource | Delete reservation |

---

## Path Helpers in Views/Controllers

### Public Routes
```ruby
# In views/controllers:

restaurants_path
→ GET /restaurants

restaurant_path(@restaurant)
→ GET /restaurants/1

restaurant_menu_items_path(@restaurant)
→ GET /restaurants/1/menu_items

restaurant_reservations_new_path(@restaurant)
→ GET /restaurants/1/reservations/new

restaurant_reservations_path(@restaurant)
→ POST /restaurants/1/reservations (when using form_with)
→ GET /restaurants/1/reservations

restaurant_reviews_path(@restaurant)
→ GET /restaurants/1/reviews

new_restaurant_review_path(@restaurant)
→ GET /restaurants/1/reviews/new
```

### Authentication Routes
```ruby
new_restaurant_session_path
→ GET /restaurants/sign_in

restaurant_session_path  
→ POST /restaurants/sign_in

destroy_restaurant_session_path
→ DELETE /restaurants/sign_out

new_restaurant_password_path
→ GET /restaurants/password/new

restaurant_password_path
→ POST /restaurants/password
```

### Admin Routes
```ruby
admin_restaurants_path
→ GET /admin/restaurants

admin_restaurant_path(@restaurant)
→ GET /admin/restaurants/1

edit_admin_restaurant_path(@restaurant)
→ GET /admin/restaurants/1/edit

admin_restaurant_reservations_path(@restaurant)
→ GET /admin/restaurants/1/reservations

admin_restaurant_reservation_path(@restaurant, @reservation)
→ GET /admin/restaurants/1/reservations/5

edit_admin_restaurant_reservation_path(@restaurant, @reservation)
→ GET /admin/restaurants/1/reservations/5/edit
```

---

## Forms (with Examples)

### Public Reservation Form
```erb
<%= form_with model: [@restaurant, @reservation], local: true do |form| %>
  <%= form.text_field :first_name %>
  <%= form.text_field :last_name %>
  <%= form.telephone_field :phone_number %>
  <%= form.number_field :number_of_guests %>
  <%= form.date_field :reservation_date %>
  <%= form.time_field :reservation_time %>
  <%= form.submit "Book" %>
<% end %>

<!-- Submits POST to /restaurants/:id/reservations -->
```

### Admin Status Update Form
```erb
<%= form_with model: [:admin, @restaurant, @reservation], local: true do |form| %>
  <%= form.select :status, [["Pending", "pending"], ["Confirmed", "confirmed"], ["Cancelled", "cancelled"]] %>
  <%= form.submit "Update" %>
<% end %>

<!-- Submits PATCH to /admin/restaurants/:id/reservations/:id -->
```

### Restaurant Edit Form
```erb
<%= form_with model: [:admin, @restaurant], local: true do |form| %>
  <%= form.text_field :name %>
  <%= form.text_area :description %>
  <%= form.text_field :address %>
  <%= form.time_field :open_time %>
  <%= form.time_field :close_time %>
  <%= form.submit "Save" %>
<% end %>

<!-- Submits PATCH to /admin/restaurants/:id -->
```

---

## URL Examples (What URLs Exist)

### Homepage
```
http://localhost:3000/
```

### Restaurant Pages
```
http://localhost:3000/restaurants
http://localhost:3000/restaurants/1
http://localhost:3000/restaurants/1/menu_items
http://localhost:3000/restaurants/1/reservations/new
http://localhost:3000/restaurants/1/reviews/new
http://localhost:3000/restaurants/1/reviews
```

### Reservation Pages
```
http://localhost:3000/restaurants/1/reservations/new     (form)
http://localhost:3000/restaurants/1/reservations          (list)
```

### Authentication
```
http://localhost:3000/restaurants/sign_up
http://localhost:3000/restaurants/sign_in
http://localhost:3000/restaurants/password/new
```

### Admin Dashboard
```
http://localhost:3000/admin/restaurants
http://localhost:3000/admin/restaurants/1                 (dashboard)
http://localhost:3000/admin/restaurants/1/edit
http://localhost:3000/admin/restaurants/1/reservations    (list)
http://localhost:3000/admin/restaurants/1/reservations/5  (view)
http://localhost:3000/admin/restaurants/1/reservations/5/edit  (update status)
```

---

## Request/Response Examples

### Create Reservation (Public)
```
POST /restaurants/1/reservations HTTP/1.1
Content-Type: application/x-www-form-urlencoded

reservation[first_name]=John
reservation[last_name]=Doe
reservation[phone_number]=555-1234
reservation[number_of_guests]=4
reservation[reservation_date]=2025-02-20
reservation[reservation_time]=19:00

HTTP/1.1 302 Found
Location: /restaurants/1
```

### Update Reservation Status (Admin)
```
PATCH /admin/restaurants/1/reservations/5 HTTP/1.1
Authorization: Bearer <session_token>
Content-Type: application/x-www-form-urlencoded

reservation[status]=confirmed

HTTP/1.1 302 Found
Location: /admin/restaurants/1/reservations/5
```

### Login Restaurant
```
POST /restaurants/sign_in HTTP/1.1
Content-Type: application/x-www-form-urlencoded

restaurant[email]=owner@pizzeria.com
restaurant[password]=securepass123

HTTP/1.1 302 Found
Location: /admin/restaurants
Set-Cookie: _session=...
```

---

## Route Constraints (Authorization)

### Public Routes (No Constraints)
All public routes are accessible without authentication.

### Admin Routes (Constraint: Require Authentication)
```ruby
before_action :authenticate_restaurant!
# In Admin::RestaurantsController & Admin::ReservationsController
# Redirects to /restaurants/sign_in if not logged in
```

### Authorization Check (Constraint: Own Data Only)
```ruby
before_action :authorize_restaurant!
# Ensures: current_restaurant == @restaurant
# Redirects if user tries to access another restaurant's data
```

---

## Testing Routes (in Rails Console)

```ruby
rails routes | grep restaurant    # Show all restaurant routes
rails routes | grep admin         # Show all admin routes
rails routes -c restaurants       # Show only RestaurantsController routes

# Or view all:
rails routes
```

---

## Common Route Errors & Solutions

| Error | Cause | Fix |
|-------|-------|-----|
| `No route matches` | Wrong path helper or HTTP verb | Check path helper matches route |
| `Uninitialized constant` | Wrong controller namespace | Add `module Admin end` |
| `Undefined method` | Path helper doesn't exist | Use `rails routes` to find exact name |
| Route works in browser but not AJAX | Missing CSRF token | Add `authenticity_token` to form |

---

## Parameter Passing Examples

### Query String (in URL)
```
GET /restaurants?sort=name&page=2

# Access in controller:
params[:sort]   # => "name"
params[:page]   # => "2"
```

### Path Parameter
```
GET /restaurants/1

# Access in controller:
params[:id]  # => "1"
@restaurant = Restaurant.find(params[:id])
```

### Form Data (POST/PATCH)
```
POST /restaurants/1/reservations
  first_name=John&last_name=Doe&...

# Access in controller:
params[:reservation][:first_name]  # => "John"
reservation_params
```

### Nested Routes
```
/restaurants/:restaurant_id/reservations/:id

# Access in controller:
params[:restaurant_id]  # => "1"
params[:id]             # => "5"
```

---

## Redirect Examples

### After Successful Create
```ruby
redirect_to restaurant_path(@restaurant), notice: "Created successfully"
# → Redirects to GET /restaurants/1 with flash message
```

### After Authorization Failure
```ruby
redirect_to admin_restaurants_path, alert: "Not authorized"
# → Redirects to GET /admin/restaurants with alert message
```

### After Login Required
```ruby
redirect_to new_restaurant_session_path, alert: "Please sign in"
# → Redirects to GET /restaurants/sign_in with alert
```

---

## Using Routes in Views

### Link Helpers
```erb
<%= link_to "View Restaurant", restaurant_path(@restaurant) %>
<%= link_to "Edit Status", edit_admin_restaurant_reservation_path(@restaurant, @reservation) %>
<%= link_to "Logout", destroy_restaurant_session_path, method: :delete %>
<%= link_to "Back", admin_restaurants_path %>
```

### Button Helpers
```erb
<%= button_to "Delete", restaurant_path(@restaurant), method: :delete %>
```

### URL Helpers
```erb
<%= image_tag @restaurant.logo, alt: @restaurant.name %>
<img src="<%= restaurant_path(@restaurant) %>" />
```

---

## Nested Route Best Practices

✅ **Use nested paths in forms:**
```erb
<%= form_with model: [@restaurant, @reservation] %>
<!-- Knows to POST to /restaurants/:id/reservations -->
```

✅ **Use full path helpers:**
```erb
<%= link_to "Edit", edit_admin_restaurant_reservation_path(@restaurant, @reservation) %>
```

❌ **Don't hardcode URLs:**
```erb
<!-- Bad -->
<a href="/restaurants/<%= @restaurant.id %>/reservations/<%= @reservation.id %>">
```

---

**Last Updated**: February 6, 2025  
**Rails Version**: 8.1.2  
**Route Framework**: RESTful with Devise

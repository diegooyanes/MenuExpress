# Restaurant Reservation System - Implementation Guide

## Architecture Overview

This is a **public restaurant discovery platform** with a **private restaurant management dashboard**.

### Key Features

#### 🌐 Public Interface (No Authentication)
- Browse all restaurants
- View restaurant details (name, description, address, hours)
- View menu items
- View customer reviews
- **Create reservations** without account
- Leave reviews without account

#### 🔒 Restaurant Admin Dashboard (Devise Authentication)
- Secure login for restaurant accounts
- View upcoming and past reservations
- Manage reservation statuses (pending → confirmed/cancelled)
- Dashboard with statistics
- Edit restaurant information

---

## Database Schema

### Models & Relationships

```
Restaurant (has Devise authentication)
├── has_many :menu_items (dependent: destroy)
├── has_many :tables (dependent: destroy)
├── has_many :reservations (dependent: destroy)
└── has_many :reviews (dependent: destroy)

Reservation
├── belongs_to :restaurant
├── belongs_to :table
└── has scopes: upcoming, past, pending, confirmed

Table
├── belongs_to :restaurant
└── has_many :reservations

MenuItem
└── belongs_to :restaurant

Review
└── belongs_to :restaurant
```

### Reservation Fields

| Field | Type | Purpose |
|-------|------|---------|
| first_name | string | Guest first name |
| last_name | string | Guest last name |
| phone_number | string | Contact number (no auth required) |
| number_of_guests | integer | Party size |
| reservation_date | date | Reservation date |
| reservation_time | time | Reservation time |
| status | enum | pending \| confirmed \| cancelled |
| restaurant_id | FK | Which restaurant |
| table_id | FK | Assigned table |

### Restaurant Fields (Devise)

| Field | Type | Purpose |
|-------|------|---------|
| email | string | Login email (unique) |
| encrypted_password | string | Devise authentication |
| name | string | Restaurant name |
| description | text | Restaurant description |
| address | string | Physical location |
| open_time | time | Opening hour |
| close_time | time | Closing hour |
| logo | string | Logo image URL |
| reset_password_token | string | Devise recovery |

---

## Routes Structure

### Public Routes (No Authentication)
```ruby
GET  /                           # List all restaurants
GET  /restaurants                # List restaurants (same as root)
GET  /restaurants/:id            # View restaurant details
GET  /restaurants/:id/menu_items # View menu
GET  /restaurants/:id/reservations/new  # Reservation form
POST /restaurants/:id/reservations      # Create reservation
GET  /restaurants/:id/reviews/new       # Review form
POST /restaurants/:id/reviews           # Create review
GET  /restaurants/:id/reviews           # View reviews
```

### Authentication Routes
```ruby
GET  /restaurants/sign_up        # Restaurant registration
GET  /restaurants/sign_in        # Restaurant login
DELETE /restaurants/sign_out     # Restaurant logout
```

### Admin Routes (Requires Devise Authentication)
```ruby
GET  /admin/restaurants              # Admin restaurants list
GET  /admin/restaurants/:id          # Admin dashboard
GET  /admin/restaurants/:id/edit     # Edit restaurant info
PATCH /admin/restaurants/:id         # Update restaurant

GET  /admin/restaurants/:id/reservations                    # All reservations
GET  /admin/restaurants/:id/reservations/:reservation_id    # View reservation
GET  /admin/restaurants/:id/reservations/:reservation_id/edit  # Edit status
PATCH /admin/restaurants/:id/reservations/:reservation_id   # Update status

GET  /admin/restaurants/:id/menu_items                # Manage menu
GET  /admin/restaurants/:id/tables                    # Manage tables
GET  /admin/restaurants/:id/reviews                   # View reviews
```

---

## Controllers

### PUBLIC CONTROLLERS

#### RestaurantsController
```ruby
# app/controllers/restaurants_controller.rb
- index  # List all restaurants
- show   # Display restaurant details with menu, reviews, reservation form
```

#### ReservationsController
```ruby
# app/controllers/reservations_controller.rb
- new    # Show reservation form (no auth needed)
- create # Save reservation and auto-assign table based on guest count
- index  # List public reservations for a restaurant
```

#### ReviewsController
```ruby
# app/controllers/reviews_controller.rb
- new    # Show review form
- create # Save review
- index  # List reviews for restaurant
```

### ADMIN CONTROLLERS (Devise Protected)

#### Admin::RestaurantsController
```ruby
# app/controllers/admin/restaurants_controller.rb
- index   # List restaurants (restaurants see only their own)
- show    # Admin dashboard with stats
- edit    # Edit restaurant info
- update  # Save changes
```

**Authorization Flow:**
```ruby
before_action :authenticate_restaurant!  # Require login
before_action :authorize_restaurant!     # Ensure restaurants can only see their own
```

#### Admin::ReservationsController
```ruby
# app/controllers/admin/reservations_controller.rb
- index     # Upcoming & past reservations (tabbed view)
- show      # Reservation details
- edit      # Change status form
- update    # Save status change
```

---

## Key Implementation Details

### 1. Reservation Validation
```ruby
validates :first_name, :last_name, :phone_number, :number_of_guests, presence: true
validates :reservation_date, :reservation_time, presence: true
validates :number_of_guests, numericality: { greater_than: 0 }
validates :status, inclusion: { in: STATUSES.values }
```

### 2. Automatic Table Assignment
When creating a reservation, the system automatically assigns the smallest available table that can accommodate the group:
```ruby
def find_available_table
  @restaurant.tables.find_by("capacity >= ?", reservation_params[:number_of_guests].to_i)
end
```

### 3. Reservation Scopes
```ruby
scope :upcoming, -> { where("reservation_date >= ?", Date.current).order(:reservation_date) }
scope :past, -> { where("reservation_date < ?", Date.current).order(reservation_date: :desc) }
scope :pending, -> { where(status: "pending") }
scope :confirmed, -> { where(status: "confirmed") }
```

### 4. Status Management
```ruby
STATUSES = { 
  pending: "pending",    # Awaiting restaurant confirmation
  confirmed: "confirmed", # Restaurant confirmed the reservation
  cancelled: "cancelled"  # Cancelled by either party
}
```

---

## Views

### Public Pages

#### `/restaurants` - Restaurant Directory
- Grid/list of all restaurants
- Links to view details

#### `/restaurants/:id` - Restaurant Profile
- Restaurant info (name, description, location, hours)
- Menu items list
- Customer reviews
- **Reservation form** (embedded)
- Review form

#### Reservation Form (`/restaurants/:id/reservations/new`)
- First name & last name fields
- Phone number (no account creation)
- Number of guests (1-20)
- Date picker (minimum today)
- Time picker
- Submit button
- Success message after booking

### Admin Pages

#### `/admin/restaurants/:id` - Admin Dashboard
Interactive dashboard showing:
- **Statistics cards**: Upcoming reservations, Pending confirmations, Operating hours
- **Pending confirmations**: Quick action table for reservations awaiting yes/no
- **Upcoming reservations**: Next 10 bookings with status badges
- Link to view all reservations

#### `/admin/restaurants/:id/reservations` - Reservation Management
- **Upcoming tab**: All future reservations
- **Past tab**: Historical reservations
- Table showing: Guest name, date/time, party size, status
- Action buttons to edit status

#### `/admin/restaurants/:id/reservations/:id/edit` - Update Status
- Full reservation details (read-only)
- Status dropdown (pending → confirmed/cancelled)
- Confirmation buttons
- Danger zone to cancel

---

## Setup & Installation

### 1. Install Gems
```bash
bundle install
```

### 2. Run Migrations
```bash
rails db:migrate
```

### 3. Seed Database (Optional)
```bash
rails db:seed
```

### 4. Generate Devise Views (Optional - for customization)
```bash
rails generate devise:views restaurants
```

### 5. Start Server
```bash
./bin/dev  # or rails s
```

---

## Usage Examples

### Creating a Restaurant Account
1. Navigate to `/restaurants/sign_up`
2. Enter email and password
3. Receive confirmation
4. Login at `/restaurants/sign_in`
5. Access dashboard at `/admin/restaurants`

### Making a Reservation (Public)
1. Browse to homepage → select restaurant
2. Scroll to "Make a Reservation"
3. Enter: Name, Phone, Date, Time, Guest Count
4. Click "Request Reservation"
5. Restaurant receives pending reservation in dashboard

### Managing Reservations (Admin)
1. Login to restaurant account
2. View dashboard showing pending reservations
3. Click "Confirm" to approve
4. View all reservations in full list
5. Click any reservation to change status
6. Statuses: Pending → Confirmed/Cancelled

---

## Security Features

✅ **Restaurant Authentication**: Devise handles password security, email verification  
✅ **Authorization**: Restaurants can only see their own data  
✅ **SQL Injection Prevention**: Rails parameterized queries  
✅ **CSRF Protection**: Built-in Rails protection  
✅ **Public Access**: No auth required for customer-facing pages  

### Authorization Example
```ruby
def authorize_restaurant!
  redirect_to admin_restaurants_path, alert: "Not authorized" unless current_restaurant == @restaurant
end
```

---

## Important Notes

### Field Name Changes
The migration updates field names from the original schema:
- `name` → `first_name`
- `surname` → `last_name`
- `phone` → `phone_number`

If this is a new database, run migrations fresh:
```bash
rails db:reset
```

### Table Capacity
Tables must have a `capacity` field:
```ruby
# Migration for tables table
t.integer :capacity  # Seats available
```

### Status Values
Reservations use lowercase string values:
- `"pending"` (default)
- `"confirmed"`
- `"cancelled"`

### Future Enhancements
- [ ] Email notifications when status changes
- [ ] SMS confirmations for reservations
- [ ] QR code check-in system
- [ ] Rating/review moderation
- [ ] Reservation cancellation by guest
- [ ] Availability calendar
- [ ] Payment processing

---

## Troubleshooting

**"No route matches" errors**: Ensure nested routes use correct path helpers
```erb
<%= form_with model: [@restaurant, @reservation] %>  ✓ Correct
<%= form_with model: @reservation %>                 ✗ Wrong
```

**Can't login to admin**: 
- Check email is registered: `Restaurant.pluck(:email)`
- Reset password at `/restaurants/password/new`

**Reservations not showing**:
- Ensure `restaurant_id` matches current user
- Check authorization is working

---

## File Structure

```
app/
├── controllers/
│   ├── application_controller.rb      # Auth helpers
│   ├── restaurants_controller.rb      # Public listing
│   ├── reservations_controller.rb     # Public booking
│   ├── reviews_controller.rb          # Public reviews
│   └── admin/
│       ├── restaurants_controller.rb  # Admin dashboard
│       └── reservations_controller.rb # Admin management
├── models/
│   ├── restaurant.rb                  # Devise + associations
│   ├── reservation.rb                 # Scopes + validations
│   ├── table.rb
│   ├── menu_item.rb
│   └── review.rb
└── views/
    ├── restaurants/
    │   ├── index.html.erb             # Directory
    │   └── show.html.erb              # Profile + forms
    ├── reservations/
    │   └── new.html.erb               # Booking form
    └── admin/
        ├── restaurants/
        │   └── show.html.erb          # Dashboard
        └── reservations/
            ├── index.html.erb         # List
            └── edit.html.erb          # Status update

db/
├── migrate/
│   ├── 20260206033348_create_restaurants.rb
│   ├── 20260206033353_create_menu_items.rb
│   ├── 20260206033358_create_tables.rb
│   ├── 20260206033402_create_reservations.rb
│   ├── 20260206033407_create_reviews.rb
│   ├── 20260206034000_update_restaurants_for_devise.rb
│   └── 20260206034001_update_reservations_table.rb
└── schema.rb

config/
└── routes.rb                          # Updated with Devise & namespaces
```

---

## Questions & Support

For Devise documentation: [devise.readthedocs.io](https://devise.readthedocs.io/)

For Rails guides: [guides.rubyonrails.org](https://guides.rubyonrails.org/)

Happy coding! 🚀

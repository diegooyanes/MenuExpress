# MenuExpress - Restaurant Reservation System

> A complete **restaurant discovery and reservation platform** built with Ruby on Rails + PostgreSQL

---

## 🚀 Quick Start (5 Minutes)

```bash
# 1. Install dependencies
bundle install

# 2. Run database migrations
rails db:migrate

# 3. Start the server
./bin/dev

# 4. Access the app
# Public:  http://localhost:3000
# Admin:   http://localhost:3000/restaurants/sign_in
```

---

## 📚 Documentation

Read the guides in this order:

1. **[GETTING_STARTED.md](./GETTING_STARTED.md)** - Installation & testing (5 min)
2. **[IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)** - Architecture & features (reference)
3. **[ROUTES_REFERENCE.md](./ROUTES_REFERENCE.md)** - All URLs and endpoints (reference)
4. **[CODE_EXAMPLES.md](./CODE_EXAMPLES.md)** - Copy-paste code snippets (reference)
5. **[PROJECT_CHECKLIST.md](./PROJECT_CHECKLIST.md)** - Task tracking & checklists

---

## ✨ Features

### 🌐 Public Interface
- Browse restaurants without login
- View restaurant details (menu, reviews, hours)
- Make reservations in 2 minutes (no account needed)
- Leave reviews and ratings
- Automatic table assignment based on party size

### 🔒 Restaurant Admin Dashboard
- Secure login with Devise authentication
- Dashboard showing reservation statistics
- View upcoming and past reservations
- Manage reservation status (pending → confirmed/cancelled)
- Quick action buttons for pending approvals
- Authorization ensures restaurants only see their own data

---

## 🏗️ Architecture

### Two-Tier System

**Public Layer** (Customers)
```
GET  /restaurants              # Browse all restaurants
POST /restaurants/:id/reservations  # Book a table
GET  /restaurants/:id/reviews  # View & write reviews
```

**Admin Layer** (Restaurants - Requires Login)
```
GET  /admin/restaurants/:id    # Dashboard with stats
GET  /admin/reservations      # Manage all reservations
PATCH /admin/reservations/:id # Update reservation status
```

---

## 📊 What's Included

- ✅ 5 Models with validations & associations
- ✅ 6 Controllers with business logic
- ✅ 4 View templates with styling
- ✅ Devise authentication for restaurants
- ✅ Authorization checks (security)
- ✅ RESTful routes
- ✅ 2 Database migrations
- ✅ Complete documentation (6 guides)

---

## 🧪 Testing

### Test Public Reservation Flow (5 min)
1. Open http://localhost:3000
2. Click a restaurant
3. Fill reservation form (name, phone, guests, date, time)
4. Submit → Success!

### Test Admin Dashboard (5 min)
1. Go to http://localhost:3000/restaurants/sign_up
2. Create account
3. Login at /restaurants/sign_in
4. View dashboard
5. Update reservation status

**→ Detailed testing in [GETTING_STARTED.md](./GETTING_STARTED.md#testing-the-system-15-minutes)**

---

## 🛠️ Tech Stack

- **Framework**: Ruby on Rails 8.1.2
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Frontend**: ERB templates with CSS
- **Ruby Version**: 3.1+ recommended

---

## 📁 Project Structure

```
app/
├── controllers/              # 6 controllers
│   ├── restaurants_controller.rb
│   ├── reservations_controller.rb
│   ├── reviews_controller.rb
│   └── admin/
│       ├── restaurants_controller.rb
│       └── reservations_controller.rb
├── models/                   # 5 models
│   ├── restaurant.rb        (with Devise)
│   ├── reservation.rb       (with scopes)
│   ├── table.rb
│   ├── menu_item.rb
│   └── review.rb
└── views/                    # 4 templates
    ├── reservations/new.html.erb
    └── admin/
        ├── restaurants/show.html.erb
        └── reservations/
            ├── index.html.erb
            └── edit.html.erb

db/migrate/
├── 20260206034000_update_restaurants_for_devise.rb
└── 20260206034001_update_reservations_table.rb
```

---

## 🔐 Security

✅ **Devise Authentication** - Industry-standard password hashing  
✅ **Authorization** - Restaurants can only access their own reservations  
✅ **CSRF Protection** - Built into Rails  
✅ **SQL Injection Prevention** - Parameterized queries  
✅ **Public Access** - No credentials needed for customers  

---

## 📊 Database Schema

```
Restaurants ──┬─ has_many MenuItems
              ├─ has_many Tables
              ├─ has_many Reservations ─── belongs to Table
              └─ has_many Reviews

Reservations:
  - first_name, last_name, phone_number
  - number_of_guests, reservation_date, reservation_time
  - status: "pending" | "confirmed" | "cancelled"
  - table_id, restaurant_id
```

---

## 🚀 Commands Reference

### Development
```bash
./bin/dev              # Start server + asset compilation
rails s                # Start server only
rails c                # Open Rails console

rails routes           # List all routes
rails routes | grep admin  # Filter routes
```

### Database
```bash
rails db:migrate       # Run migrations
rails db:reset         # Drop, create, migrate
rails db:seed          # Run seed.rb
```

### Testing
```bash
rails test             # Run all tests
rails test:models      # Test models only
```

---

## 📝 Examples

### Create Restaurant (via console)
```ruby
rails c
Restaurant.create(
  email: 'owner@pizzeria.com',
  password: 'securepass123',
  name: 'Marios Pizzeria',
  description: 'Best pizza in town',
  address: '123 Main St',
  open_time: '11:00',
  close_time: '22:00'
)
```

### Query Reservations
```ruby
restaurant = Restaurant.first
restaurant.reservations.upcoming          # Future reservations
restaurant.reservations.pending           # Awaiting confirmation
restaurant.reservations.confirmed.count   # Number of confirmed
```

### View Pending Confirmations
```ruby
Reservation.pending.where('reservation_date >= ?', Date.current).order(:reservation_date)
```

---

## 🎯 Next Steps

1. **Run Setup** - `bundle install && rails db:migrate`
2. **Test Flows** - Create reservation + admin account
3. **Customize** - Update styling for your brand
4. **Add Features** - Email notifications, payments, etc.
5. **Deploy** - Push to production when ready

---

## 🆘 Troubleshooting

### Migrations fail?
```bash
rails db:reset         # Start fresh
rails db:migrate:status  # Check migration status
```

### Routes not found?
```bash
rails routes | grep reservation  # Verify routes exist
```

### Can't login?
```bash
rails c
Restaurant.all         # Check restaurants exist
Restaurant.create(email: 'test@test.com', password: 'test123', name: 'Test')
```

**→ More help in [GETTING_STARTED.md](./GETTING_STARTED.md#troubleshooting)**

---

## 📚 Documentation Files

| File | Purpose | Read When |
|------|---------|-----------|
| [GETTING_STARTED.md](./GETTING_STARTED.md) | Installation & testing | First time setup |
| [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) | Architecture & features | Understanding the system |
| [ROUTES_REFERENCE.md](./ROUTES_REFERENCE.md) | URL endpoints | Building URLs/forms |
| [CODE_EXAMPLES.md](./CODE_EXAMPLES.md) | Snippets & patterns | Writing code |
| [PROJECT_CHECKLIST.md](./PROJECT_CHECKLIST.md) | Tasks & status | Project planning |

---

## 🌟 Key Features

| Feature | Public | Admin | Notes |
|---------|--------|-------|-------|
| Browse restaurants | ✅ | ✅ | No login needed for public |
| Make reservation | ✅ | ✅ | No account required |
| View reviews | ✅ | ✅ | Anyone can see |
| Leave review | ✅ | ✅ | No account needed |
| View dashboard | ❌ | ✅ | Login required |
| Manage reservations | ❌ | ✅ | Only own reservations |
| Update status | ❌ | ✅ | pending→confirmed/cancelled |

---

## 💡 Architecture Highlights

### Devise Authentication
```ruby
# Restaurant model
devise :database_authenticatable, :registerable, :recoverable

# Protect admin routes
before_action :authenticate_restaurant!
```

### Nested Resources
```ruby
# routes.rb
resources :restaurants do
  resources :reservations, only: [:new, :create]
end

# Form automatically posts to /restaurants/1/reservations
<%= form_with model: [@restaurant, @reservation] %>
```

### Automatic Table Assignment
```ruby
# Controller automatically finds best table
table = restaurant.tables.find_by("capacity >= ?", guest_count)
reservation.update(table_id: table.id)
```

### Authorization
```ruby
# Ensure restaurant owns this data
before_action :authorize_restaurant!

def authorize_restaurant!
  redirect_to admin_restaurants_path unless current_restaurant == @restaurant
end
```

---

## 📱 Browser Support

Modern browsers only (Rails 8.1 default):
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

---

## 🎓 Learning Resources

- [Rails Guides](https://guides.rubyonrails.org/) - Official documentation
- [Devise Wiki](https://github.com/heartcombo/devise/wiki) - Authentication
- [Ruby Docs](https://ruby-doc.org/) - Language reference
- [PostgreSQL Docs](https://www.postgresql.org/docs/) - Database

---

## 📈 Production Checklist

- [ ] Configure email service for notifications
- [ ] Set environment variables for secrets
- [ ] Enable HTTPS
- [ ] Set up error tracking (Sentry, etc)
- [ ] Configure CDN for assets
- [ ] Set up database backups
- [ ] Rate limiting for API
- [ ] Security headers configured
- [ ] Tests passing (min 60% coverage)

---

## 🎉 You're All Set!

Your restaurant reservation system is ready. Follow [GETTING_STARTED.md](./GETTING_STARTED.md) to begin.

**Questions?** Check the relevant documentation file or Rails community resources.

---

**System Version**: 1.0  
**Last Updated**: February 6, 2025  
**Status**: ✅ Complete & Tested  
**Rail Version**: 8.1.2  

Made with ❤️ for restaurant owners and diners.

# Clear existing data
Restaurant.destroy_all
MenuItem.destroy_all
Table.destroy_all

# Create example restaurants
restaurants = [
  {
    name: "La Trattoria Italiana",
    description: "Auténtica cocina italiana con pastas caseras y pizzas al horno de leña. Especialidad en risottos y mariscos.",
    address: "Carrera 7 #45-23, Bogotá",
    open_time: "11:00",
    close_time: "23:00",
    email: "trattoria@menuexpress.com",
    password: "password123",
    logo: nil
  },
  {
    name: "Casa Arepas",
    description: "Comida tradicional venezolana. Arepas caseras, tequeños, patacones y cachapas. El sabor auténtico de Venezuela.",
    address: "Calle 10 #5-42, Medellín",
    open_time: "10:00",
    close_time: "22:00",
    email: "arepas@menuexpress.com",
    password: "password123",
    logo: nil
  },
  {
    name: "Sushi Tokio",
    description: "Fresco sushi bar con ingredientes importados de Japón. Rolls creativos, nigiri premium y sopa miso artesanal.",
    address: "Paseo de las Flores #120, Cali",
    open_time: "12:00",
    close_time: "23:30",
    email: "sushi@menuexpress.com",
    password: "password123",
    logo: nil
  },
  {
    name: "Grill Master",
    description: "Parrilla argentina con carnes premium, costillas a la BBQ y chorizos. Ambiente acogedor perfecto para grupos.",
    address: "Avenida Libertador #500, Barranquilla",
    open_time: "11:30",
    close_time: "23:30",
    email: "grill@menuexpress.com",
    password: "password123",
    logo: nil
  },
  {
    name: "Thai Garden",
    description: "Cocina tailandesa auténtica. Pad Thai, curry rojo, sopa tom yum y rollos de primavera. Ambiente tropical.",
    address: "Calle Principal #89, Bucaramanga",
    open_time: "12:00",
    close_time: "22:00",
    email: "thai@menuexpress.com",
    password: "password123",
    logo: nil
  },
  {
    name: "El Sabor Colombiano",
    description: "Comida casera colombiana. Ajiaco, bandeja paisa, empanadas, tamales y jugos naturales frescos.",
    address: "Carrera 82 #12-45, Santa Marta",
    open_time: "11:00",
    close_time: "21:00",
    email: "sabor@menuexpress.com",
    password: "password123",
    logo: nil
  }
]

restaurants.each do |attrs|
  restaurant = Restaurant.find_or_create_by!(email: attrs[:email]) do |r|
    r.name = attrs[:name]
    r.description = attrs[:description]
    r.address = attrs[:address]
    r.open_time = attrs[:open_time]
    r.close_time = attrs[:close_time]
    r.password = attrs[:password]
    r.logo = attrs[:logo]
  end

  # Create tables for each restaurant (2-4 tables with different capacities)
  capacities = [2, 4, 6]
  capacities.each_with_index do |capacity, index|
    Table.find_or_create_by!(
      restaurant_id: restaurant.id,
      number: index + 1
    ) do |t|
      t.capacity = capacity
      t.available = true
    end
  end

  # Create menu items
  menu_items_data = []
  case restaurant.name
  when "La Trattoria Italiana"
    menu_items_data = [
      { name: "Pasta Carbonara", description: "Auténtica carbonara romana con guanciale", price: 18.99 },
      { name: "Risotto ai Funghi", description: "Risotto cremoso con hongos porcini", price: 16.99 },
      { name: "Pizza Margherita", description: "Pizza al horno de leña con mozzarella fresca", price: 14.99 },
      { name: "Lasagna della Nonna", description: "Lasaña casera con ragù de carne", price: 17.99 }
    ]
  when "Casa Arepas"
    menu_items_data = [
      { name: "Arepa de Queso", description: "Arepa recién hecha con queso fresco", price: 5.99 },
      { name: "Tequeños", description: "6 tequeños de queso de yuca", price: 8.99 },
      { name: "Patacones Rellenos", description: "Patacones con carnes y queso", price: 12.99 },
      { name: "Cachapa con Queso", description: "Cachapa dulce de maíz con queso", price: 10.99 }
    ]
  when "Sushi Tokio"
    menu_items_data = [
      { name: "Philadelphia Roll", description: "Salmón, queso crema y aguacate", price: 14.99 },
      { name: "Dragon Roll", description: "Anguila y aguacate, especial de la casa", price: 16.99 },
      { name: "Nigiri Surtido (10 pz)", description: "Variedad de nigiri con salmón y atún", price: 19.99 },
      { name: "Sopa Miso", description: "Sopa miso tradicional con tofu", price: 5.99 }
    ]
  when "Grill Master"
    menu_items_data = [
      { name: "Asado Argentino", description: "Media res marinada y a la parrilla", price: 35.99 },
      { name: "Costillas BBQ", description: "Costillas al horno con salsa barbecue", price: 24.99 },
      { name: "Chorizo Argentino", description: "2 chorizos a la parrilla con chimichurri", price: 12.99 },
      { name: "Provoleta a la Parrilla", description: "Queso provolone a la parrilla", price: 9.99 }
    ]
  when "Thai Garden"
    menu_items_data = [
      { name: "Pad Thai", description: "Fideos frescos con camarones y maní", price: 13.99 },
      { name: "Curry Rojo", description: "Curry rojo tailandés con pollo y leche de coco", price: 15.99 },
      { name: "Tom Yum", description: "Sopa picante con camarones", price: 12.99 },
      { name: "Rollitos Primavera", description: "6 rollitos de verdura crujientes", price: 8.99 }
    ]
  when "El Sabor Colombiano"
    menu_items_data = [
      { name: "Ajiaco Santafereño", description: "Sopa típica de Bogotá con tres papas", price: 9.99 },
      { name: "Bandeja Paisa", description: "El clásico de Medellín con todo incluido", price: 16.99 },
      { name: "Empanadas (3)", description: "Empanadas caseras de carne", price: 7.99 },
      { name: "Tamales", description: "Tamales caseros, orden de 3", price: 8.99 }
    ]
  end

  menu_items_data.each do |item_attrs|
    MenuItem.find_or_create_by!(
      restaurant_id: restaurant.id,
      name: item_attrs[:name]
    ) do |item|
      item.description = item_attrs[:description]
      item.price = item_attrs[:price]
    end
  end
end

puts "✅ Restaurantes de ejemplo creados:"
puts "Total: #{Restaurant.count} restaurantes"
puts "Total: #{Table.count} mesas"
puts "Total: #{MenuItem.count} items de menú"

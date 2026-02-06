# 🎨 Sistema de Diseño CSS - MenuExpress

## Descripción General del Aplicativo

### Concepto
MenuExpress es una **plataforma de descubrimiento y reserva de restaurantes** que permite a los usuarios comer sin crear cuenta:

#### Flujo Público (Sin autenticación)
```
1. Usuario anonimo → Navega a http://localhost:3000
2. Ve lista de restaurantes en grid responsivo
3. Hace click en un restaurante
4. Ve detalles (descripción, menu, reviews)
5. Completa formulario de reserva (nombre, teléfono, fecha, hora, # de comensales)
6. Sistema asigna automáticamente mesa disponible
7. Reserva guardada con estado "pending"
```

#### Flujo Admin (Con autenticación)
```
1. Restaurante crea cuenta en /restaurants/sign_up
2. Inicia sesión en /restaurants/sign_in
3. Accede a dashboard privado (/admin/restaurants/:id)
4. Ve estadísticas (reservas próximas, confirmaciones pendientes)
5. Puede cambiar estado de reserva (pending → confirmed/cancelled)
6. Solo ve sus propias reservas (autorización implementada)
```

---

## 🏗️ Arquitectura del Sistema de Diseño CSS

### Variables del Tema (CSS Variables)

```css
:root {
  /* Colores - Paleta SaaS Premium */
  --primary: #007bff;              /* Azul principal - clickeable, CTAs */
  --primary-dark: #0056b3;         /* Azul oscuro - hover state */
  --primary-light: #e7f1ff;        /* Azul muy claro - fondo highlights */
  
  --success: #10b981;              /* Verde - confirmaciones OK */
  --warning: #f59e0b;              /* Amarillo - estados pendientes */
  --danger: #ef4444;               /* Rojo - errores, cancelaciones */
  --info: #3b82f6;                 /* Azul info - mensajes informativos */
  
  /* Fondos */
  --bg-primary: #ffffff;           /* Blanco - contenido principal */
  --bg-secondary: #f9fafb;         /* Gris muy claro - fondo de página */
  --bg-tertiary: #f3f4f6;          /* Gris claro - headers, separadores */
  
  /* Texto */
  --text-primary: #111827;         /* Casi negro - texto principal */
  --text-secondary: #6b7280;       /* Gris medio - texto secundario */
  --text-tertiary: #9ca3af;        /* Gris claro - metadata */
  
  /* Bordes y Sombras */
  --border-color: #e5e7eb;         /* Gris bordereline */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);   /* Sutil */
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);    /* Normal */
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);  /* Grande */
  --shadow-xl: 0 20px 25px rgba(0,0,0,0.1);  /* Extra grande */
  
  /* Espaciado - Escala consistente */
  --spacing-xs: 0.25rem;   /* 4px */
  --spacing-sm: 0.5rem;    /* 8px */
  --spacing-md: 1rem;      /* 16px */
  --spacing-lg: 1.5rem;    /* 24px */
  --spacing-xl: 2rem;      /* 32px */
  --spacing-2xl: 3rem;     /* 48px */
}
```

### Principios de Diseño Implementados

1. **Minimalismo Limpio**: Mucho espacio en blanco, sin ornamentación.
2. **Contraste Elegante**: Jerarquía clara entre elementos.
3. **Transiciones Suaves**: Animaciones rápidas (150-300ms) para feedback.
4. **Mobile-First**: Responsive desde 480px hasta desktop.
5. **Accesibilidad**: Colores con suficiente contraste, focus states claros.

---

## 📐 Componentes Reutilizables

### 1. **Botones** (`.btn`)
```css
/* Por defecto: Botón primario azul */
.btn { background: var(--primary); }

/* Variantes */
.btn-primary   → Azul (CTA principal)
.btn-secondary → Gris (acciones secundarias)
.btn-success   → Verde (confirmaciones)
.btn-danger    → Rojo (destructivas)
.btn-sm        → Versión pequeña
.btn-lg        → Versión grande
```

**Reutilización**: En formularios, tarjetas de restaurante, admin dashboard, etc.

### 2. **Tarjetas** (`.card`)
```css
.card {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-md);
}
```

**Uso**: Admin panels, detalles de restaurante, reviews, etc.

### 3. **Forms**
```css
.form-group {
  display: flex;
  flex-direction: column;
  margin-bottom: var(--spacing-lg);
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-lg);
}
```

**Reutilización**: Formulario de reserva, login, signup, editar estado, etc.

### 4. **Grid de Restaurantes** (`.restaurants-grid`)
```css
.restaurants-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: var(--spacing-xl);
}
```

**Responsive**:
- Desktop: 3+ columnas
- Tablet: 2 columnas
- Móvil: 1 columna

### 5. **Tablas** (`<table>`)
```css
th {
  background: var(--bg-tertiary);
  font-weight: 600;
  text-transform: uppercase;
}

tbody tr:hover {
  background: var(--bg-secondary);
}
```

**Uso**: Lista de reservas en admin, menú items, etc.

### 6. **Badges/Status** (`.badge-*`)
```css
.badge-pending   → Amarillo (#fef3c7)
.badge-confirmed → Verde (#dcfce7)
.badge-cancelled → Rojo (#fee2e2)
```

**Reutilización**: Estados de reserva en tablas y cards.

### 7. **Alertas** (`.alert-*)`)
```css
.alert-success   → Verde (confirmaciones)
.alert-danger    → Rojo (errores)
.alert-warning   → Amarillo (advertencias)
.alert-info      → Azul (información)
```

**Uso**: Mensajes flash, validaciones, confirmaciones.

---

## 🎯 Cómo Se Reutilizan los Estilos

### Página Pública - Listado de Restaurantes

```html
<!-- Header -->
<header>
  <h1>MenuExpress</h1>
  <nav>
    <a href="/restaurants/sign_in">Login Restaurante</a>
    <a href="/restaurants/sign_up">Crear Cuenta</a>
  </nav>
</header>

<!-- Main content -->
<main>
  <div class="restaurants-grid">
    <!-- Cada restaurante es una .restaurant-card -->
    <div class="restaurant-card">
      <div class="restaurant-image" style="background-image: url(...)"></div>
      <div class="restaurant-content">
        <h3>Nombre del Restaurante</h3>
        <p>Descripción...</p>
        <div class="restaurant-meta">
          <span>⏰ 11:00 - 22:00</span>
          <span>📍 Ubicación</span>
        </div>
        <div class="restaurant-actions">
          <a href="/restaurants/1" class="btn btn-primary">Ver Detalles</a>
        </div>
      </div>
    </div>
  </div>
</main>
```

**Estilos Usados**:
- `header`: Navegación limpia y profesional
- `.restaurants-grid`: Grid responsivo
- `.restaurant-card`: Tarjeta con hover effects
- `.btn btn-primary`: Botón azul CTA

---

### Página de Restaurante - Formulario de Reserva

```html
<div class="restaurant-card card">
  <div class="card-header">
    <h2>Hacer una Reserva</h2>
  </div>
  
  <div class="card-body">
    <form class="reservation-form">
      <!-- Row 1: Nombre y Apellido -->
      <div class="form-row">
        <div class="form-group">
          <label>Nombre</label>
          <input type="text" name="first_name" required>
        </div>
        <div class="form-group">
          <label>Apellido</label>
          <input type="text" name="last_name" required>
        </div>
      </div>
      
      <!-- Row 2: Teléfono y # Comensales -->
      <div class="form-row">
        <div class="form-group">
          <label>Teléfono</label>
          <input type="tel" name="phone_number" required>
        </div>
        <div class="form-group">
          <label># Comensales</label>
          <input type="number" name="number_of_guests" min="1" max="20" required>
        </div>
      </div>
      
      <!-- Row 3: Fecha y Hora -->
      <div class="form-row">
        <div class="form-group">
          <label>Fecha</label>
          <input type="date" name="reservation_date" required>
        </div>
        <div class="form-group">
          <label>Hora</label>
          <input type="time" name="reservation_time" required>
        </div>
      </div>
      
      <button type="submit" class="btn btn-lg">Solicitar Reserva</button>
    </form>
  </div>
</div>
```

**Estilos Usados**:
- `.reservation-form`: Contenedor con padding y border-radius
- `.form-row`: Grid responsivo para campos lado a lado
- `.form-group`: Estructura consistente para cada campo
- `input`: Estilos unificados con focus states
- `.btn btn-lg`: Botón grande para CTA principal

---

### Dashboard Admin - Panel de Administración

```html
<div class="admin-dashboard">
  <!-- Header -->
  <div class="dashboard-header">
    <h1>Panel de Administración</h1>
    <a href="/restaurants/sign_out" class="btn btn-secondary">Salir</a>
  </div>
  
  <!-- Stats -->
  <div class="dashboard-stats">
    <div class="stat-card">
      <h3>12</h3>
      <p>Próximas Reservas</p>
    </div>
    <div class="stat-card">
      <h3>3</h3>
      <p>Confirmaciones Pendientes</p>
    </div>
    <div class="stat-card">
      <h3>10</h3>
      <p>Horas de Operación</p>
    </div>
  </div>
  
  <!-- Sección: Reservas Pendientes -->
  <div class="dashboard-section">
    <h2>Reservas Pendientes de Confirmación</h2>
    <div class="table-responsive">
      <table>
        <thead>
          <tr>
            <th>Nombre</th>
            <th>Día y Hora</th>
            <th>Comensales</th>
            <th>Teléfono</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Juan Pérez</td>
            <td>Mié 19 Feb, 19:00</td>
            <td>4</td>
            <td><a href="tel:...">555-1234</a></td>
            <td>
              <a href="#" class="btn btn-sm btn-success">Confirmar</a>
              <a href="#" class="btn btn-sm btn-danger">Rechazar</a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  
  <!-- Sección: Todas las Reservas -->
  <div class="dashboard-section">
    <div class="section-header">
      <h2>Todas las Reservas</h2>
      <a href="#" class="btn btn-link">Ver Todo</a>
    </div>
    
    <!-- Tabs: Próximas / Pasadas -->
    <div class="tabs">
      <button class="tab-btn active" onclick="showTab('upcoming')">Próximas</button>
      <button class="tab-btn" onclick="showTab('past')">Pasadas</button>
    </div>
    
    <div id="upcoming" class="tab-content active">
      <!-- Tabla de próximas reservas -->
    </div>
    
    <div id="past" class="tab-content">
      <!-- Tabla de reservas pasadas -->
    </div>
  </div>
</div>
```

**Estilos Usados**:
- `.admin-dashboard`: Contenedor principal con padding
- `.dashboard-header`: Flex layout con título y botones
- `.dashboard-stats`: Grid de 3 columnas con stat-cards
- `.stat-card`: Gradiente azul con números grandes
- `.dashboard-section`: Separación clara de secciones
- `.table-responsive`: Wrapper para tablas
- `table`, `thead`, `tbody`: Estilos de tabla profesional
- `.tabs` y `.tab-btn`: Interfaz de pestañas
- `.badge-*`: Estados visuales

---

## 📱 Sistema Responsivo

### Breakpoints

```css
/* Desktop (default) */
-- 768px+ : Layouts completos

/* Tablet (768px y menos) */
@media (max-width: 768px) {
  .form-row { grid-template-columns: 1fr; }
  .restaurants-grid { grid-template-columns: 1fr; }
  .dashboard-stats { grid-template-columns: 1fr; }
}

/* Móvil (480px y menos) */
@media (max-width: 480px) {
  h1 { font-size: var(--font-size-2xl); }
  input, button { width: 100%; }
}
```

### Ejemplos de Responsividad

**Grid de Restaurantes:**
```
Desktop: ▪️ ▪️ ▪️ (3 columnas)
Tablet:  ▪️ ▪️   (2 columnas)
Móvil:   ▪️     (1 columna)
```

**Formulario:**
```
Desktop: [Nombre] [Apellido]
Tablet:  [Nombre] [Apellido]
Móvil:   [Nombre]
         [Apellido]
```

---

## 🎨 Paleta de Colores Explicada

### Colores Primarios (Clickeable, CTAs)
- `--primary: #007bff` → Azul confiable (como Stripe, Twitter)
- `--primary-dark: #0056b3` → Para hover states
- `--primary-light: #e7f1ff` → Para highlights, tooltips

### Colores Semánticos
- `--success: #10b981` → Verde (reserva confirmada)
- `--warning: #f59e0b` → Amarillo (pendiente acción)
- `--danger: #ef4444` → Rojo (error, cancelación)

### Colores de Fondo
- `--bg-primary: #ffffff` → Tarjetas, contenido
- `--bg-secondary: #f9fafb` → Fondo de página
- `--bg-tertiary: #f3f4f6` → Headers de tabla, separadores

### Colores de Texto
- `--text-primary: #111827` → Título, contenido principal
- `--text-secondary: #6b7280` → Párrafos, descripción
- `--text-tertiary: #9ca3af` → Metadata, timestamps

---

## ⚡ Transiciones y Animaciones

```css
--transition-fast: 150ms ease-in-out;    /* Hover sin scroll */
--transition-base: 200ms ease-in-out;    /* Standard */
--transition-slow: 300ms ease-in-out;    /* Grandes cambios */
```

### Ejemplos de Uso

```css
/* Hover sutil en botones */
.btn:hover {
  transform: translateY(-2px);  /* Sube 2px */
  box-shadow: var(--shadow-lg); /* Sombra más grande */
  transition: all var(--transition-base);
}

/* Hover en tarjetas de restaurante */
.restaurant-card:hover {
  transform: translateY(-8px);  /* Sube 8px */
  box-shadow: var(--shadow-xl); /* Sombra muy grande */
  transition: all var(--transition-base);
}

/* Cambio de color en enlaces */
header a:hover {
  color: var(--primary);
  transition: color var(--transition-base);
}
```

---

## 🔑 Claves de Mantenibilidad

### 1. **Usuario Variables** (No hardcodear valores)
❌ MALO:
```css
button { background-color: #007bff; }
button { padding: 16px 24px; }
```

✅ BUENO:
```css
button {
  background-color: var(--primary);
  padding: var(--spacing-md) var(--spacing-lg);
}
```

### 2. **Jerarquía de Especificidad Baja**
- Clases en lugar de IDs
- Evitar `!important`
- Reutilizar componentes base

### 3. **Nomenclatura BEM (Block Element Modifier)**
```css
.card { }                    /* Block */
.card-header { }             /* Element */
.card-header.active { }      /* Modifier */
.tab-btn { }
.tab-btn.active { }          /* Estado */
```

### 4. **Fluid Typography**
```css
h1 { font-size: var(--font-size-xxx); }
@media (max-width: 480px) {
  h1 { font-size: var(--font-size-xx); }
}
```

---

## 🚀 Inspiraciones Implementadas

| Plataforma | Elemento Inspirado | Implementación |
|------------|-------------------|----------------|
| **ChatGPT** | Minimalismo, mucho whitespace | Backgrounds limpios, padding generoso |
| **Spotify** | Contraste, dark sections | Colores vibrantes, gradientes suaves |
| **Netflix** | Jerarquía fuerte, premium | Tamaños de fuente, sombras dramáticas |
| **Stripe** | Claridad, tablas, SaaS feel | Tablas limpias, botones claros, spacing |

---

## 📝 Conclusión

Este sistema de diseño proporciona:

✅ **Consistencia**: Variables reutilizables en todo la app  
✅ **Mantenibilidad**: Cambiar 1 variable = cambia todo  
✅ **Responsividad**: Mobile-first desde el inicio  
✅ **Accesibilidad**: Colores contrastantes, focus states  
✅ **Profesionalismo**: Inspirado en líderes de industria  

La paleta de colores, tipografía, espaciado y componentes están diseñados para ser **fáciles de mantener**, **hermosos de ver**, y **profesionales para una SaaS premium**.

---

**Creado**: 6 de Febrero, 2026  
**Framework**: Ruby on Rails 8.1.2  
**Sistema CSS**: Custom CSS con Variables + Grid + Flexbox

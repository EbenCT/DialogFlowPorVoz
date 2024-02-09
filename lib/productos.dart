class Producto {
  String nombre;
  int precio;
  int cantidad;

  Producto(this.nombre, this.precio, this.cantidad);
  
  // Función para aumentar la cantidad de un producto en el carrito
  void aumentarCantidad(int cantidad) {
    this.cantidad += cantidad;
  }

  // Función para disminuir la cantidad de un producto en el carrito
  void disminuirCantidad(int cantidad) {
    if (this.cantidad - cantidad >= 0) {
      this.cantidad -= cantidad;
    }
  }

  // Función para eliminar el producto del carrito
  void eliminarDelCarrito() {
    this.cantidad = 0;
  }

  // Función para calcular el subtotal del producto (precio por cantidad)
  int calcularSubtotal() {
    return precio * cantidad;
  }

  static void eliminarDelCarritoPorNombre(String nombre) {
    carritoProductos.removeWhere((producto) => producto.nombre == nombre);
  }
}

List<Producto> carritoProductos = [];

// Función para añadir un producto al carrito
void addToCart(String nombre, int precio, int cantidad) {
  Producto nuevoProducto = Producto(nombre, precio, cantidad);
  carritoProductos.add(nuevoProducto);
}

// Función para mostrar todos los productos del carrito
void mostrarCarrito() {
  for (Producto producto in carritoProductos) {
    print('Producto: ${producto.nombre}');
    print('Precio: ${producto.precio} Bs.');
    print('Cantidad: ${producto.cantidad}');
  }
}

// Función para calcular el total del carrito
  int calcularTotal() {
    int total = 0;
    for (var producto in carritoProductos) {
      total += producto.calcularSubtotal();
    }
    return total;
  }

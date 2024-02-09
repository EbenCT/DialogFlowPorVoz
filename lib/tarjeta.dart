class TarjetaCredito {
  String nombrePropietario;
  String numeroTarjeta;
  String fechaVencimiento;
  String codigoSeguridad;

  TarjetaCredito(
      {required this.nombrePropietario,
      required this.numeroTarjeta,
      required this.fechaVencimiento,
      required this.codigoSeguridad});

        bool estaVacia() {
    return nombrePropietario.isEmpty &&
        numeroTarjeta.isEmpty &&
        fechaVencimiento.isEmpty &&
        codigoSeguridad.isEmpty;
  }
}

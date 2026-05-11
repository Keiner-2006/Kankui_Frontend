class Validators {
  static String? required(String? value, [String field = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$field es requerido';
    }
    return null;
  }

  static String? email(String? value) {
    final error = required(value, 'El correo');
    if (error != null) return error;
    if (!value!.contains('@')) return 'Ingresa un correo válido';
    return null;
  }

  static String? identification(String? value) {
    final error = required(value, 'La identificación');
    if (error != null) return error;
    if (value!.length < 6) return 'Mínimo 6 dígitos';
    if (value.length > 11) return 'Máximo 11 dígitos';
    return null;
  }

  static String? pin(String? value) {
    final error = required(value, 'El PIN');
    if (error != null) return error;
    if (value!.length < 4) return 'Mínimo 4 caracteres';
    return null;
  }

  static String? fullName(String? value) {
    final error = required(value, 'El nombre');
    if (error != null) return error;
    if (value!.trim().split(' ').length < 2) {
      return 'Ingresa nombre y apellido';
    }
    return null;
  }
}

class Validators {
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName es requerido'
          : 'Este campo es requerido';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo';
    }
    if (!value.contains('@')) {
      return 'Correo inválido';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return required(value, fieldName: fieldName);
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} no puede exceder $maxLength caracteres';
    }
    return null;
  }

  static String? numeric(String? value, {String? fieldName}) {
    if (value != null && value.isNotEmpty) {
      if (double.tryParse(value) == null) {
        return '${fieldName ?? 'Este campo'} debe ser numérico';
      }
    }
    return null;
  }

  static String? phone(String? value) {
    if (value != null && value.isNotEmpty) {
      final cleaned = value.replaceAll(RegExp(r'\D'), '');
      if (cleaned.length < 7 || cleaned.length > 15) {
        return 'Número de teléfono inválido';
      }
    }
    return null;
  }
}

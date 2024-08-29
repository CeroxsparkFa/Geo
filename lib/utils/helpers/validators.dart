library geoblast.validators;

String? Function(String?)? getConfirmPasswordValidator(password) {
  return (String? value) {
    var isEmpty = isFieldEmpty(value);
    if (isEmpty != null) {
      return isEmpty;
    }
    if (value != password) {
      return "El valor ingresado no coincide con la contraseña";
    }
    return null;
  };
}

String? emailValidator(email) {
  var isEmpty = isFieldEmpty(email);
  if (isEmpty != null) {
    return isEmpty; 
  }
  if (!email.contains("@")) {
    return "Este no es un correo valido";
  }
  return null;
}

String? isFieldEmpty(value) {
  if (value.isEmpty) {
    return "Este campo no puede estar vacio";
  }
  return null;
}

String? passwordValidator(password) {
  var isEmpty = isFieldEmpty(password);
  if (isEmpty != null) {
    return isEmpty; 
  }
  if (password.length < 8) {
    return "La contraseña debe contener al menos 8 caracteres";
  }
  return null;
}
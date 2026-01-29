class FormValidators {
  // Validate required field
  static String? Function(String?) required(String fieldName) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter $fieldName';
      }
      return null;
    };
  }

  // Validate email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // minimum length
  static String? Function(String?) minLength(int length, String fieldName) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter $fieldName';
      }
      if (value.trim().length < length) {
        return '$fieldName must be at least $length characters';
      }
      return null;
    };
  }

  // numeric value
  static String? numeric(String? value, {String fieldName = 'value'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}

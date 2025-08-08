interface PaymentMethodData {
  name?: string;
  isActive?: boolean;
}

interface PaymentMethodValidation {
  isValid: boolean;
  errors: string[];
}

export const validatePaymentMethodData = (
  data: PaymentMethodData
): PaymentMethodValidation => {
  const errors: string[] = [];

  if (data.name !== undefined) {
    if (typeof data.name !== "string" || data.name.trim() === "") {
      errors.push("Payment method name must be a non-empty string");
    } else if (data.name.length > 100) {
      errors.push("Payment method name cannot exceed 100 characters");
    }
  }

  if (data.isActive !== undefined) {
    if (typeof data.isActive !== "boolean") {
      errors.push("isActive must be a boolean value");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

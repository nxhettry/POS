interface BillSettingsData {
  includeTax?: boolean;
  includeDiscount?: boolean;
  printCustomerCopy?: boolean;
  printKitchenCopy?: boolean;
  showItemCode?: boolean;
  billFooter?: string;
}

export const validateBillSettingsData = (data: BillSettingsData) => {
  const errors: string[] = [];

  // Validate includeTax
  if (data.includeTax !== undefined) {
    if (typeof data.includeTax !== "boolean") {
      errors.push("Include tax must be a boolean value");
    }
  }

  // Validate includeDiscount
  if (data.includeDiscount !== undefined) {
    if (typeof data.includeDiscount !== "boolean") {
      errors.push("Include discount must be a boolean value");
    }
  }

  // Validate printCustomerCopy
  if (data.printCustomerCopy !== undefined) {
    if (typeof data.printCustomerCopy !== "boolean") {
      errors.push("Print customer copy must be a boolean value");
    }
  }

  // Validate printKitchenCopy
  if (data.printKitchenCopy !== undefined) {
    if (typeof data.printKitchenCopy !== "boolean") {
      errors.push("Print kitchen copy must be a boolean value");
    }
  }

  // Validate showItemCode
  if (data.showItemCode !== undefined) {
    if (typeof data.showItemCode !== "boolean") {
      errors.push("Show item code must be a boolean value");
    }
  }

  // Validate billFooter
  if (data.billFooter !== undefined) {
    if (typeof data.billFooter !== "string") {
      errors.push("Bill footer must be a string");
    } else if (data.billFooter.length > 500) {
      errors.push("Bill footer must be less than 500 characters");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

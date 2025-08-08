interface ExpenseCategoryData {
  name?: string;
  description?: string;
  isActive?: boolean;
}

interface ExpenseCategoryValidation {
  isValid: boolean;
  errors: string[];
}

export const validateExpenseCategoryData = (
  data: ExpenseCategoryData
): ExpenseCategoryValidation => {
  const errors: string[] = [];

  if (data.name !== undefined) {
    if (typeof data.name !== "string" || data.name.trim() === "") {
      errors.push("Expense category name must be a non-empty string");
    } else if (data.name.length > 100) {
      errors.push("Expense category name cannot exceed 100 characters");
    }
  }

  if (data.description !== undefined) {
    if (typeof data.description !== "string") {
      errors.push("Description must be a string");
    } else if (data.description.length > 500) {
      errors.push("Description cannot exceed 500 characters");
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

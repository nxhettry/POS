interface SalesItemData {
  salesId?: number;
  itemId?: number;
  itemName?: string;
  quantity?: number;
  rate?: number;
  totalPrice?: number;
  notes?: string;
}

interface SalesItemValidation {
  isValid: boolean;
  errors: string[];
}

export const validateSalesItemData = (data: SalesItemData): SalesItemValidation => {
  const errors: string[] = [];

  if (data.salesId !== undefined) {
    if (!Number.isInteger(data.salesId) || data.salesId <= 0) {
      errors.push("Sales ID must be a positive integer");
    }
  }

  if (data.itemId !== undefined) {
    if (!Number.isInteger(data.itemId) || data.itemId <= 0) {
      errors.push("Item ID must be a positive integer");
    }
  }

  if (data.itemName !== undefined) {
    if (typeof data.itemName !== "string" || data.itemName.trim() === "") {
      errors.push("Item name must be a non-empty string");
    } else if (data.itemName.length > 255) {
      errors.push("Item name cannot exceed 255 characters");
    }
  }

  if (data.quantity !== undefined) {
    if (typeof data.quantity !== "number" || data.quantity <= 0) {
      errors.push("Quantity must be a positive number");
    }
  }

  if (data.rate !== undefined) {
    if (typeof data.rate !== "number" || data.rate < 0) {
      errors.push("Rate must be a non-negative number");
    }
  }

  if (data.totalPrice !== undefined) {
    if (typeof data.totalPrice !== "number" || data.totalPrice < 0) {
      errors.push("Total price must be a non-negative number");
    }
  }

  if (data.notes !== undefined) {
    if (typeof data.notes !== "string") {
      errors.push("Notes must be a string");
    } else if (data.notes.length > 500) {
      errors.push("Notes cannot exceed 500 characters");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

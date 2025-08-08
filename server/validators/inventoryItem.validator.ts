interface InventoryItemData {
  name?: string;
  unit?: string;
  currentStock?: number;
  minimumStock?: number;
  costPrice?: number;
  supplierId?: number;
}

export const validateInventoryItemData = (data: InventoryItemData) => {
  const errors: string[] = [];

  if (data.name !== undefined) {
    if (!data.name || data.name.trim().length === 0) {
      errors.push("Item name is required");
    } else if (data.name.length > 255) {
      errors.push("Item name must be less than 255 characters");
    }
  }

  if (data.unit !== undefined) {
    if (!data.unit || data.unit.trim().length === 0) {
      errors.push("Unit is required");
    } else if (data.unit.length > 50) {
      errors.push("Unit must be less than 50 characters");
    }
  }

  if (data.currentStock !== undefined) {
    if (isNaN(data.currentStock) || data.currentStock < 0) {
      errors.push("Current stock must be a valid non-negative number");
    }
  }

  if (data.minimumStock !== undefined && data.minimumStock !== null) {
    if (isNaN(data.minimumStock) || data.minimumStock < 0) {
      errors.push("Minimum stock must be a valid non-negative number");
    }
  }

  if (data.costPrice !== undefined) {
    if (isNaN(data.costPrice) || data.costPrice < 0) {
      errors.push("Cost price must be a valid non-negative number");
    }
  }

  if (data.supplierId !== undefined && data.supplierId !== null) {
    if (isNaN(data.supplierId) || data.supplierId <= 0) {
      errors.push("Supplier ID must be a valid positive number");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

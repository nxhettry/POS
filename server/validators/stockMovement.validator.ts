interface StockMovementData {
  inventoryItemId?: number;
  type?: string;
  quantity?: number;
  unitCost?: number;
  reference?: string;
  notes?: string;
  createdBy?: number;
}

export const validateStockMovementData = (data: StockMovementData) => {
  const errors: string[] = [];

  if (data.inventoryItemId !== undefined) {
    if (!data.inventoryItemId || isNaN(data.inventoryItemId) || data.inventoryItemId <= 0) {
      errors.push("Valid inventory item ID is required");
    }
  }

  if (data.type !== undefined) {
    if (!data.type || data.type.trim().length === 0) {
      errors.push("Movement type is required");
    } else if (data.type.length > 100) {
      errors.push("Movement type must be less than 100 characters");
    }
  }

  if (data.quantity !== undefined) {
    if (isNaN(data.quantity) || data.quantity <= 0) {
      errors.push("Quantity must be a valid positive number");
    }
  }

  if (data.unitCost !== undefined) {
    if (isNaN(data.unitCost) || data.unitCost < 0) {
      errors.push("Unit cost must be a valid non-negative number");
    }
  }

  if (data.reference !== undefined && data.reference !== null) {
    if (data.reference.length > 255) {
      errors.push("Reference must be less than 255 characters");
    }
  }

  if (data.notes !== undefined && data.notes !== null) {
    if (data.notes.length > 500) {
      errors.push("Notes must be less than 500 characters");
    }
  }

  if (data.createdBy !== undefined && data.createdBy !== null) {
    if (isNaN(data.createdBy) || data.createdBy <= 0) {
      errors.push("Created by must be a valid user ID");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

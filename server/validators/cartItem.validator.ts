interface CartItemData {
  cartId?: number;
  itemId?: number;
  quantity?: number;
  rate?: number;
  totalPrice?: number;
  notes?: string;
}

export const validateCartItemData = (data: CartItemData) => {
  const errors: string[] = [];

  if (data.cartId !== undefined) {
    if (!data.cartId || isNaN(data.cartId) || data.cartId <= 0) {
      errors.push("Valid cart ID is required");
    }
  }

  if (data.itemId !== undefined) {
    if (!data.itemId || isNaN(data.itemId) || data.itemId <= 0) {
      errors.push("Valid item ID is required");
    }
  }

  if (data.quantity !== undefined) {
    if (isNaN(data.quantity) || data.quantity <= 0) {
      errors.push("Quantity must be a valid positive number");
    }
  }

  if (data.rate !== undefined) {
    if (isNaN(data.rate) || data.rate < 0) {
      errors.push("Rate must be a valid non-negative number");
    }
  }

  if (data.totalPrice !== undefined) {
    if (isNaN(data.totalPrice) || data.totalPrice < 0) {
      errors.push("Total price must be a valid non-negative number");
    }
  }

  if (data.notes !== undefined && data.notes !== null) {
    if (data.notes.length > 500) {
      errors.push("Notes must be less than 500 characters");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

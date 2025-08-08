interface MenuItemData {
  categoryId?: number;
  itemName?: string;
  description?: string;
  rate?: number;
  image?: string;
  isAvailable?: boolean;
}

export const validateMenuItemData = (data: MenuItemData) => {
  const errors: string[] = [];

  if (data.categoryId !== undefined) {
    if (!data.categoryId || isNaN(data.categoryId) || data.categoryId <= 0) {
      errors.push("Valid category ID is required");
    }
  }

  if (data.itemName !== undefined) {
    if (!data.itemName || data.itemName.trim().length === 0) {
      errors.push("Item name is required");
    } else if (data.itemName.length > 255) {
      errors.push("Item name must be less than 255 characters");
    }
  }

  if (data.description !== undefined && data.description !== null) {
    if (data.description.length > 500) {
      errors.push("Description must be less than 500 characters");
    }
  }

  if (data.rate !== undefined) {
    if (isNaN(data.rate) || data.rate < 0) {
      errors.push("Rate must be a valid positive number");
    }
  }

  if (data.image !== undefined && data.image !== null) {
    if (data.image.length > 500) {
      errors.push("Image URL must be less than 500 characters");
    }
  }

  if (data.isAvailable !== undefined) {
    if (typeof data.isAvailable !== "boolean") {
      errors.push("isAvailable must be a boolean value");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

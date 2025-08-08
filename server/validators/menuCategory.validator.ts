interface MenuCategoryData {
  name?: string;
  description?: string;
  isActive?: boolean;
}

export const validateMenuCategoryData = (data: MenuCategoryData) => {
  const errors: string[] = [];

  if (data.name !== undefined) {
    if (!data.name || data.name.trim().length === 0) {
      errors.push("Category name is required");
    } else if (data.name.length > 255) {
      errors.push("Category name must be less than 255 characters");
    }
  }

  if (data.description !== undefined && data.description !== null) {
    if (data.description.length > 500) {
      errors.push("Description must be less than 500 characters");
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

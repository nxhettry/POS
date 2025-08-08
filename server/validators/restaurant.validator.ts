interface RestaurantData {
  name?: string;
  address?: string;
  phone?: string;
  email?: string;
  pan?: string;
  website?: string;
  logo?: string;
}

export const validateRestaurantData = (data: RestaurantData) => {
  const errors: string[] = [];

  if (data.name !== undefined) {
    if (!data.name || data.name.trim().length === 0) {
      errors.push("Restaurant name is required");
    } else if (data.name.length > 255) {
      errors.push("Restaurant name must be less than 255 characters");
    }
  }

  if (data.address !== undefined) {
    if (!data.address || data.address.trim().length === 0) {
      errors.push("Address is required");
    } else if (data.address.length > 500) {
      errors.push("Address must be less than 500 characters");
    }
  }

  if (data.phone !== undefined) {
    if (!data.phone || data.phone.trim().length === 0) {
      errors.push("Phone number is required");
    } else if (!/^\+?[\d\s\-()]+$/.test(data.phone)) {
      errors.push("Invalid phone number format");
    }
  }

  if (data.email !== undefined && data.email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(data.email)) {
      errors.push("Invalid email format");
    }
  }

  if (data.pan !== undefined) {
    if (!data.pan || data.pan.trim().length === 0) {
      errors.push("PAN is required");
    } else if (data.pan.length > 20) {
      errors.push("PAN must be less than 20 characters");
    }
  }

  if (data.website !== undefined && data.website) {
    const urlRegex =
      /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/;
    if (!urlRegex.test(data.website)) {
      errors.push("Invalid website URL format");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

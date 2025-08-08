interface PartyData {
  name?: string;
  type?: "customer" | "supplier";
  address?: string;
  phone?: string;
  email?: string;
  balance?: number;
  isActive?: boolean;
}

export const validatePartyData = (data: PartyData) => {
  const errors: string[] = [];

  if (data.name !== undefined) {
    if (!data.name || data.name.trim().length === 0) {
      errors.push("Party name is required");
    } else if (data.name.length > 255) {
      errors.push("Party name must be less than 255 characters");
    }
  }

  if (data.type !== undefined) {
    const validTypes = ["customer", "supplier"];
    if (!validTypes.includes(data.type)) {
      errors.push("Type must be either 'customer' or 'supplier'");
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

  if (data.email !== undefined && data.email !== null && data.email.trim().length > 0) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(data.email)) {
      errors.push("Invalid email format");
    }
  }

  if (data.balance !== undefined) {
    if (isNaN(data.balance)) {
      errors.push("Balance must be a valid number");
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

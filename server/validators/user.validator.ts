interface UserData {
  username?: string;
  password?: string;
  role?: string;
  phone?: string;
  email?: string;
  isActive?: boolean;
}

interface UserValidation {
  isValid: boolean;
  errors: string[];
}

export const validateUserData = (data: UserData): UserValidation => {
  const errors: string[] = [];

  if (data.username !== undefined) {
    if (typeof data.username !== "string" || data.username.trim() === "") {
      errors.push("Username must be a non-empty string");
    } else if (data.username.length < 3) {
      errors.push("Username must be at least 3 characters long");
    } else if (data.username.length > 50) {
      errors.push("Username cannot exceed 50 characters");
    } else if (!/^[a-zA-Z0-9_-]+$/.test(data.username)) {
      errors.push("Username can only contain letters, numbers, underscores, and hyphens");
    }
  }

  if (data.password !== undefined) {
    if (typeof data.password !== "string" || data.password.trim() === "") {
      errors.push("Password must be a non-empty string");
    } else if (data.password.length < 6) {
      errors.push("Password must be at least 6 characters long");
    } else if (data.password.length > 255) {
      errors.push("Password cannot exceed 255 characters");
    }
  }

  if (data.role !== undefined) {
    const validRoles = ["admin", "waiter", "cashier"];
    if (typeof data.role !== "string" || !validRoles.includes(data.role)) {
      errors.push("Role must be one of: admin, waiter, cashier");
    }
  }

  if (data.phone !== undefined && data.phone !== null && data.phone !== "") {
    if (typeof data.phone !== "string") {
      errors.push("Phone must be a string");
    } else if (data.phone.length > 20) {
      errors.push("Phone number cannot exceed 20 characters");
    } else if (!/^[\d+\-\s()]+$/.test(data.phone)) {
      errors.push("Phone number contains invalid characters");
    }
  }

  if (data.email !== undefined && data.email !== null && data.email !== "") {
    if (typeof data.email !== "string") {
      errors.push("Email must be a string");
    } else if (data.email.length > 100) {
      errors.push("Email cannot exceed 100 characters");
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
      errors.push("Email must be a valid email address");
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

// Middleware functions for route validation
export const validateCreateUser = (req: any, res: any, next: any) => {
  const requiredFields = ["username", "password", "role"];
  const missingFields = requiredFields.filter(field => !req.body[field]);
  
  if (missingFields.length > 0) {
    return res.status(400).json({
      success: false,
      message: `Missing required fields: ${missingFields.join(", ")}`
    });
  }

  const validation = validateUserData(req.body);
  if (!validation.isValid) {
    return res.status(400).json({
      success: false,
      message: validation.errors.join(", ")
    });
  }

  next();
};

export const validateUpdateUser = (req: any, res: any, next: any) => {
  const validation = validateUserData(req.body);
  if (!validation.isValid) {
    return res.status(400).json({
      success: false,
      message: validation.errors.join(", ")
    });
  }

  next();
};

export const validateCredentials = (req: any, res: any, next: any) => {
  const { username, password } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({
      success: false,
      message: "Username and password are required"
    });
  }

  if (typeof username !== "string" || typeof password !== "string") {
    return res.status(400).json({
      success: false,
      message: "Username and password must be strings"
    });
  }

  next();
};

export const validatePasswordChange = (req: any, res: any, next: any) => {
  const { currentPassword, newPassword } = req.body;
  
  if (!currentPassword || !newPassword) {
    return res.status(400).json({
      success: false,
      message: "Current password and new password are required"
    });
  }

  if (typeof currentPassword !== "string" || typeof newPassword !== "string") {
    return res.status(400).json({
      success: false,
      message: "Passwords must be strings"
    });
  }

  if (newPassword.length < 6) {
    return res.status(400).json({
      success: false,
      message: "New password must be at least 6 characters long"
    });
  }

  next();
};

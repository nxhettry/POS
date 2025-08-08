interface UserSessionData {
  userId?: number;
  loginTime?: Date;
  logoutTime?: Date;
  deviceInfo?: string;
  ipAddress?: string;
  location?: string;
}

interface UserSessionValidation {
  isValid: boolean;
  errors: string[];
}

export const validateUserSessionData = (data: UserSessionData): UserSessionValidation => {
  const errors: string[] = [];

  if (data.userId !== undefined) {
    if (!Number.isInteger(data.userId) || data.userId <= 0) {
      errors.push("User ID must be a positive integer");
    }
  }

  if (data.loginTime !== undefined) {
    if (!(data.loginTime instanceof Date) && typeof data.loginTime !== "string") {
      errors.push("Login time must be a valid date");
    } else if (typeof data.loginTime === "string" && isNaN(Date.parse(data.loginTime))) {
      errors.push("Login time must be a valid date format");
    }
  }

  if (data.logoutTime !== undefined && data.logoutTime !== null) {
    if (!(data.logoutTime instanceof Date) && typeof data.logoutTime !== "string") {
      errors.push("Logout time must be a valid date");
    } else if (typeof data.logoutTime === "string" && isNaN(Date.parse(data.logoutTime))) {
      errors.push("Logout time must be a valid date format");
    }

    // Validate that logout time is after login time if both are provided
    if (data.loginTime && data.logoutTime) {
      const loginDate = new Date(data.loginTime);
      const logoutDate = new Date(data.logoutTime);
      if (logoutDate <= loginDate) {
        errors.push("Logout time must be after login time");
      }
    }
  }

  if (data.deviceInfo !== undefined && data.deviceInfo !== null && data.deviceInfo !== "") {
    if (typeof data.deviceInfo !== "string") {
      errors.push("Device info must be a string");
    } else if (data.deviceInfo.length > 255) {
      errors.push("Device info cannot exceed 255 characters");
    }
  }

  if (data.ipAddress !== undefined && data.ipAddress !== null && data.ipAddress !== "") {
    if (typeof data.ipAddress !== "string") {
      errors.push("IP address must be a string");
    } else if (data.ipAddress.length > 45) {
      errors.push("IP address cannot exceed 45 characters");
    } else {
      // Basic IP address format validation (supports both IPv4 and IPv6)
      const ipv4Regex = /^(\d{1,3}\.){3}\d{1,3}$/;
      const ipv6Regex = /^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$/;
      const isValidIPv4 = ipv4Regex.test(data.ipAddress) && 
        data.ipAddress.split('.').every(octet => parseInt(octet) <= 255);
      const isValidIPv6 = ipv6Regex.test(data.ipAddress);
      
      if (!isValidIPv4 && !isValidIPv6 && data.ipAddress !== "localhost" && data.ipAddress !== "::1") {
        errors.push("IP address must be a valid IPv4 or IPv6 address");
      }
    }
  }

  if (data.location !== undefined && data.location !== null && data.location !== "") {
    if (typeof data.location !== "string") {
      errors.push("Location must be a string");
    } else if (data.location.length > 255) {
      errors.push("Location cannot exceed 255 characters");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

// Middleware functions for route validation
export const validateCreateUserSession = (req: any, res: any, next: any) => {
  const requiredFields = ["userId"];
  const missingFields = requiredFields.filter(field => !req.body[field]);
  
  if (missingFields.length > 0) {
    return res.status(400).json({
      success: false,
      message: `Missing required fields: ${missingFields.join(", ")}`
    });
  }

  const validation = validateUserSessionData(req.body);
  if (!validation.isValid) {
    return res.status(400).json({
      success: false,
      message: validation.errors.join(", ")
    });
  }

  next();
};

export const validateUpdateUserSession = (req: any, res: any, next: any) => {
  const validation = validateUserSessionData(req.body);
  if (!validation.isValid) {
    return res.status(400).json({
      success: false,
      message: validation.errors.join(", ")
    });
  }

  next();
};

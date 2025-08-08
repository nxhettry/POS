interface SystemSettingsData {
  currency?: string;
  dateFormat?: "YYYY-MM-DD" | "DD-MM-YYYY";
  language?: "en" | "np";
  defaultTaxRate?: number;
  autoBackup?: boolean;
  sessionTimeout?: Date | string;
}

export const validateSystemSettingsData = (data: SystemSettingsData) => {
  const errors: string[] = [];

  // Validate currency
  if (data.currency !== undefined) {
    if (!data.currency || data.currency.trim().length === 0) {
      errors.push("Currency is required");
    } else if (data.currency.length > 10) {
      errors.push("Currency code must be less than 10 characters");
    }
  }

  // Validate date format
  if (data.dateFormat !== undefined) {
    const validFormats = ["YYYY-MM-DD", "DD-MM-YYYY"];
    if (!validFormats.includes(data.dateFormat)) {
      errors.push("Date format must be either 'YYYY-MM-DD' or 'DD-MM-YYYY'");
    }
  }

  // Validate language
  if (data.language !== undefined) {
    const validLanguages = ["en", "np"];
    if (!validLanguages.includes(data.language)) {
      errors.push("Language must be either 'en' or 'np'");
    }
  }

  // Validate default tax rate
  if (data.defaultTaxRate !== undefined) {
    if (isNaN(data.defaultTaxRate)) {
      errors.push("Default tax rate must be a valid number");
    } else if (data.defaultTaxRate < 0 || data.defaultTaxRate > 100) {
      errors.push("Default tax rate must be between 0 and 100");
    }
  }

  // Validate auto backup
  if (data.autoBackup !== undefined) {
    if (typeof data.autoBackup !== "boolean") {
      errors.push("Auto backup must be a boolean value");
    }
  }

  // Validate session timeout
  if (data.sessionTimeout !== undefined && data.sessionTimeout !== null) {
    const timeoutDate = new Date(data.sessionTimeout);
    if (isNaN(timeoutDate.getTime())) {
      errors.push("Session timeout must be a valid date");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

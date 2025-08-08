interface ExpenseData {
  title?: string;
  description?: string;
  amount?: number;
  paymentMethodId?: number;
  date?: string;
  categoryId?: number;
  partyId?: number;
  receipt?: string;
  createdBy?: number;
  approvedBy?: number;
}

interface ExpenseValidation {
  isValid: boolean;
  errors: string[];
}

export const validateExpenseData = (data: ExpenseData): ExpenseValidation => {
  const errors: string[] = [];

  if (data.title !== undefined) {
    if (typeof data.title !== "string" || data.title.trim() === "") {
      errors.push("Expense title must be a non-empty string");
    } else if (data.title.length > 255) {
      errors.push("Expense title cannot exceed 255 characters");
    }
  }

  if (data.description !== undefined) {
    if (typeof data.description !== "string") {
      errors.push("Description must be a string");
    } else if (data.description.length > 1000) {
      errors.push("Description cannot exceed 1000 characters");
    }
  }

  if (data.amount !== undefined) {
    if (typeof data.amount !== "number" || data.amount <= 0) {
      errors.push("Amount must be a positive number");
    }
  }

  if (data.paymentMethodId !== undefined) {
    if (!Number.isInteger(data.paymentMethodId) || data.paymentMethodId <= 0) {
      errors.push("Payment method ID must be a positive integer");
    }
  }

  if (data.date !== undefined) {
    if (typeof data.date !== "string") {
      errors.push("Date must be a string");
    } else {
      const dateObj = new Date(data.date);
      if (isNaN(dateObj.getTime())) {
        errors.push("Date must be a valid date string");
      }
    }
  }

  if (data.categoryId !== undefined) {
    if (!Number.isInteger(data.categoryId) || data.categoryId <= 0) {
      errors.push("Category ID must be a positive integer");
    }
  }

  if (data.partyId !== undefined) {
    if (!Number.isInteger(data.partyId) || data.partyId <= 0) {
      errors.push("Party ID must be a positive integer");
    }
  }

  if (data.receipt !== undefined) {
    if (typeof data.receipt !== "string") {
      errors.push("Receipt must be a string");
    } else if (data.receipt.length > 500) {
      errors.push("Receipt cannot exceed 500 characters");
    }
  }

  if (data.createdBy !== undefined) {
    if (!Number.isInteger(data.createdBy) || data.createdBy <= 0) {
      errors.push("Created by must be a positive integer");
    }
  }

  if (data.approvedBy !== undefined) {
    if (!Number.isInteger(data.approvedBy) || data.approvedBy <= 0) {
      errors.push("Approved by must be a positive integer");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

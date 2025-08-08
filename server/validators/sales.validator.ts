interface SalesData {
  tableId?: number;
  orderType?: string;
  orderStatus?: string;
  paymentStatus?: string;
  paymentMethodId?: number;
  subTotal?: number;
  tax?: number;
  total?: number;
  partyId?: number;
  createdBy?: number;
  signedBy?: number;
}

interface SalesValidation {
  isValid: boolean;
  errors: string[];
}

export const validateSalesData = (data: SalesData): SalesValidation => {
  const errors: string[] = [];

  if (data.tableId !== undefined) {
    if (!Number.isInteger(data.tableId) || data.tableId <= 0) {
      errors.push("Table ID must be a positive integer");
    }
  }

  if (data.orderType !== undefined) {
    const validOrderTypes = ["dine-in", "takeaway", "delivery"];
    if (typeof data.orderType !== "string" || !validOrderTypes.includes(data.orderType)) {
      errors.push("Order type must be one of: dine-in, takeaway, delivery");
    }
  }

  if (data.orderStatus !== undefined) {
    const validOrderStatuses = ["pending", "preparing", "ready", "served", "cancelled"];
    if (typeof data.orderStatus !== "string" || !validOrderStatuses.includes(data.orderStatus)) {
      errors.push("Order status must be one of: pending, preparing, ready, served, cancelled");
    }
  }

  if (data.paymentStatus !== undefined) {
    const validPaymentStatuses = ["pending", "paid", "partial", "refunded"];
    if (typeof data.paymentStatus !== "string" || !validPaymentStatuses.includes(data.paymentStatus)) {
      errors.push("Payment status must be one of: pending, paid, partial, refunded");
    }
  }

  if (data.paymentMethodId !== undefined) {
    if (!Number.isInteger(data.paymentMethodId) || data.paymentMethodId <= 0) {
      errors.push("Payment method ID must be a positive integer");
    }
  }

  if (data.subTotal !== undefined) {
    if (typeof data.subTotal !== "number" || data.subTotal < 0) {
      errors.push("Sub total must be a non-negative number");
    }
  }

  if (data.tax !== undefined) {
    if (typeof data.tax !== "number" || data.tax < 0) {
      errors.push("Tax must be a non-negative number");
    }
  }

  if (data.total !== undefined) {
    if (typeof data.total !== "number" || data.total < 0) {
      errors.push("Total must be a non-negative number");
    }
  }

  if (data.partyId !== undefined) {
    if (!Number.isInteger(data.partyId) || data.partyId <= 0) {
      errors.push("Party ID must be a positive integer");
    }
  }

  if (data.createdBy !== undefined) {
    if (!Number.isInteger(data.createdBy) || data.createdBy <= 0) {
      errors.push("Created by must be a positive integer");
    }
  }

  if (data.signedBy !== undefined) {
    if (!Number.isInteger(data.signedBy) || data.signedBy <= 0) {
      errors.push("Signed by must be a positive integer");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

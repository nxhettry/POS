interface CartData {
  tableId?: number;
  userId?: number;
  status?: "open" | "closed" | "cancelled";
}

export const validateCartData = (data: CartData) => {
  const errors: string[] = [];

  if (data.tableId !== undefined) {
    if (!data.tableId || isNaN(data.tableId) || data.tableId <= 0) {
      errors.push("Valid table ID is required");
    }
  }

  if (data.userId !== undefined && data.userId !== null) {
    if (isNaN(data.userId) || data.userId <= 0) {
      errors.push("Valid user ID is required");
    }
  }

  if (data.status !== undefined) {
    const validStatuses = ["open", "closed", "cancelled"];
    if (!validStatuses.includes(data.status)) {
      errors.push("Status must be either 'open', 'closed', or 'cancelled'");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

interface PartyTransactionData {
  partyId?: number;
  type?: "debit" | "credit";
  amount?: number;
  reference?: string;
  description?: string;
  createdBy?: number;
}

export const validatePartyTransactionData = (data: PartyTransactionData) => {
  const errors: string[] = [];

  if (data.partyId !== undefined) {
    if (!data.partyId || isNaN(data.partyId) || data.partyId <= 0) {
      errors.push("Valid party ID is required");
    }
  }

  if (data.type !== undefined) {
    const validTypes = ["debit", "credit"];
    if (!validTypes.includes(data.type)) {
      errors.push("Type must be either 'debit' or 'credit'");
    }
  }

  if (data.amount !== undefined) {
    if (isNaN(data.amount) || data.amount <= 0) {
      errors.push("Amount must be a valid positive number");
    }
  }

  if (data.reference !== undefined && data.reference !== null) {
    if (data.reference.length > 255) {
      errors.push("Reference must be less than 255 characters");
    }
  }

  if (data.description !== undefined && data.description !== null) {
    if (data.description.length > 500) {
      errors.push("Description must be less than 500 characters");
    }
  }

  if (data.createdBy !== undefined) {
    if (!data.createdBy || isNaN(data.createdBy) || data.createdBy <= 0) {
      errors.push("Valid created by user ID is required");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

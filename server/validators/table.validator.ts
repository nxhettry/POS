interface TableData {
  name?: string;
  status?: "available" | "occupied" | "reserved";
}

export const validateTableData = (data: TableData) => {
  const errors: string[] = [];

  if (data.name !== undefined) {
    if (!data.name || data.name.trim().length === 0) {
      errors.push("Table name is required");
    } else if (data.name.length > 255) {
      errors.push("Table name must be less than 255 characters");
    }
  }

  if (data.status !== undefined) {
    const validStatuses = ["available", "occupied", "reserved"];
    if (!validStatuses.includes(data.status)) {
      errors.push("Status must be either 'available', 'occupied', or 'reserved'");
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

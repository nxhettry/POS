import PartyTransaction from "../models/partyTransaction.js";
import Party from "../models/party.models.js";
import User from "../models/user.models.js";

interface PartyTransactionUpdateData {
  partyId?: number;
  type?: "debit" | "credit";
  amount?: number;
  reference?: string;
  description?: string;
  createdBy?: number;
}

interface PartyTransactionCreateData {
  partyId: number;
  type: "debit" | "credit";
  amount: number;
  reference?: string;
  description?: string;
  createdBy: number;
}

const handleUniqueConstraintError = (error: any) => {
  if (error.name === "SequelizeUniqueConstraintError") {
    return {
      success: false,
      data: null,
      message: "A transaction with these details already exists",
    };
  }
  return null;
};

export const createPartyTransactionService = async (
  transactionData: PartyTransactionCreateData
) => {
  try {
    const party = await Party.findByPk(transactionData.partyId);

    if (!party) {
      return {
        success: false,
        data: null,
        message: "Party not found",
      };
    }

    const user = await User.findByPk(transactionData.createdBy);

    if (!user) {
      return {
        success: false,
        data: null,
        message: "User not found",
      };
    }

    const currentBalance = parseFloat(party.get("balance") as string) || 0;
    let newBalance = currentBalance;

    if (transactionData.type === "debit") {
      newBalance += transactionData.amount;
    } else {
      newBalance -= transactionData.amount;
    }

    const transactionWithBalance = {
      ...transactionData,
      balanceBefore: currentBalance,
      balanceAfter: newBalance,
    };

    const newTransaction = await PartyTransaction.create(
      transactionWithBalance as any
    );

    await party.update({ balance: newBalance });

    return {
      success: true,
      data: newTransaction,
      message: "Party transaction created successfully",
    };
  } catch (error: any) {
    const constraintError = handleUniqueConstraintError(error);
    if (constraintError) return constraintError;
    throw new Error(`Failed to create party transaction: ${error.message}`);
  }
};

export const updatePartyTransactionService = async (
  id: number,
  transactionData: PartyTransactionUpdateData
) => {
  try {
    const transaction = await PartyTransaction.findByPk(id);

    if (!transaction) {
      return {
        success: false,
        data: null,
        message: "Party transaction not found",
      };
    }

    if (transactionData.partyId) {
      const party = await Party.findByPk(transactionData.partyId);

      if (!party) {
        return {
          success: false,
          data: null,
          message: "Party not found",
        };
      }
    }

    if (transactionData.createdBy) {
      const user = await User.findByPk(transactionData.createdBy);

      if (!user) {
        return {
          success: false,
          data: null,
          message: "User not found",
        };
      }
    }

    const updatedTransaction = await transaction.update(transactionData);

    return {
      success: true,
      data: updatedTransaction,
      message: "Party transaction updated successfully",
    };
  } catch (error: any) {
    const constraintError = handleUniqueConstraintError(error);
    if (constraintError) return constraintError;
    throw new Error(`Failed to update party transaction: ${error.message}`);
  }
};

export const getPartyTransactionService = async (id: number) => {
  try {
    const transaction = await PartyTransaction.findByPk(id, {
      include: [Party, User],
    });

    if (!transaction) {
      return {
        success: false,
        data: null,
        message: "Party transaction not found",
      };
    }

    return {
      success: true,
      data: transaction,
      message: "Party transaction retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get party transaction: ${error.message}`);
  }
};

export const getAllPartyTransactionsService = async () => {
  try {
    const transactions = await PartyTransaction.findAll({
      include: [Party, User],
      order: [["id", "DESC"]],
    });

    return {
      success: true,
      data: transactions,
      message: "Party transactions retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get party transactions: ${error.message}`);
  }
};

export const getPartyTransactionsByPartyService = async (partyId: number) => {
  try {
    const transactions = await PartyTransaction.findAll({
      where: { partyId },
      include: [Party, User],
      order: [["id", "DESC"]],
    });

    return {
      success: true,
      data: transactions,
      message: "Party transactions retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(
      `Failed to get party transactions by party: ${error.message}`
    );
  }
};

export const getPartyTransactionsByTypeService = async (
  type: "debit" | "credit"
) => {
  try {
    const transactions = await PartyTransaction.findAll({
      where: { type },
      include: [Party, User],
      order: [["id", "DESC"]],
    });

    return {
      success: true,
      data: transactions,
      message: "Party transactions retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(
      `Failed to get party transactions by type: ${error.message}`
    );
  }
};

export const deletePartyTransactionService = async (id: number) => {
  try {
    const transaction = await PartyTransaction.findByPk(id);

    if (!transaction) {
      return {
        success: false,
        data: null,
        message: "Party transaction not found",
      };
    }

    await transaction.destroy();

    return {
      success: true,
      data: null,
      message: "Party transaction deleted successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to delete party transaction: ${error.message}`);
  }
};

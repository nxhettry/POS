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

export const createPartyTransactionService = async (transactionData: PartyTransactionCreateData) => {
  const party = await Party.findByPk(transactionData.partyId);
  
  if (!party) {
    return {
      success: false,
      data: null,
      message: "Party not found"
    };
  }

  const currentBalance = parseFloat(party.get('balance') as string) || 0;
  let newBalance = currentBalance;
  
  if (transactionData.type === 'debit') {
    newBalance += transactionData.amount;
  } else {
    newBalance -= transactionData.amount;
  }

  const transactionWithBalance = {
    ...transactionData,
    balanceBefore: currentBalance,
    balanceAfter: newBalance
  };

  const newTransaction = await PartyTransaction.create(transactionWithBalance as any);
  
  await party.update({ balance: newBalance });
  
  return {
    success: true,
    data: newTransaction,
    message: "Party transaction created successfully"
  };
};

export const updatePartyTransactionService = async (id: number, transactionData: PartyTransactionUpdateData) => {
  const transaction = await PartyTransaction.findByPk(id);
  
  if (!transaction) {
    return {
      success: false,
      data: null,
      message: "Party transaction not found"
    };
  }

  const updatedTransaction = await transaction.update(transactionData);
  
  return {
    success: true,
    data: updatedTransaction,
    message: "Party transaction updated successfully"
  };
};

export const getPartyTransactionService = async (id: number) => {
  const transaction = await PartyTransaction.findByPk(id, {
    include: [Party, User]
  });
  
  if (!transaction) {
    return {
      success: false,
      data: null,
      message: "Party transaction not found"
    };
  }

  return {
    success: true,
    data: transaction,
    message: "Party transaction retrieved successfully"
  };
};

export const getAllPartyTransactionsService = async () => {
  const transactions = await PartyTransaction.findAll({
    include: [Party, User],
    order: [['id', 'DESC']]
  });

  return {
    success: true,
    data: transactions,
    message: "Party transactions retrieved successfully"
  };
};

export const getPartyTransactionsByPartyService = async (partyId: number) => {
  const transactions = await PartyTransaction.findAll({
    where: { partyId },
    include: [Party, User],
    order: [['id', 'DESC']]
  });

  return {
    success: true,
    data: transactions,
    message: "Party transactions retrieved successfully"
  };
};

export const getPartyTransactionsByTypeService = async (type: "debit" | "credit") => {
  const transactions = await PartyTransaction.findAll({
    where: { type },
    include: [Party, User],
    order: [['id', 'DESC']]
  });

  return {
    success: true,
    data: transactions,
    message: "Party transactions retrieved successfully"
  };
};

export const deletePartyTransactionService = async (id: number) => {
  const transaction = await PartyTransaction.findByPk(id);
  
  if (!transaction) {
    return {
      success: false,
      data: null,
      message: "Party transaction not found"
    };
  }

  await transaction.destroy();
  
  return {
    success: true,
    data: null,
    message: "Party transaction deleted successfully"
  };
};

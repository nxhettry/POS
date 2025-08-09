import Daybook from "../models/daybook.models.js";
import DaybookTransaction from "../models/daybookTransaction.models.js";
import PaymentMethod from "../models/paymentMethod.models.js";
import { Op } from "sequelize";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

export const createDaybookService = async (
  daybookData: any
): Promise<ServiceResponse<any>> => {
  const existingDaybook = await Daybook.findOne({
    where: { date: daybookData.date },
  });

  if (existingDaybook) {
    return {
      success: false,
      message: `Daybook already exists for date: ${daybookData.date}`,
    };
  }

  const daybook = await Daybook.create(daybookData);
  const daybookWithTransactions = await Daybook.findByPk((daybook as any).id, {
    include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
  });

  return {
    success: true,
    data: daybookWithTransactions,
    message: "Daybook created successfully",
  };
};

export const updateDaybookService = async (
  id: number,
  daybookData: any
): Promise<ServiceResponse<any>> => {
  const daybook = await Daybook.findByPk(id);
  if (!daybook) {
    return {
      success: false,
      message: "Daybook not found",
    };
  }

  await daybook.update(daybookData);
  const updatedDaybook = await Daybook.findByPk(id, {
    include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
  });

  return {
    success: true,
    data: updatedDaybook,
    message: "Daybook updated successfully",
  };
};

export const getDaybookService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const daybook = await Daybook.findByPk(id, {
    include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
  });

  if (!daybook) {
    return {
      success: false,
      message: "Daybook not found",
    };
  }

  return {
    success: true,
    data: daybook,
    message: "Daybook retrieved successfully",
  };
};

export const getAllDaybooksService = async (): Promise<
  ServiceResponse<any[]>
> => {
  const daybooks = await Daybook.findAll({
    include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
    order: [["date", "DESC"]],
  });

  return {
    success: true,
    data: daybooks,
    message: "Daybooks retrieved successfully",
  };
};

export const getDaybookByDateService = async (
  date: string
): Promise<ServiceResponse<any>> => {
  const daybook = await Daybook.findOne({
    where: { date },
    include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
  });

  if (!daybook) {
    return {
      success: false,
      message: `Daybook not found for date: ${date}`,
    };
  }

  return {
    success: true,
    data: daybook,
    message: `Daybook for ${date} retrieved successfully`,
  };
};

export const getDaybooksByStatusService = async (
  status: string
): Promise<ServiceResponse<any[]>> => {
  const daybooks = await Daybook.findAll({
    where: { status },
    include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
    order: [["date", "DESC"]],
  });

  return {
    success: true,
    data: daybooks,
    message: `Daybooks with status ${status} retrieved successfully`,
  };
};

export const getDaybooksByDateRangeService = async (
  startDate: string,
  endDate: string
): Promise<ServiceResponse<any[]>> => {
  const daybooks = await Daybook.findAll({
    where: {
      date: {
        [Op.between]: [startDate, endDate],
      },
    },
    include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
    order: [["date", "DESC"]],
  });

  return {
    success: true,
    data: daybooks,
    message: `Daybooks from ${startDate} to ${endDate} retrieved successfully`,
  };
};

export const getOrCreateTodayDaybookService = async (
  openedBy: string = "system"
): Promise<ServiceResponse<any>> => {
  const today = new Date().toISOString().split("T")[0];

  const existingResult = await getDaybookByDateService(today);
  if (existingResult.success) {
    return {
      success: true,
      data: existingResult.data,
      message: "Today's daybook retrieved successfully",
    };
  }

  // Get previous day's closing balance for opening balance
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  const yesterdayDate = yesterday.toISOString().split("T")[0];

  const previousDaybook = await Daybook.findOne({
    where: { date: yesterdayDate },
  });

  const openingCashBalance = previousDaybook
    ? (previousDaybook as any).closingCashInHand || 0
    : 0;
  const openingBankBalance = previousDaybook
    ? (previousDaybook as any).closingCastAtBank || 0
    : 0;

  // Create new daybook for today
  return await createDaybookService({
    date: today,
    openingCashBalance,
    openingBankBalance,
    openedBy,
    totalCashBalance: openingCashBalance,
    totalOnlineBalance: openingBankBalance,
  });
};

export const closeDaybookService = async (
  id: number,
  closingData: {
    closingCashInHand: number;
    closingCastAtBank: number;
    closedBy: string;
    notes?: string;
  }
): Promise<ServiceResponse<any>> => {
  const daybook = await Daybook.findByPk(id);
  if (!daybook) {
    return {
      success: false,
      message: "Daybook not found",
    };
  }

  if ((daybook as any).status === "closed") {
    return {
      success: false,
      message: "Daybook is already closed",
    };
  }

  await daybook.update({
    ...closingData,
    status: "closed",
    closedAt: new Date(),
  });

  const updatedDaybook = await Daybook.findByPk(id, {
    include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
  });

  return {
    success: true,
    data: updatedDaybook,
    message: "Daybook closed successfully",
  };
};

export const deleteDaybookService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const daybook = await Daybook.findByPk(id);
  if (!daybook) {
    return {
      success: false,
      message: "Daybook not found",
    };
  }

  // Delete associated transactions first
  await DaybookTransaction.destroy({
    where: { daybookId: id },
  });

  await daybook.destroy();
  return {
    success: true,
    data: null,
    message: "Daybook deleted successfully",
  };
};

export const createDaybookTransactionService = async (
  transactionData: any
): Promise<ServiceResponse<any>> => {
  let paymentMode = "cash";
  if (transactionData.paymentMethodId) {
    const paymentMethod = await PaymentMethod.findByPk(
      transactionData.paymentMethodId
    );
    if (paymentMethod) {
      const cashMethods = ["cash", "Cash", "CASH"];
      paymentMode = cashMethods.includes((paymentMethod as any).name)
        ? "cash"
        : "online";
    }
  }

  const transaction = await DaybookTransaction.create({
    ...transactionData,
    paymentMode,
    timestamp: new Date(),
  });

  // Update daybook totals
  await updateDaybookTotalsService(transactionData.daybookId);

  return {
    success: true,
    data: transaction,
    message: "Daybook transaction created successfully",
  };
};

export const addSaleTransactionService = async (
  saleId: number,
  amount: number,
  paymentMethodId: number,
  date?: string,
  userId?: string
): Promise<ServiceResponse<any>> => {
  const saleDate = date || new Date().toISOString().split("T")[0];

  const daybookResult = await getOrCreateTodayDaybookService(
    userId || "system"
  );
  if (!daybookResult.success) {
    return daybookResult;
  }

  // Check if this sale transaction already exists in the daybook
  const existingTransaction = await DaybookTransaction.findOne({
    where: {
      daybookId: daybookResult.data.id,
      transactionType: "sale",
      referenceId: saleId,
    },
  });

  if (existingTransaction) {
    return {
      success: true,
      data: existingTransaction,
      message: `Sale transaction #${saleId} already exists in daybook`,
    };
  }

  return await createDaybookTransactionService({
    daybookId: daybookResult.data.id,
    transactionType: "sale",
    paymentMethodId,
    referenceId: saleId,
    amount,
    description: `Sale transaction #${saleId}`,
  });
};

export const addExpenseTransactionService = async (
  expenseId: number,
  amount: number,
  paymentMethodId: number,
  date?: string,
  userId?: string
): Promise<ServiceResponse<any>> => {
  const expenseDate = date || new Date().toISOString().split("T")[0];

  const daybookResult = await getOrCreateTodayDaybookService(
    userId || "system"
  );
  if (!daybookResult.success) {
    return daybookResult;
  }

  // Check if this expense transaction already exists in the daybook
  const existingTransaction = await DaybookTransaction.findOne({
    where: {
      daybookId: daybookResult.data.id,
      transactionType: "expense",
      referenceId: expenseId,
    },
  });

  if (existingTransaction) {
    return {
      success: true,
      data: existingTransaction,
      message: `Expense transaction #${expenseId} already exists in daybook`,
    };
  }

  return await createDaybookTransactionService({
    daybookId: daybookResult.data.id,
    transactionType: "expense",
    paymentMethodId,
    referenceId: expenseId,
    amount,
    description: `Expense transaction #${expenseId}`,
  });
};

export const updateDaybookTotalsService = async (
  daybookId: number
): Promise<ServiceResponse<any>> => {
  const daybook = await Daybook.findByPk(daybookId);
  if (!daybook) {
    return {
      success: false,
      message: "Daybook not found",
    };
  }

  const transactions = await DaybookTransaction.findAll({
    where: { daybookId },
  });

  let totalCashSales = 0;
  let totalOnlineSales = 0;
  let totalCashExpenses = 0;
  let totalOnlineExpenses = 0;

  transactions.forEach((trans) => {
    const amount = parseFloat((trans as any).amount.toString());

    if ((trans as any).transactionType === "sale") {
      if ((trans as any).paymentMode === "cash") {
        totalCashSales += amount;
      } else {
        totalOnlineSales += amount;
      }
    } else if ((trans as any).transactionType === "expense") {
      if ((trans as any).paymentMode === "cash") {
        totalCashExpenses += amount;
      } else {
        totalOnlineExpenses += amount;
      }
    }
  });

  const openingCashBalance = (daybook as any).openingCashBalance || 0;
  const openingBankBalance = (daybook as any).openingBankBalance || 0;
  const totalCashBalance =
    openingCashBalance + totalCashSales - totalCashExpenses;
  const totalOnlineBalance =
    openingBankBalance + totalOnlineSales - totalOnlineExpenses;

  await daybook.update({
    totalCashSales,
    totalOnlineSales,
    totalCashExpenses,
    totalOnlineExpenses,
    totalCashBalance,
    totalOnlineBalance,
  });

  return {
    success: true,
    data: await Daybook.findByPk(daybookId, {
      include: [{ model: DaybookTransaction, as: "DaybookTransactions" }],
    }),
    message: "Daybook totals updated successfully",
  };
};

export const getDaybookTransactionsService = async (
  daybookId: number
): Promise<ServiceResponse<any[]>> => {
  const transactions = await DaybookTransaction.findAll({
    where: { daybookId },
    order: [["timestamp", "ASC"]],
  });

  return {
    success: true,
    data: transactions,
    message: "Daybook transactions retrieved successfully",
  };
};

export const getTransactionsByTypeService = async (
  transactionType: string,
  startDate?: string,
  endDate?: string
): Promise<ServiceResponse<any[]>> => {
  const whereClause: any = { transactionType };

  if (startDate || endDate) {
    const daybookWhere: any = {};
    if (startDate) daybookWhere.date = { [Op.gte]: startDate };
    if (endDate) daybookWhere.date = { [Op.lte]: endDate };

    const daybooks = await Daybook.findAll({
      where: daybookWhere,
      attributes: ["id"],
    });

    whereClause.daybookId = { [Op.in]: daybooks.map((d) => (d as any).id) };
  }

  const transactions = await DaybookTransaction.findAll({
    where: whereClause,
    include: [
      {
        model: Daybook,
        attributes: ["date", "status"],
      },
    ],
    order: [["timestamp", "DESC"]],
  });

  return {
    success: true,
    data: transactions,
    message: `Transactions of type ${transactionType} retrieved successfully`,
  };
};

export const deleteDaybookTransactionService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const transaction = await DaybookTransaction.findByPk(id);
  if (!transaction) {
    return {
      success: false,
      message: "Transaction not found",
    };
  }

  const daybookId = (transaction as any).daybookId;
  await transaction.destroy();

  await updateDaybookTotalsService(daybookId);

  return {
    success: true,
    data: null,
    message: "Transaction deleted successfully",
  };
};

import Sales from "../models/sales.models.js";
import SalesItem from "../models/salesItem.models.js";
import MenuItem from "../models/menuItem.models.js";
import Table from "../models/table.model.js";
import PaymentMethod from "../models/paymentMethod.models.js";
import Party from "../models/party.models.js";
import User from "../models/user.models.js";
import { addSaleTransactionService } from "./daybook.service.js";
import { isNonCreditPayment } from "../utils/payment.utils.js";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

const generateInvoiceNumber = (salesId: number): string => {
  return `INV ${salesId.toString().padStart(3, "0")}`;
};

export const createSalesService = async (
  salesData: any
): Promise<ServiceResponse<any>> => {
  const sales = await Sales.create(salesData);

  const invoiceNo = generateInvoiceNumber(sales.dataValues.id as number);
  await sales.update({ invoiceNo });

  const salesWithIncludes = await Sales.findByPk(sales.dataValues.id, {
    include: [
      { model: Table, as: "Table" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
      {
        model: SalesItem,
        as: "SalesItems",
        include: [{ model: MenuItem, as: "MenuItem" }],
      },
    ],
  });

  if (salesData.paymentMethodId && salesData.paymentStatus === "paid") {
    const isNonCredit = await isNonCreditPayment(salesData.paymentMethodId);
    if (isNonCredit) {
      try {
        await addSaleTransactionService(
          sales.dataValues.id,
          salesData.total || 0,
          salesData.paymentMethodId,
          undefined,
          salesData.createdBy?.toString() || "system"
        );
      } catch (error) {
        console.error("Error adding sale to daybook:", error);
      }
    }
  }

  return {
    success: true,
    data: salesWithIncludes,
    message: "Sales record created successfully",
  };
};

export const updateSalesService = async (
  id: number,
  salesData: any
): Promise<ServiceResponse<any>> => {
  const sales = await Sales.findByPk(id);
  if (!sales) {
    return {
      success: false,
      message: "Sales record not found",
    };
  }

  const oldPaymentStatus = (sales as any).paymentStatus;
  const oldPaymentMethodId = (sales as any).paymentMethodId;

  await sales.update(salesData);
  const updatedSales = await Sales.findByPk(id, {
    include: [
      { model: Table, as: "Table" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
      {
        model: SalesItem,
        as: "SalesItems",
        include: [{ model: MenuItem, as: "MenuItem" }],
      },
    ],
  });

  if (salesData.paymentStatus === "paid" && oldPaymentStatus !== "paid") {
    const paymentMethodId = salesData.paymentMethodId || oldPaymentMethodId;
    if (paymentMethodId) {
      const isNonCredit = await isNonCreditPayment(paymentMethodId);
      if (isNonCredit) {
        try {
          await addSaleTransactionService(
            id,
            salesData.total || (sales as any).total || 0,
            paymentMethodId,
            undefined,
            salesData.createdBy?.toString() ||
              (sales as any).createdBy?.toString() ||
              "system"
          );
        } catch (error) {
          console.error("Error adding sale update to daybook:", error);
        }
      }
    }
  }

  return {
    success: true,
    data: updatedSales,
    message: "Sales record updated successfully",
  };
};

export const getSalesService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const sales = await Sales.findByPk(id, {
    include: [
      { model: Table, as: "Table" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
      {
        model: SalesItem,
        as: "SalesItems",
        include: [{ model: MenuItem, as: "MenuItem" }],
      },
    ],
  });

  if (!sales) {
    return {
      success: false,
      message: "Sales record not found",
    };
  }

  return {
    success: true,
    data: sales,
    message: "Sales record retrieved successfully",
  };
};

export const getAllSalesService = async (): Promise<ServiceResponse<any[]>> => {
  const sales = await Sales.findAll({
    include: [
      { model: Table, as: "Table" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
      {
        model: SalesItem,
        as: "SalesItems",
        include: [{ model: MenuItem, as: "MenuItem" }],
      },
    ],
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: sales,
    message: "Sales records retrieved successfully",
  };
};

export const getSalesByOrderStatusService = async (
  orderStatus: string
): Promise<ServiceResponse<any[]>> => {
  const sales = await Sales.findAll({
    where: {
      orderStatus: orderStatus,
    },
    include: [
      { model: Table, as: "Table" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
      {
        model: SalesItem,
        as: "SalesItems",
        include: [{ model: MenuItem, as: "MenuItem" }],
      },
    ],
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: sales,
    message: `Sales records with status ${orderStatus} retrieved successfully`,
  };
};

export const getSalesByPaymentStatusService = async (
  paymentStatus: string
): Promise<ServiceResponse<any[]>> => {
  const sales = await Sales.findAll({
    where: {
      paymentStatus: paymentStatus,
    },
    include: [
      { model: Table, as: "Table" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
      {
        model: SalesItem,
        as: "SalesItems",
        include: [{ model: MenuItem, as: "MenuItem" }],
      },
    ],
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: sales,
    message: `Sales records with payment status ${paymentStatus} retrieved successfully`,
  };
};

export const getSalesByTableService = async (
  tableId: number
): Promise<ServiceResponse<any[]>> => {
  const sales = await Sales.findAll({
    where: {
      tableId: tableId,
    },
    include: [
      { model: Table, as: "Table" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
      {
        model: SalesItem,
        as: "SalesItems",
        include: [{ model: MenuItem, as: "MenuItem" }],
      },
    ],
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: sales,
    message: `Sales records for table ${tableId} retrieved successfully`,
  };
};

export const getSalesByPartyService = async (
  partyId: number
): Promise<ServiceResponse<any[]>> => {
  const sales = await Sales.findAll({
    where: {
      partyId: partyId,
    },
    include: [
      { model: Table, as: "Table" },
      { model: PaymentMethod, as: "PaymentMethod" },
      { model: Party, as: "Party" },
      { model: User, as: "User" },
      {
        model: SalesItem,
        as: "SalesItems",
        include: [{ model: MenuItem, as: "MenuItem" }],
      },
    ],
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: sales,
    message: `Sales records for party ${partyId} retrieved successfully`,
  };
};

export const deleteSalesService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const sales = await Sales.findByPk(id);
  if (!sales) {
    return {
      success: false,
      message: "Sales record not found",
    };
  }

  await sales.destroy();
  return {
    success: true,
    data: null,
    message: "Sales record deleted successfully",
  };
};

export const getNextInvoiceNumberService = async (): Promise<
  ServiceResponse<any>
> => {
  try {
    const lastSales = await Sales.findOne({
      order: [["id", "DESC"]],
      attributes: ["id"],
    });

    const nextId = lastSales ? (lastSales as any).id + 1 : 1;
    const nextInvoiceNumber = generateInvoiceNumber(nextId);

    return {
      success: true,
      data: {
        nextId,
        invoiceNumber: nextInvoiceNumber,
      },
      message: "Next invoice number retrieved successfully",
    };
  } catch (error) {
    return {
      success: false,
      message: "Error retrieving next invoice number",
    };
  }
};

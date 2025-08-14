import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validateSalesData } from "../validators/sales.validator.js";
import {
  createSalesService,
  updateSalesService,
  getSalesService,
  getAllSalesService,
  getSalesByOrderStatusService,
  getSalesByPaymentStatusService,
  getSalesByTableService,
  getSalesByPartyService,
  deleteSalesService,
  getNextInvoiceNumberService,
} from "../service/sales.service.js";

const generateInvoiceNumber = (salesId: number): string => {
  return `INV ${salesId.toString().padStart(3, "0")}`;
};

export const createSales = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const salesData = req.body;

    console.log("\n\n\nRequest : ", req.body)

    if (
      !salesData.orderType ||
      !salesData.orderStatus ||
      !salesData.paymentStatus
    ) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Order type, order status, and payment status are required"
          )
        );
    }

    const validation = validateSalesData(salesData);

    if (!validation.isValid) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            `Validation failed: ${validation.errors.join(", ")}`
          )
        );
    }

    const result = await createSalesService(salesData);

    if (result.success) {
      return res
        .status(201)
        .json(new apiResponse(201, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const updateSales = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const salesData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid sales ID is required"));
    }

    const validation = validateSalesData(salesData);

    if (!validation.isValid) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            `Validation failed: ${validation.errors.join(", ")}`
          )
        );
    }

    const result = await updateSalesService(Number(id), salesData);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getSales = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid sales ID is required"));
    }

    const result = await getSalesService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getAllSales = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllSalesService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getSalesByOrderStatus = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { status } = req.params;

    const validStatuses = [
      "pending",
      "preparing",
      "ready",
      "served",
      "cancelled",
    ];
    if (!validStatuses.includes(status)) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Valid order status is required (pending, preparing, ready, served, cancelled)"
          )
        );
    }

    const result = await getSalesByOrderStatusService(status);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getSalesByPaymentStatus = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { status } = req.params;

    const validStatuses = ["pending", "paid", "partial", "refunded"];
    if (!validStatuses.includes(status)) {
      return res
        .status(400)
        .json(
          new apiResponse(
            400,
            null,
            "Valid payment status is required (pending, paid, partial, refunded)"
          )
        );
    }

    const result = await getSalesByPaymentStatusService(status);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getSalesByTable = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { tableId } = req.params;

    if (!tableId || isNaN(Number(tableId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid table ID is required"));
    }

    const result = await getSalesByTableService(Number(tableId));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getSalesByParty = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { partyId } = req.params;

    if (!partyId || isNaN(Number(partyId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid party ID is required"));
    }

    const result = await getSalesByPartyService(Number(partyId));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const deleteSales = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid sales ID is required"));
    }

    const result = await deleteSalesService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

export const getNextInvoiceNumber = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getNextInvoiceNumberService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

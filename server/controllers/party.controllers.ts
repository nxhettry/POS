import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validatePartyData } from "../validators/party.validator.js";
import { validatePartyTransactionData } from "../validators/partyTransaction.validator.js";
import {
  createPartyService,
  updatePartyService,
  getPartyService,
  getAllPartiesService,
  getPartiesByTypeService,
  getActivePartiesService,
  deletePartyService,
} from "../service/party.service.js";
import {
  createPartyTransactionService,
  updatePartyTransactionService,
  getPartyTransactionService,
  getAllPartyTransactionsService,
  getPartyTransactionsByPartyService,
  getPartyTransactionsByTypeService,
  deletePartyTransactionService,
} from "../service/partyTransaction.service.js";

export const createParty = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const partyData = req.body;

    if (!partyData.name || !partyData.type || !partyData.address || !partyData.phone) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Name, type, address, and phone are required"));
    }

    const validation = validatePartyData(partyData);

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

    const result = await createPartyService(partyData);

    if (result.success) {
      return res
        .status(201)
        .json(new apiResponse(201, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const updateParty = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const partyData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid party ID is required"));
    }

    const validation = validatePartyData(partyData);

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

    const result = await updatePartyService(Number(id), partyData);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);

export const getParty = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid party ID is required"));
    }

    const result = await getPartyService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);

export const getAllParties = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllPartiesService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const getPartiesByType = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { type } = req.params;

    const validTypes = ["customer", "supplier"];
    if (!validTypes.includes(type)) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid type is required (customer, supplier)"));
    }

    const result = await getPartiesByTypeService(type as "customer" | "supplier");

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const getActiveParties = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getActivePartiesService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const deleteParty = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid party ID is required"));
    }

    const result = await deletePartyService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);

export const createPartyTransaction = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const transactionData = req.body;

    if (!transactionData.partyId || !transactionData.type || transactionData.amount === undefined || !transactionData.createdBy) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Party ID, type, amount, and created by are required"));
    }

    const validation = validatePartyTransactionData(transactionData);

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

    const result = await createPartyTransactionService(transactionData);

    if (result.success) {
      return res
        .status(201)
        .json(new apiResponse(201, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const updatePartyTransaction = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const transactionData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid transaction ID is required"));
    }

    const validation = validatePartyTransactionData(transactionData);

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

    const result = await updatePartyTransactionService(Number(id), transactionData);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);

export const getPartyTransaction = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid transaction ID is required"));
    }

    const result = await getPartyTransactionService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);

export const getAllPartyTransactions = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllPartyTransactionsService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const getPartyTransactionsByParty = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { partyId } = req.params;

    if (!partyId || isNaN(Number(partyId))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid party ID is required"));
    }

    const result = await getPartyTransactionsByPartyService(Number(partyId));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const getPartyTransactionsByType = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { type } = req.params;

    const validTypes = ["debit", "credit"];
    if (!validTypes.includes(type)) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid type is required (debit, credit)"));
    }

    const result = await getPartyTransactionsByTypeService(type as "debit" | "credit");

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(400)
        .json(new apiResponse(400, null, result.message));
    }
  }
);

export const deletePartyTransaction = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid transaction ID is required"));
    }

    const result = await deletePartyTransactionService(Number(id));

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res
        .status(404)
        .json(new apiResponse(404, null, result.message));
    }
  }
);
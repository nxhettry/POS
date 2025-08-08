import { Request, Response } from "express";
import { asyncHandler, apiResponse } from "../utils/api.js";
import { validatePaymentMethodData } from "../validators/paymentMethod.validator.js";
import {
  createPaymentMethodService,
  updatePaymentMethodService,
  getPaymentMethodService,
  getAllPaymentMethodsService,
  getActivePaymentMethodsService,
  deletePaymentMethodService,
} from "../service/paymentMethod.service.js";

export const createPaymentMethod = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const paymentMethodData = req.body;

    if (!paymentMethodData.name) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Payment method name is required"));
    }

    const validation = validatePaymentMethodData(paymentMethodData);

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

    const result = await createPaymentMethodService(paymentMethodData);

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

export const updatePaymentMethod = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;
    const paymentMethodData = req.body;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid payment method ID is required"));
    }

    const validation = validatePaymentMethodData(paymentMethodData);

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

    const result = await updatePaymentMethodService(Number(id), paymentMethodData);

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

export const getPaymentMethod = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid payment method ID is required"));
    }

    const result = await getPaymentMethodService(Number(id));

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

export const getAllPaymentMethods = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getAllPaymentMethodsService();

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

export const getActivePaymentMethods = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getActivePaymentMethodsService();

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

export const deletePaymentMethod = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const { id } = req.params;

    if (!id || isNaN(Number(id))) {
      return res
        .status(400)
        .json(new apiResponse(400, null, "Valid payment method ID is required"));
    }

    const result = await deletePaymentMethodService(Number(id));

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

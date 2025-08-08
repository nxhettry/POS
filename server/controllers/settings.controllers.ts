import { Request, Response } from "express";
import { asyncHandler, apiResponse, apiError } from "../utils/api.js";
import { validateRestaurantData } from "../validators/restaurant.validator.js";
import { validateSystemSettingsData } from "../validators/systemSettings.validator.js";
import { validateBillSettingsData } from "../validators/billSettings.validator.js";
import {
  updateRestaurantDetailService,
  getRestaurantDetailService,
} from "../service/restaurant.service.js";
import {
  updateSystemSettingsService,
  getSystemSettingsService,
} from "../service/systemSettings.service.js";
import {
  updateBillSettingsService,
  getBillSettingsService,
} from "../service/billSettings.service.js";

export const editRestaurantDetails = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const restaurantData = req.body;

    const validation = validateRestaurantData(restaurantData);

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

    const result = await updateRestaurantDetailService(restaurantData);

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(400).json(new apiResponse(400, null, result.message));
    }
  }
);

export const getRestaurantDetails = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const result = await getRestaurantDetailService();

    if (result.success) {
      return res
        .status(200)
        .json(new apiResponse(200, result.data, result.message));
    } else {
      return res.status(404).json(new apiResponse(404, null, result.message));
    }
  }
);

// System Settings Controllers
export const editSystemSettings = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const systemSettingsData = req.body;

    const validation = validateSystemSettingsData(systemSettingsData);

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

    try {
      const result = await updateSystemSettingsService(systemSettingsData);

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(400)
          .json(new apiResponse(400, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getSystemSettings = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    try {
      const result = await getSystemSettingsService();

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(404)
          .json(new apiResponse(404, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

// Bill Settings Controllers
export const editBillSettings = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    const billSettingsData = req.body;

    const validation = validateBillSettingsData(billSettingsData);

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

    try {
      const result = await updateBillSettingsService(billSettingsData);

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(400)
          .json(new apiResponse(400, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

export const getBillSettings = asyncHandler(
  async (req: Request, res: Response): Promise<any> => {
    try {
      const result = await getBillSettingsService();

      if (result.success) {
        return res
          .status(200)
          .json(new apiResponse(200, result.data, result.message));
      } else {
        return res
          .status(404)
          .json(new apiResponse(404, null, result.message));
      }
    } catch (error: any) {
      return res
        .status(500)
        .json(
          new apiResponse(500, null, error.message || "Internal server error")
        );
    }
  }
);

import { RequestHandler } from "express";

class apiError extends Error {
  statusCode: number;
  error: string | object;
  data: any[];
  success: boolean;

  constructor(
    statusCode: number,
    message: string,
    error: string | object,
    stack?: string
  ) {
    super(message);

    this.statusCode = statusCode;
    this.error = error;
    this.data = [];
    this.success = false;

    if (stack) {
      this.stack = stack;
    } else {
      if (typeof (Error as any).captureStackTrace === "function") {
        (Error as any).captureStackTrace(this, this.constructor);
      }
    }
  }
}

class apiResponse {
  statusCode: number;
  data: any;
  message: string;
  status: boolean;

  constructor(statusCode: number, data: any, message: string) {
    this.statusCode = statusCode;
    this.data = data;
    this.message = message;
    this.status = statusCode < 400;
  }
}

const asyncHandler = (requestHandler: RequestHandler) => {
  return (
    req: Parameters<RequestHandler>[0],
    res: Parameters<RequestHandler>[1],
    next: Parameters<RequestHandler>[2]
  ) => {
    Promise.resolve(requestHandler(req, res, next)).catch((err: any) => {
      console.error("AsyncHandler caught error:", err);
      next(err);
    });
  };
};

export { asyncHandler, apiResponse, apiError };

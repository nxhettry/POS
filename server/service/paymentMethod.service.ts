import PaymentMethod from "../models/paymentMethod.models.js";

interface ServiceResponse<T> {
  success: boolean;
  data?: T;
  message: string;
}

export const createPaymentMethodService = async (
  paymentMethodData: any
): Promise<ServiceResponse<any>> => {
  const paymentMethod = await PaymentMethod.create(paymentMethodData);
  return {
    success: true,
    data: paymentMethod,
    message: "Payment method created successfully",
  };
};

export const updatePaymentMethodService = async (
  id: number,
  paymentMethodData: any
): Promise<ServiceResponse<any>> => {
  const paymentMethod = await PaymentMethod.findByPk(id);
  if (!paymentMethod) {
    return {
      success: false,
      message: "Payment method not found",
    };
  }

  await paymentMethod.update(paymentMethodData);
  return {
    success: true,
    data: paymentMethod,
    message: "Payment method updated successfully",
  };
};

export const getPaymentMethodService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const paymentMethod = await PaymentMethod.findByPk(id);
  if (!paymentMethod) {
    return {
      success: false,
      message: "Payment method not found",
    };
  }

  return {
    success: true,
    data: paymentMethod,
    message: "Payment method retrieved successfully",
  };
};

export const getAllPaymentMethodsService = async (): Promise<ServiceResponse<any[]>> => {
  const paymentMethods = await PaymentMethod.findAll({
    order: [["createdAt", "DESC"]],
  });

  return {
    success: true,
    data: paymentMethods,
    message: "Payment methods retrieved successfully",
  };
};

export const getActivePaymentMethodsService = async (): Promise<ServiceResponse<any[]>> => {
  const paymentMethods = await PaymentMethod.findAll({
    where: {
      isActive: true,
    },
    order: [["name", "ASC"]],
  });

  return {
    success: true,
    data: paymentMethods,
    message: "Active payment methods retrieved successfully",
  };
};

export const deletePaymentMethodService = async (
  id: number
): Promise<ServiceResponse<any>> => {
  const paymentMethod = await PaymentMethod.findByPk(id);
  if (!paymentMethod) {
    return {
      success: false,
      message: "Payment method not found",
    };
  }

  await paymentMethod.destroy();
  return {
    success: true,
    data: null,
    message: "Payment method deleted successfully",
  };
};

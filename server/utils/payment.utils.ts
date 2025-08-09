import PaymentMethod from "../models/paymentMethod.models.js";

/**
 * Check if a payment method is cash or online (not credit)
 * @param paymentMethodId - ID of the payment method
 * @returns Promise<boolean> - true if it's cash or online, false if credit or not found
 */
export const isNonCreditPayment = async (
  paymentMethodId: number
): Promise<boolean> => {
  try {
    const paymentMethod = await PaymentMethod.findByPk(paymentMethodId);
    if (!paymentMethod) {
      return false;
    }

    const paymentMethodName = (paymentMethod as any).name.toLowerCase();
    const creditKeywords = ["credit", "due", "unpaid", "pending", "owed"];
    return !creditKeywords.some((keyword) =>
      paymentMethodName.includes(keyword)
    );
  } catch (error) {
    console.error("Error checking payment method:", error);
    return false;
  }
};

export const getPaymentMethodName = async (
  paymentMethodId: number
): Promise<string | null> => {
  try {
    const paymentMethod = await PaymentMethod.findByPk(paymentMethodId);
    return paymentMethod ? (paymentMethod as any).name : null;
  } catch (error) {
    console.error("Error getting payment method name:", error);
    return null;
  }
};

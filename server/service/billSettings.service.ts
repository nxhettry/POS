import BillSettings from "../models/billSettings.models.js";

interface BillSettingsUpdateData {
  includeTax?: boolean;
  includeDiscount?: boolean;
  printCustomerCopy?: boolean;
  printKitchenCopy?: boolean;
  showItemCode?: boolean;
  billFooter?: string;
}

export const updateBillSettingsService = async (
  settingsData: BillSettingsUpdateData
) => {
  try {
    const settings = await BillSettings.findOne();

    if (!settings) {
      const newSettings = await BillSettings.create(settingsData as any);
      return {
        success: true,
        data: newSettings,
        message: "Bill settings created successfully",
      };
    }

    const updatedSettings = await settings.update(settingsData);

    return {
      success: true,
      data: updatedSettings,
      message: "Bill settings updated successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to update bill settings: ${error.message}`);
  }
};

export const getBillSettingsService = async () => {
  try {
    const settings = await BillSettings.findOne();

    if (!settings) {
      return {
        success: false,
        data: null,
        message: "No bill settings found",
      };
    }

    return {
      success: true,
      data: settings,
      message: "Bill settings retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get bill settings: ${error.message}`);
  }
};

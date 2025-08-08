import SystemSettings from "../models/systemSettings.models.js";

interface SystemSettingsUpdateData {
  currency?: string;
  dateFormat?: "YYYY-MM-DD" | "DD-MM-YYYY";
  language?: "en" | "np";
  defaultTaxRate?: number;
  autoBackup?: boolean;
  sessionTimeout?: Date | string;
}

export const updateSystemSettingsService = async (
  settingsData: SystemSettingsUpdateData
) => {
  try {
    const settings = await SystemSettings.findOne();

    if (!settings) {
      const newSettings = await SystemSettings.create(settingsData as any);
      return {
        success: true,
        data: newSettings,
        message: "System settings created successfully",
      };
    }

    const updatedSettings = await settings.update(settingsData);

    return {
      success: true,
      data: updatedSettings,
      message: "System settings updated successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to update system settings: ${error.message}`);
  }
};

export const getSystemSettingsService = async () => {
  try {
    const settings = await SystemSettings.findOne();

    if (!settings) {
      return {
        success: false,
        data: null,
        message: "No system settings found",
      };
    }

    return {
      success: true,
      data: settings,
      message: "System settings retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get system settings: ${error.message}`);
  }
};

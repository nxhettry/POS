import Party from "../models/party.models.js";
import { Op } from "sequelize";

interface PartyUpdateData {
  name?: string;
  type?: "customer" | "supplier";
  address?: string;
  phone?: string;
  email?: string;
  balance?: number;
  isActive?: boolean;
}

interface PartyCreateData {
  name: string;
  type: "customer" | "supplier";
  address: string;
  phone: string;
  email?: string;
  balance?: number;
  isActive?: boolean;
}

const handleUniqueConstraintError = (error: any) => {
  if (error.name === "SequelizeUniqueConstraintError") {
    return {
      success: false,
      data: null,
      message: "A party with this name, phone, or email already exists",
    };
  }
  return null;
};

export const createPartyService = async (partyData: PartyCreateData) => {
  try {
    const whereClause: any = {
      [Op.or]: [{ name: partyData.name }, { phone: partyData.phone }],
    };

    if (partyData.email) {
      whereClause[Op.or].push({ email: partyData.email });
    }

    const existingParty = await Party.findOne({
      where: whereClause,
    });

    if (existingParty) {
      return {
        success: false,
        data: null,
        message: "A party with this name, phone, or email already exists",
      };
    }

    const newParty = await Party.create(partyData as any);
    return {
      success: true,
      data: newParty,
      message: "Party created successfully",
    };
  } catch (error: any) {
    const constraintError = handleUniqueConstraintError(error);
    if (constraintError) return constraintError;
    throw new Error(`Failed to create party: ${error.message}`);
  }
};

export const updatePartyService = async (
  id: number,
  partyData: PartyUpdateData
) => {
  try {
    const party = await Party.findByPk(id);

    if (!party) {
      return {
        success: false,
        data: null,
        message: "Party not found",
      };
    }

    const whereClause: any = {
      id: { [Op.ne]: id },
      [Op.or]: [],
    };

    if (partyData.name && partyData.name !== party.get("name")) {
      whereClause[Op.or].push({ name: partyData.name });
    }

    if (partyData.phone && partyData.phone !== party.get("phone")) {
      whereClause[Op.or].push({ phone: partyData.phone });
    }

    if (partyData.email && partyData.email !== party.get("email")) {
      whereClause[Op.or].push({ email: partyData.email });
    }

    if (whereClause[Op.or].length > 0) {
      const existingParty = await Party.findOne({ where: whereClause });

      if (existingParty) {
        return {
          success: false,
          data: null,
          message: "A party with this name, phone, or email already exists",
        };
      }
    }

    const updatedParty = await party.update(partyData);

    return {
      success: true,
      data: updatedParty,
      message: "Party updated successfully",
    };
  } catch (error: any) {
    const constraintError = handleUniqueConstraintError(error);
    if (constraintError) return constraintError;
    throw new Error(`Failed to update party: ${error.message}`);
  }
};

export const getPartyService = async (id: number) => {
  try {
    const party = await Party.findByPk(id);

    if (!party) {
      return {
        success: false,
        data: null,
        message: "Party not found",
      };
    }

    return {
      success: true,
      data: party,
      message: "Party retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get party: ${error.message}`);
  }
};

export const getAllPartiesService = async () => {
  try {
    const parties = await Party.findAll({
      order: [["id", "ASC"]],
    });

    return {
      success: true,
      data: parties,
      message: "Parties retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get parties: ${error.message}`);
  }
};

export const getPartiesByTypeService = async (
  type: "customer" | "supplier"
) => {
  try {
    const parties = await Party.findAll({
      where: { type },
      order: [["id", "ASC"]],
    });

    return {
      success: true,
      data: parties,
      message: "Parties retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get parties by type: ${error.message}`);
  }
};

export const getActivePartiesService = async () => {
  try {
    const parties = await Party.findAll({
      where: { isActive: true },
      order: [["id", "ASC"]],
    });

    return {
      success: true,
      data: parties,
      message: "Active parties retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get active parties: ${error.message}`);
  }
};

export const deletePartyService = async (id: number) => {
  try {
    const party = await Party.findByPk(id);

    if (!party) {
      return {
        success: false,
        data: null,
        message: "Party not found",
      };
    }

    await party.destroy();

    return {
      success: true,
      data: null,
      message: "Party deleted successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to delete party: ${error.message}`);
  }
};

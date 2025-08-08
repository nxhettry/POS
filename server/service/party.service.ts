import Party from "../models/party.models.js";
import PartyTransaction from "../models/partyTransaction.js";

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

export const createPartyService = async (partyData: PartyCreateData) => {
  const newParty = await Party.create(partyData as any);
  return {
    success: true,
    data: newParty,
    message: "Party created successfully"
  };
};

export const updatePartyService = async (id: number, partyData: PartyUpdateData) => {
  const party = await Party.findByPk(id);
  
  if (!party) {
    return {
      success: false,
      data: null,
      message: "Party not found"
    };
  }

  const updatedParty = await party.update(partyData);
  
  return {
    success: true,
    data: updatedParty,
    message: "Party updated successfully"
  };
};

export const getPartyService = async (id: number) => {
  const party = await Party.findByPk(id);
  
  if (!party) {
    return {
      success: false,
      data: null,
      message: "Party not found"
    };
  }

  return {
    success: true,
    data: party,
    message: "Party retrieved successfully"
  };
};

export const getAllPartiesService = async () => {
  const parties = await Party.findAll({
    order: [['id', 'ASC']]
  });

  return {
    success: true,
    data: parties,
    message: "Parties retrieved successfully"
  };
};

export const getPartiesByTypeService = async (type: "customer" | "supplier") => {
  const parties = await Party.findAll({
    where: { type },
    order: [['id', 'ASC']]
  });

  return {
    success: true,
    data: parties,
    message: "Parties retrieved successfully"
  };
};

export const getActivePartiesService = async () => {
  const parties = await Party.findAll({
    where: { isActive: true },
    order: [['id', 'ASC']]
  });

  return {
    success: true,
    data: parties,
    message: "Active parties retrieved successfully"
  };
};

export const deletePartyService = async (id: number) => {
  const party = await Party.findByPk(id);
  
  if (!party) {
    return {
      success: false,
      data: null,
      message: "Party not found"
    };
  }

  await party.destroy();
  
  return {
    success: true,
    data: null,
    message: "Party deleted successfully"
  };
};

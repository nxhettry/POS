import StockMovement from "../models/stockMovement.js";
import InventoryItem from "../models/inventoryItem.models.js";
import User from "../models/user.models.js";

interface StockMovementUpdateData {
  inventoryItemId?: number;
  type?: string;
  quantity?: number;
  unitCost?: number;
  reference?: string;
  notes?: string;
  createdBy?: number;
}

interface StockMovementCreateData {
  inventoryItemId: number;
  type: string;
  quantity: number;
  unitCost: number;
  reference?: string;
  notes?: string;
  createdBy?: number;
}

export const createStockMovementService = async (movementData: StockMovementCreateData) => {
  try {
    const newMovement = await StockMovement.create(movementData as any);
    
    const inventoryItem = await InventoryItem.findByPk(movementData.inventoryItemId);
    if (inventoryItem) {
      const currentStock = parseFloat(inventoryItem.get('currentStock') as string) || 0;
      let newStock = currentStock;
      
      if (movementData.type.toLowerCase().includes('in') || movementData.type.toLowerCase().includes('purchase')) {
        newStock += movementData.quantity;
      } else if (movementData.type.toLowerCase().includes('out') || movementData.type.toLowerCase().includes('sale')) {
        newStock -= movementData.quantity;
      }
      
      await inventoryItem.update({
        currentStock: Math.max(0, newStock),
        lastStockUpdate: new Date()
      });
    }
    
    return {
      success: true,
      data: newMovement,
      message: "Stock movement created successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to create stock movement: ${error.message}`);
  }
};

export const updateStockMovementService = async (id: number, movementData: StockMovementUpdateData) => {
  try {
    const movement = await StockMovement.findByPk(id);
    
    if (!movement) {
      return {
        success: false,
        data: null,
        message: "Stock movement not found"
      };
    }

    const updatedMovement = await movement.update(movementData);
    
    return {
      success: true,
      data: updatedMovement,
      message: "Stock movement updated successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to update stock movement: ${error.message}`);
  }
};

export const getStockMovementService = async (id: number) => {
  try {
    const movement = await StockMovement.findByPk(id, {
      include: [InventoryItem, User]
    });
    
    if (!movement) {
      return {
        success: false,
        data: null,
        message: "Stock movement not found"
      };
    }

    return {
      success: true,
      data: movement,
      message: "Stock movement retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get stock movement: ${error.message}`);
  }
};

export const getAllStockMovementsService = async () => {
  try {
    const movements = await StockMovement.findAll({
      include: [InventoryItem, User],
      order: [['id', 'DESC']]
    });

    return {
      success: true,
      data: movements,
      message: "Stock movements retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get stock movements: ${error.message}`);
  }
};

export const getStockMovementsByItemService = async (inventoryItemId: number) => {
  try {
    const movements = await StockMovement.findAll({
      where: { inventoryItemId },
      include: [InventoryItem, User],
      order: [['id', 'DESC']]
    });

    return {
      success: true,
      data: movements,
      message: "Stock movements retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get stock movements by item: ${error.message}`);
  }
};

export const deleteStockMovementService = async (id: number) => {
  try {
    const movement = await StockMovement.findByPk(id);
    
    if (!movement) {
      return {
        success: false,
        data: null,
        message: "Stock movement not found"
      };
    }

    await movement.destroy();
    
    return {
      success: true,
      data: null,
      message: "Stock movement deleted successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to delete stock movement: ${error.message}`);
  }
};

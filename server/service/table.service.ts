import Table from "../models/table.model.js";

interface TableUpdateData {
  name?: string;
  status?: "available" | "occupied" | "reserved";
}

interface TableCreateData {
  name: string;
  status?: "available" | "occupied" | "reserved";
}

export const createTableService = async (tableData: TableCreateData) => {
  try {
    const existingTable = await Table.findOne({
      where: { name: tableData.name }
    });

    if (existingTable) {
      return {
        success: false,
        data: null,
        message: "A table with this name already exists"
      };
    }

    const newTable = await Table.create(tableData as any);
    return {
      success: true,
      data: newTable,
      message: "Table created successfully"
    };
  } catch (error: any) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      return {
        success: false,
        data: null,
        message: "A table with this name already exists"
      };
    }
    throw new Error(`Failed to create table: ${error.message}`);
  }
};

export const updateTableService = async (id: number, tableData: TableUpdateData) => {
  try {
    const table = await Table.findByPk(id);
    
    if (!table) {
      return {
        success: false,
        data: null,
        message: "Table not found"
      };
    }

    if (tableData.name && tableData.name !== table.get('name')) {
      const existingTable = await Table.findOne({
        where: { name: tableData.name }
      });

      if (existingTable) {
        return {
          success: false,
          data: null,
          message: "A table with this name already exists"
        };
      }
    }

    const updatedTable = await table.update(tableData);
    
    return {
      success: true,
      data: updatedTable,
      message: "Table updated successfully"
    };
  } catch (error: any) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      return {
        success: false,
        data: null,
        message: "A table with this name already exists"
      };
    }
    throw new Error(`Failed to update table: ${error.message}`);
  }
};

export const getTableService = async (id: number) => {
  try {
    const table = await Table.findByPk(id);
    
    if (!table) {
      return {
        success: false,
        data: null,
        message: "Table not found"
      };
    }

    return {
      success: true,
      data: table,
      message: "Table retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get table: ${error.message}`);
  }
};

export const getAllTablesService = async () => {
  try {
    const tables = await Table.findAll({
      order: [['id', 'ASC']]
    });

    return {
      success: true,
      data: tables,
      message: "Tables retrieved successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to get tables: ${error.message}`);
  }
};

export const deleteTableService = async (id: number) => {
  try {
    const table = await Table.findByPk(id);
    
    if (!table) {
      return {
        success: false,
        data: null,
        message: "Table not found"
      };
    }

    await table.destroy();
    
    return {
      success: true,
      data: null,
      message: "Table deleted successfully"
    };
  } catch (error: any) {
    throw new Error(`Failed to delete table: ${error.message}`);
  }
};

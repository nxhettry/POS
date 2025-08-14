-- Migration to allow NULL values for invoiceNo in sales table
-- This changes the invoiceNo column to allow NULL values

-- SQLite doesn't support direct ALTER COLUMN modifications
-- We need to recreate the table with the new schema

-- Step 1: Create a temporary table with the new schema
CREATE TABLE sales_temp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoiceNo TEXT UNIQUE, -- Removed NOT NULL constraint
    tableId INTEGER,
    orderType TEXT NOT NULL,
    orderStatus TEXT NOT NULL,
    paymentStatus TEXT NOT NULL,
    paymentMethodId INTEGER,
    subTotal DECIMAL,
    tax DECIMAL,
    total DECIMAL,
    partyId INTEGER,
    createdBy INTEGER,
    signedBy INTEGER,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tableId) REFERENCES tables (id),
    FOREIGN KEY (paymentMethodId) REFERENCES paymentmethods (id),
    FOREIGN KEY (partyId) REFERENCES parties (id),
    FOREIGN KEY (createdBy) REFERENCES users (id),
    FOREIGN KEY (signedBy) REFERENCES users (id)
);

-- Step 2: Copy data from original table to temporary table
INSERT INTO sales_temp SELECT * FROM sales;

-- Step 3: Drop the original table
DROP TABLE sales;

-- Step 4: Rename temporary table to original name
ALTER TABLE sales_temp RENAME TO sales;

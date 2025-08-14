-- Migration to remove invoiceNo column from sales table
-- This removes the invoiceNo column since we'll use sales ID as invoice number

-- SQLite doesn't support dropping columns directly
-- We need to recreate the table without the invoiceNo column

-- Step 1: Create a new temporary table without invoiceNo column
CREATE TABLE sales_temp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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

-- Step 2: Copy data from original table to temporary table (excluding invoiceNo)
INSERT INTO sales_temp (
    id, tableId, orderType, orderStatus, paymentStatus, 
    paymentMethodId, subTotal, tax, total, partyId, 
    createdBy, signedBy, createdAt, updatedAt
) 
SELECT 
    id, tableId, orderType, orderStatus, paymentStatus, 
    paymentMethodId, subTotal, tax, total, partyId, 
    createdBy, signedBy, createdAt, updatedAt 
FROM sales;

-- Step 3: Drop the original table
DROP TABLE sales;

-- Step 4: Rename temporary table to original name
ALTER TABLE sales_temp RENAME TO sales;

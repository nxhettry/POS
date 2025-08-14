-- Drop the existing sales table with incorrect foreign key constraints
DROP TABLE IF EXISTS sales;

-- Recreate the sales table with correct foreign key references
CREATE TABLE sales (
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
    FOREIGN KEY (paymentMethodId) REFERENCES payment_methods (id),
    FOREIGN KEY (partyId) REFERENCES parties (id),
    FOREIGN KEY (createdBy) REFERENCES users (id),
    FOREIGN KEY (signedBy) REFERENCES users (id)
);

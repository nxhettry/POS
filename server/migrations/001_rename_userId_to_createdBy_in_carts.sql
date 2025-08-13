-- Migration to rename userId to createdBy in carts table
-- This will preserve the existing data while updating the column name

ALTER TABLE carts RENAME COLUMN userId TO createdBy;

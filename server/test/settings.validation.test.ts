// Import the validators for testing
import { validateSystemSettingsData } from "../validators/systemSettings.validator.js";
import { validateBillSettingsData } from "../validators/billSettings.validator.js";

// System Settings Tests
console.log("=== SYSTEM SETTINGS VALIDATION TESTS ===");

// Test 1: Valid system settings data
console.log("\n1. Testing valid system settings data:");
const validSystemData = {
  currency: "USD",
  dateFormat: "YYYY-MM-DD" as const,
  language: "en" as const,
  defaultTaxRate: 13.0,
  autoBackup: true,
  sessionTimeout: "2025-01-01T12:00:00Z"
};

const systemResult1 = validateSystemSettingsData(validSystemData);
console.log("Result:", systemResult1);

// Test 2: Invalid system settings data
console.log("\n2. Testing invalid system settings data:");
const invalidSystemData = {
  currency: "",
  dateFormat: "INVALID_FORMAT" as any,
  language: "fr" as any,
  defaultTaxRate: 150,
  autoBackup: "yes" as any,
  sessionTimeout: "invalid-date"
};

const systemResult2 = validateSystemSettingsData(invalidSystemData);
console.log("Result:", systemResult2);

// Test 3: Partial system settings update
console.log("\n3. Testing partial system settings update:");
const partialSystemData = {
  currency: "NPR",
  defaultTaxRate: 10.5
};

const systemResult3 = validateSystemSettingsData(partialSystemData);
console.log("Result:", systemResult3);

console.log("\n=== BILL SETTINGS VALIDATION TESTS ===");

// Test 4: Valid bill settings data
console.log("\n4. Testing valid bill settings data:");
const validBillData = {
  includeTax: true,
  includeDiscount: false,
  printCustomerCopy: true,
  printKitchenCopy: false,
  showItemCode: true,
  billFooter: "Thank you for your visit!"
};

const billResult1 = validateBillSettingsData(validBillData);
console.log("Result:", billResult1);

// Test 5: Invalid bill settings data
console.log("\n5. Testing invalid bill settings data:");
const invalidBillData = {
  includeTax: "yes" as any,
  includeDiscount: 1 as any,
  printCustomerCopy: "true" as any,
  printKitchenCopy: null as any,
  showItemCode: undefined as any,
  billFooter: "A".repeat(600) // Too long
};

const billResult2 = validateBillSettingsData(invalidBillData);
console.log("Result:", billResult2);

// Test 6: Partial bill settings update
console.log("\n6. Testing partial bill settings update:");
const partialBillData = {
  printKitchenCopy: true,
  billFooter: "धन्यवाद!"
};

const billResult3 = validateBillSettingsData(partialBillData);
console.log("Result:", billResult3);

console.log("\n=== EDGE CASES ===");

// Test 7: Empty objects
console.log("\n7. Testing empty objects:");
const emptySystemData = {};
const emptyBillData = {};

const systemEmptyResult = validateSystemSettingsData(emptySystemData);
const billEmptyResult = validateBillSettingsData(emptyBillData);

console.log("Empty system settings result:", systemEmptyResult);
console.log("Empty bill settings result:", billEmptyResult);

// Test 8: Null and undefined values
console.log("\n8. Testing null and undefined values:");
const nullSystemData = {
  currency: null as any,
  sessionTimeout: null as any
};

const undefinedBillData = {
  includeTax: undefined,
  billFooter: undefined
};

const systemNullResult = validateSystemSettingsData(nullSystemData as any);
const billUndefinedResult = validateBillSettingsData(undefinedBillData);

console.log("Null system settings result:", systemNullResult);
console.log("Undefined bill settings result:", billUndefinedResult);

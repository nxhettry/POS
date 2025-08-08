import { body, validationResult } from 'express-validator';
import { Request, Response, NextFunction } from 'express';
import { apiResponse } from '../utils/api.js';
import { sanitizeInput } from '../utils/security.js';

/**
 * Handle validation errors
 */
export const handleValidationErrors = (req: Request, res: Response, next: NextFunction): any => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => {
      if (error.type === 'field') {
        return `${error.path}: ${error.msg}`;
      }
      return error.msg;
    });
    return res.status(400).json(
      new apiResponse(400, null, `Validation failed: ${errorMessages.join(', ')}`)
    );
  }
  
  next();
};

/**
 * Sanitize input middleware
 */
export const sanitizeInputs = (req: Request, res: Response, next: NextFunction): void => {
  if (req.body) {
    for (const key in req.body) {
      if (typeof req.body[key] === 'string') {
        req.body[key] = sanitizeInput(req.body[key]);
      }
    }
  }
  
  if (req.query) {
    for (const key in req.query) {
      if (typeof req.query[key] === 'string') {
        req.query[key] = sanitizeInput(req.query[key] as string);
      }
    }
  }
  
  next();
};

/**
 * User registration validation
 */
export const validateUserRegistration = [
  body('username')
    .isLength({ min: 3, max: 50 })
    .withMessage('Username must be between 3 and 50 characters')
    .matches(/^[a-zA-Z0-9_.-]+$/)
    .withMessage('Username can only contain letters, numbers, dots, hyphens, and underscores'),
  
  body('password')
    .isLength({ min: 8, max: 128 })
    .withMessage('Password must be between 8 and 128 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),
  
  body('role')
    .isIn(['admin', 'waiter', 'cashier'])
    .withMessage('Role must be admin, waiter, or cashier'),
  
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Must be a valid email address'),
  
  body('phone')
    .optional()
    .matches(/^\+?[\d\s\-()]+$/)
    .withMessage('Must be a valid phone number'),
    
  handleValidationErrors
];

/**
 * User login validation
 */
export const validateUserLogin = [
  body('username')
    .notEmpty()
    .withMessage('Username is required')
    .isLength({ max: 50 })
    .withMessage('Username too long'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required')
    .isLength({ max: 128 })
    .withMessage('Password too long'),
    
  handleValidationErrors
];

/**
 * Password change validation
 */
export const validatePasswordChange = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  
  body('newPassword')
    .isLength({ min: 8, max: 128 })
    .withMessage('New password must be between 8 and 128 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('New password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),
    
  handleValidationErrors
];

/**
 * User update validation
 */
export const validateUserUpdate = [
  body('username')
    .optional()
    .isLength({ min: 3, max: 50 })
    .withMessage('Username must be between 3 and 50 characters')
    .matches(/^[a-zA-Z0-9_.-]+$/)
    .withMessage('Username can only contain letters, numbers, dots, hyphens, and underscores'),
  
  body('role')
    .optional()
    .isIn(['admin', 'waiter', 'cashier'])
    .withMessage('Role must be admin, waiter, or cashier'),
  
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Must be a valid email address'),
  
  body('phone')
    .optional()
    .matches(/^\+?[\d\s\-()]+$/)
    .withMessage('Must be a valid phone number'),
    
  handleValidationErrors
];

/**
 * Menu item validation
 */
export const validateMenuItem = [
  body('name')
    .isLength({ min: 1, max: 100 })
    .withMessage('Menu item name must be between 1 and 100 characters'),
  
  body('price')
    .isFloat({ min: 0 })
    .withMessage('Price must be a positive number'),
  
  body('categoryId')
    .isInt({ min: 1 })
    .withMessage('Category ID must be a valid positive integer'),
    
  handleValidationErrors
];

/**
 * Generic ID parameter validation
 */
export const validateIdParam = [
  body('id')
    .optional()
    .isInt({ min: 1 })
    .withMessage('ID must be a positive integer'),
    
  handleValidationErrors
];

/**
 * Amount validation (for expenses, sales, etc.)
 */
export const validateAmount = [
  body('amount')
    .isFloat({ min: 0 })
    .withMessage('Amount must be a positive number'),
    
  handleValidationErrors
];

/**
 * Date range validation
 */
export const validateDateRange = [
  body('startDate')
    .optional()
    .isISO8601()
    .toDate()
    .withMessage('Start date must be a valid date'),
  
  body('endDate')
    .optional()
    .isISO8601()
    .toDate()
    .withMessage('End date must be a valid date'),
    
  handleValidationErrors
];

/**
 * Party validation (customers/suppliers)
 */
export const validateParty = [
  body('name')
    .isLength({ min: 1, max: 100 })
    .withMessage('Party name must be between 1 and 100 characters'),
  
  body('type')
    .isIn(['customer', 'supplier'])
    .withMessage('Party type must be customer or supplier'),
  
  body('phone')
    .matches(/^\+?[\d\s\-()]+$/)
    .withMessage('Must be a valid phone number'),
  
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Must be a valid email address'),
    
  handleValidationErrors
];

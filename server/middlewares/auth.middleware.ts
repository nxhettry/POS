import { Request, Response, NextFunction } from 'express';
import { verifyToken, getClientIP } from '../utils/security.js';
import { apiResponse } from '../utils/api.js';

// Extend Request interface to include user
interface AuthenticatedRequest extends Request {
  user?: {
    userId: number;
    username: string;
    role: string;
  };
}

/**
 * Authentication middleware to verify JWT tokens
 */
export const authenticate = (req: AuthenticatedRequest, res: Response, next: NextFunction): any => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json(
        new apiResponse(401, null, 'Access token is required')
      );
    }

    const token = authHeader.split(' ')[1]; 
    if (!token) {
      return res.status(401).json(
        new apiResponse(401, null, 'Invalid authorization header format')
      );
    }

    const decoded = verifyToken(token);
    
    if (!decoded) {
      return res.status(401).json(
        new apiResponse(401, null, 'Invalid or expired token')
      );
    }

    // Add user info to request object
    req.user = {
      userId: decoded.userId,
      username: decoded.username,
      role: decoded.role
    };

    next();
  } catch (error) {
    return res.status(401).json(
      new apiResponse(401, null, 'Authentication failed')
    );
  }
};

/**
 * Authorization middleware for role-based access control
 */
export const authorize = (...allowedRoles: string[]) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction): any => {
    try {
      if (!req.user) {
        return res.status(401).json(
          new apiResponse(401, null, 'Authentication required')
        );
      }

      if (!allowedRoles.includes(req.user.role)) {
        return res.status(403).json(
          new apiResponse(403, null, 'Insufficient permissions')
        );
      }

      next();
    } catch (error) {
      return res.status(403).json(
        new apiResponse(403, null, 'Authorization failed')
      );
    }
  };
};

/**
 * Middleware to ensure user can only access their own data
 */
export const ensureOwnership = (userIdParam: string = 'id') => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction): any => {
    try {
      if (!req.user) {
        return res.status(401).json(
          new apiResponse(401, null, 'Authentication required')
        );
      }

      const requestedUserId = parseInt(req.params[userIdParam]);
      
      // Admin can access all data
      if (req.user.role === 'admin') {
        return next();
      }

      // User can only access their own data
      if (req.user.userId !== requestedUserId) {
        return res.status(403).json(
          new apiResponse(403, null, 'Access denied: You can only access your own data')
        );
      }

      next();
    } catch (error) {
      return res.status(403).json(
        new apiResponse(403, null, 'Ownership verification failed')
      );
    }
  };
};

/**
 * Security headers middleware
 */
export const securityHeaders = (req: Request, res: Response, next: NextFunction): void => {
  // Remove server information
  res.removeHeader('X-Powered-By');
  
  // Security headers
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  
  // HTTPS enforcement in production
  if (process.env.NODE_ENV === 'production') {
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  }
  
  next();
};

/**
 * Request logging middleware for security auditing
 */
export const auditLog = (req: Request, res: Response, next: NextFunction): void => {
  const timestamp = new Date().toISOString();
  const ip = getClientIP(req);
  const method = req.method;
  const url = req.originalUrl;
  const userAgent = req.headers['user-agent'] || 'unknown';
  
  // Log security-relevant requests
  const securityEndpoints = ['/auth/', '/login', '/register', '/password'];
  const isSecurityRequest = securityEndpoints.some(endpoint => url.includes(endpoint));
  
  if (isSecurityRequest) {
    console.log(`[SECURITY] ${timestamp} - ${ip} - ${method} ${url} - ${userAgent}`);
  }
  
  next();
};

// Export the extended Request type for use in other files
export type { AuthenticatedRequest };

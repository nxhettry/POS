import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { Request } from 'express';

interface JWTPayload {
  userId: number;
  username: string;
  role: string;
}

interface TokenResponse {
  accessToken: string;
  refreshToken: string;
}

/**
 * Hash password using bcrypt
 */
export const hashPassword = async (password: string): Promise<string> => {
  const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '12');
  return await bcrypt.hash(password, saltRounds);
};

/**
 * Compare password with hash
 */
export const comparePassword = async (password: string, hash: string): Promise<boolean> => {
  return await bcrypt.compare(password, hash);
};

/**
 * Generate JWT tokens (access and refresh)
 */
export const generateTokens = (payload: JWTPayload): TokenResponse => {
  const jwtSecret = process.env.JWT_SECRET;
  if (!jwtSecret) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }

  const accessToken = jwt.sign(
    payload,
    jwtSecret,
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '8h', // Set to 8 hours by default
      issuer: 'ratopos-api',
      audience: 'ratopos-client'
    } as jwt.SignOptions
  );

  const refreshToken = jwt.sign(
    { userId: payload.userId },
    jwtSecret,
    {
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
      issuer: 'ratopos-api',
      audience: 'ratopos-client'
    } as jwt.SignOptions
  );

  return { accessToken, refreshToken };
};

/**
 * Verify JWT token
 */
export const verifyToken = (token: string): JWTPayload | null => {
  try {
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      throw new Error('JWT_SECRET is not defined');
    }

    const decoded = jwt.verify(token, jwtSecret, {
      issuer: 'ratopos-api',
      audience: 'ratopos-client'
    }) as JWTPayload;

    return decoded;
  } catch (error) {
    return null;
  }
};

/**
 * Generate secure random string
 */
export const generateSecureRandom = (length: number = 32): string => {
  return crypto.randomBytes(length).toString('hex');
};

/**
 * Sanitize user input to prevent XSS
 */
export const sanitizeInput = (input: string): string => {
  if (typeof input !== 'string') return '';
  
  return input
    .replace(/[<>]/g, '') // Remove < and > to prevent basic XSS
    .trim()
    .slice(0, 1000); // Limit length
};

/**
 * Extract IP address from request
 */
export const getClientIP = (req: Request): string => {
  const forwarded = req.headers['x-forwarded-for'];
  const ip = forwarded 
    ? (typeof forwarded === 'string' ? forwarded.split(',')[0] : forwarded[0])
    : req.connection.remoteAddress || req.socket.remoteAddress;
  
  return ip || 'unknown';
};

/**
 * Extract device info from request
 */
export const getDeviceInfo = (req: Request): string => {
  const userAgent = req.headers['user-agent'] || 'unknown';
  return sanitizeInput(userAgent);
};

/**
 * Validate password strength
 */
export const validatePasswordStrength = (password: string): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];
  
  if (password.length < 8) {
    errors.push('Password must be at least 8 characters long');
  }
  
  if (!/(?=.*[a-z])/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }
  
  if (!/(?=.*[A-Z])/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }
  
  if (!/(?=.*\d)/.test(password)) {
    errors.push('Password must contain at least one number');
  }
  
  if (!/(?=.*[@$!%*?&])/.test(password)) {
    errors.push('Password must contain at least one special character (@$!%*?&)');
  }
  
  if (password.length > 128) {
    errors.push('Password cannot exceed 128 characters');
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
};

/**
 * Rate limiting key generator
 */
export const generateRateLimitKey = (req: Request, identifier: string = 'global'): string => {
  const ip = getClientIP(req);
  return `${identifier}:${ip}`;
};

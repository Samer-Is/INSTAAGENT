import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { createError } from './errorHandler';
import { logger } from '../utils/logger';

export interface AdminAuthRequest extends Request {
  admin?: {
    username: string;
    iat: number;
    exp: number;
  };
}

export const authenticateAdmin = (req: AdminAuthRequest, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw createError('Access token is required', 401);
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    const jwtSecret = process.env.JWT_SECRET;

    if (!jwtSecret) {
      logger.error('JWT_SECRET environment variable is not set');
      throw createError('Server configuration error', 500);
    }

    const decoded = jwt.verify(token, jwtSecret) as any;
    
    // Verify this is an admin token
    if (decoded.role !== 'admin') {
      throw createError('Invalid token: insufficient permissions', 403);
    }

    req.admin = decoded;
    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      next(createError('Invalid token', 401));
    } else if (error instanceof jwt.TokenExpiredError) {
      next(createError('Token expired', 401));
    } else {
      next(error);
    }
  }
}; 
import { Router, Request, Response } from 'express';
import Joi from 'joi';
import { adminService } from '../services/adminService';
import { authenticateAdmin, AdminAuthRequest } from '../middleware/auth';
import { asyncHandler, createError } from '../middleware/errorHandler';
import { LoginRequest, CreateWhitelistRequest } from '../types';

const router = Router();

// Validation schemas
const loginSchema = Joi.object({
  username: Joi.string().required().min(3).max(50),
  password: Joi.string().required().min(6).max(100)
});

const createWhitelistSchema = Joi.object({
  pageId: Joi.string().required().min(1).max(100),
  merchantName: Joi.string().required().min(1).max(200)
});

// Admin login endpoint
router.post('/login', asyncHandler(async (req: Request, res: Response) => {
  // Validate request body
  const { error, value } = loginSchema.validate(req.body);
  if (error) {
    throw createError(`Validation error: ${error.details[0]?.message}`, 400);
  }

  const credentials: LoginRequest = value;
  const result = await adminService.login(credentials);

  res.json({
    success: true,
    data: result,
    message: 'Login successful'
  });
}));

// Get all whitelist entries (protected)
router.get('/whitelist', authenticateAdmin, asyncHandler(async (req: AdminAuthRequest, res: Response) => {
  const whitelist = await adminService.getWhitelist();

  res.json({
    success: true,
    data: whitelist,
    message: `Retrieved ${whitelist.length} whitelist entries`
  });
}));

// Add new entry to whitelist (protected)
router.post('/whitelist', authenticateAdmin, asyncHandler(async (req: AdminAuthRequest, res: Response) => {
  // Validate request body
  const { error, value } = createWhitelistSchema.validate(req.body);
  if (error) {
    throw createError(`Validation error: ${error.details[0]?.message}`, 400);
  }

  const data: CreateWhitelistRequest = value;
  const newEntry = await adminService.addToWhitelist(data);

  res.status(201).json({
    success: true,
    data: newEntry,
    message: 'Merchant added to whitelist successfully'
  });
}));

// Remove entry from whitelist (protected)
router.delete('/whitelist/:id', authenticateAdmin, asyncHandler(async (req: AdminAuthRequest, res: Response) => {
  const { id } = req.params;

  if (!id) {
    throw createError('ID parameter is required', 400);
  }

  await adminService.removeFromWhitelist(id);

  res.json({
    success: true,
    message: 'Merchant removed from whitelist successfully'
  });
}));

// Check if page is whitelisted (protected)
router.get('/whitelist/check/:pageId', authenticateAdmin, asyncHandler(async (req: AdminAuthRequest, res: Response) => {
  const { pageId } = req.params;

  if (!pageId) {
    throw createError('Page ID parameter is required', 400);
  }

  const isWhitelisted = await adminService.isPageWhitelisted(pageId);

  res.json({
    success: true,
    data: { 
      pageId, 
      isWhitelisted 
    },
    message: isWhitelisted ? 'Page is whitelisted' : 'Page is not whitelisted'
  });
}));

// Admin profile endpoint (protected)
router.get('/profile', authenticateAdmin, asyncHandler(async (req: AdminAuthRequest, res: Response) => {
  res.json({
    success: true,
    data: {
      username: req.admin?.username,
      role: 'admin',
      loginTime: new Date((req.admin?.iat || 0) * 1000).toISOString(),
      expiresAt: new Date((req.admin?.exp || 0) * 1000).toISOString()
    },
    message: 'Admin profile retrieved successfully'
  });
}));

export { router as adminRoutes }; 
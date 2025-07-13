import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { getWhitelistContainer } from '../config/database';
import { WhitelistEntry, LoginRequest, LoginResponse, CreateWhitelistRequest } from '../types';
import { createError } from '../middleware/errorHandler';
import { logger } from '../utils/logger';

export class AdminService {
  private readonly JWT_EXPIRES_IN = '7d'; // 7 days for admin sessions

  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const { username, password } = credentials;

    // Get admin credentials from environment variables
    const adminUsername = process.env.ADMIN_USERNAME;
    const adminPassword = process.env.ADMIN_PASSWORD;
    const jwtSecret = process.env.JWT_SECRET;

    if (!adminUsername || !adminPassword) {
      logger.error('Admin credentials not configured in environment variables');
      throw createError('Server configuration error', 500);
    }

    if (!jwtSecret) {
      logger.error('JWT_SECRET not configured in environment variables');
      throw createError('Server configuration error', 500);
    }

    // Verify username
    if (username !== adminUsername) {
      logger.warn(`Failed login attempt with username: ${username}`);
      throw createError('Invalid credentials', 401);
    }

    // Verify password using bcrypt
    const isValidPassword = await bcrypt.compare(password, adminPassword);
    if (!isValidPassword) {
      logger.warn(`Failed login attempt for admin user: ${username}`);
      throw createError('Invalid credentials', 401);
    }

    // Generate JWT token
    const token = jwt.sign(
      { 
        username: adminUsername,
        role: 'admin'
      },
      jwtSecret,
      { expiresIn: this.JWT_EXPIRES_IN }
    );

    logger.info(`Admin user ${username} logged in successfully`);

    return {
      token,
      expiresIn: 7 * 24 * 60 * 60 // 7 days in seconds
    };
  }

  async getWhitelist(): Promise<WhitelistEntry[]> {
    try {
      const container = getWhitelistContainer();
      const { resources } = await container.items.readAll<WhitelistEntry>().fetchAll();
      
      logger.info(`Retrieved ${resources.length} whitelist entries`);
      return resources;
    } catch (error) {
      logger.error('Failed to fetch whitelist:', error);
      throw createError('Failed to fetch whitelist', 500);
    }
  }

  async addToWhitelist(data: CreateWhitelistRequest): Promise<WhitelistEntry> {
    const { pageId, merchantName } = data;

    try {
      const container = getWhitelistContainer();
      
      // Check if pageId already exists
      const existingQuery = container.items.query({
        query: 'SELECT * FROM c WHERE c.pageId = @pageId',
        parameters: [{ name: '@pageId', value: pageId }]
      });
      
      const { resources: existing } = await existingQuery.fetchAll();
      
      if (existing.length > 0) {
        throw createError('Page ID already exists in whitelist', 409);
      }

      // Create new whitelist entry
      const newEntry: WhitelistEntry = {
        id: uuidv4(),
        pageId,
        merchantName,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };

      const { resource } = await container.items.create(newEntry);
      
      if (!resource) {
        throw createError('Failed to create whitelist entry', 500);
      }

      logger.info(`Added new merchant to whitelist: ${merchantName} (${pageId})`);
      return resource;
    } catch (error) {
      if (error instanceof Error && error.message.includes('already exists')) {
        throw error;
      }
      logger.error('Failed to add to whitelist:', error);
      throw createError('Failed to add to whitelist', 500);
    }
  }

  async removeFromWhitelist(id: string): Promise<void> {
    try {
      const container = getWhitelistContainer();
      
      // First, get the item to check if it exists and get partition key
      const { resource: item } = await container.item(id, id).read<WhitelistEntry>();
      
      if (!item) {
        throw createError('Whitelist entry not found', 404);
      }

      // Delete the item
      await container.item(id, id).delete();
      
      logger.info(`Removed merchant from whitelist: ${item.merchantName} (${item.pageId})`);
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw createError('Whitelist entry not found', 404);
      }
      logger.error('Failed to remove from whitelist:', error);
      throw createError('Failed to remove from whitelist', 500);
    }
  }

  async isPageWhitelisted(pageId: string): Promise<boolean> {
    try {
      const container = getWhitelistContainer();
      const query = container.items.query({
        query: 'SELECT * FROM c WHERE c.pageId = @pageId',
        parameters: [{ name: '@pageId', value: pageId }]
      });
      
      const { resources } = await query.fetchAll();
      return resources.length > 0;
    } catch (error) {
      logger.error('Failed to check whitelist:', error);
      throw createError('Failed to check whitelist', 500);
    }
  }
}

export const adminService = new AdminService(); 
import { CosmosClient, Database, Container } from '@azure/cosmos';
import { logger } from '../utils/logger';

class DatabaseManager {
  private client: CosmosClient;
  private database: Database;
  
  constructor() {
    const endpoint = process.env.COSMOS_DB_ENDPOINT;
    const key = process.env.COSMOS_DB_KEY;
    const databaseId = process.env.COSMOS_DB_DATABASE_ID || 'insta-ai-agent';

    if (!endpoint || !key) {
      throw new Error('Cosmos DB configuration is missing. Please check COSMOS_DB_ENDPOINT and COSMOS_DB_KEY environment variables.');
    }

    this.client = new CosmosClient({ endpoint, key });
    this.database = this.client.database(databaseId);
    
    logger.info('Cosmos DB client initialized');
  }

  getContainer(containerId: string): Container {
    return this.database.container(containerId);
  }

  async ensureContainers(): Promise<void> {
    const containers = [
      { id: 'whitelist', partitionKey: '/id' },
      { id: 'merchants', partitionKey: '/pageId' },
      { id: 'orders', partitionKey: '/merchantId' },
      { id: 'conversations', partitionKey: '/pageId' },
      { id: 'knowledge-base', partitionKey: '/merchantId' }
    ];

    for (const containerConfig of containers) {
      try {
        const { container } = await this.database.containers.createIfNotExists({
          id: containerConfig.id,
          partitionKey: containerConfig.partitionKey
        });
        logger.info(`Container "${containerConfig.id}" is ready`);
      } catch (error) {
        logger.error(`Failed to create container "${containerConfig.id}":`, error);
        throw error;
      }
    }
  }
}

export const dbManager = new DatabaseManager();

// Container getters for easy access
export const getWhitelistContainer = () => dbManager.getContainer('whitelist');
export const getMerchantsContainer = () => dbManager.getContainer('merchants');
export const getOrdersContainer = () => dbManager.getContainer('orders');
export const getConversationsContainer = () => dbManager.getContainer('conversations');
export const getKnowledgeBaseContainer = () => dbManager.getContainer('knowledge-base'); 
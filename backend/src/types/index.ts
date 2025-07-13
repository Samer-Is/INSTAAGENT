// Whitelist data model
export interface WhitelistEntry {
  id: string;
  pageId: string;
  merchantName: string;
  createdAt: string;
  updatedAt: string;
}

// Merchant data model
export interface Merchant {
  id: string;
  pageId: string;
  pageName: string;
  keyVaultSecretName: string;
  businessInfo: {
    workingHours: string;
    shippingPolicy: string;
    returnPolicy: string;
    contactInfo: string;
  };
  productCatalog: Product[];
  aiSettings: {
    customPrompt?: string;
    responseStyle: 'formal' | 'casual' | 'friendly';
    language: 'arabic' | 'english' | 'both';
  };
  createdAt: string;
  updatedAt: string;
}

// Product data model
export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  stock: number;
  category: string;
  mediaLink?: string;
  variants?: ProductVariant[];
  createdAt: string;
  updatedAt: string;
}

export interface ProductVariant {
  id: string;
  name: string;
  value: string;
  priceModifier: number;
  stockModifier: number;
}

// Order data model
export interface Order {
  id: string;
  merchantId: string;
  customerInfo: {
    name: string;
    phone: string;
    address: string;
  };
  items: OrderItem[];
  totalAmount: number;
  currency: string;
  status: 'pending_confirmation' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled';
  createdAt: string;
  updatedAt: string;
}

export interface OrderItem {
  productId: string;
  productName: string;
  quantity: number;
  unitPrice: number;
  variants?: { name: string; value: string }[];
}

// Conversation data model
export interface Conversation {
  id: string;
  pageId: string;
  merchantId: string;
  customerId: string;
  messages: Message[];
  status: 'active' | 'human_handover' | 'closed';
  lastActivity: string;
  createdAt: string;
  updatedAt: string;
}

export interface Message {
  id: string;
  sender: 'customer' | 'ai' | 'human';
  content: string;
  timestamp: string;
  metadata?: {
    sentiment?: 'positive' | 'negative' | 'neutral';
    intent?: string;
    confidence?: number;
  };
}

// Knowledge base data model
export interface KnowledgeBaseEntry {
  id: string;
  merchantId: string;
  title: string;
  content: string;
  source: string;
  category: string;
  createdAt: string;
  updatedAt: string;
}

// API request/response types
export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  expiresIn: number;
}

export interface CreateWhitelistRequest {
  pageId: string;
  merchantName: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
} 
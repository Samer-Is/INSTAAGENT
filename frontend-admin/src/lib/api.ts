import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { toast } from 'sonner';
import { 
  LoginRequest, 
  LoginResponse, 
  WhitelistEntry, 
  CreateWhitelistRequest, 
  ApiResponse,
  AdminProfile 
} from '../types';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: 'https://insta-ai-agent-backend.azurewebsites.net/api',
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor to add auth token
    this.client.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('admin_token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor for error handling
    this.client.interceptors.response.use(
      (response: AxiosResponse<ApiResponse>) => {
        // Show success message if provided
        if (response.data.message && response.config.method !== 'get') {
          toast.success(response.data.message);
        }
        return response;
      },
      (error) => {
        const message = error.response?.data?.error || error.message || 'An error occurred';
        
        // Handle authentication errors
        if (error.response?.status === 401) {
          localStorage.removeItem('admin_token');
          window.location.href = '/login';
          toast.error('Session expired. Please log in again.');
          return Promise.reject(error);
        }

        // Show error toast
        toast.error(message);
        return Promise.reject(error);
      }
    );
  }

  // Authentication
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await this.client.post<ApiResponse<LoginResponse>>('/admin/login', credentials);
    return response.data.data!;
  }

  async getProfile(): Promise<AdminProfile> {
    const response = await this.client.get<ApiResponse<AdminProfile>>('/admin/profile');
    return response.data.data!;
  }

  // Whitelist management
  async getWhitelist(): Promise<WhitelistEntry[]> {
    const response = await this.client.get<ApiResponse<WhitelistEntry[]>>('/admin/whitelist');
    return response.data.data!;
  }

  async addToWhitelist(data: CreateWhitelistRequest): Promise<WhitelistEntry> {
    const response = await this.client.post<ApiResponse<WhitelistEntry>>('/admin/whitelist', data);
    return response.data.data!;
  }

  async removeFromWhitelist(id: string): Promise<void> {
    await this.client.delete(`/admin/whitelist/${id}`);
  }

  async checkWhitelistStatus(pageId: string): Promise<{ pageId: string; isWhitelisted: boolean }> {
    const response = await this.client.get<ApiResponse<{ pageId: string; isWhitelisted: boolean }>>(`/admin/whitelist/check/${pageId}`);
    return response.data.data!;
  }
}

export const apiClient = new ApiClient(); 
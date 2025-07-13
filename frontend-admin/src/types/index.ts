export interface WhitelistEntry {
  id: string;
  pageId: string;
  merchantName: string;
  createdAt: string;
  updatedAt: string;
}

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

export interface AdminProfile {
  username: string;
  role: string;
  loginTime: string;
  expiresAt: string;
}

export interface AuthContextType {
  isAuthenticated: boolean;
  token: string | null;
  login: (credentials: LoginRequest) => Promise<void>;
  logout: () => void;
  loading: boolean;
} 
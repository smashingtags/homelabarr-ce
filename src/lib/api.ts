import { DeploymentMode, CommunityStoreResponse, CommunityReposResponse } from '../types';

// In production, use relative URL so requests go through nginx proxy (/api/ → backend)
// In development (npm run dev), Vite proxy handles the forwarding
const API_BASE_URL = import.meta.env.DEV ? 'http://localhost:8092' : '/api';

function getAuthHeaders(): Record<string, string> {
  const token = localStorage.getItem('homelabarr_token');
  return token ? { 'Authorization': `Bearer ${token}` } : {};
}

async function handleResponse(response: Response) {
  if (!response.ok) {
    const error = await response.json().catch(() => ({ error: 'Unknown error occurred' }));
    
    // Handle authentication errors
    if (response.status === 401) {
      // Token expired or invalid, clear auth state
      localStorage.removeItem('homelabarr_token');
      localStorage.removeItem('homelabarr_user');
      window.location.reload(); // Force re-authentication
    }
    
    throw new Error(error.details || error.error || 'Request failed');
  }
  return response.json();
}

// Seed data shown when backend has no Docker socket (dev/staging/demo)
export async function getContainers(includeStats = false) {
  const url = includeStats ? `${API_BASE_URL}/containers?stats=true` : `${API_BASE_URL}/containers`;
  try {
    const response = await fetch(url, {
      headers: getAuthHeaders()
    });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return await response.json();
  } catch {
    return { containers: [] };
  }
}

export async function getContainerStats(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/containers/${containerId}/stats`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getContainerLogs(containerId: string, tail: number = 100) {
  const response = await fetch(`${API_BASE_URL}/containers/${containerId}/logs?tail=${tail}`, {
    headers: getAuthHeaders()
  });
  const data = await handleResponse(response);
  
  // Parse the logs string into the expected format
  if (data.logs) {
    const logLines = data.logs.split('\n').filter((line: string) => line.trim());
    return logLines.map((line: string) => {
      // Try to extract timestamp if present
      const timestampMatch = line.match(/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z)\s+(.*)$/);
      if (timestampMatch) {
        return {
          timestamp: new Date(timestampMatch[1]).toLocaleString(),
          message: timestampMatch[2]
        };
      }
      
      // If no timestamp, use current time
      return {
        timestamp: new Date().toLocaleString(),
        message: line
      };
    });
  }
  
  return [];
}

export async function startContainer(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/containers/${containerId}/start`, {
    method: 'POST',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function stopContainer(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/containers/${containerId}/stop`, {
    method: 'POST',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function restartContainer(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/containers/${containerId}/restart`, {
    method: 'POST',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function deployApp(
  appId: string,
  config: Record<string, string>,
  mode: DeploymentMode
) {
  const response = await fetch(`${API_BASE_URL}/deploy`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...getAuthHeaders()
    },
    body: JSON.stringify({
      appId,
      config,
      mode,
    }),
  });
  return handleResponse(response);
}

// CLI Integration API Functions

export async function getApplicationCatalog() {
  const response = await fetch(`${API_BASE_URL}/applications`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getDeploymentModes() {
  const response = await fetch(`${API_BASE_URL}/deployment-modes`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function stopApplication(appId: string) {
  const response = await fetch(`${API_BASE_URL}/applications/${appId}/stop`, {
    method: 'POST',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function removeApplication(appId: string, removeVolumes: boolean = false) {
  const response = await fetch(`${API_BASE_URL}/applications/${appId}?removeVolumes=${removeVolumes}`, {
    method: 'DELETE',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getApplicationLogs(appId: string, lines: number = 100) {
  const response = await fetch(`${API_BASE_URL}/applications/${appId}/logs?lines=${lines}`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function removeContainer(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/containers/${containerId}`, {
    method: 'DELETE',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function checkUsedPorts() {
  const response = await fetch(`${API_BASE_URL}/ports/check`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function findAvailablePort(startPort: number = 8000, endPort: number = 9000) {
  const response = await fetch(`${API_BASE_URL}/ports/available?start=${startPort}&end=${endPort}`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

// GPU detection
export async function detectGpu(): Promise<{ success: boolean; gpus: { nvidia: boolean; intel: boolean } }> {
  const response = await fetch(`${API_BASE_URL}/gpu/detect`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

// Community App Store API functions
export async function refreshCommunityApps(): Promise<{ success: boolean; message: string }> {
  const response = await fetch(`${API_BASE_URL}/community/refresh`, {
    method: 'POST',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getCommunityApps(params?: {
  category?: string;
  search?: string;
  sort?: string;
  page?: number;
  perPage?: number;
}): Promise<CommunityStoreResponse> {
  const query = new URLSearchParams();
  if (params?.category) query.set('category', params.category);
  if (params?.search) query.set('search', params.search);
  if (params?.sort) query.set('sort', params.sort);
  if (params?.page) query.set('page', String(params.page));
  if (params?.perPage) query.set('perPage', String(params.perPage));
  const response = await fetch(`${API_BASE_URL}/community/apps?${query}`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getCommunityCategories(): Promise<{ categories: string[] }> {
  const response = await fetch(`${API_BASE_URL}/community/categories`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getCommunityRepos(): Promise<CommunityReposResponse> {
  const response = await fetch(`${API_BASE_URL}/community/repos`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function installCommunityApp(appName: string, config: Record<string, string>, mode: any): Promise<any> {
  const response = await fetch(`${API_BASE_URL}/community/install/${encodeURIComponent(appName)}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...getAuthHeaders()
    },
    body: JSON.stringify({ config, mode })
  });
  return handleResponse(response);
}

// User Preferences API functions
export async function getUserPreferences(): Promise<{ hiddenCategories: string[] }> {
  const response = await fetch(`${API_BASE_URL}/auth/me/preferences`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function setHiddenCategories(categories: string[]): Promise<{ hiddenCategories: string[] }> {
  const response = await fetch(`${API_BASE_URL}/auth/me/preferences/hidden-categories`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json', ...getAuthHeaders() },
    body: JSON.stringify({ categories })
  });
  return handleResponse(response);
}

// Starred Apps API functions
export async function getStars(): Promise<{ stars: string[] }> {
  const response = await fetch(`${API_BASE_URL}/auth/me/stars`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function starApp(appId: string): Promise<{ stars: string[] }> {
  const response = await fetch(`${API_BASE_URL}/auth/me/stars/${encodeURIComponent(appId)}`, {
    method: 'POST',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function unstarApp(appId: string): Promise<{ stars: string[] }> {
  const response = await fetch(`${API_BASE_URL}/auth/me/stars/${encodeURIComponent(appId)}`, {
    method: 'DELETE',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

// Enhanced Mount Container API functions
export async function getEnhancedMountStatus(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/enhanced-mount/${containerId}/status`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getEnhancedMountProviders(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/enhanced-mount/${containerId}/providers`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getEnhancedMountCosts(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/enhanced-mount/${containerId}/costs`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function getEnhancedMountPerformance(containerId: string) {
  const response = await fetch(`${API_BASE_URL}/enhanced-mount/${containerId}/performance`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function enableEnhancedMountProvider(
  containerId: string, 
  provider: string, 
  config: Record<string, any>
) {
  const response = await fetch(`${API_BASE_URL}/enhanced-mount/${containerId}/providers/${provider}/enable`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...getAuthHeaders()
    },
    body: JSON.stringify(config)
  });
  return handleResponse(response);
}

export async function disableEnhancedMountProvider(containerId: string, provider: string) {
  const response = await fetch(`${API_BASE_URL}/enhanced-mount/${containerId}/providers/${provider}/disable`, {
    method: 'POST',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

// Monitoring Stack API functions
export async function getMonitoringStatus() {
  const response = await fetch(`${API_BASE_URL}/monitoring/status`, {
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

export async function enableMonitoring(options: { enableLogs?: boolean; grafanaPort?: number }) {
  const response = await fetch(`${API_BASE_URL}/monitoring/enable`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...getAuthHeaders()
    },
    body: JSON.stringify(options)
  });
  return handleResponse(response);
}

export async function disableMonitoring() {
  const response = await fetch(`${API_BASE_URL}/monitoring/disable`, {
    method: 'POST',
    headers: getAuthHeaders()
  });
  return handleResponse(response);
}

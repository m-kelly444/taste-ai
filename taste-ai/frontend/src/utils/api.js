import axios from 'axios';

const API_BASE_URL = 'http://localhost:8001';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
});

let authToken = null;

export const setAuthToken = (token) => {
  authToken = token;
  api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
};

export const auth = {
  login: async (username, password) => {
    try {
      const response = await api.post('/api/v1/auth/login', {
        username,
        password
      });
      
      if (response.data.access_token) {
        setAuthToken(response.data.access_token);
        localStorage.setItem('taste_ai_token', response.data.access_token);
      }
      
      return response.data;
    } catch (error) {
      console.error('Login failed:', error);
      throw error;
    }
  },

  logout: () => {
    authToken = null;
    delete api.defaults.headers.common['Authorization'];
    localStorage.removeItem('taste_ai_token');
  },

  initializeToken: () => {
    const token = localStorage.getItem('taste_ai_token');
    if (token) {
      setAuthToken(token);
    }
  }
};

export const aestheticAPI = {
  scoreImage: async (imageFile) => {
    const formData = new FormData();
    formData.append('file', imageFile);
    
    const response = await api.post('/api/v1/aesthetic/score', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  },

  batchScore: async (imageFiles) => {
    const formData = new FormData();
    imageFiles.forEach(file => {
      formData.append('files', file);
    });
    
    const response = await api.post('/api/v1/aesthetic/batch-score', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  }
};

export const trendsAPI = {
  getCurrentTrends: async () => {
    const response = await api.get('/api/v1/trends/current');
    return response.data;
  },

  predictTrends: async (category = 'fashion') => {
    const response = await api.get(`/api/v1/trends/predict?category=${category}`);
    return response.data;
  }
};

export const systemAPI = {
  health: async () => {
    const response = await api.get('/health');
    return response.data;
  },

  metrics: async () => {
    const response = await api.get('/metrics');
    return response.data;
  }
};

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      auth.logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;

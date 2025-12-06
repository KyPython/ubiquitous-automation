import { VercelRequest, VercelResponse } from '@vercel/node';

/**
 * Serverless function handler for Vercel deployment
 */
export default function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Content-Type', 'application/json');
  
  const response = {
    message: '🚀 Ubiquitous Automation Demo API',
    status: 'running',
    endpoints: {
      demo: '/api/demo',
      health: '/api/health'
    },
    timestamp: new Date().toISOString()
  };

  res.status(200).json(response);
}


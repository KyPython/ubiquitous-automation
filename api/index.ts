import { VercelRequest, VercelResponse } from '@vercel/node';
import { withMonitoring } from './utils/middleware';
import { logger } from './utils/logger';

/**
 * Serverless function handler for Vercel deployment
 */
export default withMonitoring(async (req: VercelRequest, res: VercelResponse) => {
  res.setHeader('Content-Type', 'application/json');
  
  logger.info('API index accessed', { method: req.method });

  const response = {
    message: '🚀 Ubiquitous Automation Demo API',
    status: 'running',
    version: '1.0.0',
    endpoints: {
      demo: '/api/demo',
      health: '/api/health',
      monitor: '/api/monitor'
    },
    timestamp: new Date().toISOString()
  };

  res.status(200).json(response);
});


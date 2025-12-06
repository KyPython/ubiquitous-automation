import { VercelRequest, VercelResponse } from '@vercel/node';

/**
 * Health check endpoint
 */
export default function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Content-Type', 'application/json');
  res.status(200).json({
    status: 'healthy',
    service: 'ubiquitous-automation',
    timestamp: new Date().toISOString()
  });
}


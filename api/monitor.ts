import { VercelRequest, VercelResponse } from '@vercel/node';
import { withMonitoring } from './utils/middleware';
import { monitor } from './utils/monitor';
import { logger } from './utils/logger';
import { validateString } from './utils/validator';
import { AppError, ErrorCode } from './utils/error-handler';

/**
 * Monitoring endpoint for observability and metrics
 */
export default withMonitoring(async (req: VercelRequest, res: VercelResponse) => {
  res.setHeader('Content-Type', 'application/json');

  try {
    const action = req.query.action as string | undefined;

    switch (action) {
      case 'metrics':
        return handleMetrics(req, res);
      case 'logs':
        return handleLogs(req, res);
      case 'requests':
        return handleRequests(req, res);
      case 'reset':
        return handleReset(req, res);
      default:
        return handleDefault(req, res);
    }
  } catch (error) {
    logger.error('Monitor endpoint error', error as Error);
    throw error;
  }
});

async function handleMetrics(req: VercelRequest, res: VercelResponse): Promise<void> {
  const metrics = monitor.getSystemMetrics();
  const logStats = logger.getStats();

  res.status(200).json({
    system: metrics,
    logs: logStats,
    timestamp: new Date().toISOString()
  });
}

async function handleLogs(req: VercelRequest, res: VercelResponse): Promise<void> {
  const levelParam = req.query.level;
  const limitParam = req.query.limit;
  
  // Validate and sanitize log level with proper type checking
  let logLevel: 'DEBUG' | 'INFO' | 'WARN' | 'ERROR' | undefined = undefined;
  if (levelParam !== undefined && levelParam !== null) {
    // Ensure it's a string before processing
    if (typeof levelParam !== 'string') {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Log level must be a string', 400);
    }
    
    const upperLevel = levelParam.toUpperCase();
    if (upperLevel === 'DEBUG' || upperLevel === 'INFO' || upperLevel === 'WARN' || upperLevel === 'ERROR') {
      logLevel = upperLevel;
    } else {
      throw new AppError(ErrorCode.VALIDATION_ERROR, `Invalid log level. Must be one of: DEBUG, INFO, WARN, ERROR`, 400);
    }
  }
  
  let limit = 100;
  if (limitParam !== undefined && limitParam !== null) {
    // Ensure it's a string before parsing
    if (typeof limitParam !== 'string') {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Limit must be a string', 400);
    }
    const parsed = parseInt(limitParam, 10);
    if (!isNaN(parsed) && parsed > 0 && parsed <= 1000) {
      limit = parsed;
    } else {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Limit must be a number between 1 and 1000', 400);
    }
  }

  const logs = logger.getLogs(logLevel, limit);

  res.status(200).json({
    logs,
    count: logs.length,
    timestamp: new Date().toISOString()
  });
}

async function handleRequests(req: VercelRequest, res: VercelResponse): Promise<void> {
  const limitParam = req.query.limit;
  
  let limit = 50;
  if (limitParam !== undefined && limitParam !== null) {
    // Ensure it's a string before parsing
    if (typeof limitParam !== 'string') {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Limit must be a string', 400);
    }
    const parsed = parseInt(limitParam, 10);
    if (!isNaN(parsed) && parsed > 0 && parsed <= 500) {
      limit = parsed;
    } else {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Limit must be a number between 1 and 500', 400);
    }
  }

  const requests = monitor.getRecentRequests(limit);

  res.status(200).json({
    requests,
    count: requests.length,
    timestamp: new Date().toISOString()
  });
}

async function handleReset(req: VercelRequest, res: VercelResponse): Promise<void> {
  // Validate authorization (in production, use proper auth)
  const tokenParam = req.query.token;
  
  if (!tokenParam || typeof tokenParam !== 'string') {
    throw new AppError(ErrorCode.UNAUTHORIZED, 'Invalid or missing reset token', 401);
  }
  
  if (tokenParam !== process.env.RESET_TOKEN) {
    throw new AppError(ErrorCode.UNAUTHORIZED, 'Invalid reset token', 401);
  }

  monitor.reset();
  logger.clear();

  logger.info('Monitor reset', { resetBy: req.headers['x-forwarded-for'] || 'unknown' });

  res.status(200).json({
    message: 'Monitor and logs reset successfully',
    timestamp: new Date().toISOString()
  });
}

async function handleDefault(req: VercelRequest, res: VercelResponse): Promise<void> {
  const metrics = monitor.getSystemMetrics();
  const logStats = logger.getStats();

  res.status(200).json({
    message: 'Monitoring endpoint',
    availableActions: ['metrics', 'logs', 'requests', 'reset'],
    usage: {
      metrics: '/api/monitor?action=metrics',
      logs: '/api/monitor?action=logs&level=ERROR&limit=50',
      requests: '/api/monitor?action=requests&limit=100',
      reset: '/api/monitor?action=reset&token=YOUR_TOKEN'
    },
    summary: {
      system: {
        uptime: formatUptime(metrics.uptime),
        memoryUsage: metrics.memory.percentage.toFixed(2) + '%',
        totalRequests: metrics.requests.total
      },
      logs: {
        total: logStats.total,
        errors: logStats.errors,
        warnings: logStats.warnings
      }
    },
    timestamp: new Date().toISOString()
  });
}

function formatUptime(ms: number): string {
  const seconds = Math.floor(ms / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (days > 0) return `${days}d ${hours % 24}h`;
  if (hours > 0) return `${hours}h ${minutes % 60}m`;
  if (minutes > 0) return `${minutes}m ${seconds % 60}s`;
  return `${seconds}s`;
}


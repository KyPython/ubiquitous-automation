import { VercelRequest, VercelResponse } from '@vercel/node';
import { withMonitoring } from './utils/middleware';
import { monitor } from './utils/monitor';
import { logger } from './utils/logger';

/**
 * Enhanced health check endpoint with system metrics
 */
export default withMonitoring(async (req: VercelRequest, res: VercelResponse) => {
  res.setHeader('Content-Type', 'application/json');

  try {
    const metrics = monitor.getSystemMetrics();
    const memoryUsage = process.memoryUsage();

    // Determine health status
    const isHealthy = 
      metrics.memory.percentage < 90 && // Memory usage under 90%
      metrics.errors.total < 100; // Less than 100 errors

    const healthStatus = {
      status: isHealthy ? 'healthy' : 'degraded',
      service: 'ubiquitous-automation',
      timestamp: new Date().toISOString(),
      uptime: {
        seconds: Math.floor(metrics.uptime / 1000),
        human: formatUptime(metrics.uptime)
      },
      memory: {
        used: formatBytes(memoryUsage.heapUsed),
        total: formatBytes(memoryUsage.heapTotal),
        percentage: metrics.memory.percentage.toFixed(2) + '%'
      },
      requests: {
        total: metrics.requests.total,
        successful: metrics.requests.successful,
        failed: metrics.requests.failed,
        successRate: metrics.requests.total > 0
          ? ((metrics.requests.successful / metrics.requests.total) * 100).toFixed(2) + '%'
          : '0%'
      },
      errors: {
        total: metrics.errors.total,
        byCode: metrics.errors.byCode
      }
    };

    logger.info('Health check', { status: healthStatus.status });

    res.status(isHealthy ? 200 : 503).json(healthStatus);
  } catch (error) {
    logger.error('Health check failed', error as Error);
    res.status(503).json({
      status: 'unhealthy',
      service: 'ubiquitous-automation',
      timestamp: new Date().toISOString(),
      error: 'Health check failed'
    });
  }
});

function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
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


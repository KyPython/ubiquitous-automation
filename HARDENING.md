# Security & Hardening Guide

This document outlines the error handling, monitoring, and security measures implemented in the Ubiquitous Automation project.

## 🛡️ Error Handling

### Centralized Error Management

All API endpoints use a centralized error handling system:

- **Error Types**: Structured error codes (`VALIDATION_ERROR`, `INTERNAL_ERROR`, `NOT_FOUND`, etc.)
- **Error Responses**: Consistent error response format with timestamps and context
- **Error Boundaries**: All endpoints wrapped in error handling middleware
- **Production Safety**: Error details hidden in production, shown in development

### Error Response Format

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Invalid input provided",
  "details": {},
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/demo"
}
```

### Error Codes

- `VALIDATION_ERROR` (400) - Input validation failures
- `INTERNAL_ERROR` (500) - Server-side errors
- `NOT_FOUND` (404) - Resource not found
- `UNAUTHORIZED` (401) - Authentication required
- `RATE_LIMIT` (429) - Rate limiting (future)

## ✅ Input Validation

All user inputs are validated before processing:

- **Type Checking**: Validates data types (string, number, etc.)
- **Range Validation**: Min/max values for numbers and strings
- **Pattern Matching**: Regex validation for formats (emails, etc.)
- **Required Fields**: Validates presence of required parameters

### Example Validation

```typescript
import { validateString, validateNumber } from './utils/validator';

const name = validateString(req.body.name, 'name', { minLength: 1, maxLength: 100 });
const age = validateNumber(req.body.age, 'age', { min: 0, max: 150 });
```

## 📊 Monitoring & Logging

### Structured Logging

- **Log Levels**: DEBUG, INFO, WARN, ERROR
- **Structured Data**: Logs include metadata and context
- **Error Tracking**: Errors logged with stack traces
- **In-Memory Storage**: Last 1000 log entries kept in memory

### Request Monitoring

- **Request Metrics**: Tracks all API requests with timing
- **Error Tracking**: Counts errors by status code
- **Performance Metrics**: Average response times
- **System Metrics**: Memory usage, uptime

### Monitoring Endpoint

Access monitoring data via `/api/monitor`:

```bash
# System metrics
GET /api/monitor?action=metrics

# Recent logs (filtered by level)
GET /api/monitor?action=logs&level=ERROR&limit=50

# Recent requests
GET /api/monitor?action=requests&limit=100
```

## 🔍 Health Checks

Enhanced health check endpoint (`/api/health`) provides:

- **Status**: healthy/degraded/unhealthy
- **Uptime**: System uptime in human-readable format
- **Memory Usage**: Current memory consumption and percentage
- **Request Statistics**: Total, successful, failed requests
- **Error Statistics**: Error counts by status code
- **Success Rate**: Percentage of successful requests

### Health Check Response

```json
{
  "status": "healthy",
  "service": "ubiquitous-automation",
  "uptime": {
    "seconds": 3600,
    "human": "1h 0m 0s"
  },
  "memory": {
    "used": "45.2 MB",
    "total": "128 MB",
    "percentage": "35.31%"
  },
  "requests": {
    "total": 1000,
    "successful": 950,
    "failed": 50,
    "successRate": "95.00%"
  }
}
```

## 🔒 Security Best Practices

### Implemented

- ✅ Input validation on all endpoints
- ✅ Error message sanitization (no sensitive data in production)
- ✅ Request monitoring and logging
- ✅ Health check with resource monitoring
- ✅ Structured error responses

### Recommended for Production

- [ ] Rate limiting
- [ ] Authentication/Authorization
- [ ] HTTPS enforcement
- [ ] CORS configuration
- [ ] Request size limits
- [ ] External logging service (e.g., Datadog, Sentry)
- [ ] Alerting on error thresholds
- [ ] Request ID tracking for distributed tracing

## 📈 Observability

### Metrics Collected

1. **Request Metrics**
   - Path, method, status code
   - Response duration
   - Timestamp

2. **System Metrics**
   - Memory usage (heap)
   - Uptime
   - Request counts

3. **Error Metrics**
   - Error counts by code
   - Error rates
   - Recent errors

### Logging Best Practices

- All errors are logged with context
- Request/response logging for debugging
- Performance metrics for optimization
- Security events logged at WARN/ERROR level

## 🧪 Testing Error Scenarios

Error handling is tested with:

- Invalid input validation
- Error response formatting
- Production vs development error details
- Edge cases and boundary conditions

Run tests:
```bash
npm test
```

## 🚀 Deployment Considerations

### Environment Variables

- `NODE_ENV`: Set to `production` for production deployments
- `RESET_TOKEN`: Token for resetting monitoring (set in Vercel dashboard)

### Monitoring in Production

For production deployments, consider:

1. **External Logging**: Integrate with services like:
   - Datadog
   - New Relic
   - Sentry
   - CloudWatch

2. **Alerting**: Set up alerts for:
   - High error rates
   - Memory usage thresholds
   - Response time degradation

3. **Dashboards**: Create dashboards for:
   - Request rates
   - Error rates
   - Response times
   - System health

## 📚 References

- [OWASP API Security](https://owasp.org/www-project-api-security/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [Vercel Serverless Functions](https://vercel.com/docs/concepts/functions/serverless-functions)


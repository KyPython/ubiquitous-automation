import { AppError, ErrorCode } from './utils/error-handler';

/**
 * Simple calculator class (inline for Vercel serverless function)
 * with enhanced error handling
 */
export class Calculator {
  add(a: number, b: number): number {
    if (typeof a !== 'number' || typeof b !== 'number' || isNaN(a) || isNaN(b)) {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Invalid numbers provided for addition', 400);
    }
    return a + b;
  }

  subtract(a: number, b: number): number {
    if (typeof a !== 'number' || typeof b !== 'number' || isNaN(a) || isNaN(b)) {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Invalid numbers provided for subtraction', 400);
    }
    return a - b;
  }

  multiply(a: number, b: number): number {
    if (typeof a !== 'number' || typeof b !== 'number' || isNaN(a) || isNaN(b)) {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Invalid numbers provided for multiplication', 400);
    }
    return a * b;
  }

  divide(a: number, b: number): number {
    if (typeof a !== 'number' || typeof b !== 'number' || isNaN(a) || isNaN(b)) {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Invalid numbers provided for division', 400);
    }
    if (b === 0) {
      throw new AppError(ErrorCode.VALIDATION_ERROR, 'Division by zero is not allowed', 400);
    }
    return a / b;
  }
}


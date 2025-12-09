import { VercelRequest, VercelResponse } from '@vercel/node';
import { Calculator } from './calculator';
import { Greeter } from './greeter';
import { TaskRunner } from './task-runner';
import { withMonitoring } from './utils/middleware';
import { logger } from './utils/logger';
import { AppError, ErrorCode } from './utils/error-handler';

/**
 * Demo endpoint showcasing the application features with error handling
 */
export default withMonitoring(async (req: VercelRequest, res: VercelResponse) => {
  res.setHeader('Content-Type', 'application/json');

  try {
    logger.info('Demo endpoint accessed', { method: req.method });

    const calc = new Calculator();
    const greeter = new Greeter();
    const taskRunner = new TaskRunner();

    // Execute tasks with error handling
    try {
      taskRunner.runTask('demo-api');
      taskRunner.runTask('calculate');
      taskRunner.runTask('greet');
    } catch (error) {
      logger.warn('Task execution error', { error: error instanceof Error ? error.message : String(error) });
      throw new AppError(ErrorCode.INTERNAL_ERROR, 'Failed to execute tasks', 500, error);
    }

    // Perform calculations with error handling
    let calculatorResults;
    try {
      calculatorResults = {
        '2 + 3': calc.add(2, 3),
        '10 - 4': calc.subtract(10, 4),
        '5 * 6': calc.multiply(5, 6),
        '20 / 4': calc.divide(20, 4)
      };
    } catch (error) {
      logger.error('Calculator error', error as Error);
      throw new AppError(ErrorCode.INTERNAL_ERROR, 'Calculation failed', 500, error);
    }

    // Generate greetings with error handling
    let greeterResults;
    try {
      greeterResults = {
        world: greeter.greet('World'),
        automation: greeter.greet('Ubiquitous Automation')
      };
    } catch (error) {
      logger.error('Greeter error', error as Error);
      throw new AppError(ErrorCode.INTERNAL_ERROR, 'Greeting generation failed', 500, error);
    }

    const response = {
      message: 'Ubiquitous Automation Demo',
      calculator: calculatorResults,
      greeter: greeterResults,
      tasks: taskRunner.getExecutedTasks(),
      timestamp: new Date().toISOString()
    };

    logger.info('Demo endpoint completed successfully');
    res.status(200).json(response);
  } catch (error) {
    // Error handler middleware will catch this
    throw error;
  }
});


import { VercelRequest, VercelResponse } from '@vercel/node';
import { Calculator } from '../src/app/calculator';
import { Greeter } from '../src/app/greeter';
import { TaskRunner } from '../src/app/task-runner';

/**
 * Demo endpoint showcasing the application features
 */
export default function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Content-Type', 'application/json');

  const calc = new Calculator();
  const greeter = new Greeter();
  const taskRunner = new TaskRunner();

  taskRunner.runTask('demo-api');
  taskRunner.runTask('calculate');
  taskRunner.runTask('greet');

  const response = {
    message: 'Ubiquitous Automation Demo',
    calculator: {
      '2 + 3': calc.add(2, 3),
      '10 - 4': calc.subtract(10, 4),
      '5 * 6': calc.multiply(5, 6),
      '20 / 4': calc.divide(20, 4)
    },
    greeter: {
      world: greeter.greet('World'),
      automation: greeter.greet('Ubiquitous Automation')
    },
    tasks: taskRunner.getExecutedTasks(),
    timestamp: new Date().toISOString()
  };

  res.status(200).json(response);
}


import { Calculator } from './app/calculator';
import { Greeter } from './app/greeter';
import { TaskRunner } from './app/task-runner';

/**
 * Main entry point for the Ubiquitous Automation demo app
 */
function main() {
  console.log('🚀 Ubiquitous Automation Demo\n');

  // Demonstrate Calculator
  const calc = new Calculator();
  console.log('📊 Calculator Demo:');
  console.log(`   2 + 3 = ${calc.add(2, 3)}`);
  console.log(`   10 - 4 = ${calc.subtract(10, 4)}`);
  console.log(`   5 * 6 = ${calc.multiply(5, 6)}`);
  console.log(`   20 / 4 = ${calc.divide(20, 4)}`);
  console.log();

  // Demonstrate Greeter
  const greeter = new Greeter();
  console.log('👋 Greeter Demo:');
  console.log(`   ${greeter.greet('World')}`);
  console.log(`   ${greeter.greet('Ubiquitous Automation')}`);
  console.log();

  // Demonstrate TaskRunner
  const taskRunner = new TaskRunner();
  console.log('⚙️  Task Runner Demo:');
  taskRunner.runTask('lint');
  taskRunner.runTask('test');
  taskRunner.runTask('build');
  console.log();

  console.log('✅ All demos completed!');
}

if (require.main === module) {
  main();
}

export { Calculator, Greeter, TaskRunner };


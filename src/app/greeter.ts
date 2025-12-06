/**
 * Simple greeter class for demonstration purposes
 */
export class Greeter {
  /**
   * Creates a greeting message
   */
  greet(name: string): string {
    if (!name || name.trim().length === 0) {
      return 'Hello, Anonymous!';
    }
    return `Hello, ${name}!`;
  }

  /**
   * Creates a formal greeting message
   */
  formalGreet(title: string, name: string): string {
    return `Good day, ${title} ${name}.`;
  }
}


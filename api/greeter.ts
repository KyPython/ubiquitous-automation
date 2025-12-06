/**
 * Simple greeter class (inline for Vercel serverless function)
 */
export class Greeter {
  greet(name: string): string {
    if (!name || name.trim().length === 0) {
      return 'Hello, Anonymous!';
    }
    return `Hello, ${name}!`;
  }

  formalGreet(title: string, name: string): string {
    return `Good day, ${title} ${name}.`;
  }
}


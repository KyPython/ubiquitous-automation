/**
 * Task runner class (inline for Vercel serverless function)
 */
export class TaskRunner {
  private readonly tasks: string[] = [];

  runTask(taskName: string): void {
    if (!taskName || taskName.trim().length === 0) {
      throw new Error('Task name cannot be empty');
    }
    this.tasks.push(taskName);
  }

  getExecutedTasks(): string[] {
    return [...this.tasks];
  }

  clear(): void {
    this.tasks.length = 0;
  }

  getTaskCount(): number {
    return this.tasks.length;
  }
}


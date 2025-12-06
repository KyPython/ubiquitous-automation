/**
 * Task runner class that simulates automated task execution
 */
export class TaskRunner {
  private readonly tasks: string[] = [];

  /**
   * Runs a task and logs it
   */
  runTask(taskName: string): void {
    if (!taskName || taskName.trim().length === 0) {
      throw new Error('Task name cannot be empty');
    }

    this.tasks.push(taskName);
    console.log(`   ✓ Running task: ${taskName}`);
  }

  /**
   * Gets all executed tasks
   */
  getExecutedTasks(): string[] {
    return [...this.tasks];
  }

  /**
   * Clears all task history
   */
  clear(): void {
    this.tasks.length = 0;
  }

  /**
   * Gets the count of executed tasks
   */
  getTaskCount(): number {
    return this.tasks.length;
  }
}


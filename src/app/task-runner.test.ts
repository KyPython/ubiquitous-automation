import { TaskRunner } from './task-runner';

describe('TaskRunner', () => {
  let taskRunner: TaskRunner;

  beforeEach(() => {
    taskRunner = new TaskRunner();
  });

  describe('runTask', () => {
    it('should run a task and add it to history', () => {
      taskRunner.runTask('test');
      expect(taskRunner.getExecutedTasks()).toContain('test');
    });

    it('should track multiple tasks', () => {
      taskRunner.runTask('lint');
      taskRunner.runTask('test');
      taskRunner.runTask('build');

      const tasks = taskRunner.getExecutedTasks();
      expect(tasks).toHaveLength(3);
      expect(tasks).toEqual(['lint', 'test', 'build']);
    });

    it('should throw error for empty task name', () => {
      expect(() => taskRunner.runTask('')).toThrow('Task name cannot be empty');
    });

    it('should throw error for whitespace-only task name', () => {
      expect(() => taskRunner.runTask('   ')).toThrow('Task name cannot be empty');
    });
  });

  describe('getTaskCount', () => {
    it('should return zero for new runner', () => {
      expect(taskRunner.getTaskCount()).toBe(0);
    });

    it('should return correct count after running tasks', () => {
      taskRunner.runTask('task1');
      taskRunner.runTask('task2');
      expect(taskRunner.getTaskCount()).toBe(2);
    });
  });

  describe('clear', () => {
    it('should clear all tasks', () => {
      taskRunner.runTask('task1');
      taskRunner.runTask('task2');
      taskRunner.clear();
      expect(taskRunner.getTaskCount()).toBe(0);
    });
  });
});


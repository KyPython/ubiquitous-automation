import { Greeter } from './greeter';

describe('Greeter', () => {
  let greeter: Greeter;

  beforeEach(() => {
    greeter = new Greeter();
  });

  describe('greet', () => {
    it('should greet with a name', () => {
      expect(greeter.greet('World')).toBe('Hello, World!');
    });

    it('should handle empty string', () => {
      expect(greeter.greet('')).toBe('Hello, Anonymous!');
    });

    it('should handle whitespace-only string', () => {
      expect(greeter.greet('   ')).toBe('Hello, Anonymous!');
    });

    it('should handle special characters', () => {
      expect(greeter.greet('DevOps Team!')).toBe('Hello, DevOps Team!!');
    });
  });

  describe('formalGreet', () => {
    it('should create formal greeting', () => {
      expect(greeter.formalGreet('Mr.', 'Smith')).toBe('Good day, Mr. Smith.');
    });

    it('should handle different titles', () => {
      expect(greeter.formalGreet('Dr.', 'Jones')).toBe('Good day, Dr. Jones.');
    });
  });
});


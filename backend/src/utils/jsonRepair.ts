/**
 * Utility to auto-repair malformed or truncated JSON strings from LLMs (ChatGPT, Claude, Gemini).
 */
export function repairJson(rawInput: string): any {
  if (typeof rawInput !== 'string') return rawInput;

  let text = rawInput.trim();

  // 1. Remove markdown code fences if present
  text = text.replace(/^```json\s*/i, '');
  text = text.replace(/^```\s*/, '');
  text = text.replace(/\s*```$/, '');
  text = text.trim();

  // 2. Extract substring from first '{' or '[' to the end
  const firstBrace = text.indexOf('{');
  const firstBracket = text.indexOf('[');
  let startIdx = -1;

  if (firstBrace !== -1 && firstBracket !== -1) {
    startIdx = Math.min(firstBrace, firstBracket);
  } else if (firstBrace !== -1) {
    startIdx = firstBrace;
  } else if (firstBracket !== -1) {
    startIdx = firstBracket;
  }

  if (startIdx !== -1) {
    text = text.substring(startIdx);
  }

  // 3. Attempt direct parse first
  try {
    return JSON.parse(text);
  } catch (_) {}

  // 4. Remove trailing commas before closing braces/brackets
  text = text.replace(/,\s*([\}\]])/g, '$1');

  try {
    return JSON.parse(text);
  } catch (_) {}

  // 5. Advanced Repair for Truncated JSON
  // Balance unclosed quotes, brackets, and braces
  let inString = false;
  let isEscaped = false;
  const stack: string[] = [];
  let repaired = '';

  for (let i = 0; i < text.length; i++) {
    const char = text[i];

    if (isEscaped) {
      isEscaped = false;
      repaired += char;
      continue;
    }

    if (char === '\\') {
      isEscaped = true;
      repaired += char;
      continue;
    }

    if (char === '"') {
      inString = !inString;
      repaired += char;
      continue;
    }

    if (!inString) {
      if (char === '{' || char === '[') {
        stack.push(char);
      } else if (char === '}' && stack.length > 0 && stack[stack.length - 1] === '{') {
        stack.pop();
      } else if (char === ']' && stack.length > 0 && stack[stack.length - 1] === '[') {
        stack.pop();
      }
    }

    repaired += char;
  }

  // If cut off inside a string literal, append closing quote
  if (inString) {
    repaired += '"';
  }

  // Strip trailing comma if present at the end
  repaired = repaired.replace(/,\s*$/, '');

  // Close open brackets/braces in reverse order
  while (stack.length > 0) {
    const lastOpen = stack.pop();
    if (lastOpen === '{') repaired += '}';
    else if (lastOpen === '[') repaired += ']';
  }

  // Clean trailing commas after closing
  repaired = repaired.replace(/,\s*([\}\]])/g, '$1');

  try {
    return JSON.parse(repaired);
  } catch (err: any) {
    // Fallback: try relaxed parsing or return partial object if possible
    throw new Error(`Gagal memperbaiki JSON otomatis: ${err.message}`);
  }
}

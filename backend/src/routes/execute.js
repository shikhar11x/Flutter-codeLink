const express = require('express');
const router = express.Router();

const LANGUAGE_MAP = {
  python:     'python',
  javascript: 'nodejs',
  java:       'java',
  cpp:        'cpp',
  dart:       'dart',
};

router.post('/', async (req, res) => {
  const { language, code, stdin } = req.body;

  if (!language || !code) {
    return res.status(400).json({ error: 'Language and code required' });
  }

  const lang = LANGUAGE_MAP[language.toLowerCase()];
  if (!lang) {
    return res.status(400).json({ error: 'Language not supported' });
  }

  // Java ke liye code se class name nikaalo aur file name match karo
  let fileName = `index.${lang === 'java' ? 'java' : lang === 'nodejs' ? 'js' : lang === 'cpp' ? 'cpp' : lang === 'python' ? 'py' : 'dart'}`;

  if (lang === 'java') {
    const match = code.match(/(?:public\s+)?class\s+(\w+)/);
    const className = match ? match[1] : 'Main';
    fileName = `${className}.java`;
  }

  try {
    const response = await globalThis.fetch('https://onecompiler-apis.p.rapidapi.com/api/v1/run', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-rapidapi-host': 'onecompiler-apis.p.rapidapi.com',
        'x-rapidapi-key': process.env.RAPID_API_KEY || '',
      },
      body: JSON.stringify({
        language: lang,
        stdin: stdin || '',
        files: [
          {
            name: fileName,
            content: code,
          },
        ],
      }),
    });

    const data = await response.json();
    console.log('OneCompiler response:', JSON.stringify(data));

    const output = data.stdout || data.stderr || data.exception || 'No output';

    res.json({
      output: output.trim(),
      stderr: data.stderr || '',
      exitCode: data.stderr || data.exception ? 1 : 0,
      execTime: data.executionTime || 0,
    });
  } catch (err) {
    console.error('Execution error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
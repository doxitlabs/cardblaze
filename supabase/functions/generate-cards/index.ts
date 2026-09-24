import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Must match the model the app sends (GroqService._model, stats recap).
const ALLOWED_MODEL = 'openai/gpt-oss-120b';
// App uses 4096 (cards), 2048 (distractors), 256 (weekly recap).
const MAX_TOKENS = 4096;
const MAX_MESSAGES = 4;
const ALLOWED_ROLES = new Set(['system', 'user', 'assistant']);
// Pro input limit is 5000 chars; prompts add ~2 KB of instructions and
// JSON-escaping can inflate the text — 40 KB leaves ample headroom.
const MAX_BODY_CHARS = 40_000;

function jsonError(error: string, status: number): Response {
  return new Response(JSON.stringify({ error }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get('GROQ_API_KEY');
    if (!apiKey) {
      return new Response(JSON.stringify({ error: 'GROQ_API_KEY not set' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (req.method !== 'POST') return jsonError('Method not allowed', 405);

    // The function is public (verify_jwt = false, anon key ships in the APK),
    // so never forward the raw client body to Groq — only a whitelisted,
    // size-capped request built here. Otherwise anyone could use our Groq
    // key with any model and unlimited tokens.
    const raw = await req.text();
    if (raw.length > MAX_BODY_CHARS) return jsonError('Request too large', 413);

    let body: any;
    try {
      body = JSON.parse(raw);
    } catch {
      return jsonError('Invalid JSON', 400);
    }

    const messages = body?.messages;
    if (
      !Array.isArray(messages) ||
      messages.length === 0 ||
      messages.length > MAX_MESSAGES ||
      !messages.every((m: any) =>
        m && ALLOWED_ROLES.has(m.role) && typeof m.content === 'string'
      )
    ) {
      return jsonError('Invalid messages', 400);
    }

    const requestedTokens = Number(body.max_tokens);
    const temperature = Number(body.temperature);
    const safeBody = {
      model: ALLOWED_MODEL,
      messages: messages.map((m: any) => ({ role: m.role, content: m.content })),
      max_tokens: Number.isFinite(requestedTokens)
        ? Math.min(Math.max(1, Math.floor(requestedTokens)), MAX_TOKENS)
        : MAX_TOKENS,
      temperature: Number.isFinite(temperature)
        ? Math.min(Math.max(0, temperature), 1.5)
        : 0.7,
    };

    const groqRes = await fetch(GROQ_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(safeBody),
    });

    const data = await groqRes.json();

    return new Response(JSON.stringify(data), {
      status: groqRes.status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

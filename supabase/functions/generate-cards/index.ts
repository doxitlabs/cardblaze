import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const CF_MODEL = '@cf/meta/llama-3.3-70b-instruct-fp8-fast';
const MAX_TOKENS = 2048;
const MAX_MESSAGES = 4;
const ALLOWED_ROLES = new Set(['system', 'user', 'assistant']);
const MAX_BODY_CHARS = 40_000;
const RATE_LIMIT_PER_DAY = 30;
const _ipCounts = new Map<string, { count: number; day: string }>();

function checkRateLimit(ip: string): boolean {
  const today = new Date().toISOString().slice(0, 10);
  const entry = _ipCounts.get(ip);
  if (!entry || entry.day !== today) {
    _ipCounts.set(ip, { count: 1, day: today });
    return true;
  }
  if (entry.count >= RATE_LIMIT_PER_DAY) return false;
  entry.count++;
  return true;
}

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

  if (req.method === 'GET') {
    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  if (req.method !== 'POST') return jsonError('Method not allowed', 405);

  try {
    const accountId = Deno.env.get('CF_ACCOUNT_ID');
    const apiToken = Deno.env.get('CF_API_TOKEN');
    if (!accountId || !apiToken) {
      return jsonError('CF_ACCOUNT_ID or CF_API_TOKEN not set', 500);
    }

    const ip = req.headers.get('x-forwarded-for')?.split(',')[0].trim() ?? 'unknown';
    if (!checkRateLimit(ip)) return jsonError('Rate limit exceeded', 429);

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

    const cfBody = {
      messages: messages.map((m: any) => ({ role: m.role, content: m.content })),
      max_tokens: Number.isFinite(requestedTokens)
        ? Math.min(Math.max(1, Math.floor(requestedTokens)), MAX_TOKENS)
        : MAX_TOKENS,
      temperature: Number.isFinite(temperature)
        ? Math.min(Math.max(0, temperature), 1.5)
        : 0.7,
    };

    const cfUrl = `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/${CF_MODEL}`;
    const cfRes = await fetch(cfUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(cfBody),
    });

    const cfData = await cfRes.json();

    // Cloudflare returns { result: { response: "..." }, success: true }
    // Convert to OpenAI-compatible format that groq_service.dart expects
    if (!cfData.success) {
      return new Response(JSON.stringify({ error: JSON.stringify(cfData.errors) }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const rawContent = cfData.result?.response ?? '';
    const content = typeof rawContent === 'string' ? rawContent : JSON.stringify(rawContent);

    const openAiResponse = {
      choices: [
        {
          message: {
            role: 'assistant',
            content,
          },
        },
      ],
    };

    return new Response(JSON.stringify(openAiResponse), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

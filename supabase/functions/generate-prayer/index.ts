// Supabase Edge Function: generate-prayer
// OpenAI API key is stored as a Supabase secret (never exposed to clients)
// Deploy: supabase functions deploy generate-prayer
// Set secret: supabase secrets set OPENAI_API_KEY=sk-...

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Simple in-memory rate limiter: max 10 AI prayers per IP per day
// Resets on function cold start — sufficient for abuse prevention
const rateLimitMap = new Map<string, { count: number; date: string }>();
const MAX_CALLS_PER_DAY = 10;

function getClientIP(req: Request): string {
  return (
    req.headers.get("x-forwarded-for")?.split(",")[0].trim() ?? "unknown"
  );
}

function checkRateLimit(ip: string): boolean {
  const today = new Date().toISOString().split("T")[0];
  const record = rateLimitMap.get(ip);

  if (!record || record.date !== today) {
    rateLimitMap.set(ip, { count: 1, date: today });
    return false; // not limited
  }

  if (record.count >= MAX_CALLS_PER_DAY) {
    return true; // limited
  }

  record.count++;
  return false;
}

function getLocalizedPrompt(
  languageCode: string,
  userInput: string,
  bibleVerse: string,
  emotion: string
): string {
  switch (languageCode) {
    case "en":
      return `You are an AI assistant writing Christian prayers.

Write a heartfelt prayer of around 150 characters including elements of repentance, supplication, and gratitude, following these instructions:

- Reflect today's Bible verse: "${bibleVerse}"
- Incorporate the user's written prayer input: "${userInput}"
- Use a compassionate tone that empathizes with the user's emotional state: "${emotion}"
- Start the prayer with "Dear Heavenly Father," or "Lord," and end with "In Jesus' name, Amen."
- The prayer should sound like the warm words of a pastor, not like AI-generated text.`;

    case "ja":
      return `あなたはクリスチャンの祈りを作成するAIアシスタントです。

以下の指示に従って、悔い改め、願い、感謝の要素を含む約150文字の心のこもった祈りを作成してください。

- 今日の聖書の御言葉を反映してください: "${bibleVerse}"
- ユーザーが書いた祈りの内容を反映してください: "${userInput}"
- ユーザーの感情 "${emotion}" に共感する口調で書いてください
- 「天のお父様、」または「主よ、」で始め、「イエス様のお名前でお祈りします。アーメン。」で締めくくってください
- AIのようではなく、牧師の温かい言葉のように聞こえるように書いてください。`;

    case "zh":
      return `你是一位为基督徒撰写祷告文的AI助手。

请根据以下指示，撰写一篇约150字，包含悔改、祈求和感恩元素的真诚祷告文。

- 融入今日的圣经经文: "${bibleVerse}"
- 融入用户输入的祷告内容: "${userInput}"
- 用充满同理心的语气回应用户的情绪: "${emotion}"
- 以"亲爱的天父"或"主啊"开头，以"奉耶稣的名祷告，阿门。"结尾
- 不要像AI一样，而要像牧师温暖的话语一样`;

    case "es":
      return `Eres un asistente de IA que escribe oraciones cristianas.

Escribe una oración sincera de unas 150 palabras que incluya elementos de arrepentimiento, súplica y gratitud, siguiendo estas instrucciones:

- Refleja el versículo bíblico de hoy: "${bibleVerse}"
- Incorpora el contenido de oración escrito por el usuario: "${userInput}"
- Usa un tono compasivo que empatice con el estado emocional del usuario: "${emotion}"
- Comienza con "Padre Celestial," o "Señor," y termina con "En el nombre de Jesús, Amén."
- La oración debe sonar como las palabras cálidas de un pastor, no como un texto generado por IA.`;

    default: // ko
      return `당신은 기독교인의 기도문을 작성하는 AI 도우미입니다.

아래 지시사항을 참고하여 회개, 간구, 감사의 요소를 포함한 진심 어린 기도문을 150자 내외로 작성하세요.

- 오늘의 성경 말씀을 기도에 반영하세요: "${bibleVerse}"
- 사용자가 직접 작성한 기도문 내용을 반영하세요: "${userInput}"
- 사용자의 마음 상태 "${emotion}" 에 공감하는 어투로 기도문을 구성하세요.
- 기도문은 "하나님 아버지," 혹은 "주님,"으로 시작하고 "예수님의 이름으로 기도드립니다. 아멘."으로 마무리하세요.
- 인공지능의 말투가 아닌, 따뜻하고 목회자의 말처럼 들리게 하세요.`;
  }
}

Deno.serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  // Rate limiting
  const ip = getClientIP(req);
  if (checkRateLimit(ip)) {
    return new Response(
      JSON.stringify({ error: "하루 최대 10회 기도문을 생성할 수 있습니다." }),
      {
        status: 429,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      }
    );
  }

  try {
    const body = await req.json();
    const { emotion, userInput, languageCode, bibleVerse } = body;

    if (!emotion || !languageCode) {
      return new Response(
        JSON.stringify({ error: "필수 항목이 누락되었습니다." }),
        {
          status: 400,
          headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
        }
      );
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "서비스 설정 오류입니다." }),
        {
          status: 500,
          headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
        }
      );
    }

    const prompt = getLocalizedPrompt(
      languageCode,
      userInput ?? "",
      bibleVerse ?? "",
      emotion
    );

    const openaiResponse = await fetch(
      "https://api.openai.com/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: prompt },
            { role: "user", content: userInput ?? "" },
          ],
          temperature: 0.7,
          max_tokens: 500,
        }),
      }
    );

    if (!openaiResponse.ok) {
      return new Response(
        JSON.stringify({ error: `AI 서비스 오류: ${openaiResponse.status}` }),
        {
          status: 502,
          headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
        }
      );
    }

    const data = await openaiResponse.json();
    const prayer = data.choices?.[0]?.message?.content as string | undefined;

    if (!prayer) {
      return new Response(
        JSON.stringify({ error: "기도문을 생성하지 못했습니다." }),
        {
          status: 502,
          headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
        }
      );
    }

    return new Response(JSON.stringify({ prayer }), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (_error) {
    return new Response(
      JSON.stringify({ error: "서버 오류가 발생했습니다." }),
      {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      }
    );
  }
});

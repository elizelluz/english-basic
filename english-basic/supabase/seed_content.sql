-- ============================================================================
-- English Basic — Seed de contenido (Fase 5)
-- Aplicar en: Supabase Dashboard → SQL Editor → New query → Run
--
-- Inserta:
--   - 1 curso  "English Basic — Curso completo"
--   - 4 módulos (Semanas 1-4)
--   - 20 lecciones con contenido JSONB (vocabulary/grammar/examples/practice)
--   - 20 quizzes con ~77 preguntas y sus respuestas
--
-- NO modifica schema.sql, RLS, ni datos de usuarios.
-- (lesson_progress y events se limpian por el cascade del truncate solo si
--  existieran, pero NO se insertan aquí: son datos de usuario.)
--
-- El bloque DO usa variables plpgsql para encadenar ids de forma fiable
-- en el SQL Editor de Supabase.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Limpieza del contenido previo (FKs con on delete cascade → cascade seguro)
-- ----------------------------------------------------------------------------
truncate table public.answers, public.questions, public.quizzes,
           public.lessons, public.modules, public.courses cascade;

-- ----------------------------------------------------------------------------
-- 2. Contenido del curso
-- ----------------------------------------------------------------------------
do $$
declare
  v_course_id bigint;

  v_m1 bigint;
  v_m2 bigint;
  v_m3 bigint;
  v_m4 bigint;

  v_l1 bigint;
  v_l2 bigint;
  v_l3 bigint;
  v_l4 bigint;
  v_l5 bigint;
  v_l6 bigint;
  v_l7 bigint;
  v_l8 bigint;
  v_l9 bigint;
  v_l10 bigint;
  v_l11 bigint;
  v_l12 bigint;
  v_l13 bigint;
  v_l14 bigint;
  v_l15 bigint;
  v_l16 bigint;
  v_l17 bigint;
  v_l18 bigint;
  v_l19 bigint;
  v_l20 bigint;

  v_q1 bigint;
  v_q2 bigint;
  v_q3 bigint;
  v_q4 bigint;
  v_q5 bigint;
  v_q6 bigint;
  v_q7 bigint;
  v_q8 bigint;
  v_q9 bigint;
  v_q10 bigint;
  v_q11 bigint;
  v_q12 bigint;
  v_q13 bigint;
  v_q14 bigint;
  v_q15 bigint;
  v_q16 bigint;
  v_q17 bigint;
  v_q18 bigint;
  v_q19 bigint;
  v_q20 bigint;

  v_p bigint;
begin

  -- ==========================================================================
  -- Curso
  -- ==========================================================================
  insert into public.courses (title, description, level, active)
  values (
    'English Basic — Curso completo',
    'Aprende las bases del inglés desde cero: saludos, números, verbo to be, vida cotidiana, conversación y comunicación en 4 semanas.',
    'beginner',
    true
  )
  returning id into v_course_id;

  -- ==========================================================================
  -- Módulos (semanas)
  -- ==========================================================================
  insert into public.modules (course_id, title, description, "order")
  values (
    v_course_id,
    'Semana 1 · Supervivencia',
    'Saludos, números, verbo to be y frases útiles para empezar a hablar desde el primer día.',
    1
  )
  returning id into v_m1;

  insert into public.modules (course_id, title, description, "order")
  values (
    v_course_id,
    'Semana 2 · Vida cotidiana',
    'Familia, comida, rutinas diarias y el presente simple para hablar de tu día a día.',
    2
  )
  returning id into v_m2;

  insert into public.modules (course_id, title, description, "order")
  values (
    v_course_id,
    'Semana 3 · Conversación',
    'Hacer preguntas, ir de compras, comer en un restaurante y pedir direcciones.',
    3
  )
  returning id into v_m3;

  insert into public.modules (course_id, title, description, "order")
  values (
    v_course_id,
    'Semana 4 · Comunicación',
    'Presentarte en detalle, hablar de tu día, expresar gustos y mantener conversaciones básicas.',
    4
  )
  returning id into v_m4;

  -- ==========================================================================
  -- Lecciones — Módulo 1 · Supervivencia
  -- TODO F7: reemplazar audio_url por URL real de TTS.
  -- ==========================================================================
  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m1,
    'Saludos y presentaciones',
    'Aprende a saludar y presentarte con frases sencillas.',
    '{
      "vocabulary": [
        {"en": "hello", "es": "hola"},
        {"en": "hi", "es": "hola (informal)"},
        {"en": "goodbye", "es": "adiós"},
        {"en": "name", "es": "nombre"},
        {"en": "nice to meet you", "es": "mucho gusto"},
        {"en": "please", "es": "por favor"}
      ],
      "grammar": [
        {"en": "Hello / Hi", "es": "Se usan para saludar. Hi es más informal.", "note": "Usa Hello en contextos formales y Hi con amigos."},
        {"en": "My name is...", "es": "Se usa para presentarte.", "note": "Ejemplo: My name is Ana."},
        {"en": "I am / I''m...", "es": "Forma abreviada de presentarte.", "note": "I''m Pedro = I am Pedro."}
      ],
      "examples": [
        {"en": "Hello, my name is Ana.", "es": "Hola, mi nombre es Ana."},
        {"en": "Hi, I''m Pedro.", "es": "Hola, soy Pedro."},
        {"en": "Nice to meet you.", "es": "Mucho gusto."},
        {"en": "Goodbye, see you tomorrow.", "es": "Adiós, nos vemos mañana."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Hola, me llamo Pedro''", "answer": "Hello, my name is Pedro."},
        {"instruction": "Completa la frase: ''Nice ___ to meet you''", "answer": "Nice to meet you."},
        {"instruction": "Elige la forma correcta: ''I___ from Mexico'' (am / are / is)", "answer": "I am from Mexico."}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-1.mp3',
    1,
    true,
    true
  )
  returning id into v_l1;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m1,
    'Números del 1 al 20',
    'Cuenta y entiende los números en inglés.',
    '{
      "vocabulary": [
        {"en": "one", "es": "uno"},
        {"en": "two", "es": "dos"},
        {"en": "three", "es": "tres"},
        {"en": "four", "es": "cuatro"},
        {"en": "five", "es": "cinco"},
        {"en": "six", "es": "seis"},
        {"en": "seven", "es": "siete"},
        {"en": "ten", "es": "diez"}
      ],
      "grammar": [
        {"en": "Números del 1 al 10", "es": "one, two, three, four, five, six, seven, eight, nine, ten.", "note": "Escucha el audio y repite en voz alta."},
        {"en": "Números del 11 al 20", "es": "eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, eighteen, nineteen, twenty.", "note": "Ojo: eleven y twelve no siguen el patrón."}
      ],
      "examples": [
        {"en": "I have two brothers.", "es": "Tengo dos hermanos."},
        {"en": "She is ten years old.", "es": "Ella tiene diez años."},
        {"en": "My phone number is five, five, three.", "es": "Mi número de teléfono es cinco, cinco, tres."},
        {"en": "There are twenty students.", "es": "Hay veinte estudiantes."}
      ],
      "practice": [
        {"instruction": "Escribe en inglés el número 7", "answer": "seven"},
        {"instruction": "Traduce al inglés: ''Tengo tres hermanos''", "answer": "I have three brothers."},
        {"instruction": "Completa: ''She is ten years ___''", "answer": "She is ten years old."}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-2.mp3',
    2,
    true,
    true
  )
  returning id into v_l2;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m1,
    'Verbo to be: am, is, are',
    'Domina las tres formas del verbo ser/estar.',
    '{
      "vocabulary": [
        {"en": "I", "es": "yo"},
        {"en": "you", "es": "tú / usted"},
        {"en": "he", "es": "él"},
        {"en": "she", "es": "ella"},
        {"en": "we", "es": "nosotros"}
      ],
      "grammar": [
        {"en": "Am", "es": "Se usa solo con I.", "note": "I am a student."},
        {"en": "Is", "es": "Se usa con he, she, it.", "note": "She is my teacher."},
        {"en": "Are", "es": "Se usa con you, we, they.", "note": "We are friends."}
      ],
      "examples": [
        {"en": "I am a student.", "es": "Yo soy estudiante."},
        {"en": "She is my teacher.", "es": "Ella es mi profesora."},
        {"en": "We are friends.", "es": "Nosotros somos amigos."},
        {"en": "He is happy.", "es": "Él está feliz."}
      ],
      "practice": [
        {"instruction": "Completa: ''She ___ my sister'' (am / is / are)", "answer": "is"},
        {"instruction": "Traduce al inglés: ''Yo soy estudiante''", "answer": "I am a student."},
        {"instruction": "Completa: ''They ___ from Peru'' (am / is / are)", "answer": "are"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-3.mp3',
    3,
    false,
    true
  )
  returning id into v_l3;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m1,
    'Preguntas y respuestas básicas',
    'Pregunta y responde sobre ti mismo.',
    '{
      "vocabulary": [
        {"en": "yes", "es": "sí"},
        {"en": "no", "es": "no"},
        {"en": "question", "es": "pregunta"},
        {"en": "answer", "es": "respuesta"},
        {"en": "how", "es": "cómo"}
      ],
      "grammar": [
        {"en": "Are you...? / Is she...?", "es": "Para preguntas de sí/no.", "note": "El verbo va antes del sujeto."},
        {"en": "How are you?", "es": "¿Cómo estás?", "note": "Respuesta típica: I''m fine, thank you."},
        {"en": "Yes, I am / No, I''m not", "es": "Respuestas cortas afirmativas y negativas."}
      ],
      "examples": [
        {"en": "Are you a student? Yes, I am.", "es": "¿Eres estudiante? Sí, lo soy."},
        {"en": "How are you? I''m fine, thank you.", "es": "¿Cómo estás? Estoy bien, gracias."},
        {"en": "Is she your sister? No, she isn''t.", "es": "¿Ella es tu hermana? No, no lo es."},
        {"en": "Are they your friends? Yes, they are.", "es": "¿Ellos son tus amigos? Sí, lo son."}
      ],
      "practice": [
        {"instruction": "Responde en inglés: ''How are you?''", "answer": "I''m fine, thank you."},
        {"instruction": "Traduce al inglés: ''¿Eres estudiante?''", "answer": "Are you a student?"},
        {"instruction": "Completa: ''Is she your sister? Yes, she ___''", "answer": "is"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-4.mp3',
    4,
    false,
    true
  )
  returning id into v_l4;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m1,
    'Frases útiles para sobrevivir',
    'Las frases que necesitas en cualquier situación.',
    '{
      "vocabulary": [
        {"en": "excuse me", "es": "disculpe / perdón"},
        {"en": "thank you", "es": "gracias"},
        {"en": "sorry", "es": "perdón / lo siento"},
        {"en": "help", "es": "ayuda / ayudar"},
        {"en": "where", "es": "dónde"},
        {"en": "I don''t understand", "es": "no entiendo"}
      ],
      "grammar": [
        {"en": "Excuse me, where is...?", "es": "Para preguntar por un lugar con cortesía.", "note": "Excuse me, where is the bathroom?"},
        {"en": "Can you help me?", "es": "Para pedir ayuda.", "note": "Can you help me, please?"},
        {"en": "I don''t understand", "es": "Para decir que no entiendes."}
      ],
      "examples": [
        {"en": "Excuse me, where is the bathroom?", "es": "Disculpe, ¿dónde está el baño?"},
        {"en": "Thank you very much.", "es": "Muchas gracias."},
        {"en": "Sorry, I don''t understand.", "es": "Perdón, no entiendo."},
        {"en": "Can you help me, please?", "es": "¿Puede ayudarme, por favor?"}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Gracias''", "answer": "Thank you."},
        {"instruction": "Traduce al inglés: ''No entiendo''", "answer": "I don''t understand."},
        {"instruction": "Traduce al inglés: ''Disculpe, ¿dónde está el baño?''", "answer": "Excuse me, where is the bathroom?"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-5.mp3',
    5,
    false,
    true
  )
  returning id into v_l5;

  -- ==========================================================================
  -- Lecciones — Módulo 2 · Vida cotidiana
  -- ==========================================================================
  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m2,
    'Mi familia',
    'Aprende a hablar de tu familia.',
    '{
      "vocabulary": [
        {"en": "family", "es": "familia"},
        {"en": "mother", "es": "madre"},
        {"en": "father", "es": "padre"},
        {"en": "brother", "es": "hermano"},
        {"en": "sister", "es": "hermana"},
        {"en": "son", "es": "hijo"},
        {"en": "daughter", "es": "hija"},
        {"en": "parents", "es": "padres"}
      ],
      "grammar": [
        {"en": "My / your / his / her", "es": "Adjetivos posesivos.", "note": "My mother, your father, her sister."},
        {"en": "This is my...", "es": "Para presentar o señalar a alguien.", "note": "This is my sister."},
        {"en": "I have...", "es": "Para decir que tienes algo.", "note": "I have two brothers."}
      ],
      "examples": [
        {"en": "This is my mother.", "es": "Esta es mi madre."},
        {"en": "I have two brothers.", "es": "Tengo dos hermanos."},
        {"en": "My parents are teachers.", "es": "Mis padres son profesores."},
        {"en": "Her daughter is five years old.", "es": "Su hija tiene cinco años."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Esta es mi hermana''", "answer": "This is my sister."},
        {"instruction": "Traduce al inglés: ''Mi padre es médico''", "answer": "My father is a doctor."},
        {"instruction": "Completa: ''I have two ___'' (hermanos)", "answer": "brothers"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-6.mp3',
    1,
    false,
    true
  )
  returning id into v_l6;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m2,
    'La comida y las bebidas',
    'Vocabulario para comer y beber.',
    '{
      "vocabulary": [
        {"en": "water", "es": "agua"},
        {"en": "bread", "es": "pan"},
        {"en": "milk", "es": "leche"},
        {"en": "fruit", "es": "fruta"},
        {"en": "egg", "es": "huevo"},
        {"en": "rice", "es": "arroz"},
        {"en": "chicken", "es": "pollo"},
        {"en": "coffee", "es": "café"}
      ],
      "grammar": [
        {"en": "I like... / I don''t like...", "es": "Para hablar de gustos.", "note": "I like coffee. I don''t like milk."},
        {"en": "A / An", "es": "Artículos indefinidos.", "note": "a banana (consonante), an apple (vocal)."},
        {"en": "Would you like...?", "es": "Para ofrecer algo.", "note": "Would you like some water?"}
      ],
      "examples": [
        {"en": "I like water.", "es": "Me gusta el agua."},
        {"en": "I eat bread with eggs.", "es": "Como pan con huevos."},
        {"en": "Would you like some coffee?", "es": "¿Quieres un poco de café?"},
        {"en": "An apple a day.", "es": "Una manzana al día."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Me gusta el café''", "answer": "I like coffee."},
        {"instruction": "Completa: ''I eat ___ egg'' (a / an)", "answer": "an"},
        {"instruction": "Traduce al inglés: ''No me gusta la leche''", "answer": "I don''t like milk."}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-7.mp3',
    2,
    false,
    true
  )
  returning id into v_l7;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m2,
    'Rutinas diarias',
    'Habla de lo que haces todos los días.',
    '{
      "vocabulary": [
        {"en": "wake up", "es": "despertarse"},
        {"en": "get up", "es": "levantarse"},
        {"en": "eat", "es": "comer"},
        {"en": "drink", "es": "beber"},
        {"en": "work", "es": "trabajar"},
        {"en": "sleep", "es": "dormir"},
        {"en": "morning", "es": "mañana"},
        {"en": "night", "es": "noche"}
      ],
      "grammar": [
        {"en": "Presente simple para rutinas", "es": "Hechos y hábitos.", "note": "I wake up at seven."},
        {"en": "Con he / she se añade -s", "es": "She wakes up at seven.", "note": "He works in a bank."}
      ],
      "examples": [
        {"en": "I wake up at seven in the morning.", "es": "Me despierto a las siete de la mañana."},
        {"en": "She works in a school.", "es": "Ella trabaja en una escuela."},
        {"en": "We eat lunch at noon.", "es": "Comemos el almuerzo al mediodía."},
        {"en": "I sleep at night.", "es": "Duermo de noche."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Me despierto a las siete''", "answer": "I wake up at seven."},
        {"instruction": "Completa: ''She ___ in a school'' (work / works)", "answer": "works"},
        {"instruction": "Traduce al inglés: ''Duermo de noche''", "answer": "I sleep at night."}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-8.mp3',
    3,
    false,
    true
  )
  returning id into v_l8;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m2,
    'Presente simple: afirmaciones',
    'Forma frases afirmativas en presente simple.',
    '{
      "vocabulary": [
        {"en": "always", "es": "siempre"},
        {"en": "usually", "es": "usualmente"},
        {"en": "sometimes", "es": "a veces"},
        {"en": "never", "es": "nunca"},
        {"en": "every day", "es": "todos los días"},
        {"en": "today", "es": "hoy"}
      ],
      "grammar": [
        {"en": "Presente simple", "es": "Para hechos y rutinas.", "note": "I study English."},
        {"en": "-s con he / she / it", "es": "He studies. She goes.", "note": "Go → goes, study → studies."},
        {"en": "Adverbios de frecuencia", "es": "Van antes del verbo.", "note": "I always drink coffee."}
      ],
      "examples": [
        {"en": "I study English every day.", "es": "Estudio inglés todos los días."},
        {"en": "She always drinks coffee in the morning.", "es": "Ella siempre toma café por la mañana."},
        {"en": "We usually watch TV at night.", "es": "Normalmente vemos la tele de noche."},
        {"en": "He never eats fast food.", "es": "Él nunca come comida rápida."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Estudio inglés todos los días''", "answer": "I study English every day."},
        {"instruction": "Completa: ''She always ___ coffee'' (drink / drinks)", "answer": "drinks"},
        {"instruction": "Traduce al inglés: ''Él nunca come comida rápida''", "answer": "He never eats fast food."}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-9.mp3',
    4,
    false,
    true
  )
  returning id into v_l9;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m2,
    'Presente simple: negaciones y preguntas',
    'Niega y pregunta en presente simple.',
    '{
      "vocabulary": [
        {"en": "don''t", "es": "no (negación)"},
        {"en": "doesn''t", "es": "no (negación, 3.ª persona)"},
        {"en": "do", "es": "hacer (auxiliar)"},
        {"en": "does", "es": "hace (auxiliar, 3.ª persona)"},
        {"en": "like", "es": "gustar"},
        {"en": "want", "es": "querer"}
      ],
      "grammar": [
        {"en": "Negación", "es": "I don''t like... / She doesn''t like...", "note": "Con he/she/it se usa doesn''t."},
        {"en": "Preguntas", "es": "Do you like...? / Does she like...?", "note": "El auxiliar va al inicio."},
        {"en": "Respuestas cortas", "es": "Yes, I do. / No, I don''t.", "note": "Se repite el auxiliar."}
      ],
      "examples": [
        {"en": "I don''t like coffee.", "es": "No me gusta el café."},
        {"en": "She doesn''t work on Sundays.", "es": "Ella no trabaja los domingos."},
        {"en": "Do you like tea? Yes, I do.", "es": "¿Te gusta el té? Sí, me gusta."},
        {"en": "Does he want water? No, he doesn''t.", "es": "¿Quiere agua? No."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''No me gusta el café''", "answer": "I don''t like coffee."},
        {"instruction": "Completa: ''___ you like tea?'' (Do / Does)", "answer": "Do"},
        {"instruction": "Completa: ''She ___ like tea'' (don''t / doesn''t)", "answer": "doesn''t"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-10.mp3',
    5,
    false,
    true
  )
  returning id into v_l10;

  -- ==========================================================================
  -- Lecciones — Módulo 3 · Conversación
  -- ==========================================================================
  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m3,
    'Hacer preguntas',
    'Usa las question words para preguntar.',
    '{
      "vocabulary": [
        {"en": "what", "es": "qué"},
        {"en": "where", "es": "dónde"},
        {"en": "when", "es": "cuándo"},
        {"en": "who", "es": "quién"},
        {"en": "why", "es": "por qué"},
        {"en": "how", "es": "cómo"},
        {"en": "how much", "es": "cuánto (precio)"},
        {"en": "how many", "es": "cuántos"}
      ],
      "grammar": [
        {"en": "What", "es": "Para cosas y nombres.", "note": "What is your name?"},
        {"en": "Where", "es": "Para lugares.", "note": "Where is the station?"},
        {"en": "How much", "es": "Para precios.", "note": "How much is this shirt?"}
      ],
      "examples": [
        {"en": "What is your name?", "es": "¿Cuál es tu nombre?"},
        {"en": "Where is the station?", "es": "¿Dónde está la estación?"},
        {"en": "When do you wake up?", "es": "¿Cuándo te despiertas?"},
        {"en": "How much is this shirt?", "es": "¿Cuánto cuesta esta camisa?"}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''¿Dónde está la estación?''", "answer": "Where is the station?"},
        {"instruction": "Traduce al inglés: ''¿Cuánto cuesta esto?''", "answer": "How much is this?"},
        {"instruction": "Completa: ''___ is your name?'' (What / Where)", "answer": "What"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-11.mp3',
    1,
    false,
    true
  )
  returning id into v_l11;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m3,
    'De compras',
    'Vocabulario y frases para ir de compras.',
    '{
      "vocabulary": [
        {"en": "shop", "es": "tienda"},
        {"en": "buy", "es": "comprar"},
        {"en": "price", "es": "precio"},
        {"en": "cheap", "es": "barato"},
        {"en": "expensive", "es": "caro"},
        {"en": "money", "es": "dinero"},
        {"en": "shirt", "es": "camisa"},
        {"en": "shoes", "es": "zapatos"}
      ],
      "grammar": [
        {"en": "How much is...?", "es": "Para preguntar precios.", "note": "How much is this?"},
        {"en": "I''d like...", "es": "Para pedir de forma cortés.", "note": "I''d like this shirt."},
        {"en": "Can I pay by card?", "es": "Para preguntar cómo pagar."}
      ],
      "examples": [
        {"en": "How much is this shirt?", "es": "¿Cuánto cuesta esta camisa?"},
        {"en": "It''s ten dollars.", "es": "Son diez dólares."},
        {"en": "I''d like to buy these shoes.", "es": "Me gustaría comprar estos zapatos."},
        {"en": "This is too expensive.", "es": "Esto es muy caro."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''¿Cuánto cuesta esta camisa?''", "answer": "How much is this shirt?"},
        {"instruction": "Traduce al inglés: ''Es muy caro''", "answer": "It''s too expensive."},
        {"instruction": "Completa: ''How ___ is this?'' (much / many)", "answer": "much"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-12.mp3',
    2,
    false,
    true
  )
  returning id into v_l12;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m3,
    'En el restaurante',
    'Pide comida y pide la cuenta en inglés.',
    '{
      "vocabulary": [
        {"en": "menu", "es": "menú"},
        {"en": "food", "es": "comida"},
        {"en": "drink", "es": "bebida"},
        {"en": "waiter", "es": "mesero"},
        {"en": "bill", "es": "cuenta"},
        {"en": "delicious", "es": "delicioso"},
        {"en": "hungry", "es": "con hambre"},
        {"en": "thirsty", "es": "con sed"}
      ],
      "grammar": [
        {"en": "I''d like...", "es": "Para pedir algo.", "note": "I''d like a menu, please."},
        {"en": "Can I have...?", "es": "Otra forma de pedir.", "note": "Can I have some water?"},
        {"en": "The bill, please", "es": "Para pedir la cuenta."}
      ],
      "examples": [
        {"en": "I''d like a menu, please.", "es": "Me gustaría un menú, por favor."},
        {"en": "Can I have some water?", "es": "¿Me puede traer agua?"},
        {"en": "The food is delicious.", "es": "La comida está deliciosa."},
        {"en": "The bill, please.", "es": "La cuenta, por favor."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Me gustaría un menú, por favor''", "answer": "I''d like a menu, please."},
        {"instruction": "Traduce al inglés: ''La cuenta, por favor''", "answer": "The bill, please."},
        {"instruction": "Completa: ''Can I ___ some water?'' (have / has)", "answer": "have"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-13.mp3',
    3,
    false,
    true
  )
  returning id into v_l13;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m3,
    'Pedir direcciones',
    'Pregunta y entiende cómo llegar.',
    '{
      "vocabulary": [
        {"en": "street", "es": "calle"},
        {"en": "left", "es": "izquierda"},
        {"en": "right", "es": "derecha"},
        {"en": "straight", "es": "recto"},
        {"en": "near", "es": "cerca"},
        {"en": "far", "es": "lejos"},
        {"en": "corner", "es": "esquina"},
        {"en": "map", "es": "mapa"}
      ],
      "grammar": [
        {"en": "Where is...?", "es": "Para preguntar por un lugar.", "note": "Where is the bank?"},
        {"en": "Turn left / Turn right / Go straight", "es": "Instrucciones de dirección."},
        {"en": "It''s near... / It''s far from...", "es": "Para indicar distancia.", "note": "The hotel is near the station."}
      ],
      "examples": [
        {"en": "Excuse me, where is the bank?", "es": "Disculpe, ¿dónde está el banco?"},
        {"en": "Turn left at the corner.", "es": "Gira a la izquierda en la esquina."},
        {"en": "Go straight, then turn right.", "es": "Siga recto, luego gire a la derecha."},
        {"en": "The hotel is near the station.", "es": "El hotel está cerca de la estación."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Gira a la izquierda''", "answer": "Turn left."},
        {"instruction": "Traduce al inglés: ''Siga recto''", "answer": "Go straight."},
        {"instruction": "Completa: ''Turn ___ at the corner'' (left / right según ''izquierda'')", "answer": "left"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-14.mp3',
    4,
    false,
    true
  )
  returning id into v_l14;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m3,
    'En la ciudad y el transporte',
    'Muévete por la ciudad en inglés.',
    '{
      "vocabulary": [
        {"en": "bus", "es": "autobús"},
        {"en": "train", "es": "tren"},
        {"en": "taxi", "es": "taxi"},
        {"en": "airport", "es": "aeropuerto"},
        {"en": "ticket", "es": "boleto"},
        {"en": "stop", "es": "parada"},
        {"en": "station", "es": "estación"},
        {"en": "city", "es": "ciudad"}
      ],
      "grammar": [
        {"en": "How do I get to...?", "es": "Para preguntar cómo llegar.", "note": "How do I get to the airport?"},
        {"en": "I need a ticket to...", "es": "Para comprar un boleto.", "note": "I need a ticket to the city."},
        {"en": "Which bus goes to...?", "es": "Para el transporte público."}
      ],
      "examples": [
        {"en": "How do I get to the airport?", "es": "¿Cómo llego al aeropuerto?"},
        {"en": "I need a ticket to the city.", "es": "Necesito un boleto a la ciudad."},
        {"en": "Which bus goes to the station?", "es": "¿Qué autobús va a la estación?"},
        {"en": "The train is late.", "es": "El tren va tarde."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''¿Cómo llego al aeropuerto?''", "answer": "How do I get to the airport?"},
        {"instruction": "Traduce al inglés: ''Necesito un boleto a la ciudad''", "answer": "I need a ticket to the city."},
        {"instruction": "Completa: ''Which ___ goes to the station?'' (bus / buses)", "answer": "bus"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-15.mp3',
    5,
    false,
    true
  )
  returning id into v_l15;

  -- ==========================================================================
  -- Lecciones — Módulo 4 · Comunicación
  -- ==========================================================================
  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m4,
    'Presentarte en detalle',
    'Cuenta de dónde eres, dónde vives y qué haces.',
    '{
      "vocabulary": [
        {"en": "introduce", "es": "presentar"},
        {"en": "from", "es": "de (procedencia)"},
        {"en": "live", "es": "vivir"},
        {"en": "years old", "es": "años (edad)"},
        {"en": "job", "es": "trabajo"},
        {"en": "study", "es": "estudiar"}
      ],
      "grammar": [
        {"en": "I am from...", "es": "Para hablar de procedencia.", "note": "I am from Mexico."},
        {"en": "I live in...", "es": "Para hablar de dónde vives.", "note": "I live in Madrid."},
        {"en": "I am + age + years old", "es": "Para la edad.", "note": "I am twenty-five years old."}
      ],
      "examples": [
        {"en": "My name is Ana and I am from Mexico.", "es": "Mi nombre es Ana y soy de México."},
        {"en": "I live in Madrid.", "es": "Vivo en Madrid."},
        {"en": "I am twenty-five years old.", "es": "Tengo veinticinco años."},
        {"en": "I study English and I work in a bank.", "es": "Estudio inglés y trabajo en un banco."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Soy de México''", "answer": "I am from Mexico."},
        {"instruction": "Traduce al inglés: ''Vivo en Madrid''", "answer": "I live in Madrid."},
        {"instruction": "Completa: ''I am twenty ___ old'' (años)", "answer": "years"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-16.mp3',
    1,
    false,
    true
  )
  returning id into v_l16;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m4,
    'Hablar de tu día',
    'Describe tu rutina y tus horarios.',
    '{
      "vocabulary": [
        {"en": "morning", "es": "mañana"},
        {"en": "afternoon", "es": "tarde"},
        {"en": "evening", "es": "noche (tarde-noche)"},
        {"en": "hour", "es": "hora"},
        {"en": "minute", "es": "minuto"},
        {"en": "early", "es": "temprano"},
        {"en": "late", "es": "tarde (con retraso)"},
        {"en": "busy", "es": "ocupado"}
      ],
      "grammar": [
        {"en": "Partes del día", "es": "in the morning / in the afternoon / in the evening.", "note": "Se usa ''in the''."},
        {"en": "I get up at...", "es": "Para hablar de horarios.", "note": "I get up at seven."},
        {"en": "Every day / usually", "es": "Para rutinas.", "note": "I am busy every day."}
      ],
      "examples": [
        {"en": "I get up early in the morning.", "es": "Me levanto temprano por la mañana."},
        {"en": "In the afternoon I work.", "es": "Por la tarde trabajo."},
        {"en": "In the evening I study English.", "es": "Por la noche estudio inglés."},
        {"en": "I am busy every day.", "es": "Estoy ocupado todos los días."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Me levanto temprano por la mañana''", "answer": "I get up early in the morning."},
        {"instruction": "Traduce al inglés: ''Estoy ocupado todos los días''", "answer": "I am busy every day."},
        {"instruction": "Completa: ''___ the evening I study English'' (In / At)", "answer": "In"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-17.mp3',
    2,
    false,
    true
  )
  returning id into v_l17;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m4,
    'Expresar gustos y preferencias',
    'Di lo que te gusta y lo que prefieres.',
    '{
      "vocabulary": [
        {"en": "like", "es": "gustar"},
        {"en": "love", "es": "encantar"},
        {"en": "hate", "es": "odiar"},
        {"en": "prefer", "es": "preferir"},
        {"en": "favorite", "es": "favorito"},
        {"en": "music", "es": "música"},
        {"en": "sport", "es": "deporte"},
        {"en": "book", "es": "libro"}
      ],
      "grammar": [
        {"en": "I like / I love / I hate + sustantivo", "es": "Para expresar gustos.", "note": "I love music."},
        {"en": "My favorite...", "es": "Para preferencias.", "note": "My favorite sport is soccer."},
        {"en": "I prefer... to...", "es": "Para comparar preferencias.", "note": "I prefer tea to coffee."}
      ],
      "examples": [
        {"en": "I love music.", "es": "Me encanta la música."},
        {"en": "I hate getting up early.", "es": "Odio levantarme temprano."},
        {"en": "My favorite sport is soccer.", "es": "Mi deporte favorito es el fútbol."},
        {"en": "I prefer tea to coffee.", "es": "Prefiero el té al café."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''Me encanta la música''", "answer": "I love music."},
        {"instruction": "Traduce al inglés: ''Mi deporte favorito es el fútbol''", "answer": "My favorite sport is soccer."},
        {"instruction": "Completa: ''I ___ tea to coffee'' (prefer / prefers)", "answer": "prefer"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-18.mp3',
    3,
    false,
    true
  )
  returning id into v_l18;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m4,
    'Conversaciones básicas en contexto',
    'Frases para mantener una conversación.',
    '{
      "vocabulary": [
        {"en": "talk", "es": "hablar"},
        {"en": "listen", "es": "escuchar"},
        {"en": "say", "es": "decir"},
        {"en": "ask", "es": "preguntar"},
        {"en": "slow", "es": "lento"},
        {"en": "again", "es": "otra vez"},
        {"en": "word", "es": "palabra"},
        {"en": "sentence", "es": "oración"}
      ],
      "grammar": [
        {"en": "Can you speak slowly, please?", "es": "Para pedir que hablen lento.", "note": "Speak slowly, please."},
        {"en": "Can you say that again?", "es": "Para pedir que repitan.", "note": "Say that again, please."},
        {"en": "What does ... mean?", "es": "Para preguntar significado.", "note": "What does ''hello'' mean?"}
      ],
      "examples": [
        {"en": "Can you speak slowly, please?", "es": "¿Puede hablar más lento, por favor?"},
        {"en": "Can you say that again?", "es": "¿Puede repetir eso?"},
        {"en": "What does ''hello'' mean?", "es": "¿Qué significa ''hello''?"},
        {"en": "I need to practice speaking.", "es": "Necesito practicar el habla."}
      ],
      "practice": [
        {"instruction": "Traduce al inglés: ''¿Puede hablar más lento, por favor?''", "answer": "Can you speak slowly, please?"},
        {"instruction": "Traduce al inglés: ''¿Qué significa esto?''", "answer": "What does this mean?"},
        {"instruction": "Completa: ''Can you ___ that again?'' (say / speak)", "answer": "say"}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-19.mp3',
    4,
    false,
    true
  )
  returning id into v_l19;

  insert into public.lessons
    (module_id, title, description, content, audio_url, "order", is_free, active)
  values (
    v_m4,
    'Repaso y práctica final',
    'Repasa lo aprendido y arma tu presentación completa.',
    '{
      "vocabulary": [
        {"en": "review", "es": "repaso"},
        {"en": "practice", "es": "práctica / practicar"},
        {"en": "speak", "es": "hablar"},
        {"en": "read", "es": "leer"},
        {"en": "write", "es": "escribir"},
        {"en": "learn", "es": "aprender"}
      ],
      "grammar": [
        {"en": "Verbo to be", "es": "am, is, are.", "note": "I am Ana. She is from Peru. They are friends."},
        {"en": "Presente simple", "es": "Con -s en 3.ª persona y auxiliares do/does.", "note": "She works in a bank. Do you like tea?"},
        {"en": "Estructura de una presentación", "es": "Nombre + origen + trabajo + gustos.", "note": "I am Ana. I am from Mexico. I work in a bank. I like music."}
      ],
      "examples": [
        {"en": "I am Ana. I am from Mexico and I live in Madrid.", "es": "Soy Ana. Soy de México y vivo en Madrid."},
        {"en": "I work in a bank and I study English.", "es": "Trabajo en un banco y estudio inglés."},
        {"en": "I like music and my favorite sport is soccer.", "es": "Me gusta la música y mi deporte favorito es el fútbol."},
        {"en": "Now I can speak basic English.", "es": "Ahora puedo hablar inglés básico."}
      ],
      "practice": [
        {"instruction": "Completa: ''I ___ from Mexico'' (am / is / are)", "answer": "am"},
        {"instruction": "Traduce al inglés: ''Ella trabaja en un banco''", "answer": "She works in a bank."},
        {"instruction": "Traduce al inglés: ''Ahora puedo hablar inglés básico''", "answer": "Now I can speak basic English."}
      ]
    }'::jsonb,
    'https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-20.mp3',
    5,
    false,
    true
  )
  returning id into v_l20;

  -- ==========================================================================
  -- Quizzes — 1 por lección
  -- ==========================================================================
  insert into public.quizzes (lesson_id, title)
  values (v_l1, 'Quiz: Saludos y presentaciones') returning id into v_q1;

  insert into public.quizzes (lesson_id, title)
  values (v_l2, 'Quiz: Números del 1 al 20') returning id into v_q2;

  insert into public.quizzes (lesson_id, title)
  values (v_l3, 'Quiz: Verbo to be') returning id into v_q3;

  insert into public.quizzes (lesson_id, title)
  values (v_l4, 'Quiz: Preguntas y respuestas básicas') returning id into v_q4;

  insert into public.quizzes (lesson_id, title)
  values (v_l5, 'Quiz: Frases útiles para sobrevivir') returning id into v_q5;

  insert into public.quizzes (lesson_id, title)
  values (v_l6, 'Quiz: Mi familia') returning id into v_q6;

  insert into public.quizzes (lesson_id, title)
  values (v_l7, 'Quiz: La comida y las bebidas') returning id into v_q7;

  insert into public.quizzes (lesson_id, title)
  values (v_l8, 'Quiz: Rutinas diarias') returning id into v_q8;

  insert into public.quizzes (lesson_id, title)
  values (v_l9, 'Quiz: Presente simple: afirmaciones') returning id into v_q9;

  insert into public.quizzes (lesson_id, title)
  values (v_l10, 'Quiz: Presente simple: negaciones y preguntas') returning id into v_q10;

  insert into public.quizzes (lesson_id, title)
  values (v_l11, 'Quiz: Hacer preguntas') returning id into v_q11;

  insert into public.quizzes (lesson_id, title)
  values (v_l12, 'Quiz: De compras') returning id into v_q12;

  insert into public.quizzes (lesson_id, title)
  values (v_l13, 'Quiz: En el restaurante') returning id into v_q13;

  insert into public.quizzes (lesson_id, title)
  values (v_l14, 'Quiz: Pedir direcciones') returning id into v_q14;

  insert into public.quizzes (lesson_id, title)
  values (v_l15, 'Quiz: En la ciudad y el transporte') returning id into v_q15;

  insert into public.quizzes (lesson_id, title)
  values (v_l16, 'Quiz: Presentarte en detalle') returning id into v_q16;

  insert into public.quizzes (lesson_id, title)
  values (v_l17, 'Quiz: Hablar de tu día') returning id into v_q17;

  insert into public.quizzes (lesson_id, title)
  values (v_l18, 'Quiz: Expresar gustos y preferencias') returning id into v_q18;

  insert into public.quizzes (lesson_id, title)
  values (v_l19, 'Quiz: Conversaciones básicas en contexto') returning id into v_q19;

  insert into public.quizzes (lesson_id, title)
  values (v_l20, 'Quiz: Repaso y práctica final') returning id into v_q20;

  -- ==========================================================================
  -- Preguntas y respuestas
  -- ==========================================================================

  -- Quiz 1 (M1 · Saludos) — 3 MC + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q1, '¿Cómo dices ''hola'' de manera formal?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Hello', true, 1),
    (v_p, 'Bye', false, 2),
    (v_p, 'Thanks', false, 3),
    (v_p, 'Sorry', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q1, '¿Qué significa ''My name is Ana''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Mi nombre es Ana', true, 1),
    (v_p, 'Me gusta Ana', false, 2),
    (v_p, 'Ana es mi hermana', false, 3),
    (v_p, 'Soy de Ana', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q1, '''Nice to meet you'' significa ''mucho gusto''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q1, 'Completa: ''Hello, my ___ is Ana.''', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'name', true, 1);

  -- Quiz 2 (M1 · Números) — 2 MC + 1 fill_blank + 1 TF
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q2, '¿Cómo se dice ''tres'' en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Three', true, 1),
    (v_p, 'Two', false, 2),
    (v_p, 'Four', false, 3),
    (v_p, 'Ten', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q2, '¿Qué significa ''ten''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Diez', true, 1),
    (v_p, 'Uno', false, 2),
    (v_p, 'Cinco', false, 3),
    (v_p, 'Veinte', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q2, 'Escribe en inglés el número 7.', 'fill_blank', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'seven', true, 1);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q2, ''''Eleven'' significa ''doce''.', 'true_false', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Falso', true, 1),
    (v_p, 'Verdadero', false, 2);

  -- Quiz 3 (M1 · Verbo to be) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q3, '¿Qué forma del verbo to be usas con ''I''?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'am', true, 1),
    (v_p, 'is', false, 2),
    (v_p, 'are', false, 3),
    (v_p, 'be', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q3, 'Completa: ''She ___ my teacher.''', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'is', true, 1),
    (v_p, 'am', false, 2),
    (v_p, 'are', false, 3),
    (v_p, 'were', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q3, ''''We are friends'' significa ''nosotros somos amigos''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q3, 'Completa: ''They ___ happy.'' (am / is / are)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'are', true, 1);

  -- Quiz 4 (M1 · Preguntas básicas) — 2 MC + 1 TF
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q4, '¿Cómo respondes a ''How are you?''?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'I''m fine, thank you.', true, 1),
    (v_p, 'My name is Ana.', false, 2),
    (v_p, 'I''m ten.', false, 3),
    (v_p, 'Yes, I am.', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q4, '¿Qué significa ''No, she isn''t''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'No, ella no lo es', true, 1),
    (v_p, 'No, ella es', false, 2),
    (v_p, 'Sí, ella es', false, 3),
    (v_p, 'No sé', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q4, 'Para hacer una pregunta de sí/no se usa la estructura ''Are you...?''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  -- Quiz 5 (M1 · Frases útiles) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q5, '¿Cómo pides ayuda en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Can you help me?', true, 1),
    (v_p, 'I am fine.', false, 2),
    (v_p, 'Goodbye!', false, 3),
    (v_p, 'My name is...', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q5, '¿Qué significa ''Excuse me''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Disculpe', true, 1),
    (v_p, 'Gracias', false, 2),
    (v_p, 'Perdón por algo grave', false, 3),
    (v_p, 'Bienvenido', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q5, ''''Thank you'' significa ''gracias''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q5, 'Completa: ''I don''t ___ .'' (no entiendo)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'understand', true, 1);

  -- Quiz 6 (M2 · Familia) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q6, '¿Cómo se dice ''madre'' en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Mother', true, 1),
    (v_p, 'Father', false, 2),
    (v_p, 'Sister', false, 3),
    (v_p, 'Brother', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q6, '¿Qué significa ''I have two brothers''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Tengo dos hermanos', true, 1),
    (v_p, 'Tengo dos hermanas', false, 2),
    (v_p, 'Soy hermano', false, 3),
    (v_p, 'Dos hermanos me llaman', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q6, ''''This is my father'' significa ''este es mi padre''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q6, 'Completa: ''My ___ is a doctor.'' (padre)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'father', true, 1);

  -- Quiz 7 (M2 · Comida) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q7, '¿Cómo se dice ''pan'' en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Bread', true, 1),
    (v_p, 'Milk', false, 2),
    (v_p, 'Water', false, 3),
    (v_p, 'Rice', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q7, '¿Qué significa ''I don''t like milk''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'No me gusta la leche', true, 1),
    (v_p, 'Me gusta la leche', false, 2),
    (v_p, 'Quiero leche', false, 3),
    (v_p, 'Compro leche', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q7, 'Se dice ''an apple'' porque ''apple'' empieza con vocal.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q7, 'Completa: ''I like ___ .'' (agua)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'water', true, 1);

  -- Quiz 8 (M2 · Rutinas) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q8, '¿Cómo se dice ''despertarse'' en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Wake up', true, 1),
    (v_p, 'Sleep', false, 2),
    (v_p, 'Work', false, 3),
    (v_p, 'Eat', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q8, 'Con ''she'', el verbo en presente simple...', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Añade -s', true, 1),
    (v_p, 'No cambia', false, 2),
    (v_p, 'Se quita la -s', false, 3),
    (v_p, 'Se usa am', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q8, ''''I sleep at night'' significa ''duermo de noche''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q8, 'Completa: ''She ___ at seven.'' (despertarse)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'wakes up', true, 1);

  -- Quiz 9 (M2 · Presente simple: afirmaciones) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q9, '¿Qué significa ''I study English every day''?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Estudio inglés todos los días', true, 1),
    (v_p, 'Estudio inglés a veces', false, 2),
    (v_p, 'Nunca estudio inglés', false, 3),
    (v_p, 'Estudio inglés hoy', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q9, '¿Dónde se coloca ''always'' en una oración?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Antes del verbo', true, 1),
    (v_p, 'Al final de la oración', false, 2),
    (v_p, 'Después del verbo', false, 3),
    (v_p, 'Nunca se usa', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q9, 'Con ''he'' el verbo en presente simple añade -s.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q9, 'Completa: ''He ___ coffee.'' (beber, 3.ª persona)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'drinks', true, 1);

  -- Quiz 10 (M2 · Negaciones y preguntas) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q10, '¿Cómo dices ''no me gusta'' con ''I''?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'I don''t like', true, 1),
    (v_p, 'I doesn''t like', false, 2),
    (v_p, 'I not like', false, 3),
    (v_p, 'I no like', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q10, 'Con ''she'', la negación se forma con:', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'doesn''t', true, 1),
    (v_p, 'don''t', false, 2),
    (v_p, 'not', false, 3),
    (v_p, 'no', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q10, ''''Do you like tea?'' es una pregunta.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q10, 'Completa: ''She ___ like tea.'' (negación)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'doesn''t', true, 1);

  -- Quiz 11 (M3 · Hacer preguntas) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q11, '¿Qué palabra usas para preguntar por un lugar?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Where', true, 1),
    (v_p, 'What', false, 2),
    (v_p, 'When', false, 3),
    (v_p, 'Who', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q11, '¿Para qué se usa ''How much''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Para preguntar precios', true, 1),
    (v_p, 'Para preguntar por personas', false, 2),
    (v_p, 'Para preguntar por horas', false, 3),
    (v_p, 'Para preguntar por lugares', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q11, ''''When'' sirve para preguntar por el tiempo o el momento.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q11, 'Completa: ''___ is your name?'' (What / Where)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'What', true, 1);

  -- Quiz 12 (M3 · Compras) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q12, '¿Cómo preguntas el precio de algo?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'How much is this?', true, 1),
    (v_p, 'Where is this?', false, 2),
    (v_p, 'When is this?', false, 3),
    (v_p, 'What is this?', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q12, '¿Qué significa ''expensive''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Caro', true, 1),
    (v_p, 'Barato', false, 2),
    (v_p, 'Nuevo', false, 3),
    (v_p, 'Viejo', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q12, ''''I''d like'' significa ''me gustaría''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q12, 'Completa: ''How ___ is this shirt?'' (much / many)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'much', true, 1);

  -- Quiz 13 (M3 · Restaurante) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q13, '¿Cómo pides la cuenta en un restaurante?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'The bill, please.', true, 1),
    (v_p, 'The menu, please.', false, 2),
    (v_p, 'The water, please.', false, 3),
    (v_p, 'Goodbye!', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q13, '¿Qué significa ''delicious''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Delicioso', true, 1),
    (v_p, 'Caro', false, 2),
    (v_p, 'Frío', false, 3),
    (v_p, 'Rápido', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q13, ''''Can I have some water?'' es una forma de pedir agua.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q13, 'Completa: ''I''d ___ a menu, please.'' (like / likes)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'like', true, 1);

  -- Quiz 14 (M3 · Direcciones) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q14, '¿Cómo se dice ''izquierda'' en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Left', true, 1),
    (v_p, 'Right', false, 2),
    (v_p, 'Straight', false, 3),
    (v_p, 'Near', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q14, '¿Qué significa ''Go straight''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Siga recto', true, 1),
    (v_p, 'Gire a la izquierda', false, 2),
    (v_p, 'Gire a la derecha', false, 3),
    (v_p, 'Dé la vuelta', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q14, ''''The hotel is near the station'' significa que el hotel está cerca.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q14, 'Completa: ''Turn ___ at the corner.'' (izquierda)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'left', true, 1);

  -- Quiz 15 (M3 · Ciudad y transporte) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q15, '¿Cómo se dice ''autobús'' en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Bus', true, 1),
    (v_p, 'Train', false, 2),
    (v_p, 'Taxi', false, 3),
    (v_p, 'Ticket', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q15, '¿Qué pregunta ''How do I get to the airport?''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Cómo llegar al aeropuerto', true, 1),
    (v_p, 'Cuánto cuesta el aeropuerto', false, 2),
    (v_p, 'Dónde está el aeropuerto', false, 3),
    (v_p, 'Cuándo sale el avión', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q15, ''''I need a ticket'' significa ''necesito un boleto''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q15, 'Completa: ''Which ___ goes to the station?'' (bus / buses)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'bus', true, 1);

  -- Quiz 16 (M4 · Presentarte) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q16, '¿Cómo dices tu edad en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'I am twenty years old.', true, 1),
    (v_p, 'I have twenty.', false, 2),
    (v_p, 'I make twenty.', false, 3),
    (v_p, 'I am twenty years.', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q16, '¿Qué significa ''I am from Mexico''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Soy de México', true, 1),
    (v_p, 'Vivo en México', false, 2),
    (v_p, 'Me gusta México', false, 3),
    (v_p, 'Trabajo en México', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q16, ''''I live in Madrid'' significa ''vivo en Madrid''.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q16, 'Completa: ''I ___ from Mexico.'' (am / is / are)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'am', true, 1);

  -- Quiz 17 (M4 · Tu día) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q17, '¿Cómo se dice ''por la tarde''?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'In the afternoon', true, 1),
    (v_p, 'In the morning', false, 2),
    (v_p, 'At night', false, 3),
    (v_p, 'In the evening', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q17, '¿Qué significa ''I get up early''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Me levanto temprano', true, 1),
    (v_p, 'Me duermo temprano', false, 2),
    (v_p, 'Trabajo temprano', false, 3),
    (v_p, 'Ceno temprano', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q17, ''''In the evening I study English'' significa que estudias por la noche.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q17, 'Completa: ''I am ___ every day.'' (ocupado)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'busy', true, 1);

  -- Quiz 18 (M4 · Gustos) — 3 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q18, '¿Cómo se dice ''odiar'' en inglés?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Hate', true, 1),
    (v_p, 'Love', false, 2),
    (v_p, 'Like', false, 3),
    (v_p, 'Prefer', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q18, '¿Qué significa ''My favorite sport is soccer''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Mi deporte favorito es el fútbol', true, 1),
    (v_p, 'Odio el fútbol', false, 2),
    (v_p, 'No me gusta el fútbol', false, 3),
    (v_p, 'Juego fútbol', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q18, ''''I prefer tea to coffee'' significa que prefieres el té.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q18, 'Completa: ''I ___ music.'' (encantar)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'love', true, 1);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q18, '¿Qué expresa ''I hate getting up early''?', 'multiple_choice', 5)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Un disgusto', true, 1),
    (v_p, 'Un gusto', false, 2),
    (v_p, 'Una preferencia', false, 3),
    (v_p, 'Una rutina', false, 4);

  -- Quiz 19 (M4 · Conversaciones) — 2 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q19, '¿Cómo pides que hablen más lento?', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Can you speak slowly, please?', true, 1),
    (v_p, 'Can you say that again?', false, 2),
    (v_p, 'Goodbye!', false, 3),
    (v_p, 'I am tired.', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q19, '¿Qué significa ''Can you say that again?''?', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, '¿Puede repetir eso?', true, 1),
    (v_p, '¿Puede hablar lento?', false, 2),
    (v_p, '¿Qué significa eso?', false, 3),
    (v_p, 'Adiós', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q19, ''''What does it mean?'' se usa para preguntar el significado.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q19, 'Completa: ''Can you ___ slowly, please?'' (speak / talk)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'speak', true, 1);

  -- Quiz 20 (M4 · Repaso final) — 3 MC + 1 TF + 1 fill_blank
  insert into public.questions (quiz_id, question, type, "order")
  values (v_q20, 'Completa: ''She ___ in a bank.'' (work / works)', 'multiple_choice', 1)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'works', true, 1),
    (v_p, 'work', false, 2),
    (v_p, 'working', false, 3),
    (v_p, 'worked', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q20, '''I am from Mexico'' en una presentación habla de:', 'multiple_choice', 2)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'El origen', true, 1),
    (v_p, 'La edad', false, 2),
    (v_p, 'Los gustos', false, 3),
    (v_p, 'La rutina', false, 4);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q20, ''''I can speak basic English'' significa que puedo hablar inglés básico.', 'true_false', 3)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Verdadero', true, 1),
    (v_p, 'Falso', false, 2);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q20, 'Completa: ''She ___ in a bank.'' (3.ª persona)', 'fill_blank', 4)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'works', true, 1);

  insert into public.questions (quiz_id, question, type, "order")
  values (v_q20, '¿Qué pregunta ''How do you say ''hola'' in English?''?', 'multiple_choice', 5)
  returning id into v_p;
  insert into public.answers (question_id, answer, is_correct, "order") values
    (v_p, 'Cómo se dice algo', true, 1),
    (v_p, 'Saluda formalmente', false, 2),
    (v_p, 'Pide comida', false, 3),
    (v_p, 'Dice adiós', false, 4);

end $$;

-- ----------------------------------------------------------------------------
-- 3. Verificación
-- ----------------------------------------------------------------------------
select count(*) as lessons_count from public.lessons;
select count(*) as quizzes_count from public.quizzes;
select count(*) as questions_count from public.questions;
select count(*) as answers_count from public.answers;
-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:29:13.814242
-- Source: mini-ielts.com
-- Title: Mrs. Carlill and the Carbolic Smoke Ball
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-mrs-carlill-and-the-carbolic-smoke-ball',
    'Mrs. Carlill and the Carbolic Smoke Ball',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766600800/ielts/92170a_thumbpad_cedc041ede1a.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Mrs. Carlill and the Carbolic Smoke Ball',
    E'**Questions 1-4:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 5-8:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 9-12:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 13-13:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n---\n\n### Images for Questions 5-8\n\n\n![Question 5-8 Option A](https://res.cloudinary.com/df41zs8il/image/upload/v1766600804/ielts/diagram_7c265be8c793.jpg)\n',
    E'**Paragraph A.**\n\n**Paragraph A.**\\nOn 14 January 1892, Queen Victoria’s grandson Prince Albert Victor, second in line to the British throne, died from flu. He had succumbed to the third and most lethal wave of the Russian flu pandemic sweeping the world. The nation was shocked. The people mourned. Albert was relegated to a footnote in history. Three days later, London housewife Louisa Carlill went down with flu. She was shocked. For two months, she had inhaled thrice daily from a carbolic smoke ball, a preventive measure guaranteed to fend off flu - if you believed the advert. Which she did. And why shouldn’t she when the Carbolic Smoke Ball Company had promised to cough up £100 for any customer who fell ill? Unlike Albert, Louisa recovered, claimed her £100 and set in train events that would win her lasting fame. It started in the spring of 1889. The first reports of a flu epidemic came from Russia. By the end of the year, the world was in the grip of the first truly global flu pandemic. The disease came in waves, once a year for the next four years, and each worse than the last. Whole cities came to a standstill. London was especially hard-hit. As the flu reached each annual peak, normal life stopped. The postal service ground to a halt, trains stopped running, banks closed. Even courts stopped sitting for lack of judges. At the height of the third wave in 1892, 200 people were buried every day at just one London cemetery. This flu was far more lethal than previ­ous epidemics, and those who recovered were left weak, depressed, and often unfit for work. It was a picture repeated across the continent. Accurate figures for the number of the sick and dead were few and far between but Paris, Berlin and Vienna all reported a huge upsurge in deaths. The news­papers took an intense interest in the disease, not just because of the scale of it but because of who it attacked. Most epidemics carried off the poor and weak, the old and frail. This flu was cutting as great a swathe through the upper classes, dealing death to the rich and famous, and the young and fit. The newspaper-reading public was fed a daily diet of celebrity victims. The flu had worked its way through the Russian imperial family and invaded the royal palaces of Europe. It carried off the Dowager Empress of Germany and the second son of the king of Italy, as well as England’s future king. Aristocrats and politicians, poets and opera singers, bishops and cardinals - none escaped the attentions of the Russian flu. The public grew increasingly fearful. The press might have been overdoing the doom and gloom, but their hysterical coverage had exposed one terrible fact. The medical profession had no answer to the disease. This flu, which might ft not even have begun in Russia, was a mystery. What caused it and how did it spread? No one could agree on anything. By now, the theory that micro-organisms caused disease was gaining ground, g but no one had identified an organism responsible for flu (and wouldn’t until 1933). In the absence of a germ, many clung to the old idea of bad airs, or mi­asmas, possibly stirred by some great physical force - earthquakes, perhaps, or electrical phenomena in the upper atmosphere, even a passing comet. Doctors advised people to eat well avoiding “unnecessary assemblies”, and if they were really worried, to stuff cotton wool up their nostrils. If they fell ill, they should rest, keep warm and eat a nourishing diet of “milk, eggs and farinaceous puddings”. Alcohol figured prominently among the prescriptions: one eminent English doctor suggested champagne, although he conceded “brandy M in considerable quantities has sometimes been given with manifest advantages”. French doctors prescribed warm alcoholic drinks, arguing that they never saw an alcoholic with flu. Their prescription had immediate results: over a three-day period, 1,200 of the 1,500 drunks picked up on the streets of Paris claimed they were following doctor’s orders. Some doctors gave drugs to ease symptoms - quinine for fever, salicin for head­ache, heroin for an “incessant cough”. But nothing in the pharmacy remotely resembled a cure. Not surprisingly, people looked elsewhere for help. Hoping to cash in while the pandemic lasted, purveyors of patent medicines competed for the public’s custom with ever more outrageous advertisements. One of the most successful was the Carbolic Smoke Ball Company. The carbolic smoke ball was a hollow rubber ball, 5 centimetres across, with a nozzle covered by gauze. Inside was a powder treated with carbolic acid, or phenol. The idea was to clutch it close to the nose and squeeze gently, inhaling deeply from the emerging cloud of pungent powder. This, the company claimed, would disinfect the mucous membranes, curing any condition related to “taking cold”. In the summer of 1890, sales were steady at 300 smoke balls a month. In January 1891, the figure skyrocketed to 1,500.\\n\\n**Paragraph B.**\\nEager to exploit the public’s mounting panic, the Carbolic Smoke Ball Company made increasingly extravagant claims. Oh 13 November 1892, its latest advert in the Pall Mall Gazette caught the eye of south London housewife Louisa Carlill. “Carbolic Smoke Ball,” it declared, “will positively cure colds, coughs, asthma, bronchitis, hoarseness, influenza, croup, whooping cough ...”. And the list went on. But it was the next part Mrs. Carlill found compelling. “A £100 reward will be paid by the Carbolic Smoke Ball Company to any person who contracts the increasing epidemic influenza, colds or any disease caused by taking cold, after having used the carbolic smoke ball according to the printed directions supplied with each ball. £1,000 is deposited with the Alliance bank, Regent Street, showing our sincerity in the matter.” Mrs. Carlill hurried off to buy a smoke ball, price 10 shillings. After carefully reading the instructions, she diligently dosed herself thrice daily until 17 Janu­ary - when she fell ill. On 20 January, Louisa’s husband wrote to the Carbolic Smoke Ball Company. Unfortunately for them, Mr. Carlill happened to be a solicitor. His wife, he wrote, had seen their advert and bought a smoke ball on the strength of it. She had followed the instructions to the letter, and yet now - as their doctor could confirm - she had flu. There was no reply. But £100 was not a sum to be sneezed at. Mr. Carlill per­sisted. The company resisted. Louisa recovered and sued. In June, Mr. Justice Hawkins found in Mrs. Carlill’s favour. The company’s main defence was that adverts were mere “puffery” and only an idiot would believe such extravagant claims. Judge Hawkins pointed out that adverts were not aimed at the wise and thoughtful, but at the credulous and weak. A vendor who made a promise “must not be surprised if occasionally he is held to his promise”. Carbolic appealed. In December, three lord justices considered the case. Carbolic’s lawyers tried several lines of defence. But in the end, the case came down to a single matter: not whether the remedy was useless, or whether Carbolic had committed fraud, but whether its advert constituted a contract - which the company had broken. A contract required agreement between two parties, argued Carbolic’s lawyers. What agreement had Mrs. Carlill made with them?\\n\\n**Paragraph C.**\\nThere were times, the judges decided, when a contract could be one-sided. The advert had made a very specific offer to purchasers: protection from flu or £100. By using the smoke ball as instructed, Mrs. Carlill had accepted that offer. The company might just have wriggled out of if if it hadn’t added the bit about the £1,000 deposit. That, said the judges, gave buyers reason to believe Carbolic meant what it said. “It seems to me that if a person chooses to make extrava­gant promises of this kind, he probably does so because it pays him to make them, and, if he has made them, the extravagance of the promises is no reason in law why he should not be bound by them,” pron'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Cities rather than rural areas were badly affected by the pandemic flu.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'At the time of the flu pandemic, people didn''t know the link between micro-organisms and illnesses.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'People used to believe flu was caused by miasmas.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Flu prescriptions often contained harmful ingredients.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q5": ["GAUZE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q6": ["NOZZLE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q7": ["POWDER"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q8": ["RUBBER BALL"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Mrs. Carlill',
    '',
    '{"info-q9": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Mrs. Carlill’s husband',
    '',
    '{"info-q10": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Judge Hawkins',
    '',
    '{"info-q11": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Lord Justice Bowen',
    '',
    '{"info-q12": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'MCQ_SINGLE',
    'READING',
    2,
    'Why is Mrs. Carlill’s case often cited in present-day court trials?',
    '',
    '{"blank-q13": ["B", "b"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 4, E'## Questions 1-4\n\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 5, 8, E'## Questions 5-8\n\nComplete the diagram below.\n\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n![Diagram](http://images.mini-ielts.com/images/2017/9/diagram.jpg)');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 9, 12, E'## Questions 9-12\n\nLook at the following people (Questions 9-12) and the list of statements below.\n\nMatch each person with the correct statement.\n\nWrite the correct letter **A-F** in boxes 9-12 on your answer sheet.\n\n### List of Statements\n- **A.** Filed a complaint which was never responded to\n- **B.** Broke the contract made with Carbolic Smoke Ball Company\n- **C.** Initiated a legal case\n- **D.** Described the audience of advertisement\n- **E.** Claimed that most advertisements are fraudulent\n- **F.** Treated advertisement as a type of contract');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 4, 13, 13, E'## Questions 13-13\n\nChoose the correct letter, **A**, **B**, **C** or **D**.');

END$$;


COMMIT;
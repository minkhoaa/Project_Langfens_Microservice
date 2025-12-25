-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T22:30:02.483284
-- Source: mini-ielts.com
-- Title: The Invention of Television
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-the-invention-of-television
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-the-invention-of-television'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-invention-of-television';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-invention-of-television';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-the-invention-of-television';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-the-invention-of-television',
    'The Invention of Television',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766590037/ielts/the-invention-of-television_f9aa1e181157.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - The Invention of Television',
    E'## **Questions 1-7:**\n\nLook at the different significant people in the process of the invention of the television (questions 1-7) and match them to their roles in this process (A-G).\n\nWrite your answers in boxes 1-7 on your answer sheet.\n\n**Roles**\n- **A** His work was adopted by the BBC for their broadcasting business.\n- **B** His work was used to help fight crime.\n- **C** He was the first person to move on television.\n- **D** He used second hand parts in his invention.\n- **E** His business was destroyed by a financial crisis.\n- **F** He invented the image dissector.\n- **G** His work was initially of no interest to anyone.\n\n**1.** John Logie Baird\n**2.** William Taynton\n**3.** Philo Farnsworth\n**4.** Vladimir Zworykin\n**5.** Paul Nipkow\n**6.** Arthur Korn\n**7.** Charles Francis Jenkins\n\n---\n\n## **Questions 8-10:**\n\nLabel the diagram below.\nWrite **NO MORE THAN THREE WORDS** from the text for each answer.\n\n![Diagram](https://res.cloudinary.com/df41zs8il/image/upload/v1766590039/ielts/05-ielts-reading-q1-13-q8-10-1_bc6fbef299e9.jpg)\n\n**8.** (small) _______\n**9.** (a) _______\n**10.** (a) _______\n\n---\n\n## **Questions 11-13:**\n\nDo the following statements agree with the information given in the text?\nIn boxes 11-13 on your answer sheet write:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n**11.** Nipkow died without any of his work being widely recognized.\n**12.** Korn and Nipkow often met to discuss their work.\n**13.** Charles Francis Jenkins was already famous when he experimented with television.\n',
    E'**Paragraph A.**\n\\nThe question “Who invented television?” is simple enough, but the answer is surprisingly controversial. No one person was responsible for producing what we think of as television today and the credit is due to various inventors.\\n\\n**Paragraph B.**\n\\nThe Scotsman, John Logie Baird, is considered by many to be the inventor of television. He showed early signs of his inventing ingenuity by setting up a telephone exchange to connect his house to those of his friends near by. His first interest in television came in 1903, after he read a German book on the photoelectric properties of selenium. In 1873, this element was discovered to have the capacity to generate a current based on the amount of light applied to it. Working initially in Hastings, England, Baird famously created an apparatus using an old hatbox he bought in a used goods store, a pair of scissors, some needles, some bicycle light lenses and an old tea chest. Baird also used a Nipkow disk, created by German inventor, Paul Nipkow, and a lot of his work was based on the previous work by German, Arthur Korn. In February 1924, Baird demonstrated moving silhouette images on a ‘television’. Later that year, after nearly destroying the house and nearly killing himself with an electric shock, Baird moved to London, where he gave the first public display of his invention. On 2 October 1925, Baird used an office assistant, William Taynton, to move for his transmitted pictures, and Taynton became the first person to be televised moving and in full tonal range. Baird is also later credited with demonstrating the first images on colour television, on 3rd July 1928, although the credit for being the inventor of colour television is again disputed. Another first for Baird was transmitting the first television pictures across the Atlantic in 1928. Although Baird was well known for his invention, he also became famous for refusing an offer of £100,000 for the shares in his company, which was an enormous sum at that time. Baird famously said that he would not be able to sleep at night, knowing he had that much money.\\n\\n**Paragraph C.**\n\\nPhilo Farnsworth successfully demonstrated electronic television in San Francisco, in 1927, using a different system. Farnsworth realised that a picture could be dissected by a simple television camera into a series of lines of electricity. The lines would be transmitted so quickly that the eyes would merge the lines. Then, an image dissector, which Farnsworth created, would change those lines back into a picture. The Russian inventor, Vladimir Zworykin, built on this work and it was Zworykin’s designs that were eventually used by the BBC in the UK to replace Baird’s system.\\n\\n**Paragraph D.**\n\\nBaird’s initial work would not have been successful without the previous work of Paul Nipkow. Nipkow came up with the idea of ‘scanning’ a television image by using a spinning disk with a spiral of small pinholes. When spun at a high rate of speed, each hole would allow light to fall on a selenium cell on the other side of the disk. The amount of voltage the cell generated would depend on the amount of light reflected from the object being photographed. One rotation of the disk equalled one frame of “video”. At the place where the signal was received, the process would be reversed. A similar disk spun in sync and a neon lamp reacted to the changes in voltage with the speed required to keep up with the spinning disk and projected the images onto a screen. Although Nipkow created the disk and acquired a patent for his invention, he did not create the apparatus to project images. The patent expired after 15 years, as no one was interested then in the work. Baird’s first practical television systems used an electro-mechanical picture scanning method, the method that Nipkow had helped create with his disk. Nipkow became a celebrated scientist in Germany for his work, but the mechanical nature of the Nipkow Disk caused the invention to fade to obscurity with the use of the cathode ray tube.\\n\\n**Paragraph E.**\n\\nArthur Korn was another German scientist working in the same field as Baird and Nipkow and it was his work that allowed the development of Nipkow’s work that in turn led to Baird’s breakthroughs. Korn’s early work was focused on the transmission of visual telegraphic transmission, using his developments in amplification tube technology. He sent a picture of the German Crown Prince 1800 kilometres in 1906 and sent a picture of the Pope across the Atlantic in 1923. Korn’s work was celebrated and, from 1928, the German police used his technology to send photographs and fingerprints.\\n\\n**Paragraph F.**\n\\nFinally, another American, Charles Francis Jenkins, has a claim to be the inventor of television. Jenkins, who at the time was very well known for inventing the motion picture projector, first transmitted a silhouette picture from one room to another in 1922. Jenkins founded a broadcasting company in 1928, but the crash of 1929 forced him out of business. Most people agree that Baird gave his first public demonstration of television a couple years earlier than Jenkins, but this is disputed in some places.\\n\\n**Paragraph G.**\n\\nIt is plain to see why any claim to be the inventor of television is said to be controversial. In many cases, the answer to the question, “Who invented television?”, often just depends on from which country the person answering the question is.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_FEATURES',
    'READING',
    2,
    'John Logie Baird',
    '',
    '{"feature-q1": ["D", "D"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. His work was adopted by the BBC for their broadcasting business.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. His work was used to help fight crime.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He was the first person to move on television.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He used second hand parts in his invention.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. His business was destroyed by a financial crisis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. He invented the image dissector.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. His work was initially of no interest to anyone.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_FEATURES',
    'READING',
    2,
    'William Taynton',
    '',
    '{"feature-q2": ["C", "C"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. His work was adopted by the BBC for their broadcasting business.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. His work was used to help fight crime.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He was the first person to move on television.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He used second hand parts in his invention.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. His business was destroyed by a financial crisis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. He invented the image dissector.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. His work was initially of no interest to anyone.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Philo Farnsworth',
    '',
    '{"feature-q3": ["F", "F"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. His work was adopted by the BBC for their broadcasting business.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. His work was used to help fight crime.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He was the first person to move on television.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He used second hand parts in his invention.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. His business was destroyed by a financial crisis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. He invented the image dissector.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. His work was initially of no interest to anyone.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Vladimir Zworykin',
    '',
    '{"feature-q4": ["A", "A"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. His work was adopted by the BBC for their broadcasting business.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. His work was used to help fight crime.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He was the first person to move on television.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He used second hand parts in his invention.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. His business was destroyed by a financial crisis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. He invented the image dissector.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. His work was initially of no interest to anyone.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Paul Nipkow',
    '',
    '{"feature-q5": ["G", "G"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. His work was adopted by the BBC for their broadcasting business.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. His work was used to help fight crime.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He was the first person to move on television.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He used second hand parts in his invention.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. His business was destroyed by a financial crisis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. He invented the image dissector.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. His work was initially of no interest to anyone.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Arthur Korn',
    '',
    '{"feature-q6": ["B", "B"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. His work was adopted by the BBC for their broadcasting business.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. His work was used to help fight crime.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He was the first person to move on television.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He used second hand parts in his invention.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. His business was destroyed by a financial crisis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. He invented the image dissector.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. His work was initially of no interest to anyone.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Charles Francis Jenkins',
    '',
    '{"feature-q7": ["E", "E"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. His work was adopted by the BBC for their broadcasting business.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. His work was used to help fight crime.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He was the first person to move on television.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He used second hand parts in his invention.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. His business was destroyed by a financial crisis.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. He invented the image dissector.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. His work was initially of no interest to anyone.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'DIAGRAM_LABEL',
    'READING',
    2,
    '(small) _______',
    '',
    '{"blank-q8": ["PINHOLES"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'DIAGRAM_LABEL',
    'READING',
    2,
    '(a) _______',
    '',
    '{"blank-q9": ["SELENIUM CELL"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'DIAGRAM_LABEL',
    'READING',
    2,
    '(a) _______',
    '',
    '{"blank-q10": ["NEON LAMP"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Nipkow died without any of his work being widely recognized.',
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
    12,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Korn and Nipkow often met to discuss their work.',
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
    13,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Charles Francis Jenkins was already famous when he experimented with television.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 7, E'## Questions 1-7\n\nLook at the different significant people in the process of the invention of the television (questions 1-7) and match them to their roles in this process (A-G).\n\n**Roles**\n- **A** His work was adopted by the BBC for their broadcasting business.\n- **B** His work was used to help fight crime.\n- **C** He was the first person to move on television.\n- **D** He used second hand parts in his invention.\n- **E** His business was destroyed by a financial crisis.\n- **F** He invented the image dissector.\n- **G** His work was initially of no interest to anyone.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 8, 10, E'## Questions 8-10\n\nLabel the diagram below.\nWrite **NO MORE THAN THREE WORDS** from the text for each answer.\n\n![Diagram](https://res.cloudinary.com/df41zs8il/image/upload/v1766590039/ielts/05-ielts-reading-q1-13-q8-10-1_bc6fbef299e9.jpg)');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 11, 13, E'## Questions 11-13\n\nDo the following statements agree with the information given in the text?\nIn boxes 11-13 on your answer sheet write:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this');

END$$;


COMMIT;
-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:04:14.320343
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #13
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-13
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-13'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-13';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-13';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-13';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-13',
    'IELTS Reading Sample (Academic) #13',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #13',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - IELTS Reading Sample (Academic) #13',
    E'# Passage\n\nAcademic Reading Passage 31\nIn Praise of Amateurs\nDespite the specialization of scientific research, amateurs still have an important role to play\nDuring the scientific revolution of the 17th century, scientists were largely men of private means who pursued their interest in natural philosophy for their own edification. Only in the past century or two has it become possible to make a living from investigating the workings of nature. Modern science was, in other words, built on the work of amateurs. Today, science is an increasingly specialized and compartmentalized subject, the domain of experts who know more and more about less and less. Perhaps surprisingly, however, amateurs – even those without private means – are still important.\nA recent poll carried out at a meeting of the American Association for the Advancement of Science by astronomer Dr Richard Fienberg found that, in addition to his field of astronomy, amateurs are actively involved in such field as acoustics, horticulture, ornithology, meteorology, hydrology and palaeontology. Far from being crackpots, amateur scientists are often in close touch with professionals, some of whom rely heavily on their co-operation.\nAdmittedly, some fields are more open to amateurs than others. Anything that requires expensive equipment is clearly a no-go area. And some kinds of research can be dangerous; most amateur chemists, jokes Dr Fienberg, are either locked up or have blown themselves to bits. But amateurs can make valuable contributions in fields from rocketry to palaeontology and the rise of the internet has made it easier than before to collect data and distribute results.\nExactly which field of study has benefited most from the contributions of amateurs is a matter of some dispute. Dr Fienberg makes a strong case for astronomy. There is, he points out, a long tradition of collaboration between amateur and professional sky watchers. Numerous comets, asteroids and even the planet Uranus were discovered by amateurs. Today, in addition to comet and asteroid spotting, amateurs continue to do valuable work observing the brightness of variable stars and detecting novae- ‘new’ stars in the Milky Way and supernovae in other galaxies. Amateur observers are helpful, says Dr Fienberg, because there are so many of them (they far outnumber professionals) and because they are distributed all over the world. This makes special kinds of observations possible:’ if several observers around the world accurately record the time when a star is eclipsed by an asteroid, for example, it is possible to derive useful information about the asteroid’s shape.\nAnother field in which amateurs have traditionally \nplayed an important role is palaeontology. Adrian Hunt, a palaeontologist at \nMesa Technical College in New Mexico, insists that his is the field in which \namateurs have made the biggest contribution. Despite the development of \nhigh-tech equipment, he says, the best sensors for finding fossils are human \neyes – lots of them.\nFinding volunteers to look for fossils \nis not difficult, he says, because of the near –universal interest in anything \nto do with dinosaurs. As well as helping with this research, volunteers learn \nabout science, a process he calls ‘recreational education’.\nRick Bonney of the Cornell Laboratory of Ornithology in Ithaca, New York, contends that amateurs have contributed the most in his field. There are, he notes, thought to be as many as 60 million birdwatchers in America alone. Given their huge numbers and the wide geographical coverage they provide, Mr Bonney has enlisted thousands of amateurs in a number of research projects. Over the past few years their observations have uncovered previously unknown trends and cycles in bird migrations and revealed declines in the breeding populations of several species of migratory birds, prompting a habitat conservation programme.\nDespite the successes and whatever the field of study, collaboration between amateurs and professionals is not without its difficulties. Not everyone, for example is happy with the term ‘amateur’. Mr Bonney has coined the term ‘citizen scientist’ because he felt that other words, such as ‘volunteer’ sounded disparaging. A more serious problem is the question of how professionals can best acknowledge the contributions made by amateurs. Dr Fienberg says that some amateur astronomers are happy to provide their observations but grumble about not being reimbursed for out-of-pocket expenses. Others feel let down when their observations are used in scientific papers, but they are not listed as co-authors. Dr Hunt says some amateur palaeontologists are disappointed when told that they cannot take finds home with them.\nThese are legitimate concerns but none seems insurmountable. Provided amateurs and professionals agree the terms on which they will work together beforehand, there is no reason why co-operation between the two groups should not flourish. Last year Dr S. Carlson, founder of the Society for Amateur Scientists won an award worth $290,000 for his work in promoting such co-operation. He says that one of the main benefits of the prize is the endorsement it has given to the contributions of amateur scientists, which has done  much to silence critics among those professionals who believe science should remain their exclusive preserve.\nAt the moment, says Dr Carlson, the society is involved in several schemes including an innovative rocket-design project and the setting up of a network of observers who will search for evidence of a link between low- frequency radiation and earthquakes. The amateurs, he says, provide enthusiasm and talent, while the professionals provide guidance ‘so that anything they do discover will be taken seriously’. Having laid the foundations of science, amateurs will have much to contribute to its ever – expanding edifice.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Amateur involvement can also be an instructive pastime.',
    'Choose the correct answer.',
    '{"info-q1": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Amateur scientists are prone to accidents.',
    'Choose the correct answer.',
    '{"info-q2": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Science does not belong to professional scientists alone.',
    'Choose the correct answer.',
    '{"info-q3": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'In certain areas of my work, people are a more valuable resource than technology.',
    'Choose the correct answer.',
    '{"info-q4": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'It is important to give amateurs a name which reflects the value of their work.',
    'Choose the correct answer.',
    '{"info-q5": ["C", "c"]}'
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nPrior to the 19th century, professional (1) did not exist and scientific \n	research was largely carried out by amateurs. However, while (2) today is mostly the domain of professionals, \n	a recent US survey highlighted the fact that amateurs play an important role in \n	at least seven (3) and indeed \n	many professionals are reliant on their (4) In areas such as astronomy, amateurs can be invalua',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q6": ["scientists"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nPrior to the 19th century, professional (1) did not exist and scientific \n	research was largely carried out by amateurs. However, while (2) today is mostly the domain of professionals, \n	a recent US survey highlighted the fact that amateurs play an important role in \n	at least seven (3) and indee _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q7": ["science"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nPrior to the 19th century, professional (1) did not exist and scientific \n	research was largely carried out by amateurs. However, while (2) today is mostly the domain of professionals, \n	a recent US survey highlighted the fact that amateurs play an important role in \n	at least seven (3) and indee _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q8": ["fields"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nPrior to the 19th century, professional (1) did not exist and scientific \n	research was largely carried out by amateurs. However, while (2) today is mostly the domain of professionals, \n	a recent US survey highlighted the fact that amateurs play an important role in \n	at least seven (3) and indee _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["co-operation", "collaboration"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nPrior to the 19th century, professional (1) did not exist and scientific \n	research was largely carried out by amateurs. However, while (2) today is mostly the domain of professionals, \n	a recent US survey highlighted the fact that amateurs play an important role in \n	at least seven (3) and indee _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["observations"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nPrior to the 19th century, professional (1) did not exist and scientific \n	research was largely carried out by amateurs. However, while (2) today is mostly the domain of professionals, \n	a recent US survey highlighted the fact that amateurs play an important role in \n	at least seven (3) and indee _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["dinosaurs"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nPrior to the 19th century, professional (1) did not exist and scientific \n	research was largely carried out by amateurs. However, while (2) today is mostly the domain of professionals, \n	a recent US survey highlighted the fact that amateurs play an important role in \n	at least seven (3) and indee _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["conservation programme"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nPrior to the 19th century, professional (1) did not exist and scientific \n	research was largely carried out by amateurs. However, while (2) today is mostly the domain of professionals, \n	a recent US survey highlighted the fact that amateurs play an important role in \n	at least seven (3) and indee _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["acknowledge"]}'::jsonb
  );


END$$;


COMMIT;
-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T22:43:22.515114
-- Source: mini-ielts.com
-- Title: Astronaut ice cream, anyone
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-astronaut-ice-cream-anyone
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-astronaut-ice-cream-anyone'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-astronaut-ice-cream-anyone';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-astronaut-ice-cream-anyone';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-astronaut-ice-cream-anyone';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-astronaut-ice-cream-anyone',
    'Astronaut ice cream, anyone',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/11/28/astronaut-ice-cream-anyone_thumbpad.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Astronaut ice cream, anyone',
    E'**Questions 1-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n---\n\n### Images for Questions 6-9\n\n\n![Question 6-9 Option A](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/ip3/diagram.jpg)\n',
    E'**Paragraph A.**\\nBreeze-drying is a technique that can help to provide food for astronauts. But it also has other applications nearer home.\\n\\n**Paragraph B.**\\nFreeze-drying is like suspended animation for food: you can store a freeze-dried meal for years, and then, when you’re finally ready to eat it. you can completely revitalise it with a little hot water. Even after several years, the original foodstuff will be virtually unchanged.\\n\\n**Paragraph C.**\\nThe technique basically involves completely removing the water from some material, such as food while leaving the rest of the material virtually intact. The main reason for doing this is either to preserve the food or to reduce its weight. Removing the water from food keeps it from spoiling, because the microorganisms such as bacteria that cause spoiling cannot survive without it. Similarly, the enzymes which occur naturally in food cannot cause ripening without water, so removing water from food will also stop the ripening process.\\n\\n**Paragraph D.**\\nFreeze-drying significantly reduces the total weight of the food because most food is largely made up of water; for example, many fruits are more than 80 00% water. Removing this makes the food much lighter and therefore makes transportation less difficult. The military and camping-supply companies freeze-dry foods to make them easier for an individual to carry and NASA has also freeze-dried foods for the cramped quarters on board spacecraft.\\n\\n**Paragraph E.**\\nThe process is also used to preserve other sorts of material, such as pharmaceuticals. Chemists can greatly extend pharmaceutical shelf life by freeze-drying the material and storing it in a container free of oxygen and water. Similarly, research scientists may use freeze-drying to preserve biological samples for long periods of time. Even valuable manuscripts that had been water damaged have been saved by using this process.\\n\\n**Paragraph F.**\\nFreeze-drying is different from simple drying because it is able to remove almost all the water from materials, whereas simple drying techniques can only remove 90-95%. This means that the damage caused by bacteria and enzymes can virtually be stopped rather than just slowed down. In addition, the composition and structure of the material is not significantly changed, so materials can be revitalised without compromising the quality of the original.\\n\\n**Paragraph G.**\\nThis is possible because in freeze-drying, solid water - ice - is converted directly into water vapour, missing out the liquid phase entirely. This is called ‘sublimation’, the shift from a solid directly into a gas. Just like evaporation, sublimation occurs when a molecule gains enough energy to break free from the molecules around it. Water will sublime from a solid (ice) to a gas (vapour) when the molecules have enough energy to break free but the conditions aren''t right for a liquid to form. These conditions arc determined by heat and atmospheric pressure. When the temperature is above freezing point, so that ice can thaw, but the atmospheric pressure is too low for a liquid to form (below 0.06 atmospheres (ATM)) then it becomes a gas.\\n\\n**Paragraph H.**\\nTh is is the principle on which a freeze-drying machine is based. The material to be preserved is placed in a freeze-drying chamber which is connected to a freezing coil and refrigerator compressor. When the chamber is sealed the compressor lowers the temperature inside it. I he material is frozen solid, which separates the water from everything around it on a molecular level, even though the water is still present. Next, a vacuum pump forces air out of the chamber, lowering the atmospheric pressure below to 0.06 ATM. The heating units apply a small amount of heat to the shelves in the chamber, causing the ice to change phase. Since the pressure in the chamber is so low, the ice turns directly into water vapour, which leaves the freeze-drying chamber, and flows past the freezing coil. The water vapour condenses onto the freezing coil in the form of solid ice, in the same way that water condenses as frost on a cold day.\\n\\n**Paragraph I.**\\nThe process continues for many hours (even days) while the material gradually dries out. This time is necessary to avoid overheating, which might affect the structure of the material. Once it has dried sufficiently, it is sealed in a moisture-free package. As long as the package is secure, the material can sit on a shelf for years and years without degrading, until it is restored to its original form with a little hot water. If everything works correctly, the material will go through the entire process almost completely unscathed.\\n\\n**Paragraph J.**\\nIn fact, freeze-drying, as a general concept, is not new but has been around for centuries. The ancient Incas of Peru used mountain peaks along the Andes as natural food preservers. The extremely cold temperatures and low pressure at those high altitudes prevented food from spoiling in the same basic way as a modern freeze-drying machine and a freezer.\\n\\n\n---\n\n## Diagram/Image for Questions 6-9\n\n![Questions 6-9](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/ip3/diagram.jpg)\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'easy _______ of food items',
    '',
    '{"blank-q1": ["TRANSPORTATION"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'long-term storage of _______ and biological samples',
    '',
    '{"blank-q2": ["PHARMACEUTICALS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'preservation of precious _______',
    '',
    '{"blank-q3": ["MANUSCRIPTS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'is based on process of _______ is more efficient than',
    '',
    '{"blank-q4": ["SUBLIMATION"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'is more efficient than _______',
    '',
    '{"blank-q5": ["SIMPLE DRYING"]}'::jsonb
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
    '{"blank-q6": ["CHAMBER"]}'::jsonb
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
    '{"blank-q7": ["SHELVES"]}'::jsonb
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
    '{"blank-q8": ["FREEZING COIL"]}'::jsonb
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
    '_______',
    '',
    '{"blank-q9": ["COMPRESSOR"]}'::jsonb
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
    'Freeze-drying prevents food from going bad by stopping the activity of microorganisms or _______ Its advantages are that the food tastes and feels the same as the original because both the and structure are preserved.',
    '',
    '{"blank-q10": ["ENZYMES"]}'::jsonb
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
    'Its advantages are that the food tastes and feels the same as the original because both the _______ and structure are preserved.',
    '',
    '{"blank-q11": ["COMPOSITION"]}'::jsonb
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
    'The process is carried out slowly in order to ensure that _______ does not take place.',
    '',
    '{"blank-q12": ["OVERHEATING"]}'::jsonb
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
    'The people of one ancient mountain civilisation were able to use this method of food preservation because the conditions needed were present at _______ .',
    '',
    '{"blank-q13": ["HIGH ALTITUDES"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 5, E'## Questions 1-5\n\nComplete the notes below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 6, 9, E'## Questions 6-9\n\nLabel the diagram below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n![Diagram](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/ip3/diagram.jpg)');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 10, 13, E'## Questions 10-13\n\nComplete the summary below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.');

END$$;


COMMIT;
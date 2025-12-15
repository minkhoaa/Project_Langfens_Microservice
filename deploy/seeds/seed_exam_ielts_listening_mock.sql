BEGIN;

-- Reset the listening mock so it can be re-run safely.
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id"
  FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'listeing-test'
);

DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'listeing-test';

DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'listeing-test';

DELETE FROM exams
WHERE "Slug" = 'listeing-test';

INSERT INTO exams ("Id", "Slug", "Title", "DescriptionMd", "Category", "Level", "Status", "DurationMin", "CreatedAt", "UpdatedAt")
VALUES ('b493d316-6ebc-457f-922f-2e4b358b4a00', 'listeing-test', 'LISTENING TEST', 'string', 'IELTS', 'string', 'PUBLISHED', 0, '2025-11-17 09:10:35.060634 +00:00', '2025-11-17 09:10:50.361638 +00:00');

INSERT INTO exam_sections ("Id", "ExamId", "Idx", "Title", "InstructionsMd", "AudioUrl", "TranscriptMd") VALUES ('21712048-4a02-4d0f-9c7d-c97027d9826e', 'b493d316-6ebc-457f-922f-2e4b358b4a00', 1, 'LISTENING TEST', 'string', 'https://s4-media1.study4.com/media/simulation_ielts/sim_0101.mp3', 'Good morning. Ase accommodation. How can I help you? Good morning. I''d like to organize some short stay accommodation on the Gold Coast, please. Certainly. Who am I speaking to? Miss McKinley. Sylvia McKinley. Could you spell your family name for me, please? It''s M-A-C-K-I-N-L-A-Y. The client''s family name is McKinley, so McKinley has been written in the space. Now we shall begin. You should answer the questions as you listen, because you will not hear the recording a second time. Listen carefully and answer questions one to five. Good morning. Ase accommodation. How can I help you? Good morning. I''d like to organize some short stay accommodation on the Gold Coast, please. Certainly. Who am I speaking to? Miss McKinley. Sylvia McKinley. Could you spell your family name for me, please? It''s M-A-C-K-I-N-L-A-Y. Thank you. And your first name is Sylvia. Yes. Is that with an "I" or a "Y"? A "Y" the old fashioned way. That''s S-Y-L-V-I-A. Thank you, Miss McKinley. Now, just for our records, can you tell me what country you live in? Of course. It''s England, actually. I thought so. Now, when are you coming? Well, at the moment, we''re planning on arriving on July 26th. Oh, the 25th. That''s the last day of the public holiday, and it might be difficult to find something available on that date. No. We''re coming on the 26th of July. Oh, well, that''s fine then. We''ll have lots of good places vacant by then, although you wouldn''t be able to move in until late afternoon, because our cleaning crew will need time to get everything ready for you. That suit, sirs. Our flight won''t get in until early evening anyway. How many of you will there be? Just my sister and myself, and how long do you intend to stay for? Oh, only a couple of weeks. We''d like to stay longer, but we''ll have to get back to work. So, you''re not coming on business then? No, it''s just a holiday. Why, what difference does that make? Oh, you''d be surprised. Business people have different needs. You know, wireless internet, even fax machines and photocopiers. No, we won''t need any of that stuff. We''ll be coming to relax and get away from all that kind of thing. Good. Now, what exactly are you looking for? A house, a duplex, or an apartment? What''s a duplex? Oh, that''s what you might call a townhouse or a unit. You know, two houses semi-detached on the same property. Oh, I see. I think an apartment will suit us just fine. And how many bedrooms? Two. One or two, it depends on the size. My sister and I don''t mind sharing if it''s a decent sized bedroom with two beds. Well, that makes it easier. And car parking. Will you require a lock-up garage? They''re a little harder to find with an apartment. We''ll have a higher car, and as far as I know, there are no regulations concerning car parking. I think as long as it''s not parked on the street and it''s secure, there shouldn''t be any problems. Okay. Now, I''m assuming you want something by the beach. Yes, that''s the idea. We want to enjoy the surf sand and sunshine. Okay. But before we settle on an area and discuss your price range, I''ll need to know about other necessities. What do you mean? Well, for example, do you want to be close to a shopping mall or the casino or the fun parks? Or do you want to be in a complex, with or nearest swimming pool? No, none of that really matters to us. But we''d like to have reasonable access to the motorway so that we can drive up to Brisbane to visit friends there. Well, there are quite a few lovely small towns to choose from. There''s main beach, which is north of Cerfas Paradise, or mermaid waters, which is a bit further south, or palm beach, which is quite a bit further south. Mermaid water sounds delightful. Is it close to the motorway? Well, not really. The M1 is actually closest to palm beach, and prices are likely to be more reasonable there, too. That''s settled then. Palm beach it is. Now, if you''ll just give me your email address, I can send you information about the town and lots of photos. Well, my email is smac13@hotmail.com. And one final thing. How much are you looking to spend per week on accommodation? Do you want something at the luxury end of the market? You know, newly redecorated, great views, all the mod cons. Not necessarily. Could we get something clean, comfortable, and reasonable for $1,200 a week? Could you stretch that to $1,500 a week? I''ve got a property in mind that you''ll absolutely love, but you''d have to go to $1,500. $1,200 wouldn''t cover it. All right then, but that''s our top limit. Good. I''ll get onto this straight away, and there should be something in your inbox shortly.');

INSERT INTO exam_questions ("Id", "SectionId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptRegex", "BlankAcceptTexts", "MatchPairs", "OrderCorrects", "ShortAnswerAcceptRegex", "ShortAnswerAcceptTexts") VALUES ('88cbe75f-bec8-48af-8832-dfb8e4f2e94e', '21712048-4a02-4d0f-9c7d-c97027d9826e', 2, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 2, e'## Question 1
Speaker says the new policy will start next month.', null, null, null, null, null, null, null);
INSERT INTO exam_questions ("Id", "SectionId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptRegex", "BlankAcceptTexts", "MatchPairs", "OrderCorrects", "ShortAnswerAcceptRegex", "ShortAnswerAcceptTexts") VALUES ('84e1f3a6-4da1-49b1-b1c0-cca6e9792ce7', '21712048-4a02-4d0f-9c7d-c97027d9826e', 1, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 2, e'## Question 2
Speaker says the new policy will start next month.', null, null, null, null, null, null, null);

INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect") VALUES ('1a4a736e-a58e-4235-8c4a-0905bb5de0e5', '88cbe75f-bec8-48af-8832-dfb8e4f2e94e', 2, 'Option 2', false);
INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect") VALUES ('e6909db1-1239-48ad-9269-b47124464db4', '88cbe75f-bec8-48af-8832-dfb8e4f2e94e', 3, 'Option 1', true);
INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect") VALUES ('8e393a33-1310-4883-b0c0-82b1b8ef3413', '88cbe75f-bec8-48af-8832-dfb8e4f2e94e', 1, 'Option 3', false);
INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect") VALUES ('6717a15b-db0b-460a-bc05-284015c47b98', '84e1f3a6-4da1-49b1-b1c0-cca6e9792ce7', 2, 'Option 1', false);
INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect") VALUES ('7884b5a1-c788-492c-8b24-2de049362134', '84e1f3a6-4da1-49b1-b1c0-cca6e9792ce7', 1, 'Option 3', true);

COMMIT;

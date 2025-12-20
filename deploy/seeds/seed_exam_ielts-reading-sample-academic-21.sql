-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:03:20.163905
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #21
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-21
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-21'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-21';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-21';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-21';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-21',
    'IELTS Reading Sample (Academic) #21',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #21',
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
    'Reading Passage - IELTS Reading Sample (Academic) #21',
    E'# Passage\n\nAcademic Reading Passage 41\nIs there more to video games than people realize?\nMany people who spend a lot of time playing video games insist that they have helped them in areas like confidence-building, presentation skills and debating. Yet this way of thinking about video games can be found almost nowhere within the mainstream media, which still tend to treat games as an odd mix of the slightly menacing and the alien. This lack of awareness has become increasingly inappropriate, as video games and the culture that surrounds them have become very big business indeed.\nRecently, the British government released the Byron report into the effects of electronic media on children. Its conclusions set out a clear, rational basis for exploring the regulation of video games. The ensuing debate, however, has descended into the same old squabbling between partisan factions: the preachers of mental and moral decline, and the innovative game designers. In between are the gamers, busily buying and playing while nonsense is talked over their heads.\nSusan Greenfield, renowned neuroscientist, outlines her concerns in a new book. Every individual’s mind is the product of a brain that has been personalized by the sum total of their experiences; with an increasing quantity of our experiences from very early childhood taking place ‘on screen’ rather than in the world, there is potentially a profound shift in the way children’s minds work. She suggests that the fast-paced, second-hand experiences created by video games and the Internet may inculcate a worldview that is less empathetic, more risk-taking and less contemplative than what we tend to think of as healthy.\nGreenfield’s prose is full of mixed metaphors and self-contradictions and is perhaps the worst enemy of her attempts to persuade. This is unfortunate, because however much technophiles may snort, she is articulating widely held fears that have a basis in fact. Unlike even their immediate antecedents, the latest electronic media are at once domestic and work-related, their mobility blurring the boundaries between these spaces, and video games are at their forefront. A generational divide has opened that is in many ways more profound than the equivalent shifts associated with radio or television, more alienating for those unfamiliar with new’ technologies, more absorbing for those who are. So how do our lawmakers regulate something that is too fluid to be fully comprehended or controlled?\nAdam Martin, a lead programmer for an online games developer, says:’ Computer games teach and people don’t even notice they’re being taught.’ But isn’t the kind of learning that goes on in games rather narrow? ‘A large part of the addictiveness of games does come from the fact that as you play you are mastering a set of challenges. But humanity’s larger understanding of the world comes primarily through communication and experimentation, through answering the question “What if?’ Games excel at teaching this too.’\nSteven Johnson’s thesis is not that electronic games constitute a great, popular art, but that the mean level of mass culture has been demanding steadily more intellectual engagement from consumers. Games, he points out, generate satisfaction via the complexity of their virtual worlds, not by their robotic predictability. Testing the nature and limits of the laws of such imaginary worlds has more in common with scientific methods than with a pointless addiction, while the complexity of the problems children encounter within games exceeds that of anything they might find at school.\nGreenfield argues that there are ways of thinking that playing video games simply cannot teach. She has a point. We should never forget, for instance, the unique ability of books to engage and expand the human imagination, and to give us the means of more fully expressing our situations in the world. Intriguingly, the video games industry is now growing in ways that have more in common with an old-fashioned world of companionable pastimes than with a cyber future of lonely, isolated obsessives. Games in which friends and relations gather round a console to compete at activities are growing in popularity. The agenda is increasingly being set by the concerns of mainstream consumers – what they consider acceptable for their children, what they want to play at parties and across generations.\nThese trends embody a familiar but important truth: games are human products, and lie within our control. This doesn’t mean we yet control or understand them fully, but it should remind us that there is nothing inevitable or incomprehensible about them. No matter how deeply it may be felt, instinctive fear is an inappropriate response to technology of any kind.\nSo far, the dire predictions many traditionalists have made about the ‘death’ of old-fashioned narratives and imaginative thought at the hands of video games cannot be upheld. Television and cinema may be suffering, economically, at the hands of interactive media. But literacy standards have failed to decline. Young people still enjoy sport, going out and listening to music And most research – including a recent $1.5m study funded by the US government – suggests that even pre-teens are not in the habit of blurring game worlds and real worlds.\nThe sheer pace and scale of the changes we face, however, leave little room for complacency. Richard Battle, a British writer and game researcher, says Times change: accept it; embrace it.’ Just as, today, we have no living memories of a time before radio, we will soon live in a world in which no one living experienced growing up without computers. It is for this reason that we must try to examine what we stand to lose and gain, before it is too late.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Much media comment ignores the impact that video games can have on many people’s lives.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The publication of the Byron Report was followed by a worthwhile discussion between those for and against video games.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Susan Greenfield’s way of writing has become more complex over the years.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'It is likely that video games will take over the role of certain kinds of books in the future.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'More sociable games are being brought out to satisfy the demands of the buying public.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Being afraid of technological advances is a justifiable reaction.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the writer, what view about video games does Susan Greenfield put forward in tier new book?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They are exposing a child to an adult view of the world too soon.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Children become easily frightened by some of the situations in them.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They are changing the way children’s view of the world develops.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Children don’t learn from them because they are too repetitive.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the writer, what problems are faced when regulating video games?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The widespread and ever-changing use of games makes it difficult for lawmakers to control them.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The appeal of the games to a younger generation isn’t really understood by many lawmakers.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The lawmakers try to apply the same rules to the games as they did to radio and television.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Many lawmakers feel it is too late for the regulations to have much effect on the use of games.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What main point does Adam Martin make about video games?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. People are learning how to avoid becoming addicted to them.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. They enable people to learn without being aware of it happening.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They satisfy a need for people to compete with each other.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. People learn a narrow range of skills but they are still useful.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following does Steven Johnson disagree with?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Athe opinion that video games offer educational benefits to the user', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bthe attitude that video games are often labelled as predictable and undemanding', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cthe idea that children’s logic is tested more by video games than at school', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dthe suggestion that video games can be compared to scientific procedures', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following is the most suitable subtitle forReading Passage?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. A debate about the effects of video games on other forms of technology.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. An examination of the opinions of young people about video games.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. A discussion of whether attitudes towards video games are outdated.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. An analysis of the principles behind the historical development of video games.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'There is little evidence for the traditionalists’ prediction that',
    'Choose the correct answer.',
    '{"info-q12": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A recent study by the US government found that',
    'Choose the correct answer.',
    '{"info-q13": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Richard Battle suggests that it Is important for people to accept the fact that',
    'Choose the correct answer.',
    '{"info-q14": ["C", "c"]}'
  );


END$$;


COMMIT;
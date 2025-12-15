BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-bite-that-heat-1406'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-bite-that-heat-1406';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-bite-that-heat-1406';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-bite-that-heat-1406';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('eadd97f2-8515-55c9-a032-694be8af096e', 'ielts-reading-the-bite-that-heat-1406', $t$The Bite That Heat$t$, $md$## The Bite That Heat

Nguồn:
- Test: https://mini-ielts.com/1406/reading/the-bite-that-heat
- Solution: https://mini-ielts.com/1406/view-solution/reading/the-bite-that-heat$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('59129449-22fa-53c7-9770-d733427603bb', 'eadd97f2-8515-55c9-a032-694be8af096e', 1, $t$Reading — The Bite That Heat$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Bite That Heat

Scientists are unlocking the medical potential of venom.

A Michael decided to go for a swim. He was on vacation with his family in Guerrero, Mexico, and it was hotter than blazes. He grabbed his swimming trunks from where they’d been drying on a chair, slid them on, and jumped into the pool. Instead of cool relief, a burning pain ripped through the back of his thigh. Tearing off his trunks, he leaped naked from the pool, his leg on fire. Behind him a small, ugly, yellow creature was treading water. He scooped it into a Tupperware container, and the caretaker of the house rushed him to the local Red Cross facility, where doctors immediately identified his attacker: a bark scorpion, Centruroides sculpturatus, one of the most venomous species in North America. The fierce pain from a sting is typically followed by what feels like electric shocks racking the body. Occasionally victims die.

B Luckily for Michael (who asked me not to give his Ml name), the bark scorpion is common in the area, and antivenom was readily available. He had an injection and was released a few hours later. In about 30 hours the pain was gone. What happened next could not have been predicted. For eight years Michael had endured a condition called ankylosing spondylitis, a chronic autoimmune disease of the skeleton, a sort of spinal arthritis. No one knows what triggers it. In the worst cases the spine may fuse, leaving the patient forever stooped and in anguish. “My back hurt every morning, and during bad flare-ups it was so horrible I couldn’t even walk,” he says.

C But days after the the scorpion sting, the pain went away, and now, two years later, he remains essentially pain free and off most of his medications. As a doctor himself, Michael is cautious about overstating the role of the scorpion’s venom in his remission. Still, he says, “if my pain came back, I’d let that scorpion sting me again.” Venom-the stuff that drips from the fangs and stingers of creatures lurking on the hiking trail or hiding in the cellar or under the woodpile—is nature’s most efficient killer. Venom is exquisitely honed to stop a body in its tracks. The complex soup swirls with toxic proteins and peptides——short strings of amino acids similar to proteins. The molecules may have different targets and effects, but they work synergistically for the mightiest punch. Some go for the nervous system, paralyzing by blocking messages between nerves and muscle. Some eat away at molecules so that cells and tissues collapse. Venom can kill by clotting blood and stopping the heart or by preventing clotting and triggering a killer bleed.

D All venom is multifaceted and multitasking. (The difference between venom and poison is that venom is injected, or dibbled, into victims by way of specialized body parts, and poison is ingested.) Dozens, even hundreds, of toxins can be delivered in a single bite, some with redundant jobs and others with unique ones. In the evolutionary arms race between predator and prey, weapons and defenses are constantly tweaked. Drastically potent concoctions can result: Imagine administering poison to an adversary, then jabbing him with a knife, then finishing him off with a bullet to the head. That’s venom at work.

E Ironically, the properties that make venom deadly are also what make it so valuable for medicine. Many venom toxins target the same molecules that need to be controlled to treat diseases. Venom works fast and is highly specific. Its active components—those peptides and proteins, working as toxins diabetes have been derived from venom. New treatments for autoimmune diseases, cancer, and pain could be available within a decade.

F “We aren’t talking just a few novel drugs but entire classes of drugs,” says National Geographic Society Emerging Explorer Zoltan Takacs, a toxinologist and herpetologist. So far, fewer than a thousand toxins have been scrutinized for medicinal value, and a dozen or so major drugs have made it to market. “There could be upwards of 20 million venom toxins out there waiting to be screened,” Takacs says. “It’s huge. Venom has opened up whole new avenues of pharmacology.” Toxins from venom and poison sources are also giving us a clearer picture of how proteins that control many of the body’s crucial cellular functions work. Studies of the deadly poison tetrodotoxin (TTX) from puffer fish, for instance, have revealed intricate details about the way nerve cells communicate.

G “We ’re motivated to look for new compounds to lessen human suffering,” Angel Yanagihara of the University of Hawaii told me. “But while doing that, you may uncover things you don’t expect.” Driven in part out of revenge for a box jellyfish sting she endured 15 years ago, Yanagihara discovered a potential wound-healing agent within the tubules that contain jellyfish venom. “It had nothing to do with the venom itself,” she said. “By getting intimate with a noxious animal, I’ve been informed way beyond my expectations.”

H More than 100,000 animals have evolved to produce venom, along with the glands to house it and the apparatuses to expel it: snakes, scorpions, spiders, a few lizards, bees, sea creatures such as octopuses, numerous species of fish, and cone snails. The male duck-billed platypus, which carries venom inside ankle spurs, is one of the few venomous mammals. Venom and its components emerged independently, again and again, in different animal groups. The composition of the venom of a single snake species varies from place to place and between adults and their young. An individual snake’s venom may even change with its diet.

I Although evolution has been fine-tuning these compounds for more than a hundred million years, venom’s molecular architecture has been in place much longer. Nature repurposes key molecules from around the body—the blood, brain, digestive tract, and elsewhere—to serve animals for predation or protection. “It makes sense for nature to steal the scaffolds already in place,” Takacs says. “To make a toxin to wreck the nervous system, it’s most efficient to take a template from the brain that already works in that system, make some tiny changes, and there you have it: Now it’s a toxin.” Not all venom kills, of course—bees have it as a nonlethal defense, and the male platypus uses it to show rival males who’s boss during mating season. But mostly it’s for killing, or at least immobilizing, an animal’s next meal. Humans are often accidental victims. The World Health Organization estimates that every year some five million bites kill 100,000 people, although the actual number is presumed to be much higher. In rural areas of developing countries, where most bites occur, victims may not be able to get treatment or may instead choose traditional therapies and are therefore not counted.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('67b99fab-b4be-5be5-952b-76e7e9d86881', '59129449-22fa-53c7-9770-d733427603bb', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

1 ____ Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ceb669d5-d46c-5897-9541-8e6d3097be02', '67b99fab-b4be-5be5-952b-76e7e9d86881', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b8cdc51-2e85-58f2-aa55-83920f7fc469', '67b99fab-b4be-5be5-952b-76e7e9d86881', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8f52877-c4e5-5db5-9646-91567e1c77b6', '67b99fab-b4be-5be5-952b-76e7e9d86881', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7892aa64-2525-5ace-9e5a-0f3e618b299d', '59129449-22fa-53c7-9770-d733427603bb', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

2 ____ The disease Michael had suffered from for eight years was caused by an accident$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20881efa-cc3b-5f89-82b8-6a3c27ecba0a', '7892aa64-2525-5ace-9e5a-0f3e618b299d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9a29349-eed7-51b2-b22a-992a94f3fd50', '7892aa64-2525-5ace-9e5a-0f3e618b299d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e45b273e-8ea4-538a-a2b2-20708cab5be4', '7892aa64-2525-5ace-9e5a-0f3e618b299d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3e728bce-0aa6-5784-8903-2ee4d95c3fdb', '59129449-22fa-53c7-9770-d733427603bb', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

3 ____ Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6f58bcc-2435-5e70-8ccc-c45e5ca39218', '3e728bce-0aa6-5784-8903-2ee4d95c3fdb', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47c2328a-dfbf-5c19-bf05-675e1d96d139', '3e728bce-0aa6-5784-8903-2ee4d95c3fdb', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbe79ef8-8068-57b6-a8d6-d5f401ccfb52', '3e728bce-0aa6-5784-8903-2ee4d95c3fdb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b7acd871-43f3-5cd7-a84c-1ec2a8996a96', '59129449-22fa-53c7-9770-d733427603bb', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

4 ____ No venom is just responsible for one job.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26b84d91-04e8-539e-9ec0-21e1045e9e16', 'b7acd871-43f3-5cd7-a84c-1ec2a8996a96', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28e1d621-0113-58a7-9590-acde3f56725d', 'b7acd871-43f3-5cd7-a84c-1ec2a8996a96', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e7fed3c-cb5a-5e49-827b-f0a2adb1c7f6', 'b7acd871-43f3-5cd7-a84c-1ec2a8996a96', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5306bf62-fa2a-5c5f-9765-c6a290f3ee78', '59129449-22fa-53c7-9770-d733427603bb', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

5 ____ There is no difference between venom and poison.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97b69357-0ea9-5029-b213-e6fdbdc643b1', '5306bf62-fa2a-5c5f-9765-c6a290f3ee78', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06b63c4b-0f5d-513c-829a-34c985b7706d', '5306bf62-fa2a-5c5f-9765-c6a290f3ee78', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c488543-2c28-58c4-a593-9e47866dcd42', '5306bf62-fa2a-5c5f-9765-c6a290f3ee78', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('537872b6-c9fd-5336-a461-80dab83d051f', '59129449-22fa-53c7-9770-d733427603bb', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

6 ____ Venom can kill while it can also be used as medicine to save.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c0b31ae-2e6f-58f0-a6ae-66806fc505f2', '537872b6-c9fd-5336-a461-80dab83d051f', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f78242eb-b210-5b07-8df0-39a1a83e8dff', '537872b6-c9fd-5336-a461-80dab83d051f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be7e6367-99cb-5675-81b2-5723e616204a', '537872b6-c9fd-5336-a461-80dab83d051f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d354018-7a71-5ff9-8d0a-acb57577e95f', '59129449-22fa-53c7-9770-d733427603bb', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

7 ____ New treatments for cancer are now available in the market.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a5c5640-6a47-5212-8afa-773d6d96fab6', '2d354018-7a71-5ff9-8d0a-acb57577e95f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5182035-2e6a-5e89-9abd-499655504683', '2d354018-7a71-5ff9-8d0a-acb57577e95f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cc973d2-f9c1-529a-91ba-11cf0d1651f6', '2d354018-7a71-5ff9-8d0a-acb57577e95f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('12050b5c-31e8-5a4f-9aa8-806262aa256c', '59129449-22fa-53c7-9770-d733427603bb', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

8 ____ So far 20 million venom toxins have been checked for medical use.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5b459e5-38f2-5afd-818a-8fb28c891f72', '12050b5c-31e8-5a4f-9aa8-806262aa256c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('149d006d-7d2f-57a6-9c4b-01e81d6cc4ea', '12050b5c-31e8-5a4f-9aa8-806262aa256c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76b78642-49c0-5f68-b763-3200844b41ae', '12050b5c-31e8-5a4f-9aa8-806262aa256c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('235b42f0-67ba-59f9-af17-77f2630e6822', '59129449-22fa-53c7-9770-d733427603bb', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 1-9
Questions 1-9
Do the following statements agree with the information given in Reading Passage？
In boxes
1-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Michael was unluckily hit by electric shocks and nearly lost his life during his vacation.
2
The disease Michael had suffered from for eight years was caused by an accident
3
Michael is grateful for the bark scorpion bite because it helped him recover from the ankylosing spondylitis.
4
No venom is just responsible for one job.
5
There is no difference between venom and poison.
6
Venom can kill while it can also be used as medicine to save.
7
New treatments for cancer are now available in the market.
8
So far 20 million venom toxins have been checked for medical use.
9
The majority of mammals carry venom inside their bodies.

9 ____ The majority of mammals carry venom inside their bodies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c635330-6141-5a24-9d46-f91f8cec98fc', '235b42f0-67ba-59f9-af17-77f2630e6822', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ccb259b-bb45-5c4f-bd98-65ab72008772', '235b42f0-67ba-59f9-af17-77f2630e6822', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e4e0610-c840-5ce2-8ebf-3ffbefffc0de', '235b42f0-67ba-59f9-af17-77f2630e6822', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f2ccfdc0-f9c6-5e29-b934-1477c0d76d1b', '59129449-22fa-53c7-9770-d733427603bb', 10, 'FORM_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Complete the sentences below.
Choose
NO MORE THAN TWO words
from the Reading Passage for each answer. Write your answers in boxes
10-14
on your answer sheet.
10
The way how venom works is compared to that of .
11
A venom source such as has helped to present complex facts about how nerve cells convey information to each other.
12
Tens of thousands of animals have developed and which are respectively responsible for storing and letting out venom.
13
The makeup of venom of a snake may change with places, ages and .
14
Some animal uses venom to warn of its exclusive power during the mating season.

10 ____ The way how venom works is compared to that of .$md$, NULL, ARRAY['.*medicines.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bf388b2a-6bc4-58f5-bcd3-4dcc9498e0df', '59129449-22fa-53c7-9770-d733427603bb', 11, 'FORM_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Complete the sentences below.
Choose
NO MORE THAN TWO words
from the Reading Passage for each answer. Write your answers in boxes
10-14
on your answer sheet.
10
The way how venom works is compared to that of .
11
A venom source such as has helped to present complex facts about how nerve cells convey information to each other.
12
Tens of thousands of animals have developed and which are respectively responsible for storing and letting out venom.
13
The makeup of venom of a snake may change with places, ages and .
14
Some animal uses venom to warn of its exclusive power during the mating season.

11 ____ A venom source such as has helped to present complex facts about how nerve cells convey information to each other.$md$, NULL, ARRAY['.*puffer.*fish.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2b2e22bd-fe21-519f-810b-30ef0517434f', '59129449-22fa-53c7-9770-d733427603bb', 12, 'FORM_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Complete the sentences below.
Choose
NO MORE THAN TWO words
from the Reading Passage for each answer. Write your answers in boxes
10-14
on your answer sheet.
10
The way how venom works is compared to that of .
11
A venom source such as has helped to present complex facts about how nerve cells convey information to each other.
12
Tens of thousands of animals have developed and which are respectively responsible for storing and letting out venom.
13
The makeup of venom of a snake may change with places, ages and .
14
Some animal uses venom to warn of its exclusive power during the mating season.

12 ____ Tens of thousands of animals have developed and which are respectively responsible for storing and letting out venom.$md$, NULL, ARRAY['.*glands.*apparatuses.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fe934180-c398-55a7-afb4-fca43669f67b', '59129449-22fa-53c7-9770-d733427603bb', 13, 'FORM_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Complete the sentences below.
Choose
NO MORE THAN TWO words
from the Reading Passage for each answer. Write your answers in boxes
10-14
on your answer sheet.
10
The way how venom works is compared to that of .
11
A venom source such as has helped to present complex facts about how nerve cells convey information to each other.
12
Tens of thousands of animals have developed and which are respectively responsible for storing and letting out venom.
13
The makeup of venom of a snake may change with places, ages and .
14
Some animal uses venom to warn of its exclusive power during the mating season.

13 ____ The makeup of venom of a snake may change with places, ages and .$md$, NULL, ARRAY['.*diet.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4c84d534-7f55-5cc3-b153-ccfef67eba55', '59129449-22fa-53c7-9770-d733427603bb', 14, 'FORM_COMPLETION', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Complete the sentences below.
Choose
NO MORE THAN TWO words
from the Reading Passage for each answer. Write your answers in boxes
10-14
on your answer sheet.
10
The way how venom works is compared to that of .
11
A venom source such as has helped to present complex facts about how nerve cells convey information to each other.
12
Tens of thousands of animals have developed and which are respectively responsible for storing and letting out venom.
13
The makeup of venom of a snake may change with places, ages and .
14
Some animal uses venom to warn of its exclusive power during the mating season.

14 ____ Some animal uses venom to warn of its exclusive power during the mating season.$md$, NULL, ARRAY['.*rival.*males.*']);

COMMIT;

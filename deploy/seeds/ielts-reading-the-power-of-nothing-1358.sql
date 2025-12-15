BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-power-of-nothing-1358'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-power-of-nothing-1358';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-power-of-nothing-1358';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-power-of-nothing-1358';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8a918532-6205-53ec-929e-fd664753dcb7', 'ielts-reading-the-power-of-nothing-1358', $t$The Power of Nothing$t$, $md$## The Power of Nothing

Nguồn:
- Test: https://mini-ielts.com/1358/reading/the-power-of-nothing
- Solution: https://mini-ielts.com/1358/view-solution/reading/the-power-of-nothing$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('180a35e9-26ef-56d1-83f2-addb6dddf159', '8a918532-6205-53ec-929e-fd664753dcb7', 1, $t$Reading — The Power of Nothing$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Power of Nothing

Geoff Watts, New Scientist (May 26th, 2001)

A

Want to devise a new form of alternative medicine? No problem. Here is the recipe. Be warm, sympathetic, reassuring and enthusiastic. Your treatment should involve physical contact, and each session with your patients should last at least half an hour. Encourage your patients to take an active part in their treatment and understand how their disorders relate to the rest of their lives. Tell them that their own bodies possess the true power to heal. Make them pay you out of their own pockets. Describe your treatment in familiar words, but embroidered with a hint of mysticism: energy fields, energy flows, energy blocks, meridians, forces, auras, rhythms and the like. Refer to the knowledge of an earlier age: wisdom carelessly swept aside by the rise and rise of blind, mechanistic science. Oh, come off it, you are saying. Something invented off the top of your head could not possibly work, could it?

B

Well yes, it could – and often well enough to earn you a living. A good living if you are sufficiently convincing, or better still, really believe in your therapy. Many illnesses get better on their own, so if you are lucky and administer your treatment at just the right time you will get the credit. But that’s only part of it. Some of the improvement really would be down to you. Your healing power would be the outcome of a paradoxical force that conventional medicine recognizes but remains oddly ambivalent about: the placebo effect.

C

Placebos are treatments that have no direct effect on the body, yet still, work because the patient has faith in their power to heal. Most often the term refers to a dummy pill, but it applies just as much to any device or procedure, from a sticking plaster to a crystal to an operation. The existence of the placebo effect implies that even quackery may confer real benefits, which is why any mention of placebo is a touchy subject for many practitioners of complementary and alternative medicine, who are likely to regard it as tantamount to a charge of charlatanism. In fact, the placebo effect is a powerful part of all medical care, orthodox or otherwise, though its role is often neglected or misunderstood.

D

One of the great strengths of CAM may be its practitioners’ skill in deploying the placebo effect to accomplish real healing. “Complementary practitioners are miles better at producing non-specific effects and good therapeutic relationships,” says Edzard Ernst, professor of CAM at Exeter University. The question is whether CAM could be integrated into conventional medicines, as some would like, without losing much of this power.

E

At one level, it should come as no surprise that our state of mind can influence our physiology: anger opens the superficial blood vessels of the face; sadness pumps the tear glands. But exactly how placebos work their medical magic is still largely unknown. Most of the scant research done so far has focused on the control of pain because it’s one of the commonest complaints and lends itself to experimental study. Here, attention has turned to the endorphins, morphine-like neurochemicals known to help control pain.

F

But exactly how placebos work their medical magic is still largely unknown. Most of the scant research to date has focused on the control of pain because it’s one of the commonest complaints and lends itself to experimental study. Here, attention has turned to the endorphins, natural counterparts of morphine that are known to help control pain. “Any of the neurochemicals involved in transmitting pain impulses or modulating them might also be involved in generating the placebo response,” says Don Price, an oral surgeon at the University of Florida who studies the placebo effect in dental pain.

G

“But endorphins are still out in front.” That case has been strengthened by the recent work of Fabrizio Benedetti of the University of Turin, who showed that the placebo effect can be abolished by a drug, naloxone, which blocks the effects of endorphins. Benedetti induced pain in human volunteers by inflating a blood-pressure cuff on the forearm. He did this several times a day for several days, using morphine each time to control the pain. On the final day, without saying anything, he replaced the morphine with a saline solution. This still relieved the subjects’ pain: a placebo effect. But when he added naloxone to the saline the pain relief disappeared. Here was direct proof that placebo analgesia is mediated, at least in part, by these natural opiates.

H

Still, no one knows how belief triggers endorphin release, or why most people can’t achieve placebo pain relief simply by willing it. Though scientists don’t know exactly how placebos work, they have accumulated a fair bit of knowledge about how to trigger the effect. A London rheumatologist found, for example, that red dummy capsules made more effective painkillers than blue, green or yellow ones. Research on American students revealed that blue pills make better sedatives than pink, a colour more suitable for stimulants. Even branding can make a difference: if Aspro or Tylenol is what you like to take for a headache, their chemically identical generic equivalents may be less effective.

I

It matters, too, how the treatment is delivered. Decades ago, when the major tranquilliser chlorpromazine was being introduced, a doctor in Kansas categorised his colleagues according to whether they were keen on it, openly skeptical of its benefits, or took a “let’s try and see” attitude. His conclusion: the more enthusiastic the doctor, the better the drug performed. And this year Ernst surveyed published studies that compared doctors’ bedside manners. The studies turned up one consistent finding: “Physicians who adopt a warm, friendly and reassuring manner,” he reported, “are more effective than those whose consultations are formal and do not offer reassurance.”

J

Warm, friendly and reassuring are precisely CAM’s strong suits, of course. Many of the ingredients of that opening recipe – the physical contact, the generous swathes of time, the strong hints of supernormal healing power – are just the kind of thing likely to impress patients. It’s hardly surprising, then, that complementary practitioners are generally best at mobilising the placebo effect, says Arthur Kleinman, professor of social anthropology at Harvard University.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e9b839c-16f6-517f-8528-91ed4f353ad8', '180a35e9-26ef-56d1-83f2-addb6dddf159', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Use the information in the passage to match the deed (listed
A-H
) with people below.
Write the appropriate letters
A-H
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
A
Should easily be understood
B
Should improve by itself
C
Should not involve any mysticism
D
Ought to last a minimum length of time.
E
Needs to be treated at the right time.
F
Should give more recognition.
G
Can earn valuable money.
H
Do not rely on any specific treatment
1
Appointments with an alternative practitioner
2
An alternative practitioner’s description of the treatment
3
An alternative practitioner who has faith in what he does
4
the illness of patients convinced of alternative practice
5
Improvements of patients receiving alternative practice
6
Conventional medical doctors (who is aware of placebo)

1 ____ Appointments with an alternative practitioner$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2429fb5-5909-5628-9de2-984fd9577e95', '4e9b839c-16f6-517f-8528-91ed4f353ad8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('319794a0-3b53-53b0-9e4a-0cdabc872c54', '4e9b839c-16f6-517f-8528-91ed4f353ad8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('350ce13c-9400-5dc6-ba61-ff28ad697b26', '4e9b839c-16f6-517f-8528-91ed4f353ad8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf874b88-40cd-53a9-b55c-b76b784fe789', '4e9b839c-16f6-517f-8528-91ed4f353ad8', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89e98eef-c8f9-5e32-b8a9-5978c0e836d6', '4e9b839c-16f6-517f-8528-91ed4f353ad8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ac99c8e-5c04-551b-b4fb-fa810b17e995', '4e9b839c-16f6-517f-8528-91ed4f353ad8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9d29890-605c-5588-9bba-365009581440', '4e9b839c-16f6-517f-8528-91ed4f353ad8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d10b89a0-43e2-5503-89b9-299fc9f81fee', '4e9b839c-16f6-517f-8528-91ed4f353ad8', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b7cee872-f787-5f4e-ac68-bc4feb4b0611', '180a35e9-26ef-56d1-83f2-addb6dddf159', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Use the information in the passage to match the deed (listed
A-H
) with people below.
Write the appropriate letters
A-H
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
A
Should easily be understood
B
Should improve by itself
C
Should not involve any mysticism
D
Ought to last a minimum length of time.
E
Needs to be treated at the right time.
F
Should give more recognition.
G
Can earn valuable money.
H
Do not rely on any specific treatment
1
Appointments with an alternative practitioner
2
An alternative practitioner’s description of the treatment
3
An alternative practitioner who has faith in what he does
4
the illness of patients convinced of alternative practice
5
Improvements of patients receiving alternative practice
6
Conventional medical doctors (who is aware of placebo)

2 ____ An alternative practitioner’s description of the treatment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86811985-a960-593c-bf82-da7f90768c46', 'b7cee872-f787-5f4e-ac68-bc4feb4b0611', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19c15a43-be1d-5b25-9291-da7cbc5f25cc', 'b7cee872-f787-5f4e-ac68-bc4feb4b0611', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cce5356-71bd-57b0-a51f-119aa04b7474', 'b7cee872-f787-5f4e-ac68-bc4feb4b0611', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3668d981-56fe-5adf-8086-13c3213e1f37', 'b7cee872-f787-5f4e-ac68-bc4feb4b0611', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6236d88a-53dd-52dc-b449-98728b762c9e', 'b7cee872-f787-5f4e-ac68-bc4feb4b0611', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8615bf45-1ceb-5a08-8129-45392d0fb7cd', 'b7cee872-f787-5f4e-ac68-bc4feb4b0611', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('485dcc1b-28eb-5b10-bac1-abcead6709b4', 'b7cee872-f787-5f4e-ac68-bc4feb4b0611', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('518cb793-4b7f-5d8b-8993-88fe4b14bb6f', 'b7cee872-f787-5f4e-ac68-bc4feb4b0611', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3c42f211-3685-5a5d-8d4e-2c236f22e7e6', '180a35e9-26ef-56d1-83f2-addb6dddf159', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Use the information in the passage to match the deed (listed
A-H
) with people below.
Write the appropriate letters
A-H
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
A
Should easily be understood
B
Should improve by itself
C
Should not involve any mysticism
D
Ought to last a minimum length of time.
E
Needs to be treated at the right time.
F
Should give more recognition.
G
Can earn valuable money.
H
Do not rely on any specific treatment
1
Appointments with an alternative practitioner
2
An alternative practitioner’s description of the treatment
3
An alternative practitioner who has faith in what he does
4
the illness of patients convinced of alternative practice
5
Improvements of patients receiving alternative practice
6
Conventional medical doctors (who is aware of placebo)

3 ____ An alternative practitioner who has faith in what he does$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c0bc944-6ebf-5405-85eb-edbc83a856c7', '3c42f211-3685-5a5d-8d4e-2c236f22e7e6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46848cb8-ac2b-50ae-8c55-8553827ded3d', '3c42f211-3685-5a5d-8d4e-2c236f22e7e6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11d9b361-e932-5e1b-8603-9e5eda190bfd', '3c42f211-3685-5a5d-8d4e-2c236f22e7e6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35cd3b6f-fbd1-512f-bff3-96eec9df09f7', '3c42f211-3685-5a5d-8d4e-2c236f22e7e6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('996697ae-2eab-56f3-a7e3-220b26146cd9', '3c42f211-3685-5a5d-8d4e-2c236f22e7e6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8109790c-0b9a-5070-a89c-3f644e6eab86', '3c42f211-3685-5a5d-8d4e-2c236f22e7e6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5975e0cd-4672-505d-8f8e-4ee9d387bc7e', '3c42f211-3685-5a5d-8d4e-2c236f22e7e6', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcc67d71-dda8-5173-a943-23baa8e805b5', '3c42f211-3685-5a5d-8d4e-2c236f22e7e6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6b9c1583-e440-5591-ae5f-dc43314f4fd5', '180a35e9-26ef-56d1-83f2-addb6dddf159', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Use the information in the passage to match the deed (listed
A-H
) with people below.
Write the appropriate letters
A-H
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
A
Should easily be understood
B
Should improve by itself
C
Should not involve any mysticism
D
Ought to last a minimum length of time.
E
Needs to be treated at the right time.
F
Should give more recognition.
G
Can earn valuable money.
H
Do not rely on any specific treatment
1
Appointments with an alternative practitioner
2
An alternative practitioner’s description of the treatment
3
An alternative practitioner who has faith in what he does
4
the illness of patients convinced of alternative practice
5
Improvements of patients receiving alternative practice
6
Conventional medical doctors (who is aware of placebo)

4 ____ the illness of patients convinced of alternative practice$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41152a2a-6e32-5e16-8b76-ff78f6045d6b', '6b9c1583-e440-5591-ae5f-dc43314f4fd5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fb13909-3644-5573-85f5-b324bf54c548', '6b9c1583-e440-5591-ae5f-dc43314f4fd5', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c41148bb-87f1-5b4a-a9c8-70e7da349b17', '6b9c1583-e440-5591-ae5f-dc43314f4fd5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('499eeb30-f9ce-5eee-bcc9-db0cff8faa64', '6b9c1583-e440-5591-ae5f-dc43314f4fd5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efa6c9fb-a50d-5335-80c7-4635404e1f0b', '6b9c1583-e440-5591-ae5f-dc43314f4fd5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0eb2b522-4642-5248-a9c5-ec090fff3a9e', '6b9c1583-e440-5591-ae5f-dc43314f4fd5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64416007-9d5c-5a7e-a619-b458716146af', '6b9c1583-e440-5591-ae5f-dc43314f4fd5', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07a37946-21d7-5ee8-8154-cd4da24c10c9', '6b9c1583-e440-5591-ae5f-dc43314f4fd5', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d3d3a5a-7da6-56c1-989c-8129f16c9556', '180a35e9-26ef-56d1-83f2-addb6dddf159', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Use the information in the passage to match the deed (listed
A-H
) with people below.
Write the appropriate letters
A-H
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
A
Should easily be understood
B
Should improve by itself
C
Should not involve any mysticism
D
Ought to last a minimum length of time.
E
Needs to be treated at the right time.
F
Should give more recognition.
G
Can earn valuable money.
H
Do not rely on any specific treatment
1
Appointments with an alternative practitioner
2
An alternative practitioner’s description of the treatment
3
An alternative practitioner who has faith in what he does
4
the illness of patients convinced of alternative practice
5
Improvements of patients receiving alternative practice
6
Conventional medical doctors (who is aware of placebo)

5 ____ Improvements of patients receiving alternative practice$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('052c8521-b52a-553c-88f1-6ca8bd6a53a6', '2d3d3a5a-7da6-56c1-989c-8129f16c9556', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f30c6bb-5b22-5c1b-8c60-50db9cb2167c', '2d3d3a5a-7da6-56c1-989c-8129f16c9556', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54464e79-aa92-5f13-8a39-06a2960287ac', '2d3d3a5a-7da6-56c1-989c-8129f16c9556', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69462ec4-f6d0-5ab5-8b3a-9cf0661fa8eb', '2d3d3a5a-7da6-56c1-989c-8129f16c9556', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d8b3344-0174-5b05-9c7e-9edbebba7040', '2d3d3a5a-7da6-56c1-989c-8129f16c9556', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae04b90a-f554-592d-a572-835ed18e4be5', '2d3d3a5a-7da6-56c1-989c-8129f16c9556', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cfe2405-c018-515b-ae66-22923e80cbf3', '2d3d3a5a-7da6-56c1-989c-8129f16c9556', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a892e5a8-4e52-572b-8c94-7b33d2fef340', '2d3d3a5a-7da6-56c1-989c-8129f16c9556', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62d3cea3-5099-58b0-8bb1-09410e7aefb6', '180a35e9-26ef-56d1-83f2-addb6dddf159', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Use the information in the passage to match the deed (listed
A-H
) with people below.
Write the appropriate letters
A-H
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
A
Should easily be understood
B
Should improve by itself
C
Should not involve any mysticism
D
Ought to last a minimum length of time.
E
Needs to be treated at the right time.
F
Should give more recognition.
G
Can earn valuable money.
H
Do not rely on any specific treatment
1
Appointments with an alternative practitioner
2
An alternative practitioner’s description of the treatment
3
An alternative practitioner who has faith in what he does
4
the illness of patients convinced of alternative practice
5
Improvements of patients receiving alternative practice
6
Conventional medical doctors (who is aware of placebo)

6 ____ Conventional medical doctors (who is aware of placebo)$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b4b9e5e-52a5-5fe9-8c50-cd18b3414219', '62d3cea3-5099-58b0-8bb1-09410e7aefb6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ce3ce47-0a4b-5297-9434-0e6de7ba1c34', '62d3cea3-5099-58b0-8bb1-09410e7aefb6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c55593ca-ffdf-5a39-ade2-856b90bd07bc', '62d3cea3-5099-58b0-8bb1-09410e7aefb6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9aea23a-719d-54b5-a208-7f5f7cd28e90', '62d3cea3-5099-58b0-8bb1-09410e7aefb6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d4747bf-005f-592f-8cc0-418fc2ed39e2', '62d3cea3-5099-58b0-8bb1-09410e7aefb6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e1ec8f2-24c4-5a40-b152-103b53d52720', '62d3cea3-5099-58b0-8bb1-09410e7aefb6', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d48d1f2e-00ca-5318-9b46-09258790ad26', '62d3cea3-5099-58b0-8bb1-09410e7aefb6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54f5060e-178a-5edd-9ce6-97ee42b351c5', '62d3cea3-5099-58b0-8bb1-09410e7aefb6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55c79da2-2226-52b6-92a7-676e080d0dff', '180a35e9-26ef-56d1-83f2-addb6dddf159', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
7-9
on your answer sheet.
7.
In the fifth paragraph, the writer uses the example of
anger and sadness
to illustrate that:
A
People’s feeling could affect their physical behaviour
B
Scientists don’t understand how the mind influences the body.
C
Research on the placebo effect is very limited
D
How placebo achieves its effect is yet to be understood.
8.
Research on pain control attracts most of the attention because
A
Scientists have discovered that endorphins can help to reduce pain.
B
Only a limited number of researchers gain relevant experience
C
Pain reducing agents might also be involved in the placebo effect.
D
Patients often experience pain and like to complain about it
9.
Fabrizio Benedetti
’s research on endorphins indicates that
A
They are widely used to regulate pain.
B
They can be produced by willful thoughts
C
They can be neutralized by introducing naloxone.
D
Their pain-relieving effects do not last long enough.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('692eca64-f7da-552c-ac9d-65a404daefd7', '180a35e9-26ef-56d1-83f2-addb6dddf159', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
7-9
on your answer sheet.
7.
In the fifth paragraph, the writer uses the example of
anger and sadness
to illustrate that:
A
People’s feeling could affect their physical behaviour
B
Scientists don’t understand how the mind influences the body.
C
Research on the placebo effect is very limited
D
How placebo achieves its effect is yet to be understood.
8.
Research on pain control attracts most of the attention because
A
Scientists have discovered that endorphins can help to reduce pain.
B
Only a limited number of researchers gain relevant experience
C
Pain reducing agents might also be involved in the placebo effect.
D
Patients often experience pain and like to complain about it
9.
Fabrizio Benedetti
’s research on endorphins indicates that
A
They are widely used to regulate pain.
B
They can be produced by willful thoughts
C
They can be neutralized by introducing naloxone.
D
Their pain-relieving effects do not last long enough.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b5958156-83fd-58ee-b493-9773367c3816', '180a35e9-26ef-56d1-83f2-addb6dddf159', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
7-9
on your answer sheet.
7.
In the fifth paragraph, the writer uses the example of
anger and sadness
to illustrate that:
A
People’s feeling could affect their physical behaviour
B
Scientists don’t understand how the mind influences the body.
C
Research on the placebo effect is very limited
D
How placebo achieves its effect is yet to be understood.
8.
Research on pain control attracts most of the attention because
A
Scientists have discovered that endorphins can help to reduce pain.
B
Only a limited number of researchers gain relevant experience
C
Pain reducing agents might also be involved in the placebo effect.
D
Patients often experience pain and like to complain about it
9.
Fabrizio Benedetti
’s research on endorphins indicates that
A
They are widely used to regulate pain.
B
They can be produced by willful thoughts
C
They can be neutralized by introducing naloxone.
D
Their pain-relieving effects do not last long enough.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('650362df-3890-5618-9c5b-c43da8ce3588', '180a35e9-26ef-56d1-83f2-addb6dddf159', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
There is enough information for scientists to fully understand the placebo effect.
11
A London based researcher discovered that red pills should be taken off the market.
12
People’s preference for brands would also have an effect on their healing.
13
Medical doctors have a range of views of the newly introduced drug of
chlorpromazine.
14
Alternative practitioners are seldom known for applying the placebo effect.

10 ____ There is enough information for scientists to fully understand the placebo effect.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca79bfec-d70a-5b3c-ae4c-02c6df0a53e1', '650362df-3890-5618-9c5b-c43da8ce3588', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90916076-6dc5-5407-af02-66cc88bd2bcc', '650362df-3890-5618-9c5b-c43da8ce3588', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a449810-bc36-5de7-93ee-3700403db267', '650362df-3890-5618-9c5b-c43da8ce3588', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5f7a06a-869f-5b5b-bad9-5160bebe13ac', '180a35e9-26ef-56d1-83f2-addb6dddf159', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
There is enough information for scientists to fully understand the placebo effect.
11
A London based researcher discovered that red pills should be taken off the market.
12
People’s preference for brands would also have an effect on their healing.
13
Medical doctors have a range of views of the newly introduced drug of
chlorpromazine.
14
Alternative practitioners are seldom known for applying the placebo effect.

11 ____ A London based researcher discovered that red pills should be taken off the market.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('047e858b-2296-5b72-96cd-fd11146ce8dd', 'a5f7a06a-869f-5b5b-bad9-5160bebe13ac', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80e2db92-5420-535d-8ce2-a41a9fd8b29b', 'a5f7a06a-869f-5b5b-bad9-5160bebe13ac', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a99de41c-f03b-5249-b70e-1b1e3634bb51', 'a5f7a06a-869f-5b5b-bad9-5160bebe13ac', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a37e2bb2-b8c7-5ebf-8c19-d281871f472d', '180a35e9-26ef-56d1-83f2-addb6dddf159', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
There is enough information for scientists to fully understand the placebo effect.
11
A London based researcher discovered that red pills should be taken off the market.
12
People’s preference for brands would also have an effect on their healing.
13
Medical doctors have a range of views of the newly introduced drug of
chlorpromazine.
14
Alternative practitioners are seldom known for applying the placebo effect.

12 ____ People’s preference for brands would also have an effect on their healing.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d316a67-a517-5b06-899d-7c2ed8e934ba', 'a37e2bb2-b8c7-5ebf-8c19-d281871f472d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1853ccd0-8303-5c5c-b7da-268d9db0b227', 'a37e2bb2-b8c7-5ebf-8c19-d281871f472d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47313763-5b67-5a6b-b21e-1c2d469e0493', 'a37e2bb2-b8c7-5ebf-8c19-d281871f472d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fb70ef33-4d6a-581b-b426-f524c8c06a74', '180a35e9-26ef-56d1-83f2-addb6dddf159', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
There is enough information for scientists to fully understand the placebo effect.
11
A London based researcher discovered that red pills should be taken off the market.
12
People’s preference for brands would also have an effect on their healing.
13
Medical doctors have a range of views of the newly introduced drug of
chlorpromazine.
14
Alternative practitioners are seldom known for applying the placebo effect.

13 ____ Medical doctors have a range of views of the newly introduced drug of chlorpromazine.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91e8ed4f-2665-5574-b6a1-d9a829957621', 'fb70ef33-4d6a-581b-b426-f524c8c06a74', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6baffb82-fc39-51bd-8bb1-614c8e5d3636', 'fb70ef33-4d6a-581b-b426-f524c8c06a74', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eed35636-a5d2-5941-9cba-288fb9584ee8', 'fb70ef33-4d6a-581b-b426-f524c8c06a74', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf5b7b94-ca7d-596f-bd25-e11486e03cea', '180a35e9-26ef-56d1-83f2-addb6dddf159', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
There is enough information for scientists to fully understand the placebo effect.
11
A London based researcher discovered that red pills should be taken off the market.
12
People’s preference for brands would also have an effect on their healing.
13
Medical doctors have a range of views of the newly introduced drug of
chlorpromazine.
14
Alternative practitioners are seldom known for applying the placebo effect.

14 ____ Alternative practitioners are seldom known for applying the placebo effect.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05970ef6-df0d-5130-b581-4006a47554e0', 'bf5b7b94-ca7d-596f-bd25-e11486e03cea', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efc3be3d-8c94-549d-94a1-6c131101e3ae', 'bf5b7b94-ca7d-596f-bd25-e11486e03cea', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('510abb6f-6685-5ecf-a34b-de2c869c63f5', 'bf5b7b94-ca7d-596f-bd25-e11486e03cea', 3, $md$NOT GIVEN$md$, false);

COMMIT;

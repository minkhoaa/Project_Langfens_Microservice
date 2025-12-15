BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-mental-gymnastics-1292'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mental-gymnastics-1292';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mental-gymnastics-1292';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-mental-gymnastics-1292';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('495db997-d2e2-5d11-9e88-5f02dc53e5a1', 'ielts-reading-mental-gymnastics-1292', $t$Mental Gymnastics$t$, $md$## Mental Gymnastics

Nguồn:
- Test: https://mini-ielts.com/1292/reading/mental-gymnastics
- Solution: https://mini-ielts.com/1292/view-solution/reading/mental-gymnastics$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d9e5e870-85ac-5358-90a6-d6406e5ef375', '495db997-d2e2-5d11-9e88-5f02dc53e5a1', 1, $t$Reading — Mental Gymnastics$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Mental Gymnastics

A . THE working day has just started at the head office of Barclays Bank in London. Seventeen staff are helping themselves to a buffet breakfast as young psychologist Sebastian Bailey enters the room to begin the morning’s framing session. But this is no ordinary training session. He’s not here to sharpen their finance or management skills. He’s here to exercise their brains.

B . Today’s workout, organised by a company called the Mind Gym in London, is entitled “having presence”. What follows is an intense 90-minute session in which this rather abstract concept is gradually broken down into a concrete set of feelings, mental tricks and behaviours. At one point the bankers are instructed to shut then eyes and visualise themselves filling the room and then the building. They finish up by walking around the room acting out various levels of presence, from low-key to over the top.

C . It’s easy to poke fun. Yet similar mental workouts are happening in corporate seminar rooms around the globe. The Mind Gym alone offers some 70 different sessions, including ones on mental stamina, creativity for logical thinkers and “zoom learning”. Other outfits draw more directly on the exercise analogy, offering “neurobics” courses with names like “brain sets” and “cerebral fitness”. Then there are books with titles like Pumping Ions, full of brainteasers that claim to “flex your mind”, and software packages offering memory and spatial- awareness games.

D . But whatever the style, the companies’ sales pitch is invariably the same— follow our routines to shape and sculpt your brain or mind, just as you might tone and train your body. And, of course, they nearly all claim that their mental workouts draw on serious scientific research and thinking into how the brain works.

E . One outfit, Brainergy of Cambridge, Massachusetts (motto: “Because your grey matter matters”) puts it like this: “Studies have shown that mental exercise can cause changes in brain anatomy and brain chemistry which promote increased mental efficiency and clarity. The neuroscience is cutting-edge.” And on its website, Mind Gym trades on a quote from Susan Greenfield, one of Britain’s best known neuroscientists: “It’s a bit like going to the gym, if you exercise your brain it will grow.”

F . Indeed, die Mind Gym originally planned to hold its sessions in a local health club, until its founders realised where the real money was to be made. Modem companies need flexible, bright thinkers and will seize on anything that claims to create them, especially if it looks like a quick fix backed by science. But are neurobic workouts really backed by science? And do we need them?

G . Nor is there anything remotely high-tech about what Lawrence Katz, co- author of Keep Your Brain Alive, recommends. Katz, a neurobiologist at Duke University Medical School in North Carolina, argues that just as many of US fail to get enough physical exercise, so we also lack sufficient mental stimulation to keep our brain in trim. Sine we are busy with jobs, family and housework. But most of this activity is repetitive routine. And any leisure time is spent slumped in front of the TV.

H . So, read a book upside down. Write or brush your teeth with your wrong hand. Feel your way around the room with your eyes shut. Sniff vanilla essence while listening intently to orchestral music. Anything, says Katz, to break your normal mental routine. It will help invigorate your brain, encouraging its cells to make new connections and pump out neuroteophins, substances that feed and sustain brain circuits.

I . Well, up to a point it will. “What I’m really talking about is brain maintenance rather than bulking up your IQ,” Katz adds. Neurobics, in other words, is about letting your brain fulfill its potential. It cannot create super-brains. Can it achieve even that much, though? Certainly the brain is an organ that can adapt to the demands placed on it. Tests on animal brain tissue, for example, have repeatedly shown that electrically stimulating the synapses that connect nerve cells thought to be crucial to learning and reasoning, makes them stronger and more responsive. Brain scans suggest we use a lot more of our grey matter when carrying out new or strange tasks than when we’re doing well-rehearsed ones. Rats raised in bright cages with toys sprout more neural connections than rats raised in bare cages— suggesting perhaps that novelty and variety could be crucial to a developing brain. Katz, And neurologists have proved time and again that people who lose brain cells suddenly during a stroke often sprout new connections to compensate for the loss—especially if they undergo extensive therapy to overcome any paralysis.

J . Guy Claxton, an educational psychologist at the University of Bristol, dismisses most of the neurological approaches as “neuro-babble”. Nevertheless, there are specific mental skills we can learn, he contends. Desirable attributes such as creativity, mental flexibility, and even motivation, are not the fixed faculties that most of US think. They are thought habits that can be learned. The problem, says Claxton, is that most of US never get proper training in these skills. We develop our own private set of mental strategies for tackling tasks and never learn anything explicitly. Worse still, because any learned skill— even driving a car or brushing our teeth-quickly sinks out of consciousness, we can no longer see the very thought habits we’re relying upon. Our mental tools become invisible to US.

K . Claxton is the academic adviser to the Mind Gym. So not surprisingly, the company espouses his solution-that we must return our thought patterns to a conscious level, becoming aware of the details of how we usually think. Only then can we start to practise better thought patterns, until eventually these become our new habits. Switching metaphors, picture not gym classes, but tennis or football coaching.

L . In practice, the training can seem quite mundane. For example, in one of the eight different creativity workouts offered by the Mind Gym—entitled “creativity for logical thinkers” one of the mental strategies taught is to make a sensible suggestion, then immediately pose its opposite. So, asked to spend five minutes inventing a new pizza, a group soon comes up with no topping, sweet topping, cold topping, price based on time of day, flat-rate prices and so on.

M . Bailey agrees that the trick is simple. But it is surprising how few such tricks people have to call upon when they are suddenly asked to be creative: “They tend to just label themselves as uncreative, not realising that there are techniques that every creative person employs.” Bailey says the aim is to introduce people to half a dozen or so such strategies in a session so that what at first seems like a dauntingly abstract mental task becomes a set of concrete, learnable behaviours. He admits this is not a short cut to genius. Neurologically, some people do start with quicker circuits or greater handling capacity. However, with the right kind of training he thinks we can dramatically increase how efficiently we use it.

N . It is hard to prove that the training itself is effective. How do you measure a change in an employee’s creativity levels, or memory skills? But staff certainly report feeling that such classes have opened their eyes. So, neurological boosting or psychological training? At the moment you can pay your money and take your choice. Claxton for one believes there is no reason why schools and universities shouldn’t spend more time teaching basic thinking skills, rather than trying to stuff heads with facts and hoping that effective thought habits are somehow absorbed by osmosis.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec54e761-a6c0-5305-ba77-09f593a7a071', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in
Reading Passage 1
In boxes
1-5
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Mind Gym coach instructed employees to imagine that they are the building
2
Mind Gym uses the similar marketing theory that is used all round
3
Susan Greenfield is the founder of Mind Gym
4
All business and industries are using Mind Gym’s session globally
5
According to Mind Gym, extensive scientific background supports their mental training sessions

1 ____ Mind Gym coach instructed employees to imagine that they are the building$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83597904-722d-58ed-8388-aa7d593a39a6', 'ec54e761-a6c0-5305-ba77-09f593a7a071', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1ae8766-ca13-56bf-9d73-1b76e0b9b030', 'ec54e761-a6c0-5305-ba77-09f593a7a071', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ae315a2-e20b-54ce-83c1-b01874bfb4f6', 'ec54e761-a6c0-5305-ba77-09f593a7a071', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e9ed9bd9-796c-5e2a-9698-91dde29c306a', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in
Reading Passage 1
In boxes
1-5
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Mind Gym coach instructed employees to imagine that they are the building
2
Mind Gym uses the similar marketing theory that is used all round
3
Susan Greenfield is the founder of Mind Gym
4
All business and industries are using Mind Gym’s session globally
5
According to Mind Gym, extensive scientific background supports their mental training sessions

2 ____ Mind Gym uses the similar marketing theory that is used all round$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6817face-5f76-5726-baec-a1d430f9e7e9', 'e9ed9bd9-796c-5e2a-9698-91dde29c306a', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77e548b2-ef32-527b-b8e8-c6e956b0b8fd', 'e9ed9bd9-796c-5e2a-9698-91dde29c306a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d5ee0d8-1a09-5980-91c1-1f45422c3063', 'e9ed9bd9-796c-5e2a-9698-91dde29c306a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2c48e548-162a-545d-8a5f-929225a9e0ca', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in
Reading Passage 1
In boxes
1-5
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Mind Gym coach instructed employees to imagine that they are the building
2
Mind Gym uses the similar marketing theory that is used all round
3
Susan Greenfield is the founder of Mind Gym
4
All business and industries are using Mind Gym’s session globally
5
According to Mind Gym, extensive scientific background supports their mental training sessions

3 ____ Susan Greenfield is the founder of Mind Gym$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64272c9c-0fe4-59c3-87cc-f8a5c3278cdb', '2c48e548-162a-545d-8a5f-929225a9e0ca', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6842dfaa-e868-5503-8993-7168a2c4b428', '2c48e548-162a-545d-8a5f-929225a9e0ca', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea767064-a252-5ab5-ba71-702e082f8d29', '2c48e548-162a-545d-8a5f-929225a9e0ca', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77335dd0-16fe-5b55-949e-9ca5229d6db2', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in
Reading Passage 1
In boxes
1-5
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Mind Gym coach instructed employees to imagine that they are the building
2
Mind Gym uses the similar marketing theory that is used all round
3
Susan Greenfield is the founder of Mind Gym
4
All business and industries are using Mind Gym’s session globally
5
According to Mind Gym, extensive scientific background supports their mental training sessions

4 ____ All business and industries are using Mind Gym’s session globally$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b440c5f-c11e-5edc-bb24-287e59b1221c', '77335dd0-16fe-5b55-949e-9ca5229d6db2', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc5b469f-7139-55a4-9dbe-4dfaaa9d8c10', '77335dd0-16fe-5b55-949e-9ca5229d6db2', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ca57b0c-1b04-5d85-aaa4-69a40c27f7ac', '77335dd0-16fe-5b55-949e-9ca5229d6db2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9f0f48d3-8097-5f30-a337-cc8f012f9f58', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in
Reading Passage 1
In boxes
1-5
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Mind Gym coach instructed employees to imagine that they are the building
2
Mind Gym uses the similar marketing theory that is used all round
3
Susan Greenfield is the founder of Mind Gym
4
All business and industries are using Mind Gym’s session globally
5
According to Mind Gym, extensive scientific background supports their mental training sessions

5 ____ According to Mind Gym, extensive scientific background supports their mental training sessions$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44d1231e-0e58-517a-9fe1-c446af6626a1', '9f0f48d3-8097-5f30-a337-cc8f012f9f58', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efb24ea3-ee20-518e-a773-d661f507de2e', '9f0f48d3-8097-5f30-a337-cc8f012f9f58', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ee9085d-7798-5972-977c-00bce967454a', '9f0f48d3-8097-5f30-a337-cc8f012f9f58', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e8e26de0-8854-59ee-8bd1-830ca3a78c59', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-13
Questions 6-13
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below. Write the appropriate letters A-D in boxes
6-13
on your answer sheet.
A. Guy Claxton
B. Sebastian Bailey
C. Susan Greenfield
D. Lawrence Katz
NB: You may use any letter more than once
6
inspiration to keep our brain fit##q We do not have enough
7
The more you exercise your brain like exercise in the gym, the more brain will grow
8
Exercise can keep your brain health instead of improving someone’s IQ
9
It is valuable for schools to teach students about creative skills besides basic known knowledge
10
We can develop new neuron connections when we lose old connections via certain treatment
11
People usually mark themselves as not creative before figuring out there are approaches for each person
12
An instructor in Mind Gym who guided the employees to exercise
13
Majority of people don’t have appropriate skills-training for brain

6 ____ inspiration to keep our brain fit##q We do not have enough$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('213dcc40-0cf6-57f5-8e0e-b456e234b188', 'e8e26de0-8854-59ee-8bd1-830ca3a78c59', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ec2ff64-0d0a-5a7c-8ea1-3b02c7095883', 'e8e26de0-8854-59ee-8bd1-830ca3a78c59', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da6d0285-a02a-575b-9297-f24e576ad312', 'e8e26de0-8854-59ee-8bd1-830ca3a78c59', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b37c3da5-d496-54c7-9a79-6930500e385d', 'e8e26de0-8854-59ee-8bd1-830ca3a78c59', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db156d65-f9e6-513f-b9d6-c6d5234db379', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-13
Questions 6-13
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below. Write the appropriate letters A-D in boxes
6-13
on your answer sheet.
A. Guy Claxton
B. Sebastian Bailey
C. Susan Greenfield
D. Lawrence Katz
NB: You may use any letter more than once
6
inspiration to keep our brain fit##q We do not have enough
7
The more you exercise your brain like exercise in the gym, the more brain will grow
8
Exercise can keep your brain health instead of improving someone’s IQ
9
It is valuable for schools to teach students about creative skills besides basic known knowledge
10
We can develop new neuron connections when we lose old connections via certain treatment
11
People usually mark themselves as not creative before figuring out there are approaches for each person
12
An instructor in Mind Gym who guided the employees to exercise
13
Majority of people don’t have appropriate skills-training for brain

7 ____ The more you exercise your brain like exercise in the gym, the more brain will grow$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41566b5b-294a-5aaf-99b1-1f6a8425ae51', 'db156d65-f9e6-513f-b9d6-c6d5234db379', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39e3b9c2-228b-5f50-b91f-4b8470b656de', 'db156d65-f9e6-513f-b9d6-c6d5234db379', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79ccde70-941e-5bc8-b8a8-af93068af176', 'db156d65-f9e6-513f-b9d6-c6d5234db379', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5cdd420-345e-57a2-aba7-afdb8b9da3f1', 'db156d65-f9e6-513f-b9d6-c6d5234db379', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('36fe8de8-cc1a-5bc1-b1bb-2f02eb026126', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-13
Questions 6-13
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below. Write the appropriate letters A-D in boxes
6-13
on your answer sheet.
A. Guy Claxton
B. Sebastian Bailey
C. Susan Greenfield
D. Lawrence Katz
NB: You may use any letter more than once
6
inspiration to keep our brain fit##q We do not have enough
7
The more you exercise your brain like exercise in the gym, the more brain will grow
8
Exercise can keep your brain health instead of improving someone’s IQ
9
It is valuable for schools to teach students about creative skills besides basic known knowledge
10
We can develop new neuron connections when we lose old connections via certain treatment
11
People usually mark themselves as not creative before figuring out there are approaches for each person
12
An instructor in Mind Gym who guided the employees to exercise
13
Majority of people don’t have appropriate skills-training for brain

8 ____ Exercise can keep your brain health instead of improving someone’s IQ$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('690bc7ef-ca5f-531f-918d-4972349f445e', '36fe8de8-cc1a-5bc1-b1bb-2f02eb026126', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c02b1179-a158-5577-bc53-ecd5e44f7f78', '36fe8de8-cc1a-5bc1-b1bb-2f02eb026126', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e91fe593-d53d-55d6-8804-0f29445040e6', '36fe8de8-cc1a-5bc1-b1bb-2f02eb026126', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80d5874e-abb2-505b-865f-7e57a21958e6', '36fe8de8-cc1a-5bc1-b1bb-2f02eb026126', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b3b7137b-32cf-5fe7-901f-0f3beb467fdf', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-13
Questions 6-13
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below. Write the appropriate letters A-D in boxes
6-13
on your answer sheet.
A. Guy Claxton
B. Sebastian Bailey
C. Susan Greenfield
D. Lawrence Katz
NB: You may use any letter more than once
6
inspiration to keep our brain fit##q We do not have enough
7
The more you exercise your brain like exercise in the gym, the more brain will grow
8
Exercise can keep your brain health instead of improving someone’s IQ
9
It is valuable for schools to teach students about creative skills besides basic known knowledge
10
We can develop new neuron connections when we lose old connections via certain treatment
11
People usually mark themselves as not creative before figuring out there are approaches for each person
12
An instructor in Mind Gym who guided the employees to exercise
13
Majority of people don’t have appropriate skills-training for brain

9 ____ It is valuable for schools to teach students about creative skills besides basic known knowledge$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcf8917d-1d57-56f9-a116-85adcfd23a0b', 'b3b7137b-32cf-5fe7-901f-0f3beb467fdf', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebaa4935-5ecd-5cca-be67-69bea9767614', 'b3b7137b-32cf-5fe7-901f-0f3beb467fdf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('975a15dd-c11e-5f48-8b22-7ce33a912c4f', 'b3b7137b-32cf-5fe7-901f-0f3beb467fdf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7a05b8d-418a-53c8-937b-04e594f128d2', 'b3b7137b-32cf-5fe7-901f-0f3beb467fdf', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97802566-23b1-5155-ac17-aee1100d55bb', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-13
Questions 6-13
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below. Write the appropriate letters A-D in boxes
6-13
on your answer sheet.
A. Guy Claxton
B. Sebastian Bailey
C. Susan Greenfield
D. Lawrence Katz
NB: You may use any letter more than once
6
inspiration to keep our brain fit##q We do not have enough
7
The more you exercise your brain like exercise in the gym, the more brain will grow
8
Exercise can keep your brain health instead of improving someone’s IQ
9
It is valuable for schools to teach students about creative skills besides basic known knowledge
10
We can develop new neuron connections when we lose old connections via certain treatment
11
People usually mark themselves as not creative before figuring out there are approaches for each person
12
An instructor in Mind Gym who guided the employees to exercise
13
Majority of people don’t have appropriate skills-training for brain

10 ____ We can develop new neuron connections when we lose old connections via certain treatment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcefe88a-d52a-5385-9a7a-038050ea5a86', '97802566-23b1-5155-ac17-aee1100d55bb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('349f713a-03a3-5e0c-9072-870296738229', '97802566-23b1-5155-ac17-aee1100d55bb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a17df7c9-38d6-57a0-8f2e-05ae825d1da5', '97802566-23b1-5155-ac17-aee1100d55bb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96be20e4-796e-5463-8d8a-4427b847531e', '97802566-23b1-5155-ac17-aee1100d55bb', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de48ff01-b96f-52ad-8b6d-af72c6fd2ec6', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 6-13
Questions 6-13
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below. Write the appropriate letters A-D in boxes
6-13
on your answer sheet.
A. Guy Claxton
B. Sebastian Bailey
C. Susan Greenfield
D. Lawrence Katz
NB: You may use any letter more than once
6
inspiration to keep our brain fit##q We do not have enough
7
The more you exercise your brain like exercise in the gym, the more brain will grow
8
Exercise can keep your brain health instead of improving someone’s IQ
9
It is valuable for schools to teach students about creative skills besides basic known knowledge
10
We can develop new neuron connections when we lose old connections via certain treatment
11
People usually mark themselves as not creative before figuring out there are approaches for each person
12
An instructor in Mind Gym who guided the employees to exercise
13
Majority of people don’t have appropriate skills-training for brain

11 ____ People usually mark themselves as not creative before figuring out there are approaches for each person$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8e53eec-2289-598b-8436-35f042f355d2', 'de48ff01-b96f-52ad-8b6d-af72c6fd2ec6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4f3df79-7c62-5145-8858-f3712d9372d0', 'de48ff01-b96f-52ad-8b6d-af72c6fd2ec6', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d704838f-a23b-52fc-b01d-a2a171da838f', 'de48ff01-b96f-52ad-8b6d-af72c6fd2ec6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9135878c-4bb9-52cf-b321-ee7f902269a3', 'de48ff01-b96f-52ad-8b6d-af72c6fd2ec6', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9de011b9-befd-54c2-a6a5-fe4712d5bfed', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 6-13
Questions 6-13
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below. Write the appropriate letters A-D in boxes
6-13
on your answer sheet.
A. Guy Claxton
B. Sebastian Bailey
C. Susan Greenfield
D. Lawrence Katz
NB: You may use any letter more than once
6
inspiration to keep our brain fit##q We do not have enough
7
The more you exercise your brain like exercise in the gym, the more brain will grow
8
Exercise can keep your brain health instead of improving someone’s IQ
9
It is valuable for schools to teach students about creative skills besides basic known knowledge
10
We can develop new neuron connections when we lose old connections via certain treatment
11
People usually mark themselves as not creative before figuring out there are approaches for each person
12
An instructor in Mind Gym who guided the employees to exercise
13
Majority of people don’t have appropriate skills-training for brain

12 ____ An instructor in Mind Gym who guided the employees to exercise$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c334096-a0e0-55c8-b0b3-d09a4f4228bb', '9de011b9-befd-54c2-a6a5-fe4712d5bfed', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1056d2bd-e5a3-572d-bcca-8af8e78ce5ce', '9de011b9-befd-54c2-a6a5-fe4712d5bfed', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b663dd84-dda2-543a-94a9-57047573b26e', '9de011b9-befd-54c2-a6a5-fe4712d5bfed', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c27fd160-d4a6-5337-8649-3762669a5774', '9de011b9-befd-54c2-a6a5-fe4712d5bfed', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64c63635-618b-5a1c-9a0d-13de203e9a1e', 'd9e5e870-85ac-5358-90a6-d6406e5ef375', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 6-13
Questions 6-13
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below. Write the appropriate letters A-D in boxes
6-13
on your answer sheet.
A. Guy Claxton
B. Sebastian Bailey
C. Susan Greenfield
D. Lawrence Katz
NB: You may use any letter more than once
6
inspiration to keep our brain fit##q We do not have enough
7
The more you exercise your brain like exercise in the gym, the more brain will grow
8
Exercise can keep your brain health instead of improving someone’s IQ
9
It is valuable for schools to teach students about creative skills besides basic known knowledge
10
We can develop new neuron connections when we lose old connections via certain treatment
11
People usually mark themselves as not creative before figuring out there are approaches for each person
12
An instructor in Mind Gym who guided the employees to exercise
13
Majority of people don’t have appropriate skills-training for brain

13 ____ Majority of people don’t have appropriate skills-training for brain$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3807e19f-b8fb-5518-97f9-cb8670bb40a5', '64c63635-618b-5a1c-9a0d-13de203e9a1e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b9944ee-db05-5cc0-b79f-e447be230c20', '64c63635-618b-5a1c-9a0d-13de203e9a1e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f454b0cd-8b28-5fe4-b871-9125e2dad708', '64c63635-618b-5a1c-9a0d-13de203e9a1e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72255849-7ba9-5e3c-a68b-7fa00e9576ba', '64c63635-618b-5a1c-9a0d-13de203e9a1e', 4, $md$D$md$, false);

COMMIT;

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-what-is-a-dinosaur-1036'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-is-a-dinosaur-1036';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-is-a-dinosaur-1036';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-what-is-a-dinosaur-1036';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c2723df4-0459-5da7-8c49-9b7466fcb987', 'ielts-reading-what-is-a-dinosaur-1036', $t$What is a dinosaur?$t$, $md$## What is a dinosaur?

Nguồn:
- Test: https://mini-ielts.com/1036/reading/what-is-a-dinosaur
- Solution: https://mini-ielts.com/1036/view-solution/reading/what-is-a-dinosaur$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e6098e4c-70c5-5dfb-a085-94a3ab96f424', 'c2723df4-0459-5da7-8c49-9b7466fcb987', 1, $t$Reading — What is a dinosaur?$t$, $md$Read the passage and answer questions **1–14**.

### Passage: What is a dinosaur?

A. Lizards and dinosaurs - two distinct superorders

Although the name dinosaur is derived from the Greek for "terrible lizard", dinosaurs were not, in fact, lizards at all. Like lizards, dinosaurs are included in the class Reptilia, or reptiles, one of the five main classes of Vertebrata, animals with backbones. However, at the next level of classification, within reptiles, significant differences in the skeletal anatomy of lizards and dinosaurs have led scientists to place these groups of animals into two different superorders : Lepidosauria, or lepidosaurs, and Archosauria, or archosaurs.

B. The origins of dinosaurs and lizards

Classified as lepidosaurs are lizards and snakes and their prehistoric ancestors. Included among the archosaurs, or "ruling reptiles", are prehistoric and modern crocodiles, and the now extinct thecodonts, pterosaurs and dinosaurs . Palaeontologists believe that both dinosaurs and crocodiles evolved, in the later years of the Triassic Period (c. 248-208 million years ago), from creatures called pseudosuchian thecodonts. Lizards, snakes and different types of thecodont are believed to have evolved earlier in the Triassic Period from reptiles known as eosuchians .

C. Skull bones distinguish dinosaurs from other archosaurs

The most important skeletal differences between dinosaurs and other archosaurs are in the bones of the skull , pelvis and limbs. Dinosaur skulls are found in a great range of shapes and sizes, reflecting the different eating habits and lifestyles of a large and varied group of animals that dominated life on Earth for an extraordinary 165 million years. However, unlike the skulls of any other known animals, the skulls of dinosaurs had two long bones known as vomers. These bones extended on either side of the head, from the front of the snout to the level of the holes on the skull known as the antorbital fenestra, situated in front of the dinosaur's orbits or eyesockets.

D. Unique body plan helps identify dinosaurs from other animals

All dinosaurs, whether large or small, quadrupedal or bidepal, fleet-footed or slow-moving, shared a common body plan. Identification of this plan makes it possible to differentiate dinosaurs from any other types of animal , even other archosaurs. Most significantly, in dinosaurs, the pelvis and femur had evolved so that the hind limbs were held vertically beneath the body, rather than sprawling out to the sides like the limbs of a lizard. The femur of a dinosaur had a sharply in-turned neck and a ball-shaped head, which slotted into a fully open acetabulum or hip socket. A supra-acetabular crest helped prevent dislocation of the femur. The position of the knee joint, aligned below the acetabulum, made it possible for the whole hind limb to swing backwards and forwards. This unique combination of features gave dinosaurs what is known as a " fully improved gait ". Evolution of this highly efficient method of walking also developed in mammals, but among reptiles it occurred only in dinosaurs.

E. Classification according to pelvic anatomy

For the purpose of further classification, dinosaurs are divided into two orders: Saurischia, or saurischian dinosaurs, and Ornithischia, or ornithischian dinosaurs. This division is made on the basis of their pelvic anatomy . All dinosaurs had a pelvic girdle with each side comprised of three bones: the pubis, ilium and ischium. However, the orientation of these bones follows one of two patterns. In saurischian dinosaurs, also known as lizard-hipped dinosaurs, the pubis points forwards, as is usual in most types of reptile. By contrast, in ornithischian, or bird-hipped, dinosaurs, the pubis points backwards towards the rear of the animal, which is also true of birds.

F. The suborders of Saurischia

Of the two orders of dinosaurs, the Saurischia was the larger and the first to evolve . It is divided into two suborders: Therapoda, or therapods, and Sauropodomorpha, or sauropodomorphs. The therapods, or "beast feet", were bipedal, predatory carnivores. They ranged in size from the mighty Tyrannosaurus rex, 12m long, 5.6m tall and weighing an estimated 6.4 tonnes, to the smallest known dinosaur, Compsognathus, a mere 1.4m long and estimated 3kg in weight when fully grown. The sauropodomorphs, or "lizard feet forms", included both bipedal and quadrupedal dinosaurs. Some sauropodomorphs were carnivorous or omnivorous but later species were typically herbivorous . They included some of the largest and best-known of all dinosaurs, such as Diplodocus, a huge quadruped with an elephant-like body, a long, thin tail and neck that gave it a total length of 27m, and a tiny head.

G. Herbivore dinosaurs

Ornithischian dinosaurs were bipedal or quadrupedal herbivores . They are now usually divided into three suborders: Ornithipoda, Thyreophora and Marginocephalia. The ornithopods, or "bird feet", both large and small, could walk or run on their long hind legs , balancing their body by holding their tails stiffly off the ground behind them. An example is Iguanodon, up to 9m long, 5m tall and weighing 4.5 tonnes. The thyreophorans, or "shield bearers", also known as armoured dinosaurs, were quadrupeds with rows of protective bony spikes, studs, or plates along their backs and tails. They included Stegosaurus, 9m long and weighing 2 tonnes.

H. Frills and shelves

The marginocephalians, or "margined heads", were bipedal or quadrupedal ornithschians with a deep bony frill or narrow shelf at the back of the skull. An example is Triceratops, a rhinoceros-like dinosaur, 9m long, weighing 5.4 tonnes and bearing a prominent neck frill and three large horns.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has 8 paragraphs (
A-H
).
Choose the most suitable heading for each paragraph from the
List of headings
below.
Write the appropriate numbers (
i-xiii
) in Boxes
1-7
on your answer sheet.
One of the headings has been done for you as an example.
NB.
There are
more headings than paragraphs
, so you will not use all of them.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
Example :
Paragraph
H
Answer
: x
List of headings
i.
165 million years
ii.
The body plan of archosaurs
iii.
Dinosaurs - terrible lizards
iv.
Classification according to pelvic anatomy
v.
The suborders of Saurischia
vi.
Lizards and dinosaurs - two distinct superorders
vii.
Unique body plan helps identify dinosaurs from other animals
viii.
Herbivore dinosaurs
ix.
Lepidosaurs
x.
Frills and shelves
xi.
The origins of dinosaurs and lizards
xii.
Bird-hipped dinosaurs
xiii.
Skull bones distinguish dinosaurs from other archosaurs

1 ____ Paragraph A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('666c5462-7b8b-5ad1-b751-6c1911e7417f', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01fe680f-6762-527e-848e-24d457e572e7', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe08e7b-cf53-570b-8ae5-370cb4491da7', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fed9c18-f98a-5ad9-b567-262d7bd88332', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f0d849a-39bb-5b25-9990-09bcda9613fe', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ba6215f-8f73-50fc-aecf-5693356cae11', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b186c05-fb99-588a-999c-7f596304b5d0', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e54ce23f-c7c7-5eb9-9831-44ac7f766b40', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0499b8a8-0ba4-5be6-8fe0-84f5dc33e75c', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1c3c75f-1e7d-5448-a828-1e985501794a', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de3a57e0-4ccc-54c9-a82f-1128fdca8107', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4298f088-f892-5425-b9e4-34d4b8146085', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 12, $md$xii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3a32d77-98e1-5385-90bb-602e761760f6', '5cc85b4c-7010-590e-bb6c-0a851cfa01dc', 13, $md$xiii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2571351b-23cb-5575-b249-5cfe3cc8e46e', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has 8 paragraphs (
A-H
).
Choose the most suitable heading for each paragraph from the
List of headings
below.
Write the appropriate numbers (
i-xiii
) in Boxes
1-7
on your answer sheet.
One of the headings has been done for you as an example.
NB.
There are
more headings than paragraphs
, so you will not use all of them.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
Example :
Paragraph
H
Answer
: x
List of headings
i.
165 million years
ii.
The body plan of archosaurs
iii.
Dinosaurs - terrible lizards
iv.
Classification according to pelvic anatomy
v.
The suborders of Saurischia
vi.
Lizards and dinosaurs - two distinct superorders
vii.
Unique body plan helps identify dinosaurs from other animals
viii.
Herbivore dinosaurs
ix.
Lepidosaurs
x.
Frills and shelves
xi.
The origins of dinosaurs and lizards
xii.
Bird-hipped dinosaurs
xiii.
Skull bones distinguish dinosaurs from other archosaurs

2 ____ Paragraph B Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acd63faa-a89d-5eef-bcae-e5e908c2d050', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('613a4037-f5b2-5f52-8a81-3c5c01e55b86', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('deda37e6-a7d7-5486-b59f-3a7e7eee6e7f', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('877a3bec-70dc-5421-a4c2-090e07ce73ce', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8af48eeb-96b9-562d-8d84-fce9fc917aed', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4aee1e30-2a00-5eda-9b9c-ab268ca494e4', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54f69b00-67e4-5133-8d24-b484aa1c6ab9', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45105c03-f68f-5dc9-aeed-d4f19d7766da', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('735d8ad3-b7a7-5f24-8b28-956c79355527', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91539ad0-8268-5ad1-af88-fbf064ee2a75', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c07af10-dd32-5dc5-9b06-24df802314af', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 11, $md$xi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa55f316-f7a4-53cf-8607-2ccefcc09344', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 12, $md$xii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('342d2e9c-a9fa-5980-9251-4763ce4f46e0', '2571351b-23cb-5575-b249-5cfe3cc8e46e', 13, $md$xiii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('080170e7-fdc6-5b35-932a-8dae605aa84a', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has 8 paragraphs (
A-H
).
Choose the most suitable heading for each paragraph from the
List of headings
below.
Write the appropriate numbers (
i-xiii
) in Boxes
1-7
on your answer sheet.
One of the headings has been done for you as an example.
NB.
There are
more headings than paragraphs
, so you will not use all of them.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
Example :
Paragraph
H
Answer
: x
List of headings
i.
165 million years
ii.
The body plan of archosaurs
iii.
Dinosaurs - terrible lizards
iv.
Classification according to pelvic anatomy
v.
The suborders of Saurischia
vi.
Lizards and dinosaurs - two distinct superorders
vii.
Unique body plan helps identify dinosaurs from other animals
viii.
Herbivore dinosaurs
ix.
Lepidosaurs
x.
Frills and shelves
xi.
The origins of dinosaurs and lizards
xii.
Bird-hipped dinosaurs
xiii.
Skull bones distinguish dinosaurs from other archosaurs

3 ____ Paragraph C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed0c682d-fd7b-5034-b3f3-c0d25b63c982', '080170e7-fdc6-5b35-932a-8dae605aa84a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('176eb367-165e-576e-8e5b-a3d6650b1609', '080170e7-fdc6-5b35-932a-8dae605aa84a', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e4e256b-4e4f-54af-8cc3-3cdf8691b6c6', '080170e7-fdc6-5b35-932a-8dae605aa84a', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71158ad2-8b9b-5f8f-9272-7288032d1c6f', '080170e7-fdc6-5b35-932a-8dae605aa84a', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d0ece5b-5f73-5cb4-9536-c51e69dc1c4f', '080170e7-fdc6-5b35-932a-8dae605aa84a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60cfc7f3-5529-59e0-bfc6-679b921078c4', '080170e7-fdc6-5b35-932a-8dae605aa84a', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1af56ff9-3d13-5a5e-9ccd-5321962fea0e', '080170e7-fdc6-5b35-932a-8dae605aa84a', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3042f87-9c8d-5d06-9cb5-82ef7ce8a903', '080170e7-fdc6-5b35-932a-8dae605aa84a', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f570e11-d0c9-5e55-9131-a1607056fccf', '080170e7-fdc6-5b35-932a-8dae605aa84a', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c735df9-c647-5db6-994e-2d644179acdb', '080170e7-fdc6-5b35-932a-8dae605aa84a', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8701f62-b5f4-5355-9292-a01dd058ba78', '080170e7-fdc6-5b35-932a-8dae605aa84a', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce44f7ea-84ab-5d03-af75-d2fb117bd604', '080170e7-fdc6-5b35-932a-8dae605aa84a', 12, $md$xii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30d5f5fc-8749-52a5-a9a5-084e570af18f', '080170e7-fdc6-5b35-932a-8dae605aa84a', 13, $md$xiii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c8d55cfa-0e69-5b1f-bc76-30e14245424d', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has 8 paragraphs (
A-H
).
Choose the most suitable heading for each paragraph from the
List of headings
below.
Write the appropriate numbers (
i-xiii
) in Boxes
1-7
on your answer sheet.
One of the headings has been done for you as an example.
NB.
There are
more headings than paragraphs
, so you will not use all of them.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
Example :
Paragraph
H
Answer
: x
List of headings
i.
165 million years
ii.
The body plan of archosaurs
iii.
Dinosaurs - terrible lizards
iv.
Classification according to pelvic anatomy
v.
The suborders of Saurischia
vi.
Lizards and dinosaurs - two distinct superorders
vii.
Unique body plan helps identify dinosaurs from other animals
viii.
Herbivore dinosaurs
ix.
Lepidosaurs
x.
Frills and shelves
xi.
The origins of dinosaurs and lizards
xii.
Bird-hipped dinosaurs
xiii.
Skull bones distinguish dinosaurs from other archosaurs

4 ____ Paragraph D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db27bcec-4a5b-5378-a265-bc3c86bbb84a', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33a5c804-ee9f-58fd-aeed-54b1f7161379', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d46cb83d-6870-5270-a8de-d5b7b2344c05', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57b3c8cf-1e05-5ac2-8c5d-2f32e84a41cd', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43616766-e1af-55a3-9262-bc9316f41974', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('568eb36d-34a9-56cc-a0dd-64f7d5652b4d', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6940dcfb-c033-5224-b722-88423a073a2e', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46d57438-b17b-5b39-a3fe-7af1b8ea08b9', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c894371-6728-5442-b466-5f27a9e6f630', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa4217e5-bb6d-5e0f-a8c6-7e33eba1d53d', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fbbc832-c939-51b1-8c57-430191f88f57', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d638d8fa-050a-553d-8a9a-c5c81dda1838', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 12, $md$xii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c155097d-bf83-5666-a3d2-35e1fbfb240e', 'c8d55cfa-0e69-5b1f-bc76-30e14245424d', 13, $md$xiii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has 8 paragraphs (
A-H
).
Choose the most suitable heading for each paragraph from the
List of headings
below.
Write the appropriate numbers (
i-xiii
) in Boxes
1-7
on your answer sheet.
One of the headings has been done for you as an example.
NB.
There are
more headings than paragraphs
, so you will not use all of them.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
Example :
Paragraph
H
Answer
: x
List of headings
i.
165 million years
ii.
The body plan of archosaurs
iii.
Dinosaurs - terrible lizards
iv.
Classification according to pelvic anatomy
v.
The suborders of Saurischia
vi.
Lizards and dinosaurs - two distinct superorders
vii.
Unique body plan helps identify dinosaurs from other animals
viii.
Herbivore dinosaurs
ix.
Lepidosaurs
x.
Frills and shelves
xi.
The origins of dinosaurs and lizards
xii.
Bird-hipped dinosaurs
xiii.
Skull bones distinguish dinosaurs from other archosaurs

5 ____ Paragraph E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ba5100a-083b-5fa2-afd6-031a0fc76aff', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6abe135-6f72-5dc6-8f63-8982699f14de', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7123aed7-b4df-5200-9d9b-ff117372b391', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('440c6b53-63b0-51ab-9b82-04d2116ef997', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f43ce18-0797-5312-b3fd-05a4f2270469', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee90d2fe-0352-5b12-8934-9b0fee170e98', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a39680f3-7448-5d17-a4e4-60dbec98d713', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e38c1dd0-881b-5bac-b0dd-d633422fa6f4', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5843d52-f0bd-51b5-b785-6cabf1831d33', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94438703-70bb-5800-9894-a7e34db16069', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c5d801e-1266-557b-a09c-cee67dfe11f3', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d0318ba-dd63-58ce-85b3-da72cce82241', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 12, $md$xii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7b270fe-a899-5cf9-ba3e-48f2ce8a69a1', '4bbbe55f-5a0a-5f5c-b873-38f97b8a4113', 13, $md$xiii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cf849e7f-c6be-5603-b9d2-a9399904c531', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has 8 paragraphs (
A-H
).
Choose the most suitable heading for each paragraph from the
List of headings
below.
Write the appropriate numbers (
i-xiii
) in Boxes
1-7
on your answer sheet.
One of the headings has been done for you as an example.
NB.
There are
more headings than paragraphs
, so you will not use all of them.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
Example :
Paragraph
H
Answer
: x
List of headings
i.
165 million years
ii.
The body plan of archosaurs
iii.
Dinosaurs - terrible lizards
iv.
Classification according to pelvic anatomy
v.
The suborders of Saurischia
vi.
Lizards and dinosaurs - two distinct superorders
vii.
Unique body plan helps identify dinosaurs from other animals
viii.
Herbivore dinosaurs
ix.
Lepidosaurs
x.
Frills and shelves
xi.
The origins of dinosaurs and lizards
xii.
Bird-hipped dinosaurs
xiii.
Skull bones distinguish dinosaurs from other archosaurs

6 ____ Paragraph F Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43820256-a094-590b-8fe8-29f0141163f6', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fb3218c-43dc-5806-86f3-4714d5d6121b', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f2fd4ab-56b8-5a11-9f6e-a59f35d558bd', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5596f4c1-ce19-50d3-a926-eba6673d83c3', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68854f9c-6193-58e1-a000-ec949fec8ffb', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdda6481-9f2e-538a-9c8b-a2063a9990df', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81b90958-6f99-537d-b444-beffa3688e38', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fcbf065-588c-5974-9034-244069698e7f', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('655058bb-51c3-51ad-b15f-6c93b3108c7f', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41ef8804-d389-5c1b-aab5-f3da847d3e40', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('511a3b26-0297-51cf-9929-66c3f036dddd', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90c51400-d371-5fa5-9e6c-241ec480d9ed', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 12, $md$xii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('832f864c-81a4-5294-b731-fa2373174a0e', 'cf849e7f-c6be-5603-b9d2-a9399904c531', 13, $md$xiii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d0487817-a6fc-596b-a1cc-334191ba3488', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has 8 paragraphs (
A-H
).
Choose the most suitable heading for each paragraph from the
List of headings
below.
Write the appropriate numbers (
i-xiii
) in Boxes
1-7
on your answer sheet.
One of the headings has been done for you as an example.
NB.
There are
more headings than paragraphs
, so you will not use all of them.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
Example :
Paragraph
H
Answer
: x
List of headings
i.
165 million years
ii.
The body plan of archosaurs
iii.
Dinosaurs - terrible lizards
iv.
Classification according to pelvic anatomy
v.
The suborders of Saurischia
vi.
Lizards and dinosaurs - two distinct superorders
vii.
Unique body plan helps identify dinosaurs from other animals
viii.
Herbivore dinosaurs
ix.
Lepidosaurs
x.
Frills and shelves
xi.
The origins of dinosaurs and lizards
xii.
Bird-hipped dinosaurs
xiii.
Skull bones distinguish dinosaurs from other archosaurs

7 ____ Paragraph G Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7cd837dc-1e0a-5055-8693-f8cf3fa9dc1c', 'd0487817-a6fc-596b-a1cc-334191ba3488', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e44cb20-0a6c-51dc-a588-da023e8032db', 'd0487817-a6fc-596b-a1cc-334191ba3488', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58add52c-dea1-51e4-9874-69289738ed8f', 'd0487817-a6fc-596b-a1cc-334191ba3488', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c78548db-7c11-53b5-a8b6-c14f706fde8c', 'd0487817-a6fc-596b-a1cc-334191ba3488', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8315f0fa-d45e-58b8-813d-541e9fb1b40a', 'd0487817-a6fc-596b-a1cc-334191ba3488', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4985ec55-ef6e-56df-83ec-22867f50ce07', 'd0487817-a6fc-596b-a1cc-334191ba3488', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c646171f-b0ab-5109-851f-834d3510ec34', 'd0487817-a6fc-596b-a1cc-334191ba3488', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95d65522-7cb3-5c29-b6ff-c3c8576386f5', 'd0487817-a6fc-596b-a1cc-334191ba3488', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcfc7608-0bf4-544c-8f50-643566a05799', 'd0487817-a6fc-596b-a1cc-334191ba3488', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1b38e96-f44b-5b19-a136-8fd20c17b941', 'd0487817-a6fc-596b-a1cc-334191ba3488', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4475429b-dce3-5b77-9ccf-5e42f95c281c', 'd0487817-a6fc-596b-a1cc-334191ba3488', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5472a00c-9558-5c0c-8508-7e4f39b6192d', 'd0487817-a6fc-596b-a1cc-334191ba3488', 12, $md$xii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26232302-4d17-5f8b-8bd0-e4bbe9275518', 'd0487817-a6fc-596b-a1cc-334191ba3488', 13, $md$xiii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('585f0e03-12f0-5f1b-8a4a-c28194de5600', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-10
Questions 8-10
Complete then sentences below.
Use
NO MORE THAN THREE WORDS
from the passage for each blank space.
Write your answers in boxes
8-10
on your answer sheet.
8.
Lizards and dinosaurs are classified into two different superorders because of the difference in their
Locate
9.
In the Triassic Period,
evolved into thecodonts, for example, lizards and snakes.
Locate
10.
Dinosaur skulls differed from those of any other known animals because of the presence of vomers:
Locate

8. Lizards and dinosaurs are classified into two different superorders because of the difference in their ____ Locate$md$, NULL, ARRAY['.*skeletal.*anatomy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f5484d48-a525-58c0-a333-68a6704cc6b9', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-10
Questions 8-10
Complete then sentences below.
Use
NO MORE THAN THREE WORDS
from the passage for each blank space.
Write your answers in boxes
8-10
on your answer sheet.
8.
Lizards and dinosaurs are classified into two different superorders because of the difference in their
Locate
9.
In the Triassic Period,
evolved into thecodonts, for example, lizards and snakes.
Locate
10.
Dinosaur skulls differed from those of any other known animals because of the presence of vomers:
Locate

9. In the Triassic Period, ____ evolved into thecodonts, for example, lizards and snakes. Locate$md$, NULL, ARRAY['.*eosuchians.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6c6dfd0c-4321-56e3-b87d-d9beb30a95cb', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-10
Questions 8-10
Complete then sentences below.
Use
NO MORE THAN THREE WORDS
from the passage for each blank space.
Write your answers in boxes
8-10
on your answer sheet.
8.
Lizards and dinosaurs are classified into two different superorders because of the difference in their
Locate
9.
In the Triassic Period,
evolved into thecodonts, for example, lizards and snakes.
Locate
10.
Dinosaur skulls differed from those of any other known animals because of the presence of vomers:
Locate

10. Dinosaur skulls differed from those of any other known animals because of the presence of vomers: ____ Locate$md$, NULL, ARRAY['.*two.*long.*bones.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b8623138-cc9d-510f-ba4e-814ff8974d8c', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Choose one phrase (
A-H
) from the
List of features
to match with the
Dinosaurs
listed below.
Write the appropriate letters (
A-H
) in boxes
11-14
on your answer sheet.
The information in the completed sentences should be an accurate summary of the points made by the writer.
NB.
There are more phrases (
A-H
) than sentences, so you will not need to use them all. You may use each phrase
once only
.
Dinosaurs
11.
Dinosaurs differed from lizards, because
Locate
12.
Saurischian and ornithischian dinosaurs
Locate
13.
Unlike therapods, sauropodomorphs
Locate
14.
Some dinosaurs used their tails to balance, others
Locate
List of features
A
are both divided into two orders.
B
the former had a "fully improved gait".
C
were not usually very heavy.
D
could walk or run on their back legs.
E
their hind limbs sprawled out to the side.
F
walked or ran on four legs, rather than two.
G
both had a pelvic girdle comprising six bones.
H
did not always eat meat.

11. Dinosaurs differed from lizards, because ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6de4a1fe-6c9a-5621-b1d5-3a7c742c3772', 'b8623138-cc9d-510f-ba4e-814ff8974d8c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('946e4d21-b9de-584b-9553-b81ac791e90d', 'b8623138-cc9d-510f-ba4e-814ff8974d8c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d62ef8e-fed6-574b-9ce6-0b2934605a53', 'b8623138-cc9d-510f-ba4e-814ff8974d8c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e3b8964-8449-54c7-a26f-15cbc4dbe3eb', 'b8623138-cc9d-510f-ba4e-814ff8974d8c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88dfddd1-beb3-5ee3-9809-e7b48440fd51', 'b8623138-cc9d-510f-ba4e-814ff8974d8c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cf5a30a-229f-5f50-8728-087feb0ce5e3', 'b8623138-cc9d-510f-ba4e-814ff8974d8c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3443ba94-b7c2-5be8-96ad-020edb3d0509', 'b8623138-cc9d-510f-ba4e-814ff8974d8c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e21cca2-b349-5c6d-8cea-2a3fe4ec81c4', 'b8623138-cc9d-510f-ba4e-814ff8974d8c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Choose one phrase (
A-H
) from the
List of features
to match with the
Dinosaurs
listed below.
Write the appropriate letters (
A-H
) in boxes
11-14
on your answer sheet.
The information in the completed sentences should be an accurate summary of the points made by the writer.
NB.
There are more phrases (
A-H
) than sentences, so you will not need to use them all. You may use each phrase
once only
.
Dinosaurs
11.
Dinosaurs differed from lizards, because
Locate
12.
Saurischian and ornithischian dinosaurs
Locate
13.
Unlike therapods, sauropodomorphs
Locate
14.
Some dinosaurs used their tails to balance, others
Locate
List of features
A
are both divided into two orders.
B
the former had a "fully improved gait".
C
were not usually very heavy.
D
could walk or run on their back legs.
E
their hind limbs sprawled out to the side.
F
walked or ran on four legs, rather than two.
G
both had a pelvic girdle comprising six bones.
H
did not always eat meat.

12. Saurischian and ornithischian dinosaurs ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3a224d4-f357-5967-b6c9-011d508a54c0', '1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a461e773-2168-5dc8-8ab0-290e05c49d9e', '1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08d043a2-ed64-5144-a415-3ef9764e3183', '1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a2ae977-f26f-5496-970c-ee7f8f23deac', '1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f56acdd0-fe8e-5002-8341-79cb2edb8e3f', '1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de80eced-696e-5c04-8d1e-de153ab33ef3', '1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c3d0c63-4ab5-589f-8c5f-a902ab256ce1', '1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86c6c539-ec8a-5e0e-a178-0889812c1fa4', '1ece4a0d-c03e-5ca1-9ad9-d418e0d4516b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c92a624f-d762-562d-b6ea-31f1d656a62e', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Choose one phrase (
A-H
) from the
List of features
to match with the
Dinosaurs
listed below.
Write the appropriate letters (
A-H
) in boxes
11-14
on your answer sheet.
The information in the completed sentences should be an accurate summary of the points made by the writer.
NB.
There are more phrases (
A-H
) than sentences, so you will not need to use them all. You may use each phrase
once only
.
Dinosaurs
11.
Dinosaurs differed from lizards, because
Locate
12.
Saurischian and ornithischian dinosaurs
Locate
13.
Unlike therapods, sauropodomorphs
Locate
14.
Some dinosaurs used their tails to balance, others
Locate
List of features
A
are both divided into two orders.
B
the former had a "fully improved gait".
C
were not usually very heavy.
D
could walk or run on their back legs.
E
their hind limbs sprawled out to the side.
F
walked or ran on four legs, rather than two.
G
both had a pelvic girdle comprising six bones.
H
did not always eat meat.

13. Unlike therapods, sauropodomorphs ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('657dec12-3f23-5ef8-a4bc-50303075fd9a', 'c92a624f-d762-562d-b6ea-31f1d656a62e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7596ef13-95d0-51f3-a2b9-18756368ce31', 'c92a624f-d762-562d-b6ea-31f1d656a62e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aee088e5-f378-5a7e-ad7d-1135eee06c62', 'c92a624f-d762-562d-b6ea-31f1d656a62e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e9f6b9f-87dc-5f75-944f-debe11877c9a', 'c92a624f-d762-562d-b6ea-31f1d656a62e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('290b0e94-156c-5498-bea8-fac8e92b01f6', 'c92a624f-d762-562d-b6ea-31f1d656a62e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c176a135-8cfd-59bc-ba3c-895508e928fe', 'c92a624f-d762-562d-b6ea-31f1d656a62e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f66ab2f-4db7-57d8-a578-c54efde6f4dd', 'c92a624f-d762-562d-b6ea-31f1d656a62e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f690578a-ce07-559d-9a3b-86d77b7c1b9c', 'c92a624f-d762-562d-b6ea-31f1d656a62e', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8fcee6d-73f4-55b0-b94f-84cdfa13d797', 'e6098e4c-70c5-5dfb-a085-94a3ab96f424', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Choose one phrase (
A-H
) from the
List of features
to match with the
Dinosaurs
listed below.
Write the appropriate letters (
A-H
) in boxes
11-14
on your answer sheet.
The information in the completed sentences should be an accurate summary of the points made by the writer.
NB.
There are more phrases (
A-H
) than sentences, so you will not need to use them all. You may use each phrase
once only
.
Dinosaurs
11.
Dinosaurs differed from lizards, because
Locate
12.
Saurischian and ornithischian dinosaurs
Locate
13.
Unlike therapods, sauropodomorphs
Locate
14.
Some dinosaurs used their tails to balance, others
Locate
List of features
A
are both divided into two orders.
B
the former had a "fully improved gait".
C
were not usually very heavy.
D
could walk or run on their back legs.
E
their hind limbs sprawled out to the side.
F
walked or ran on four legs, rather than two.
G
both had a pelvic girdle comprising six bones.
H
did not always eat meat.

14. Some dinosaurs used their tails to balance, others ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4885e5c6-3e5a-59fc-bb2c-e86ecfb17f16', 'd8fcee6d-73f4-55b0-b94f-84cdfa13d797', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('102bf56a-7e79-50e5-a2a9-6184fbe74729', 'd8fcee6d-73f4-55b0-b94f-84cdfa13d797', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2eb3b834-5bf7-5997-9e14-979bd3766b62', 'd8fcee6d-73f4-55b0-b94f-84cdfa13d797', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58ec1fe4-d88d-5274-b1f7-cf1185550e12', 'd8fcee6d-73f4-55b0-b94f-84cdfa13d797', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcf09efb-e89c-5c26-ab7e-04c3ab18130c', 'd8fcee6d-73f4-55b0-b94f-84cdfa13d797', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e2e17da-d4af-55f3-8000-8962a72bc058', 'd8fcee6d-73f4-55b0-b94f-84cdfa13d797', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fe2a5f3-40a6-52da-b8a2-2d860cbb4328', 'd8fcee6d-73f4-55b0-b94f-84cdfa13d797', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6096020-71e5-5e14-8486-bf1d3d50d38c', 'd8fcee6d-73f4-55b0-b94f-84cdfa13d797', 8, $md$H$md$, false);

COMMIT;

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-science-and-the-stradivariusuncovering-the-secret-of-quality-1534'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-science-and-the-stradivariusuncovering-the-secret-of-quality-1534';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-science-and-the-stradivariusuncovering-the-secret-of-quality-1534';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-science-and-the-stradivariusuncovering-the-secret-of-quality-1534';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('39382abf-4430-51d8-adff-99bceb941e47', 'ielts-reading-science-and-the-stradivariusuncovering-the-secret-of-quality-1534', $t$Science and the Stradivarius:Uncovering the secret of quality$t$, $md$## Science and the Stradivarius:Uncovering the secret of quality

Nguồn:
- Test: https://mini-ielts.com/1534/reading/science-and-the-stradivariusuncovering-the-secret-of-quality
- Solution: https://mini-ielts.com/1534/view-solution/reading/science-and-the-stradivariusuncovering-the-secret-of-quality$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f84d9246-184f-5dbb-be7b-d26d8055e606', '39382abf-4430-51d8-adff-99bceb941e47', 1, $t$Reading — Science and the Stradivarius:Uncovering the secret of quality$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Science and the Stradivarius:Uncovering the secret of quality

| | Science and the Stradivarius:Uncovering the secret of quality Violins made by long-dead Italian craftsmen from the Cremona region are beautiful works of art, coveted by collectors as well as players. Particularly outstanding violins have reputedly changed hands for over a million pounds. In contrast, fine modern instruments can be bought for under £100. Do such figures really reflect such large differences in quality? After more than a hundred years of vigorous debate, this question remains highly contentious, provoking strongly held but divergent views among musicians, violin makers and scientists alike. Every violin, whether a Stradivarius or the cheapest factory- made copy, has a distinctive 'voice’ of its 0. Just as any musician can immediately recognise the difference between Domingo and Pavarotti singing the same operatic aria, so a skilled violinist can distinguish between different qualities in the sound produced by individual Stradivari or Guarneri violins. Individual notes on a single instrument sound different each time they are played, which suggests that the perceived tone of a violin must be related to the overall design of the instrument, rather than the frequencies of particular resonances on it. But although various attempts have been made to analyse such global properties, it is extremely difficult to distinguish between a fine Stradivarius instrument and an indifferent modern copy on the basis of the measured response alone. The ear is a supreme detection device, and a system has yet to be developed which can match the brain's sophisticated ability to assess complex sounds. So how do skilled violinmakers optimise the tone of an instrument during the construction process? They begin by selecting a wood of the highest possible quality for the front and back plates (or parts of the violin), which they test by tapping with a hammer and judging how well it 'rings’. The next important step is to skillfully carve the plates out of the solid wood, taking great care to get the right degree of arching and variations in thickness. Traditional makers optimise the thickness by testing the ‘feel’ of the plates when they are flexed, and by the sounds produced when they are tapped at different positions with the knuckles. However, in the last 50 years or so a group of violin makers has emerged who have tried to take a more overtly scientific approach to violin making. One common practice they have adopted is to replace the traditional flexing and tapping of plates by controlled measurements. During the carving process, the thinned plates are sprinkled with flakes of glitter and suspended horizontally above a loudspeaker. The glitter forms a pattern each time the loudspeaker excites a resonance. The aim is to interactively 'tune' these first few free plate resonances to specified patterns. Unfortunately, there are very few examples of such measurements for really fine Italian instruments because their owners are naturally reluctant to allow their violins to be taken apart for the sake of science. The few tests that have been performed suggest that the first Italian makers may have tuned the resonant modes of the individual plates - which they could identify as they tapped them - to exact musical intervals. This would be consistent with the prevailing Renaissance view of ’perfection 1 , which was measured in terms of numbers and exact ratios. However, there is no historical data to support this case. Another factor that affects sound quality is the presence of moisture. To achieve the quality of “vibrancy” in a violin requires high-quality wood with low internal damping. By measuring the pattern of growth-rings in the wood of a Stradivarius, we know that the Italian violin makers sometimes used planks of wood that had only been seasoned for five years. However, such wood is now 300 years old, and the intrinsic internal damping will almost certainly have decreased with time. The age of the wood may therefore automatically contribute to the improved quality of older instruments. This may also explain why the quality of a modern instrument appears to improve in its first few years. Another factor thought to account for sound quality is the nature of the varnish used to protect the instrument. One of the most popular theories for well over a century to account for the Stradivarius secret has been that the varnish had some sort of 'magic' composition. However, historical research has shown that it was very similar to the varnish used today. So apart from the possibility that the Italian varnish was contaminated with the wings of passing insects and debris from the workshop floor, there is no convincing evidence to support the idea of a secret formula. Other researchers, meanwhile, have claimed that Stradivarius's secret was to soak the timber in water, to leach out supposedly harmful chemicals, before it was seasoned. Although this would be consistent with the idea that the masts and cars of recently sunken Venetian war galleys might have been used to make violins, other scientific and historical evidence to support this view is unconvincing. In conclusion, science has not provided any convincing evidence to set Cremonese instruments apart from the finest violins made by skilled craftsmen today. Indeed, some leading soloists do occasionally play on modern instruments. However, the foremost soloists - and, not surprisingly, violin dealers, who have a vested interest in maintaining the Cremonese legend of intrinsic superiority - remain utterly unconvinced.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('814b52de-c15c-5f8b-b479-b68d2157f947', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs,
A-l
Choose the correct heading for paragraphs A and C-l from the list of headings below.
Write the correct number,
i-xi,
in boxes 1-8 on your answer sheet.
List of Headings
i
An analysis of protective coatings
ii
Applying technology to violin production
iii.
Location - a key factor
iv
A controversial range
of
prices
v
Techniques of mass production
vi
The advantages of older wood
vii.
A re-evaluation of documentary evidence
viii.
The mathematical basis
of
earlier design
ix
Manual woodworking techniques
x
Preferences of top musicians
xi.
The use of
saturated wood
xii.
The
challenge
for
scientists
1
Paragraph
A
2
Paragraph
C
Example
Paragraph
C Vii
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H
8
Paragraph I

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a83aed1-ce6f-5a34-b2c0-99d0e344242d', '814b52de-c15c-5f8b-b479-b68d2157f947', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15da0928-4173-5cf9-a7cf-116a43addf75', '814b52de-c15c-5f8b-b479-b68d2157f947', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b1754aa-91bc-5728-831e-523db88d4188', '814b52de-c15c-5f8b-b479-b68d2157f947', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cf8dcc8-5980-58c4-b7d3-4325e5febb82', '814b52de-c15c-5f8b-b479-b68d2157f947', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5602502e-74d6-5878-b284-cf3b7435eb6f', '814b52de-c15c-5f8b-b479-b68d2157f947', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('912daacf-e7f8-5811-b846-ef1da5004277', '814b52de-c15c-5f8b-b479-b68d2157f947', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e7effe8-a19a-5f60-86a6-7d5e18c409e8', '814b52de-c15c-5f8b-b479-b68d2157f947', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbf191c6-7953-58db-9af8-d1706d9d4d58', '814b52de-c15c-5f8b-b479-b68d2157f947', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8e58c16-e7cc-5881-8d2f-11d8253c761c', '814b52de-c15c-5f8b-b479-b68d2157f947', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10d324ed-bf57-5b0e-b69d-f73addf84c3f', '814b52de-c15c-5f8b-b479-b68d2157f947', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a11adf1-f012-5564-aebf-be9a96c6105a', '814b52de-c15c-5f8b-b479-b68d2157f947', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('728e75bb-02db-51fc-8cf7-431683c455b8', '814b52de-c15c-5f8b-b479-b68d2157f947', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('04811614-d7da-517b-9896-5c803b8e915c', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs,
A-l
Choose the correct heading for paragraphs A and C-l from the list of headings below.
Write the correct number,
i-xi,
in boxes 1-8 on your answer sheet.
List of Headings
i
An analysis of protective coatings
ii
Applying technology to violin production
iii.
Location - a key factor
iv
A controversial range
of
prices
v
Techniques of mass production
vi
The advantages of older wood
vii.
A re-evaluation of documentary evidence
viii.
The mathematical basis
of
earlier design
ix
Manual woodworking techniques
x
Preferences of top musicians
xi.
The use of
saturated wood
xii.
The
challenge
for
scientists
1
Paragraph
A
2
Paragraph
C
Example
Paragraph
C Vii
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H
8
Paragraph I

2 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6da98f6b-4582-5548-9a00-207ee0e79626', '04811614-d7da-517b-9896-5c803b8e915c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b36b2246-0a6f-5c54-b3cc-6e0ef049782d', '04811614-d7da-517b-9896-5c803b8e915c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('802a9880-c447-5664-80f3-a54805102226', '04811614-d7da-517b-9896-5c803b8e915c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4e2fd55-2bb1-5f81-8a14-8b5a0ca5c6ac', '04811614-d7da-517b-9896-5c803b8e915c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51eea6f3-8ffe-5ab1-ae2d-92aa6fcf61c0', '04811614-d7da-517b-9896-5c803b8e915c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e96b6ee4-b1cd-5157-a54d-52319acd1d05', '04811614-d7da-517b-9896-5c803b8e915c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6154644a-da17-57e6-a515-c88bd525f214', '04811614-d7da-517b-9896-5c803b8e915c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb93d2b6-7e0e-5662-834b-76c189a1bbe3', '04811614-d7da-517b-9896-5c803b8e915c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2adc09e-5194-50e2-a632-6044b805ce8a', '04811614-d7da-517b-9896-5c803b8e915c', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b42f98dd-06a9-599c-bf9b-7aec01bd4ba5', '04811614-d7da-517b-9896-5c803b8e915c', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dc53237-a731-5ecf-b076-16eee11c236a', '04811614-d7da-517b-9896-5c803b8e915c', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05070470-4794-5bf2-9a72-5974c6b7ebf8', '04811614-d7da-517b-9896-5c803b8e915c', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aeaa7d26-a00c-5c18-8790-a941534f3ce1', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs,
A-l
Choose the correct heading for paragraphs A and C-l from the list of headings below.
Write the correct number,
i-xi,
in boxes 1-8 on your answer sheet.
List of Headings
i
An analysis of protective coatings
ii
Applying technology to violin production
iii.
Location - a key factor
iv
A controversial range
of
prices
v
Techniques of mass production
vi
The advantages of older wood
vii.
A re-evaluation of documentary evidence
viii.
The mathematical basis
of
earlier design
ix
Manual woodworking techniques
x
Preferences of top musicians
xi.
The use of
saturated wood
xii.
The
challenge
for
scientists
1
Paragraph
A
2
Paragraph
C
Example
Paragraph
C Vii
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H
8
Paragraph I

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98756c9d-d9db-5f11-8a48-29971dee8a0a', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd4a257c-dd3f-5aa6-87cd-92d18df44cec', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b0b8b21-a601-588c-8c28-0e0ac22cfd3b', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7591e30-6f7e-5bf8-bd89-2a23e0410451', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7e4461b-78e3-5b17-abec-8811c1fcd2b3', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0eb07b4-e75b-55de-9adc-8d9454235055', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a8de496-6e7d-5579-8b60-661d241079ad', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2117a15-5152-59c6-afba-538b5d413982', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8eb6e11b-2cd7-5ac7-96b3-8245c96c26d1', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f638cd06-3124-5e59-9545-d166c9c73cf9', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('605e0454-a5fd-5605-898d-98fa77f4ba0e', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69a3558e-954f-5937-8afe-870c1dd800ca', 'aeaa7d26-a00c-5c18-8790-a941534f3ce1', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs,
A-l
Choose the correct heading for paragraphs A and C-l from the list of headings below.
Write the correct number,
i-xi,
in boxes 1-8 on your answer sheet.
List of Headings
i
An analysis of protective coatings
ii
Applying technology to violin production
iii.
Location - a key factor
iv
A controversial range
of
prices
v
Techniques of mass production
vi
The advantages of older wood
vii.
A re-evaluation of documentary evidence
viii.
The mathematical basis
of
earlier design
ix
Manual woodworking techniques
x
Preferences of top musicians
xi.
The use of
saturated wood
xii.
The
challenge
for
scientists
1
Paragraph
A
2
Paragraph
C
Example
Paragraph
C Vii
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H
8
Paragraph I

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52a73e4a-36e2-56ea-9225-445cac306fc1', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de8c03fb-5210-5185-b686-7caba8364966', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98b4dc55-c342-5e1d-b917-4e67c71895d7', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a4f958f-e78a-5a8f-9899-e3fae38dc972', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9c316f4-68a0-544b-b6c6-867d3b89ef64', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e10f696d-b19d-51de-ba74-7bd5e6fc79c6', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bc0ca7f-1272-5ce1-a0d6-859209c4630e', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5af52312-0c47-555f-8709-4c2d20ceb2f6', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('932ecf04-e86e-5d19-a1cf-e973da9a595e', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('626f8f74-a286-57f8-92d1-01153f315a67', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9eda45b6-2d4a-546a-a556-e1a13c4d8336', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1852386c-388e-5cfb-8862-7cb468c68052', 'ffdc1c04-eba6-59c9-85f2-71ddbc7138cd', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs,
A-l
Choose the correct heading for paragraphs A and C-l from the list of headings below.
Write the correct number,
i-xi,
in boxes 1-8 on your answer sheet.
List of Headings
i
An analysis of protective coatings
ii
Applying technology to violin production
iii.
Location - a key factor
iv
A controversial range
of
prices
v
Techniques of mass production
vi
The advantages of older wood
vii.
A re-evaluation of documentary evidence
viii.
The mathematical basis
of
earlier design
ix
Manual woodworking techniques
x
Preferences of top musicians
xi.
The use of
saturated wood
xii.
The
challenge
for
scientists
1
Paragraph
A
2
Paragraph
C
Example
Paragraph
C Vii
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H
8
Paragraph I

5 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c809d65-de24-50cd-9479-508518f6b9b5', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b8eabaf-64a0-5492-a030-32d603ebd7e7', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afa41055-f806-5ba8-beed-8d1512126870', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc6a4eb7-b42e-598c-b111-c7968f18a297', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e1eb2de-e3ba-5b55-9c7d-007d09dd86e3', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fcbf061-37c0-5f23-8dea-e25b525e3a5a', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0578b42-4f5c-512e-a57d-5cb64293848a', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36cc79af-32c0-5072-9d78-2278cb9721ec', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('163490e9-fd5b-58fe-a71e-782f2d4f2bf4', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0148c12d-d631-51b5-8265-267d827afd34', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e58324ff-c37d-5caf-9282-ad4eba432ff0', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f400c5a6-0462-54ac-9474-3486cbe503d5', '8a1cc304-ce7d-5d19-bb35-570e9e8b782a', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs,
A-l
Choose the correct heading for paragraphs A and C-l from the list of headings below.
Write the correct number,
i-xi,
in boxes 1-8 on your answer sheet.
List of Headings
i
An analysis of protective coatings
ii
Applying technology to violin production
iii.
Location - a key factor
iv
A controversial range
of
prices
v
Techniques of mass production
vi
The advantages of older wood
vii.
A re-evaluation of documentary evidence
viii.
The mathematical basis
of
earlier design
ix
Manual woodworking techniques
x
Preferences of top musicians
xi.
The use of
saturated wood
xii.
The
challenge
for
scientists
1
Paragraph
A
2
Paragraph
C
Example
Paragraph
C Vii
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H
8
Paragraph I

6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90d3f90e-0c5b-5abb-b65c-300eb3c39467', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('720f912e-ff8a-58a2-984e-6f606006c293', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24bee1eb-ae38-5be2-a159-40ee105eaad9', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c150e632-637b-56b1-8f6d-992b51394ed2', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddd0b40d-aa02-5758-9610-00c1c7a24c30', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a163a52-8202-5704-9b6f-845fa6e32692', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f04e86cb-36bf-5433-a2f0-5605451a95be', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16e94184-b6e6-5333-b937-1acd50c46ff0', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f96194d-09f1-5b8c-8e2f-cea1d4a3da5b', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5867f0c6-673c-55f1-a8b7-6bd739319129', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0c7d48c-0b8a-5919-9c65-222a8c29100d', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d539bc7f-af69-513d-af1d-95895486536e', 'bec17983-6dbb-53e7-b6a0-63e4fe06fd54', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bcb08410-8b61-59e3-a273-aef6904c9237', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs,
A-l
Choose the correct heading for paragraphs A and C-l from the list of headings below.
Write the correct number,
i-xi,
in boxes 1-8 on your answer sheet.
List of Headings
i
An analysis of protective coatings
ii
Applying technology to violin production
iii.
Location - a key factor
iv
A controversial range
of
prices
v
Techniques of mass production
vi
The advantages of older wood
vii.
A re-evaluation of documentary evidence
viii.
The mathematical basis
of
earlier design
ix
Manual woodworking techniques
x
Preferences of top musicians
xi.
The use of
saturated wood
xii.
The
challenge
for
scientists
1
Paragraph
A
2
Paragraph
C
Example
Paragraph
C Vii
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H
8
Paragraph I

7 ____ Paragraph H$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('679852c0-0e3f-5d98-9ab2-d2fe830488dc', 'bcb08410-8b61-59e3-a273-aef6904c9237', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4fab2ad-f818-5d44-b825-39e268af3de0', 'bcb08410-8b61-59e3-a273-aef6904c9237', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1085019-82da-53e0-9e65-82c5c269ffd8', 'bcb08410-8b61-59e3-a273-aef6904c9237', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('313ec15b-6b0c-59df-bc19-12f7c9006fb7', 'bcb08410-8b61-59e3-a273-aef6904c9237', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('700d7cdd-7fac-5412-96b9-f3699fec8e40', 'bcb08410-8b61-59e3-a273-aef6904c9237', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dbb63c5-96d8-52ed-98c5-3eec29bd9e84', 'bcb08410-8b61-59e3-a273-aef6904c9237', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ad7b177-eb3b-54d0-8747-72b8f6146207', 'bcb08410-8b61-59e3-a273-aef6904c9237', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ea6eff5-2100-544e-8fe5-083984a98f85', 'bcb08410-8b61-59e3-a273-aef6904c9237', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a9b91f1-e4e4-57f8-8cf5-4354f32a8d4b', 'bcb08410-8b61-59e3-a273-aef6904c9237', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd59514d-5680-5a8d-9560-b9bd744a62b7', 'bcb08410-8b61-59e3-a273-aef6904c9237', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bde16c47-2098-5d7c-90c0-c3c3ab37eff8', 'bcb08410-8b61-59e3-a273-aef6904c9237', 11, $md$xi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d31f6fb-fc84-547e-80ee-1cb7b0899c40', 'bcb08410-8b61-59e3-a273-aef6904c9237', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b1668be3-ff6b-5e80-8507-6ea58adaaa93', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 8, 'MATCHING_HEADING', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs,
A-l
Choose the correct heading for paragraphs A and C-l from the list of headings below.
Write the correct number,
i-xi,
in boxes 1-8 on your answer sheet.
List of Headings
i
An analysis of protective coatings
ii
Applying technology to violin production
iii.
Location - a key factor
iv
A controversial range
of
prices
v
Techniques of mass production
vi
The advantages of older wood
vii.
A re-evaluation of documentary evidence
viii.
The mathematical basis
of
earlier design
ix
Manual woodworking techniques
x
Preferences of top musicians
xi.
The use of
saturated wood
xii.
The
challenge
for
scientists
1
Paragraph
A
2
Paragraph
C
Example
Paragraph
C Vii
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G
7
Paragraph H
8
Paragraph I

8 ____ Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1a4aa29-4dd3-51e6-b9f8-f7855be0af09', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9832e7b3-c2a0-5dc0-92fc-d1b8d247f09a', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6343b1f-d922-5bd2-ac42-dac4168b5c83', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dfeafef-6c3f-532a-b5ff-1dd270c5bf7d', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4463c1a6-ddb3-5e29-9c0d-aa8f9c0cdccf', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1a6be54-5313-54c5-852e-aa3d8cfc5f8f', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7c609c3-1706-5c3d-949e-c6dc6233f194', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed2ed7aa-3830-5211-ab2a-323615139db5', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6edb87b8-74f0-5541-9b03-82fb86c6249b', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df14be22-8d63-5832-9ea3-ea07d537ae58', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 10, $md$x$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3e8056b-5269-50c7-ab71-31da7536fb07', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b853a3b3-b24c-5d21-a012-a6dcdbb3dbfb', 'b1668be3-ff6b-5e80-8507-6ea58adaaa93', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8638d50c-afe3-5720-a9ec-75b11689ea70', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The quality of any particular note played on the same violin varies.
10
Scientific instruments analyse complex sound more accurately than humans.
11
The quality of handmade violins varies according to the musical ability of the craftsman.
12
Modern violins seem to improve in their early years.
13
Modern violins are gaining in popularity amongst the top violinists

9 ____ The quality of any particular note played on the same violin varies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc7ef6be-81ea-5cfd-99eb-1217736e8c3d', '8638d50c-afe3-5720-a9ec-75b11689ea70', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('935be93d-a4fe-5209-b8c4-bb6ba86b6704', '8638d50c-afe3-5720-a9ec-75b11689ea70', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0185c74c-cd49-5004-9807-634eb8838119', '8638d50c-afe3-5720-a9ec-75b11689ea70', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fcd8b006-9831-596d-95ea-c6c92cc52b98', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The quality of any particular note played on the same violin varies.
10
Scientific instruments analyse complex sound more accurately than humans.
11
The quality of handmade violins varies according to the musical ability of the craftsman.
12
Modern violins seem to improve in their early years.
13
Modern violins are gaining in popularity amongst the top violinists

10 ____ Scientific instruments analyse complex sound more accurately than humans.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3427878-141e-5b58-b16e-c2cc754bedde', 'fcd8b006-9831-596d-95ea-c6c92cc52b98', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27ae07f2-cb9b-5aef-a0ec-f2655398318f', 'fcd8b006-9831-596d-95ea-c6c92cc52b98', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('045f145b-5733-5311-a8f4-721ad03ace08', 'fcd8b006-9831-596d-95ea-c6c92cc52b98', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35517c4d-3bb4-5028-86eb-4dbf907dd63c', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The quality of any particular note played on the same violin varies.
10
Scientific instruments analyse complex sound more accurately than humans.
11
The quality of handmade violins varies according to the musical ability of the craftsman.
12
Modern violins seem to improve in their early years.
13
Modern violins are gaining in popularity amongst the top violinists

11 ____ The quality of handmade violins varies according to the musical ability of the craftsman.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac3dac10-cc94-531e-bd52-b6531ea913e6', '35517c4d-3bb4-5028-86eb-4dbf907dd63c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b366cacc-c906-5d84-bb25-da574c264b38', '35517c4d-3bb4-5028-86eb-4dbf907dd63c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('731f8329-6cf7-55ae-8133-5ce133ae308f', '35517c4d-3bb4-5028-86eb-4dbf907dd63c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bd123bc8-827e-5b5e-b7b2-6284342905b9', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The quality of any particular note played on the same violin varies.
10
Scientific instruments analyse complex sound more accurately than humans.
11
The quality of handmade violins varies according to the musical ability of the craftsman.
12
Modern violins seem to improve in their early years.
13
Modern violins are gaining in popularity amongst the top violinists

12 ____ Modern violins seem to improve in their early years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b7fc211-4ab0-5d0c-8bca-c507c668f644', 'bd123bc8-827e-5b5e-b7b2-6284342905b9', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e85964f-911c-5bb7-b007-4bafdd4860da', 'bd123bc8-827e-5b5e-b7b2-6284342905b9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5046fea5-47b1-5bef-8844-a8f3d7866d61', 'bd123bc8-827e-5b5e-b7b2-6284342905b9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3c01280c-ced3-599b-b4c4-9c2102cfc97c', 'f84d9246-184f-5dbb-be7b-d26d8055e606', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes 9-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
The quality of any particular note played on the same violin varies.
10
Scientific instruments analyse complex sound more accurately than humans.
11
The quality of handmade violins varies according to the musical ability of the craftsman.
12
Modern violins seem to improve in their early years.
13
Modern violins are gaining in popularity amongst the top violinists

13 ____ Modern violins are gaining in popularity amongst the top violinists$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('accc561d-8820-595c-9d94-1938fb1dd24c', '3c01280c-ced3-599b-b4c4-9c2102cfc97c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83ffcbe2-bda2-54bf-a4ae-719937c3547c', '3c01280c-ced3-599b-b4c4-9c2102cfc97c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28cfab8e-1586-5887-a1c2-58c49d2e4eb5', '3c01280c-ced3-599b-b4c4-9c2102cfc97c', 3, $md$NOT GIVEN$md$, false);

COMMIT;

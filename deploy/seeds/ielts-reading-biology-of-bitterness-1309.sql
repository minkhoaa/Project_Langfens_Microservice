BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-biology-of-bitterness-1309'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-biology-of-bitterness-1309';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-biology-of-bitterness-1309';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-biology-of-bitterness-1309';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('ac81a21d-65c5-536b-b484-abf5b59f9610', 'ielts-reading-biology-of-bitterness-1309', $t$Biology of Bitterness$t$, $md$## Biology of Bitterness

Nguồn:
- Test: https://mini-ielts.com/1309/reading/biology-of-bitterness
- Solution: https://mini-ielts.com/1309/view-solution/reading/biology-of-bitterness$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0e1cc4fa-71b7-507d-83fe-fe83d0389325', 'ac81a21d-65c5-536b-b484-abf5b59f9610', 1, $t$Reading — Biology of Bitterness$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Biology of Bitterness

To many people, grapefruit is palatable only when doused in sugar. Bitter Blockers like adenosine monophosphate could change that.

A. There is a reason why grapefruit juice is served in little glasses: most people don’t want to drink more than a few ounces at a time. aringin, a natural chemical compound found in grapefruit, tastes bitter. Some people like that bitterness in small doses and believe it enhances the general flavor, but others would rather avoid it altogether. So juice packagers often select grapefruit with low naringin though the compound has antioxidant properties that some nutritionists contend may help prevent cancer and arteriosclerosis.

B. It is possible, however, to get the goodness of grapefruit juice without the bitter taste. I found that out by participating in a test conducted at the Linguagen Corporation, a biotechnology company in Cranbury, New Jersey. Sets of two miniature white paper cups, labeled 304and 305, were placed before five people seated around a conference table. Each of us drank from one cup and then the other, cleansing our palates between tastes with water and a soda cracker. Even the smallest sip of 304 had grapefruit ‘s unmistakable bitter bite. But 305 was smoother; there was the sour taste of citrus but none of the bitterness of naringin. This juice had been treated with adenosine monophosphate, or AMP, a compound that blocks the bitterness in foods without making them less nutritious.

C. Taste research is a booming business these days, with scientists delving into all five basics-sweet, bitter, sour, salty, and umami, the savory taste of protein. Bitterness is of special interest to industry because of its untapped potential in food. There are thousands of bitter -tasting compounds in nature. They defend plants by warning animals away and protect animals by letting them know when a plant may be poisonous. But the system isn’t foolproof. Grapefruit and cruciferous vegetable like Brussels sprouts and kale are nutritious despite-and sometimes because of-their bitter-tasting components. Over time, many people have learned to love them, at least in small doses. “Humans are the only species that enjoys bitter taste,” says Charles Zuker, a neuroscientist at the University of California School of Medicine at San Diego. “Every other species is averse to bitter because it means bad news. But we have learned to enjoy it. We drink coffee, which is bitter, and quinine [in tonic water] too. We enjoy having that spice in our lives.” Because bitterness can be pleasing in small quantities but repellent when intense, bitter blockers like AMP could make a whole range of foods, drinks, and medicines more palatable-and therefore more profitable.

D. People have varying capacities for tasting bitterness, and the differences appear to be genetic. About 75 percent of people are sensitive to the taste of the bitter compounds phenylthiocarbamide and 6-n-propylthiouracil. and 25 percent are insensitive. Those who are sensitive to phenylthiocarbamide seem to be less likely than others to eat cruciferous vegetables, according to Stephen Wooding, a geneticist at the University of Utah. Some people, known as supertasters, are especially sensitive to 6-n-propylthiouraci because they have an unusually high number of taste buds. Supertasters tend to shun all kinds of bitter-tasting things, including vegetable, coffee, and dark chocolate. Perhaps as a result, they tend to be thin. They’re also less fond of alcoholic drinks, which are often slightly bitter. Dewar’s scotch, for instance, tastes somewhat sweet to most people. ” But a supertaster tastes no sweetness at all, only bitterness,” says Valerie Duffy, an associate professor of dietetics at the University of Connecticut at Storrs.

E. In one recent study, Duffy found that supertasters consume alcoholic beverages, on average, only two to three times a week, compared with five or six times for the average nontasters. Each taste bud, which looks like an onion, consists of 50 to 100 elongated cells running from the top of the bud to the bottom. At the top is a little clump of receptors that capture the taste molecules, known as tastants, in food and drink. The receptors function much like those for sight and smell. Once a bitter signal has been received, it is relayed via proteins known as G proteins. The G protein involved in the perception of bitterness, sweetness, and umami was identified in the early 1990s by Linguagen’s founder, Robert Margolskee, at Mount Sinai School of Medicine in New York City. Known as gustducin, the protein triggers a cascade of chemical reactions that lead to changes in ion concentrations within the cell. Ultimately, this delivers a signal to the brain that registers as bitter. “The signaling system is like a bucket brigade,” Margolskee says. “It goes from the G protein to other proteins.”

F. In 2000 Zuker and others found some 30 different kinds of genes that code for bitter-taste receptors. “We knew the number would have to be large because there is such a large universe of bitter tastants,” Zuker says. Yet no matter which tastant enters the mouth or which receptor it attaches to, bitter always tastes the same to us. The only variation derives from its intensity and the ways in which it can be flavored by the sense of smell. “Taste cells are like a light switch,” Zuker says. “They are either on or off.”

G. Once they figured put the taste mechanism, scientists began to think of ways to interfere with it. They tried AMP, an organic compound found in breast milk and other substances, which is created as cells break down food. Amp has no bitterness of its own, but when put it in foods, Margolskee and his colleagues discovered, it attaches to bitter-taste receptors. As effective as it is, AMP may not be able to dampen every type pf bitter taste, because it probably doesn’t attach to all 30 bitter-taste receptors. So Linguagen has scaled up the hunt for other bitter blockers with a technology called high-throughput screening. Researchers start by coaxing cells in culture to activate bitter-taste receptors. Then candidate substances, culled from chemical compound libraries, are dropped onto the receptors, and scientists look for evidence of a reaction.

H. Tin time, some taste researchers believe, compounds like AMP will help make processed foods less unhealthy. Consider, for example, that a single cup of Campbell’s chicken noodle soup contains 850 milligrams of sodium chloride, or table salt-more than a third of the recommended daily allowance. The salt masks the bitterness created by the high temperatures used in the canning process, which cause sugars and amino acids to react. Part of the salt could be replaced by another salt, potassium chloride, which tends to be scarce in some people’s diets. Potassium chloride has a bitter aftertaste, but that could be eliminated with a dose of AMP. Bitter blockers could also be used in place of cherry or grape flavoring to take the harshness out of children’s cough syrup, and they could dampen the bitterness of antihistamines, antibiotics, certain HIV drugs, and other medications.

I. A number of foodmakers have already begun to experiment with AMP in their products, and other bitter blockers are being developed by rival firms such as Senomyx in La Jolla, California. In a few years, perhaps, after food companies have taken the bitterness from canned soup and TV dinners, they can set their sights on something more useful: a bitter blocker in a bottle that any of us can sprinkle on our brussels sprouts or stir into our grapefruit juice.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2200474e-9fee-50a3-9718-bbb21319a640', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
The reading Passage has seven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 1-8 on your answer sheet.
1
Experiment on bitterness conducted
2
Look into the future application
3
Bitterness means different information for human and animals
4
Spread process of bitterness inside of body
5
How AMP blocks bitterness
6
Some bitterness blocker may help lower unhealthy impact
7
Bitterness introduced from a fruit
8
Genetic feature determines sensitivity

1 ____ Experiment on bitterness conducted$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b29d4dd-c288-53c1-be6c-5a4372f6c03f', '2200474e-9fee-50a3-9718-bbb21319a640', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a974b8ce-bd72-560f-95b1-ad27cdcb0203', '2200474e-9fee-50a3-9718-bbb21319a640', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a9d4bcd-56a8-5718-9afb-b6282749e99b', '2200474e-9fee-50a3-9718-bbb21319a640', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31dee627-5976-59bd-ae44-bb121fd3dd39', '2200474e-9fee-50a3-9718-bbb21319a640', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f78e46cb-a460-5b9a-80ce-cdb9adc33683', '2200474e-9fee-50a3-9718-bbb21319a640', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87e00123-3078-58cd-a98d-dc9b25edc489', '2200474e-9fee-50a3-9718-bbb21319a640', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('740449e0-657d-57e0-93fe-fe7c74df1bec', '2200474e-9fee-50a3-9718-bbb21319a640', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c9016e1-7e39-5041-9ab1-1be18b13df0b', '2200474e-9fee-50a3-9718-bbb21319a640', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4cb4625-b157-5457-b83d-8683f570be63', '2200474e-9fee-50a3-9718-bbb21319a640', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
The reading Passage has seven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 1-8 on your answer sheet.
1
Experiment on bitterness conducted
2
Look into the future application
3
Bitterness means different information for human and animals
4
Spread process of bitterness inside of body
5
How AMP blocks bitterness
6
Some bitterness blocker may help lower unhealthy impact
7
Bitterness introduced from a fruit
8
Genetic feature determines sensitivity

2 ____ Look into the future application$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edcb53e1-2926-56b9-810c-651f06712f97', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb9d107b-7e92-5f9d-89ff-ee20decc5ac5', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c9703f8-e4ff-5175-839f-0fd7b4d99fec', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff0e29c0-03ee-5c0a-be79-bc6657ab80bb', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12711923-ecce-5333-b75f-df0de86ef0ea', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3eda9a18-0364-5532-bc7c-308a00e91ba4', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13390413-de33-5709-9862-cdff62724a31', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2019467f-637b-5744-ac95-78134c5c1a0e', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2457bb5c-b97f-5d99-83ad-fccb7e6cd168', '4d1ff1a8-5649-5d33-9a53-c88a2f7199c5', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4f9ac9ab-b674-5fe2-992e-ed1522d68daf', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
The reading Passage has seven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 1-8 on your answer sheet.
1
Experiment on bitterness conducted
2
Look into the future application
3
Bitterness means different information for human and animals
4
Spread process of bitterness inside of body
5
How AMP blocks bitterness
6
Some bitterness blocker may help lower unhealthy impact
7
Bitterness introduced from a fruit
8
Genetic feature determines sensitivity

3 ____ Bitterness means different information for human and animals$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c5ec54c-78a4-5b6c-b9d8-97166738cca9', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7eb68862-8544-5560-8d5e-ecb03cedd8ba', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ddc61b9-8280-5e8d-a276-374c48853f88', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d432d771-4caa-526d-9836-7f7e4e9f26bd', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ca90a03-62fc-5360-842f-2bbfe5d85efe', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42f67d80-f4ff-507e-8aff-243f12c6a4a9', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c0714c8-4bb6-5a32-891f-dfc26ae0d1c8', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('649f294b-98ac-5b1f-bd84-da3392c5f620', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('889419cd-d3fe-5e19-938c-4bc4873af3e1', '4f9ac9ab-b674-5fe2-992e-ed1522d68daf', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9390f4ef-70d9-5861-9d41-7c8107fd86d3', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
The reading Passage has seven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 1-8 on your answer sheet.
1
Experiment on bitterness conducted
2
Look into the future application
3
Bitterness means different information for human and animals
4
Spread process of bitterness inside of body
5
How AMP blocks bitterness
6
Some bitterness blocker may help lower unhealthy impact
7
Bitterness introduced from a fruit
8
Genetic feature determines sensitivity

4 ____ Spread process of bitterness inside of body$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b5a330f-4ac0-59ca-b557-291d1adecede', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8921bbd3-e30d-5a6a-92b2-ed400d526d48', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b73918e-12b7-55d6-98a1-bdf1901306aa', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d0924da-c0b2-5f9e-bbc4-f898e6b1cc20', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93b7d0c1-71ad-523a-a2e7-51de283dcc45', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b4cabe7-8d20-5e5a-a515-c620b409b7e7', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acb32476-631a-5f57-b22c-808d4525e4ca', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebe39529-2ac3-56a7-a1f2-05ae233eed8b', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87ad0704-4d66-5a93-8ac5-8cf4bb695f40', '9390f4ef-70d9-5861-9d41-7c8107fd86d3', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec8306e6-14e6-525a-bd20-c75d1c23af52', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
The reading Passage has seven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 1-8 on your answer sheet.
1
Experiment on bitterness conducted
2
Look into the future application
3
Bitterness means different information for human and animals
4
Spread process of bitterness inside of body
5
How AMP blocks bitterness
6
Some bitterness blocker may help lower unhealthy impact
7
Bitterness introduced from a fruit
8
Genetic feature determines sensitivity

5 ____ How AMP blocks bitterness$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0bee1d4-9abf-5af4-ab20-cf7b6f03b0dc', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26b36a4d-ff27-54be-8991-20ecc4977e38', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b41b7611-1899-53bc-b1d3-bb339c63777d', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5b308f8-6479-5a7a-9467-89342a3027c4', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9d95a48-1b15-503b-ba0a-9343c4741178', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ab92209-efd0-5cea-ac2f-dad45d962356', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc45a0e3-dc94-5b05-8a27-01405269337f', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89267e37-3bf0-534e-bfe9-cd086f659023', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ead2215-3fcb-5d69-9d7d-4ed862a9491b', 'ec8306e6-14e6-525a-bd20-c75d1c23af52', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bcf21d70-3464-57d2-b0cd-923c9cd80766', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
The reading Passage has seven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 1-8 on your answer sheet.
1
Experiment on bitterness conducted
2
Look into the future application
3
Bitterness means different information for human and animals
4
Spread process of bitterness inside of body
5
How AMP blocks bitterness
6
Some bitterness blocker may help lower unhealthy impact
7
Bitterness introduced from a fruit
8
Genetic feature determines sensitivity

6 ____ Some bitterness blocker may help lower unhealthy impact$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9409734-0e18-5b71-a33c-c6042dbe3919', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da81862e-8f69-5ebc-957b-aa89e49b7a21', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c3a34dc-68e6-5d5f-9356-51db1eadafa3', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac22c30a-6549-5383-9626-cec187e2afcb', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e00b8d8d-e7aa-5331-a7b3-e74a64486e41', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd73301e-3378-5166-94de-5c28adeab9ad', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bdc9e89-166d-553f-9622-5c9ab92857c5', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0917e9b5-5ff9-58b0-9683-150c0e55b03e', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea50bf4c-412f-5c76-8833-33060d7b393d', 'bcf21d70-3464-57d2-b0cd-923c9cd80766', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7cf93d30-0bd4-58d5-a836-47dc5cbb214c', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
The reading Passage has seven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 1-8 on your answer sheet.
1
Experiment on bitterness conducted
2
Look into the future application
3
Bitterness means different information for human and animals
4
Spread process of bitterness inside of body
5
How AMP blocks bitterness
6
Some bitterness blocker may help lower unhealthy impact
7
Bitterness introduced from a fruit
8
Genetic feature determines sensitivity

7 ____ Bitterness introduced from a fruit$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e909e98-4799-5bc1-8749-59dad7931801', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f28e23f-fa0f-533b-a27b-d5f68b6bade1', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10dfc08e-cae2-563b-a342-88648b1c6345', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8d35ea2-c6d9-50e4-8856-c8b874a2aa1e', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5f0e9af-b146-559f-b447-c461bcc9799a', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b12a6673-abfc-5ef0-820f-26a0df05f0aa', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81a189f6-f03c-5a83-bfbf-e5a23b91e59e', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('695da8fb-221b-5422-b752-facbe529d281', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1083ad9a-5727-5b7b-856b-7c13b2425cc5', '7cf93d30-0bd4-58d5-a836-47dc5cbb214c', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8a141866-a06e-5dee-b411-44db374f5a76', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
The reading Passage has seven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 1-8 on your answer sheet.
1
Experiment on bitterness conducted
2
Look into the future application
3
Bitterness means different information for human and animals
4
Spread process of bitterness inside of body
5
How AMP blocks bitterness
6
Some bitterness blocker may help lower unhealthy impact
7
Bitterness introduced from a fruit
8
Genetic feature determines sensitivity

8 ____ Genetic feature determines sensitivity$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('869fe048-d8e2-5d31-b330-7a2cd92f777b', '8a141866-a06e-5dee-b411-44db374f5a76', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abd0685d-e065-540d-a364-c6575193d530', '8a141866-a06e-5dee-b411-44db374f5a76', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('332da239-b66c-5a85-ae9b-14cbe016bfa5', '8a141866-a06e-5dee-b411-44db374f5a76', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38c6cf02-2d7d-5c51-888c-47940549831b', '8a141866-a06e-5dee-b411-44db374f5a76', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('effcee3d-102c-55d0-83ee-593f803df174', '8a141866-a06e-5dee-b411-44db374f5a76', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('938e9d0f-b539-5a37-8993-8b859d3ad338', '8a141866-a06e-5dee-b411-44db374f5a76', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e34a4c9-98e2-5f33-8df6-dc58ce4bdd3d', '8a141866-a06e-5dee-b411-44db374f5a76', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('932b587b-54e2-54e7-bd3c-fcba4dec0901', '8a141866-a06e-5dee-b411-44db374f5a76', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fc40100-9544-5da9-8aa5-8df0afa7e2ca', '8a141866-a06e-5dee-b411-44db374f5a76', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a1a94b28-646c-5c60-96cc-9ae5eb4cfef0', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Question 9-12
Question 9-12
Summary
Complete the following summary of the paragraphs of Reading Passage, using no more than two words from the Reading Passage for each answer. Write your answers in boxes 9-12 on your answer sheet.
The reason why grapefruit tastes bitter is because a substance called
9
contained in it. However, bitterness plays a significant role for plants. It gives a signal that certain plant is
10
. For human beings, different person carries various genetic abilities of tasting bitterness. According to a scientist at the University of Utah,
11
have exceptionally plenty of
12
, which allows them to perceive bitter compounds.

The reason why grapefruit tastes bitter is because a substance called 9 ____ contained in it. However, bitterness plays a significant role for plants. It gives a signal that certain plant is 10 ____ . For human beings, different person carries various genetic abilities of tasting bitterness. According to a scientist at the University of Utah, 11 ____ have exceptionally plenty of 12 ____ , which allows them to perceive bitter compounds.$md$, NULL, ARRAY['.*naringin.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e856de8b-b204-5a1e-9b0f-02c5ae28adb9', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Question 9-12
Question 9-12
Summary
Complete the following summary of the paragraphs of Reading Passage, using no more than two words from the Reading Passage for each answer. Write your answers in boxes 9-12 on your answer sheet.
The reason why grapefruit tastes bitter is because a substance called
9
contained in it. However, bitterness plays a significant role for plants. It gives a signal that certain plant is
10
. For human beings, different person carries various genetic abilities of tasting bitterness. According to a scientist at the University of Utah,
11
have exceptionally plenty of
12
, which allows them to perceive bitter compounds.

The reason why grapefruit tastes bitter is because a substance called 9 ____ contained in it. However, bitterness plays a significant role for plants. It gives a signal that certain plant is 10 ____ . For human beings, different person carries various genetic abilities of tasting bitterness. According to a scientist at the University of Utah, 11 ____ have exceptionally plenty of 12 ____ , which allows them to perceive bitter compounds.$md$, NULL, ARRAY['.*naringin.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('855e5dfe-5014-5f13-8726-1c1a0fe1f1ff', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Question 9-12
Question 9-12
Summary
Complete the following summary of the paragraphs of Reading Passage, using no more than two words from the Reading Passage for each answer. Write your answers in boxes 9-12 on your answer sheet.
The reason why grapefruit tastes bitter is because a substance called
9
contained in it. However, bitterness plays a significant role for plants. It gives a signal that certain plant is
10
. For human beings, different person carries various genetic abilities of tasting bitterness. According to a scientist at the University of Utah,
11
have exceptionally plenty of
12
, which allows them to perceive bitter compounds.

The reason why grapefruit tastes bitter is because a substance called 9 ____ contained in it. However, bitterness plays a significant role for plants. It gives a signal that certain plant is 10 ____ . For human beings, different person carries various genetic abilities of tasting bitterness. According to a scientist at the University of Utah, 11 ____ have exceptionally plenty of 12 ____ , which allows them to perceive bitter compounds.$md$, NULL, ARRAY['.*naringin.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6b17ffc6-ff65-58bc-9ac3-0e2a271f7f0e', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Question 9-12
Question 9-12
Summary
Complete the following summary of the paragraphs of Reading Passage, using no more than two words from the Reading Passage for each answer. Write your answers in boxes 9-12 on your answer sheet.
The reason why grapefruit tastes bitter is because a substance called
9
contained in it. However, bitterness plays a significant role for plants. It gives a signal that certain plant is
10
. For human beings, different person carries various genetic abilities of tasting bitterness. According to a scientist at the University of Utah,
11
have exceptionally plenty of
12
, which allows them to perceive bitter compounds.

The reason why grapefruit tastes bitter is because a substance called 9 ____ contained in it. However, bitterness plays a significant role for plants. It gives a signal that certain plant is 10 ____ . For human beings, different person carries various genetic abilities of tasting bitterness. According to a scientist at the University of Utah, 11 ____ have exceptionally plenty of 12 ____ , which allows them to perceive bitter compounds.$md$, NULL, ARRAY['.*naringin.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3c6436a9-2697-5f07-9a7b-036d9b89c74e', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13-14
Questions 13-14
Choose the correct letter, A, B, C or D.
Write your answers in boxes 13-14 on your answer sheet.
13 What is the main feature of AMP according to this passage?
A
offset bitter flavour in food
B
only exist in 304 cup
C
tastes like citrus
D
chemical reaction when meets biscuit
14 What is the main function of G protein?
A
collecting taste molecule
B
identifying different flavors elements
C
resolving large molecules
D
transmitting bitter signals to the brain

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('709b5c74-e77e-548a-8b82-56eba74afe06', '0e1cc4fa-71b7-507d-83fe-fe83d0389325', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 13-14
Questions 13-14
Choose the correct letter, A, B, C or D.
Write your answers in boxes 13-14 on your answer sheet.
13 What is the main feature of AMP according to this passage?
A
offset bitter flavour in food
B
only exist in 304 cup
C
tastes like citrus
D
chemical reaction when meets biscuit
14 What is the main function of G protein?
A
collecting taste molecule
B
identifying different flavors elements
C
resolving large molecules
D
transmitting bitter signals to the brain

Choose the correct letter, A, B, C or D.$md$, NULL);

COMMIT;

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-columbian-exchange-1096'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-columbian-exchange-1096';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-columbian-exchange-1096';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-columbian-exchange-1096';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9d9c6e93-c909-58e6-b4b4-2b9e13cd7cee', 'ielts-reading-the-columbian-exchange-1096', $t$The Columbian Exchange$t$, $md$## The Columbian Exchange

Nguồn:
- Test: https://mini-ielts.com/1096/reading/the-columbian-exchange
- Solution: https://mini-ielts.com/1096/view-solution/reading/the-columbian-exchange$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cca06798-2702-51dd-98a1-5f0a5b468c00', '9d9c6e93-c909-58e6-b4b4-2b9e13cd7cee', 1, $t$Reading — The Columbian Exchange$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Columbian Exchange

A Millions of years ago, continental drift carried the Old World and New World apart, splitting North and South America from Eurasia and Africa . That sep­aration lasted so long that it fostered divergent evolution; for instance, the development of rattlesnakes on one side of the Atlantic and of vipers on the other. After 1492, human voyagers in part reversed this tendency. Their ar­tificial re-establishment of connections through the commingling of Old and New World plants, animals, and bacteria, commonly known as the Columbian Exchange, is one of the more spectacular and significant ecological events of the past millennium.

B When Europeans first touched the shores of the Americas, Old World crops such as wheat, barley, rice, and turnips had not travelled west across the Atlantic, and New World crops such as maize, white potatoes, sweet potatoes, and manioc had not travelled east to Europe. In the Americas, there were no horses, cattle, sheep, or goats, all animals of Old World origin . Except for the llama, alpaca, dog, a few fowl, and guinea pig, the New World had no equivalents to the domesticated animals associated with the Old World, nor did it have the pathogens associated with the Old World’s dense populations of humans and such associated creatures as chickens, cattle, black rats, and Aedes aegypti mosquitoes. Among these germs were those that carried smallpox, measles, chickenpox, influenza, malaria, and yellow fever.

C As might be expected, the Europeans who settled on the east coast of the United States cultivated crops like wheat and apples, which they had brought with them. European weeds, which the colonists did not cultivate, and, in fact, preferred to uproot, also fared well in the New World. John Josselyn, an Englishman and amateur naturalist who visited New England twice in the seventeenth century, left us a list, “Of Such Plants as Have Sprung Up since the English Planted and Kept Cattle in New England,” which included couch grass, dandelion, shepherd’s purse, groundsel, sow thistle, and chickweed.

One of these, a plantain (Plantago major), was named “Englishman’s Foot” by the Amerindians of New England and Virginia who believed that it would grow only where the English “have trodden, and was never known before the English came into this country”. Thus, as they intentionally sowed Old World crop seeds, the European settlers were unintentionally contaminating American fields with weed seeds. More importantly, they were stripping and burning forests, exposing the native minor flora to direct sunlight, and the hooves and teeth of Old World livestock. The native flora could not tolerate the stress. The imported weeds could, because they had lived with large numbers of graz­ing animals for thousands of years.

D Cattle and horses were brought ashore in the early 1600s and found hos­pitable climate and terrain in North America . Horses arrived in Virginia as early as 1620 and in Massachusetts in 1629. Many wandered free with little more evidence of their connection to humanity than collars with a hook at the bottom to catch on fences as they tried to leap over them to get at crops. Fences were not for keeping livestock in, but for keeping livestock out .

E Native American resistance to the Europeans was ineffective. Indigenous peoples suffered from white brutality, alcoholism, the killing and driving off of game , and the expropriation of farmland, but all these together are insufficient to explain the degree of their defeat. The crucial factor was not people, plants, or animals, but germs. Smallpox was the worst and the most spectacular of the infectious diseases mowing down the Native Americans . The first recorded pandemic of that disease in British North America detonated among the Al­gonquin of Massachusetts in the early 1630s. William Bradford of Plymouth Plantation wrote that the victims “fell down so generally of this disease as they were in the end not able to help one another, no, not to make a fire nor fetch a little water to drink, nor any to bury the dead”. The missionaries and the traders who ventured into the American interior told the same appalling story about smallpox and the indigenes. In 1738 alone, the epidemic destroyed half the Cherokee; in 1759 nearly half the Catawbas; in the first years of the next century, two thirds of the Omahas and perhaps half the entire population between the Missouri River and New Mexico; in 1837-38 nearly every last one of the Mandans and perhaps half the people of the high plains.

F The export of America’s native animals has not revolutionised Old World agri­culture or ecosystems as the introduction of European animals to the New World did . America’s grey squirrels and muskrats and a few others have established themselves east of the Atlantic and west of the Pacific, but that has not made much of a difference. Some of America’s domesticated animals are raised in the Old World, but turkeys have not displaced chickens and geese , and guinea pigs have proved useful in laboratories, but have not usurped rabbits in the butcher shops.

G The New World’s great contribution to the Old is in crop plants. Maize, white potatoes, sweet potatoes, various squashes, chiles, and manioc have become essentials in the diets of hundreds of millions of Europeans, Africans, and Asians. Their influence on Old World peoples, like that of wheat and rice on New World peoples, goes far to explain the global population explosion of the past three centuries . The Columbian Exchange has been an indispensable fac­tor in that demographic explosion.

H All this had nothing to do with superiority or inferiority of biosystems in any absolute sense. It has to do with environmental contrasts. Amerindians were accustomed to living in one particular kind of environment, Europeans and Africans in another. When the Old World peoples came to America, they brought with them all their plants, animals, and germs, creating a kind of environment to which they were already adapted, and so they increased in number . Amerindians had not adapted to European germs, and so initially their numbers plunged. That decline has reversed in our time as Amerindian populations have adapted to the Old World’s environmental influence, but the demographic triumph of the invaders, which was the most spectacular feature of the Old World’s invasion of the New, still stands.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5630503d-a341-5f2b-8ad1-329e3b67555b', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-8
on your answer sheet.
1
A description of an imported species that is named after the English colonists
Locate
2
The reason why both the New World and Old World experienced population growth
Locate
3
The formation of new continents explained
Locate
4
The reason why the indigenous population declined
Locate
5
An overall description of the species lacked in the Old World and New World
Locate
6
A description of some animal species being ineffective in affecting the Old World
Locate
7
An overall explanation of the success of the Old World species invasion
Locate
8
An account of European animals taking roots in the New World
Locate

1 ____ A description of an imported species that is named after the English colonists Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45a0e10e-c849-5ceb-a121-4bd1cca44333', '5630503d-a341-5f2b-8ad1-329e3b67555b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0fdb499-366f-5b35-b33f-4092a578b622', '5630503d-a341-5f2b-8ad1-329e3b67555b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf4be20d-3167-59b4-b860-c3da55628582', '5630503d-a341-5f2b-8ad1-329e3b67555b', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2441335-f4e7-53c5-b1cc-1027eb88b98a', '5630503d-a341-5f2b-8ad1-329e3b67555b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e888332-6809-5a5f-8429-80351b1d434f', '5630503d-a341-5f2b-8ad1-329e3b67555b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c409ab7b-dbcf-58a6-9c12-5db7ffd76919', '5630503d-a341-5f2b-8ad1-329e3b67555b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c2c98f5-907d-5261-86dc-14d8a206136c', '5630503d-a341-5f2b-8ad1-329e3b67555b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d7997b7-aa1f-5edf-ab1d-a705d29cf01a', '5630503d-a341-5f2b-8ad1-329e3b67555b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('99111dce-442d-501e-970d-ea1b64065eae', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-8
on your answer sheet.
1
A description of an imported species that is named after the English colonists
Locate
2
The reason why both the New World and Old World experienced population growth
Locate
3
The formation of new continents explained
Locate
4
The reason why the indigenous population declined
Locate
5
An overall description of the species lacked in the Old World and New World
Locate
6
A description of some animal species being ineffective in affecting the Old World
Locate
7
An overall explanation of the success of the Old World species invasion
Locate
8
An account of European animals taking roots in the New World
Locate

2 ____ The reason why both the New World and Old World experienced population growth Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a8c8a4e-f810-59c4-8ffb-43beb0c76a09', '99111dce-442d-501e-970d-ea1b64065eae', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35fb2cc8-7aa3-5b14-89e2-81d8068f095f', '99111dce-442d-501e-970d-ea1b64065eae', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aca8de3-5f8e-5d08-8d01-db13d28d7b4f', '99111dce-442d-501e-970d-ea1b64065eae', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a251e7df-277d-5d18-9a81-15d59cd1bf95', '99111dce-442d-501e-970d-ea1b64065eae', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5884f29c-2274-51e6-b20c-ff7444304a3f', '99111dce-442d-501e-970d-ea1b64065eae', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2d1055c-d97c-5bf6-b881-35bc04461d1c', '99111dce-442d-501e-970d-ea1b64065eae', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5c84a9d-034b-56c3-805a-d42f7b5fbbd3', '99111dce-442d-501e-970d-ea1b64065eae', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc3ad6bb-2d43-57fe-8a42-75d7f1ec299b', '99111dce-442d-501e-970d-ea1b64065eae', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-8
on your answer sheet.
1
A description of an imported species that is named after the English colonists
Locate
2
The reason why both the New World and Old World experienced population growth
Locate
3
The formation of new continents explained
Locate
4
The reason why the indigenous population declined
Locate
5
An overall description of the species lacked in the Old World and New World
Locate
6
A description of some animal species being ineffective in affecting the Old World
Locate
7
An overall explanation of the success of the Old World species invasion
Locate
8
An account of European animals taking roots in the New World
Locate

3 ____ The formation of new continents explained Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f890ca2-caa4-5d46-a4cb-1a4474286333', '36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08a65607-3ae9-527c-8ac4-0c8e07d451d2', '36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00a28553-9336-5cbd-b423-e5d9905107c3', '36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed6b9a96-3c3d-5c07-9a57-102691234186', '36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d99ceef-92f1-5115-969c-95a58c3b6ef0', '36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cdf5c9b-7bf3-573e-af26-a3d55f9a11c0', '36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69634722-5a7b-5fa2-97dc-c9d8bb78d9f0', '36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c39ec87a-ea69-52e4-881f-855f39899224', '36775c0a-f88b-5fa9-9dd7-50c6b79ea86f', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ebb29631-b56c-5482-8a13-e054b7aa8e2d', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-8
on your answer sheet.
1
A description of an imported species that is named after the English colonists
Locate
2
The reason why both the New World and Old World experienced population growth
Locate
3
The formation of new continents explained
Locate
4
The reason why the indigenous population declined
Locate
5
An overall description of the species lacked in the Old World and New World
Locate
6
A description of some animal species being ineffective in affecting the Old World
Locate
7
An overall explanation of the success of the Old World species invasion
Locate
8
An account of European animals taking roots in the New World
Locate

4 ____ The reason why the indigenous population declined Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfb0a7a3-737d-5258-b3b1-a24a960474ca', 'ebb29631-b56c-5482-8a13-e054b7aa8e2d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ebd8807-2483-5b87-b9b7-35e38e9295a1', 'ebb29631-b56c-5482-8a13-e054b7aa8e2d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fad7b69-0c4a-5012-a1a4-0276b00f877d', 'ebb29631-b56c-5482-8a13-e054b7aa8e2d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c0ddfa2-7198-5060-868d-94d54a572c92', 'ebb29631-b56c-5482-8a13-e054b7aa8e2d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8660397b-9e3d-5d54-88ac-a348d91e227b', 'ebb29631-b56c-5482-8a13-e054b7aa8e2d', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a235aeb-07c9-5d9a-8cdc-46f73990b4b7', 'ebb29631-b56c-5482-8a13-e054b7aa8e2d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87b24815-1da5-5d1f-8a00-0f04fed14027', 'ebb29631-b56c-5482-8a13-e054b7aa8e2d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67c96106-1253-5e0a-a492-2c890553a2e5', 'ebb29631-b56c-5482-8a13-e054b7aa8e2d', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('834e754e-a9ad-5810-af4e-ade6e81797d6', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-8
on your answer sheet.
1
A description of an imported species that is named after the English colonists
Locate
2
The reason why both the New World and Old World experienced population growth
Locate
3
The formation of new continents explained
Locate
4
The reason why the indigenous population declined
Locate
5
An overall description of the species lacked in the Old World and New World
Locate
6
A description of some animal species being ineffective in affecting the Old World
Locate
7
An overall explanation of the success of the Old World species invasion
Locate
8
An account of European animals taking roots in the New World
Locate

5 ____ An overall description of the species lacked in the Old World and New World Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ca93530-6794-5677-9c8d-06aee8b923e1', '834e754e-a9ad-5810-af4e-ade6e81797d6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05e122df-ec5d-5870-8790-9f1b8401666d', '834e754e-a9ad-5810-af4e-ade6e81797d6', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de3cf012-6f81-5bad-a62d-9c4599e9f38d', '834e754e-a9ad-5810-af4e-ade6e81797d6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5a38aa3-4bc2-5bc3-aa7a-115df97013fa', '834e754e-a9ad-5810-af4e-ade6e81797d6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8fd491a-4431-50de-b754-7e79e944c737', '834e754e-a9ad-5810-af4e-ade6e81797d6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5ee1f7f-601a-5c3f-b04e-3b03a24035c8', '834e754e-a9ad-5810-af4e-ade6e81797d6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08302c17-3134-5b97-a705-1943f061e2c2', '834e754e-a9ad-5810-af4e-ade6e81797d6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61cb84ff-b7f7-58fe-9582-2cf69e50f316', '834e754e-a9ad-5810-af4e-ade6e81797d6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-8
on your answer sheet.
1
A description of an imported species that is named after the English colonists
Locate
2
The reason why both the New World and Old World experienced population growth
Locate
3
The formation of new continents explained
Locate
4
The reason why the indigenous population declined
Locate
5
An overall description of the species lacked in the Old World and New World
Locate
6
A description of some animal species being ineffective in affecting the Old World
Locate
7
An overall explanation of the success of the Old World species invasion
Locate
8
An account of European animals taking roots in the New World
Locate

6 ____ A description of some animal species being ineffective in affecting the Old World Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b4eefc5-603a-51a9-87e0-5a9aa18a53db', 'e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f6878fe-e502-5d1d-a44e-18483a1ae24e', 'e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f263de7-5a4e-5502-a720-a03c008b3cd3', 'e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06b4c1c6-33fe-5b8f-8f60-5a4ad54a428f', 'e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('888a3b7a-3163-5ba4-be4d-14927ab295f8', 'e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51eda50a-e86a-567f-ac2c-df1b588883a3', 'e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ded30cb0-9a74-5e53-b08b-f797cbe8e21d', 'e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da6b0947-f525-5abc-bf76-918e2ae7eccf', 'e6032fa3-37ca-5df2-95fd-3c55bf1e405f', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f04f764-c932-56fb-b8bb-72a1db9c3c80', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-8
on your answer sheet.
1
A description of an imported species that is named after the English colonists
Locate
2
The reason why both the New World and Old World experienced population growth
Locate
3
The formation of new continents explained
Locate
4
The reason why the indigenous population declined
Locate
5
An overall description of the species lacked in the Old World and New World
Locate
6
A description of some animal species being ineffective in affecting the Old World
Locate
7
An overall explanation of the success of the Old World species invasion
Locate
8
An account of European animals taking roots in the New World
Locate

7 ____ An overall explanation of the success of the Old World species invasion Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e500e4a-1e97-5e94-b339-af951fdb10bc', '1f04f764-c932-56fb-b8bb-72a1db9c3c80', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2370bb24-9635-5920-a236-25f25b5e05b1', '1f04f764-c932-56fb-b8bb-72a1db9c3c80', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9f8a7fd-640c-5f6c-a193-81c15c6f17aa', '1f04f764-c932-56fb-b8bb-72a1db9c3c80', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e865c329-0d46-5a7a-a29d-4ce48d03a40c', '1f04f764-c932-56fb-b8bb-72a1db9c3c80', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16879924-0574-52d4-9c9e-ded3b93f30ed', '1f04f764-c932-56fb-b8bb-72a1db9c3c80', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0efa7e52-7ed4-5032-a262-388c240458bc', '1f04f764-c932-56fb-b8bb-72a1db9c3c80', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f96d4e6-6759-5df9-a691-ac2ccf20e077', '1f04f764-c932-56fb-b8bb-72a1db9c3c80', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53dbc305-51c2-5af0-a9f0-8fed61430f71', '1f04f764-c932-56fb-b8bb-72a1db9c3c80', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec8136db-0abb-51de-b47d-ebd61afe42d6', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-8
on your answer sheet.
1
A description of an imported species that is named after the English colonists
Locate
2
The reason why both the New World and Old World experienced population growth
Locate
3
The formation of new continents explained
Locate
4
The reason why the indigenous population declined
Locate
5
An overall description of the species lacked in the Old World and New World
Locate
6
A description of some animal species being ineffective in affecting the Old World
Locate
7
An overall explanation of the success of the Old World species invasion
Locate
8
An account of European animals taking roots in the New World
Locate

8 ____ An account of European animals taking roots in the New World Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c39ed356-97f2-5d5b-8496-76203d62dcd9', 'ec8136db-0abb-51de-b47d-ebd61afe42d6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74aefc34-3e7a-5f56-934c-cd707219b8d5', 'ec8136db-0abb-51de-b47d-ebd61afe42d6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56a9a592-6333-59f3-980b-36430d0ee712', 'ec8136db-0abb-51de-b47d-ebd61afe42d6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b56a5bc9-226a-50bf-ad38-258b878a464d', 'ec8136db-0abb-51de-b47d-ebd61afe42d6', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6196cb4-b85f-5336-9b2c-788efcaa23c5', 'ec8136db-0abb-51de-b47d-ebd61afe42d6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('991af2b1-6111-5afc-ab96-4826c93db56d', 'ec8136db-0abb-51de-b47d-ebd61afe42d6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('144dfc24-0b76-5aa8-8db1-7da4e0624fec', 'ec8136db-0abb-51de-b47d-ebd61afe42d6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1aa0ebad-692e-50cb-8943-c3dd41554a23', 'ec8136db-0abb-51de-b47d-ebd61afe42d6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8c2e9218-971a-5328-adbb-a01bb4bac3e0', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-12
Questions 9-12
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
9-12
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
European settlers built fences to keep their cattle and horses inside.
Locate
10
The indigenous people had been brutally killed by the European colonists.
Locate
11
America's domesticated animals, such as turkey, became popular in the Old World.
Locate
12
Crop exchange between the two worlds played a major role in world p

9 ____ European settlers built fences to keep their cattle and horses inside. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f938b0e-8e2f-5cc6-871d-7872a75523fb', '8c2e9218-971a-5328-adbb-a01bb4bac3e0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('896bfedc-003c-50f0-804f-28e62b7abc90', '8c2e9218-971a-5328-adbb-a01bb4bac3e0', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19244640-31da-5225-b75c-bcc0b8bef442', '8c2e9218-971a-5328-adbb-a01bb4bac3e0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d614f9a-445e-5b09-8c3f-6bec8f23d578', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-12
Questions 9-12
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
9-12
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
European settlers built fences to keep their cattle and horses inside.
Locate
10
The indigenous people had been brutally killed by the European colonists.
Locate
11
America's domesticated animals, such as turkey, became popular in the Old World.
Locate
12
Crop exchange between the two worlds played a major role in world p

10 ____ The indigenous people had been brutally killed by the European colonists. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51d9808c-b2d4-5c76-8b8f-da6a253efbfb', '1d614f9a-445e-5b09-8c3f-6bec8f23d578', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62a1edc2-af9f-5dc2-85be-047ec779bf16', '1d614f9a-445e-5b09-8c3f-6bec8f23d578', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfb5296e-36cc-53b2-a9a3-9ac76a52e24d', '1d614f9a-445e-5b09-8c3f-6bec8f23d578', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4dda9447-9724-5c21-9d71-9444b80607e6', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-12
Questions 9-12
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
9-12
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
European settlers built fences to keep their cattle and horses inside.
Locate
10
The indigenous people had been brutally killed by the European colonists.
Locate
11
America's domesticated animals, such as turkey, became popular in the Old World.
Locate
12
Crop exchange between the two worlds played a major role in world p

11 ____ America's domesticated animals, such as turkey, became popular in the Old World. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61d91360-b414-5e52-8438-3b24526a7df9', '4dda9447-9724-5c21-9d71-9444b80607e6', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac2eaa98-37b6-5b39-a196-c35215103018', '4dda9447-9724-5c21-9d71-9444b80607e6', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e463b52-75ab-5df3-b963-bc3f49b71331', '4dda9447-9724-5c21-9d71-9444b80607e6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('07556de3-2dc5-5f9f-aace-d4de8cf2bec1', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-12
Questions 9-12
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
9-12
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
European settlers built fences to keep their cattle and horses inside.
Locate
10
The indigenous people had been brutally killed by the European colonists.
Locate
11
America's domesticated animals, such as turkey, became popular in the Old World.
Locate
12
Crop exchange between the two worlds played a major role in world p

12 ____ Crop exchange between the two worlds played a major role in world p$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65093a4c-5294-59ef-8955-0e5e3d91530e', '07556de3-2dc5-5f9f-aace-d4de8cf2bec1', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be23c87c-f2e7-588a-af6b-71d3d4ffc062', '07556de3-2dc5-5f9f-aace-d4de8cf2bec1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec1b6a2e-6c0c-520a-959d-19e1fc6ead9f', '07556de3-2dc5-5f9f-aace-d4de8cf2bec1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a2febf0d-b2e1-5f6a-98a7-f3cd0a5abd77', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 13-14
Questions 13-14
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
13
. Who reported the same story of European diseases among the indigenes from the American interior?
Locate
14
. What is the still existing feature of the Old World's invasion of the New?
Locate

13 . Who reported the same story of European diseases among the indigenes from the American interior? ____ Locate$md$, NULL, ARRAY['.*missionaries.*and.*traders.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('be1d2475-7e09-53d8-9850-6797effb6ff9', 'cca06798-2702-51dd-98a1-5f0a5b468c00', 14, 'SHORT_ANSWER', 'READING', 4, $md$### Question 14

Questions 13-14
Questions 13-14
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
13
. Who reported the same story of European diseases among the indigenes from the American interior?
Locate
14
. What is the still existing feature of the Old World's invasion of the New?
Locate

14 . What is the still existing feature of the Old World's invasion of the New? ____ Locate$md$, NULL, ARRAY['.*demographic.*triumph.*']);

COMMIT;

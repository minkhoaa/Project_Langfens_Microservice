BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-bring-back-the-big-cats-1147'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bring-back-the-big-cats-1147';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bring-back-the-big-cats-1147';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-bring-back-the-big-cats-1147';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fd7cca84-b3aa-5f37-a487-b45d21187576', 'ielts-reading-bring-back-the-big-cats-1147', $t$Bring back the big cats$t$, $md$## Bring back the big cats

Nguồn:
- Test: https://mini-ielts.com/1147/reading/bring-back-the-big-cats
- Solution: https://mini-ielts.com/1147/view-solution/reading/bring-back-the-big-cats$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('05cadf11-d415-5b0b-834e-192e03f977d9', 'fd7cca84-b3aa-5f37-a487-b45d21187576', 1, $t$Reading — Bring back the big cats$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Bring back the big cats

It's time to start returning vanished native animals to Britain, says John Vesty There is a poem, written around 598 AD, which describes hunting a mystery animal called a llewyn. But what was it? Nothing seemed to fit, until 2006, when an animal bone, dating from around the same period, was found in the Kinsey Cave in northern England. Until this discovery, the lynx - a large spotted cat with tassel led ears - was presumed to have died out in Britain at least 6,000 years ago , before the inhabitants of these islands took up farming. But the 2006 find, together with three others in Yorkshire and Scotland, is compelling evidence that the lynx and the mysterious llewyn were in fact one and the same animal. If this is so, it would bring forward the tassel-eared cat's estimated extinction date by roughly 5,000 years.

However, this is not quite the last glimpse of the animal in British culture. A 9th- century stone cross from the Isle of Eigg shows, alongside the deer, boar and aurochs pursued by a mounted hunter, a speckled cat with tasselled ears. Were it not for the animal's backside having worn away with time, we could have been certain, as the lynx's stubby tail is unmistakable. But even without this key feature, it's hard to see what else the creature could have been. The lynx is now becoming the totemic animal of a movement that is transforming British environmentalism: rewilding.

Rewilding means the mass restoration of damaged ecosystems. It involves letting trees return to places that have been denuded, allowing parts of the seabed to recover from trawling and dredging, permitting rivers to flow freely again. Above all, it means bringing back missing species. One of the most striking findings of modern ecology is that ecosystems without large predators behave in completely different ways from those that retain them Some of them drive dynamic processes that resonate through the whole food chain, creating niches for hundreds of species that might otherwise struggle to survive. The killers turn out to be bringers of life.

Such findings present a big challenge to British conservation, which has often selected arbitrary assemblages of plants and animals and sought , at great effort and expense, to prevent them from changing. It has tried to preserve the living world as if it were a jar of pickles, letting nothing in and nothing out, keeping nature in a state of arrested development. But ecosystems are not merely collections of species; they are also the dynamic and ever-shifting relationships between them. And this dynamism often depends on large predators.

At sea the potential is even greater: by protecting large areas from commercial fishing, we could once more see what 18th-century literature describes: vast shoals of fish being chased by fin and sperm whales, within sight of the English shore. This policy would also greatly boost catches in the surrounding seas ; the fishing industry's insistence on scouring every inch of seabed, leaving no breeding reserves, could not be more damaging to its own interests.

Rewilding is a rare example of an environmental movement in which campaigners articulate what they are for rather than only what they are against. One of the reasons why the enthusiasm for rewilding is spreading so quickly in Britain is that it helps to create a more inspiring vision than the green movement's usual promise of 'Follow us and the world will be slightly less awful than it would otherwise have been .

The lynx presents no threat to human beings: there is no known instance of one preying on people . It is a specialist predator of roe deer, a species that has exploded in Britain in recent decades, holding back, by intensive browsing, attempts to re-establish forests. It will also winkle out sika deer: an exotic species that is almost impossible for human beings to control, as it hides in impenetrable plantations of young trees. The attempt to reintroduce this predator marries well with the aim of bringing forests back to parts of our bare and barren uplands. The lynx requires deep cover, and as such presents little risk to sheep and other livestock, which are supposed, as a condition of farm subsidies, to be kept out of the woods.

On a recent trip to the Cairngorm Mountains, I heard several conservationists suggest that the lynx could be reintroduced there within 20 years. If trees return to the bare hills elsewhere in Britain, the big cats could soon follow. There is nothing extraordinary about these proposals, seen from the perspective of anywhere else in Europe. The lynx has now been reintroduced to the Mountains, the Alps, the in eastern France and the mountains in Germany, and has re-established itself in many more places. The European population has tripled since 1970 to roughly 10,000. As with wolves, bears, beavers, boar, bison, moose and many other species, the lynx has been able to spread as farming has,left the hills and people discover that it is more lucrative to protect charismatic wildlife than to hunt it, as tourists will pay for the chance to see it . Large-scale rewilding is happening almost everywhere - except Britain.

Here, attitudes are just beginning to change. Conservationists are starting to accept that the old preservation-jar model is failing, even on its own terms. Already, projects such as Trees for Life in the Highlands provide a hint of what might be coming. An organisation is being set up that will seek to catalyse the rewilding of land and sea across Britain, its aim being to reintroduce that rarest of species to British ecosystems: hope.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('adc933eb-380f-5e9f-8e77-630eb04d4ba8', '05cadf11-d415-5b0b-834e-192e03f977d9', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
1
What did the 2006 discovery of the animal bone reveal about the lynx?
A
Its physical appearance was very distinctive.
B
Its extinction was linked to the spread of farming.
C
It vanished from Britain several thousand years ago.
D
It survived in Britain longer than was previously thought.
Locate
2
What point does the writer make about large predators in the third paragraph?
A
Their presence can increase biodiversity.
B
They may cause damage to local ecosystems.
C
Their behaviour can alter according to the environment.
D
They should be reintroduced only to areas where they were native.
Locate
3
What does the writer suggest about British conservation in the fourth paragraph?
A
It has failed to achieve its aims.
B
It is beginning to change direction.
C
it has taken a misguided approach.
D
It has focused on the most widespread species.
Locate
4
Protecting large areas of the sea from commercial fishing would result in
A
practical benefits for the fishing industry.
B
some short-term losses to the fishing industry.
C
widespread opposition from the fishing industry.
D
certain changes to techniques within the fishing industry.
Locate
5
According to the author, what distinguishes rewilding from other environmental campaigns?
A
Its objective is more achievable.
B
Its supporters are more articulate.
C
Its positive message is more appealing.
D
It is based on sounder scientific principles.
Locate

Write the correct letter, A, B, C or D , in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('91aac292-d0b2-597e-8943-77c6bed6c23f', '05cadf11-d415-5b0b-834e-192e03f977d9', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
1
What did the 2006 discovery of the animal bone reveal about the lynx?
A
Its physical appearance was very distinctive.
B
Its extinction was linked to the spread of farming.
C
It vanished from Britain several thousand years ago.
D
It survived in Britain longer than was previously thought.
Locate
2
What point does the writer make about large predators in the third paragraph?
A
Their presence can increase biodiversity.
B
They may cause damage to local ecosystems.
C
Their behaviour can alter according to the environment.
D
They should be reintroduced only to areas where they were native.
Locate
3
What does the writer suggest about British conservation in the fourth paragraph?
A
It has failed to achieve its aims.
B
It is beginning to change direction.
C
it has taken a misguided approach.
D
It has focused on the most widespread species.
Locate
4
Protecting large areas of the sea from commercial fishing would result in
A
practical benefits for the fishing industry.
B
some short-term losses to the fishing industry.
C
widespread opposition from the fishing industry.
D
certain changes to techniques within the fishing industry.
Locate
5
According to the author, what distinguishes rewilding from other environmental campaigns?
A
Its objective is more achievable.
B
Its supporters are more articulate.
C
Its positive message is more appealing.
D
It is based on sounder scientific principles.
Locate

Write the correct letter, A, B, C or D , in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3170dfe1-8012-528d-83a6-7bf2a1b8c215', '05cadf11-d415-5b0b-834e-192e03f977d9', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
1
What did the 2006 discovery of the animal bone reveal about the lynx?
A
Its physical appearance was very distinctive.
B
Its extinction was linked to the spread of farming.
C
It vanished from Britain several thousand years ago.
D
It survived in Britain longer than was previously thought.
Locate
2
What point does the writer make about large predators in the third paragraph?
A
Their presence can increase biodiversity.
B
They may cause damage to local ecosystems.
C
Their behaviour can alter according to the environment.
D
They should be reintroduced only to areas where they were native.
Locate
3
What does the writer suggest about British conservation in the fourth paragraph?
A
It has failed to achieve its aims.
B
It is beginning to change direction.
C
it has taken a misguided approach.
D
It has focused on the most widespread species.
Locate
4
Protecting large areas of the sea from commercial fishing would result in
A
practical benefits for the fishing industry.
B
some short-term losses to the fishing industry.
C
widespread opposition from the fishing industry.
D
certain changes to techniques within the fishing industry.
Locate
5
According to the author, what distinguishes rewilding from other environmental campaigns?
A
Its objective is more achievable.
B
Its supporters are more articulate.
C
Its positive message is more appealing.
D
It is based on sounder scientific principles.
Locate

Write the correct letter, A, B, C or D , in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('69894741-3ee2-503d-84aa-a22c674a9be8', '05cadf11-d415-5b0b-834e-192e03f977d9', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
1
What did the 2006 discovery of the animal bone reveal about the lynx?
A
Its physical appearance was very distinctive.
B
Its extinction was linked to the spread of farming.
C
It vanished from Britain several thousand years ago.
D
It survived in Britain longer than was previously thought.
Locate
2
What point does the writer make about large predators in the third paragraph?
A
Their presence can increase biodiversity.
B
They may cause damage to local ecosystems.
C
Their behaviour can alter according to the environment.
D
They should be reintroduced only to areas where they were native.
Locate
3
What does the writer suggest about British conservation in the fourth paragraph?
A
It has failed to achieve its aims.
B
It is beginning to change direction.
C
it has taken a misguided approach.
D
It has focused on the most widespread species.
Locate
4
Protecting large areas of the sea from commercial fishing would result in
A
practical benefits for the fishing industry.
B
some short-term losses to the fishing industry.
C
widespread opposition from the fishing industry.
D
certain changes to techniques within the fishing industry.
Locate
5
According to the author, what distinguishes rewilding from other environmental campaigns?
A
Its objective is more achievable.
B
Its supporters are more articulate.
C
Its positive message is more appealing.
D
It is based on sounder scientific principles.
Locate

Write the correct letter, A, B, C or D , in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('023699af-bd8a-5bdd-ac30-6a4fd9524a1c', '05cadf11-d415-5b0b-834e-192e03f977d9', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
1
What did the 2006 discovery of the animal bone reveal about the lynx?
A
Its physical appearance was very distinctive.
B
Its extinction was linked to the spread of farming.
C
It vanished from Britain several thousand years ago.
D
It survived in Britain longer than was previously thought.
Locate
2
What point does the writer make about large predators in the third paragraph?
A
Their presence can increase biodiversity.
B
They may cause damage to local ecosystems.
C
Their behaviour can alter according to the environment.
D
They should be reintroduced only to areas where they were native.
Locate
3
What does the writer suggest about British conservation in the fourth paragraph?
A
It has failed to achieve its aims.
B
It is beginning to change direction.
C
it has taken a misguided approach.
D
It has focused on the most widespread species.
Locate
4
Protecting large areas of the sea from commercial fishing would result in
A
practical benefits for the fishing industry.
B
some short-term losses to the fishing industry.
C
widespread opposition from the fishing industry.
D
certain changes to techniques within the fishing industry.
Locate
5
According to the author, what distinguishes rewilding from other environmental campaigns?
A
Its objective is more achievable.
B
Its supporters are more articulate.
C
Its positive message is more appealing.
D
It is based on sounder scientific principles.
Locate

Write the correct letter, A, B, C or D , in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7209e22a-2ec8-5bd7-aef4-5b9e63a45622', '05cadf11-d415-5b0b-834e-192e03f977d9', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete the summary using the list of words and phrases
A-F
below.
Write the correct letter,
A-F
, in boxes
6-9
on your answer sheet.
Reintroducing the lynx to Britain
There would be many advantages to reintroducing the lynx to Britain. While there is no evidence that the lynx has ever put
6
Locate
in danger, it would reduce the numbers of certain
7
Locate
whose populations have increased enormously in recent decades. It would present only a minimal threat to
8
Locate
, provided these were kept away from lynx habitats. Furthermore, the reintroduction programme would also link efficiently with initiatives to return native
9
Locate
to certain areas of the country.
A
trees
B
endangered species
C
hillsides
D
wild animals
E
humans
F
farm animals

There would be many advantages to reintroducing the lynx to Britain. While there is no evidence that the lynx has ever put 6 ____ Locate in danger, it would reduce the numbers of certain 7 ____ Locate whose populations have increased enormously in recent decades. It would present only a minimal threat to 8 ____ Locate , provided these were kept away from lynx habitats. Furthermore, the reintroduction programme would also link efficiently with initiatives to return native 9 ____ Locate to certain areas of the country.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53a3c8e3-c80e-5e6a-8cf5-e1e1ab948a76', '7209e22a-2ec8-5bd7-aef4-5b9e63a45622', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75026e21-71a8-5a09-94ef-557c3a031e51', '7209e22a-2ec8-5bd7-aef4-5b9e63a45622', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c226c4d-d1fd-589d-9f22-e2267d72fcd9', '7209e22a-2ec8-5bd7-aef4-5b9e63a45622', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65bd0cee-d283-55a6-9adb-06103b07dd89', '7209e22a-2ec8-5bd7-aef4-5b9e63a45622', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b00ad613-96a1-5616-be28-428871346362', '7209e22a-2ec8-5bd7-aef4-5b9e63a45622', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('433441f2-51d7-53b7-ae7a-67a82aa85907', '7209e22a-2ec8-5bd7-aef4-5b9e63a45622', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8b94612e-68e0-5ad6-8214-c3ec32145cb6', '05cadf11-d415-5b0b-834e-192e03f977d9', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete the summary using the list of words and phrases
A-F
below.
Write the correct letter,
A-F
, in boxes
6-9
on your answer sheet.
Reintroducing the lynx to Britain
There would be many advantages to reintroducing the lynx to Britain. While there is no evidence that the lynx has ever put
6
Locate
in danger, it would reduce the numbers of certain
7
Locate
whose populations have increased enormously in recent decades. It would present only a minimal threat to
8
Locate
, provided these were kept away from lynx habitats. Furthermore, the reintroduction programme would also link efficiently with initiatives to return native
9
Locate
to certain areas of the country.
A
trees
B
endangered species
C
hillsides
D
wild animals
E
humans
F
farm animals

There would be many advantages to reintroducing the lynx to Britain. While there is no evidence that the lynx has ever put 6 ____ Locate in danger, it would reduce the numbers of certain 7 ____ Locate whose populations have increased enormously in recent decades. It would present only a minimal threat to 8 ____ Locate , provided these were kept away from lynx habitats. Furthermore, the reintroduction programme would also link efficiently with initiatives to return native 9 ____ Locate to certain areas of the country.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee9d5d49-da3d-5d9d-983f-2e6918111123', '8b94612e-68e0-5ad6-8214-c3ec32145cb6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0eab0a48-0c85-58dd-b6aa-3f393a1b8c9c', '8b94612e-68e0-5ad6-8214-c3ec32145cb6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23006c48-ca95-50e4-89bb-0790b355d948', '8b94612e-68e0-5ad6-8214-c3ec32145cb6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f81241d9-c44e-5ff4-a41f-7bd731ab53ad', '8b94612e-68e0-5ad6-8214-c3ec32145cb6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fea83c61-ec53-5c28-85ca-cff32879db0b', '8b94612e-68e0-5ad6-8214-c3ec32145cb6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff9bdbab-9131-59e5-a887-3915514cdb4c', '8b94612e-68e0-5ad6-8214-c3ec32145cb6', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35b14394-c973-59bd-89d5-86e95e38da14', '05cadf11-d415-5b0b-834e-192e03f977d9', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete the summary using the list of words and phrases
A-F
below.
Write the correct letter,
A-F
, in boxes
6-9
on your answer sheet.
Reintroducing the lynx to Britain
There would be many advantages to reintroducing the lynx to Britain. While there is no evidence that the lynx has ever put
6
Locate
in danger, it would reduce the numbers of certain
7
Locate
whose populations have increased enormously in recent decades. It would present only a minimal threat to
8
Locate
, provided these were kept away from lynx habitats. Furthermore, the reintroduction programme would also link efficiently with initiatives to return native
9
Locate
to certain areas of the country.
A
trees
B
endangered species
C
hillsides
D
wild animals
E
humans
F
farm animals

There would be many advantages to reintroducing the lynx to Britain. While there is no evidence that the lynx has ever put 6 ____ Locate in danger, it would reduce the numbers of certain 7 ____ Locate whose populations have increased enormously in recent decades. It would present only a minimal threat to 8 ____ Locate , provided these were kept away from lynx habitats. Furthermore, the reintroduction programme would also link efficiently with initiatives to return native 9 ____ Locate to certain areas of the country.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a668b9a-0e1c-520f-9a5c-3da0d785957a', '35b14394-c973-59bd-89d5-86e95e38da14', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88c062e5-7d6c-5be6-8b9e-9efb5baa50ae', '35b14394-c973-59bd-89d5-86e95e38da14', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('744c28f7-1c6b-5127-8a84-7aea014dfd85', '35b14394-c973-59bd-89d5-86e95e38da14', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd29ef25-2fe4-5d57-927e-e6e1ea622744', '35b14394-c973-59bd-89d5-86e95e38da14', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5423e0f4-db3b-550e-a223-d4f2c0ec15c0', '35b14394-c973-59bd-89d5-86e95e38da14', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('155f64ac-151d-5c52-b97d-c18928af2d39', '35b14394-c973-59bd-89d5-86e95e38da14', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a6aac0a0-0c29-58cc-b6cd-bf20f1bc892e', '05cadf11-d415-5b0b-834e-192e03f977d9', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete the summary using the list of words and phrases
A-F
below.
Write the correct letter,
A-F
, in boxes
6-9
on your answer sheet.
Reintroducing the lynx to Britain
There would be many advantages to reintroducing the lynx to Britain. While there is no evidence that the lynx has ever put
6
Locate
in danger, it would reduce the numbers of certain
7
Locate
whose populations have increased enormously in recent decades. It would present only a minimal threat to
8
Locate
, provided these were kept away from lynx habitats. Furthermore, the reintroduction programme would also link efficiently with initiatives to return native
9
Locate
to certain areas of the country.
A
trees
B
endangered species
C
hillsides
D
wild animals
E
humans
F
farm animals

There would be many advantages to reintroducing the lynx to Britain. While there is no evidence that the lynx has ever put 6 ____ Locate in danger, it would reduce the numbers of certain 7 ____ Locate whose populations have increased enormously in recent decades. It would present only a minimal threat to 8 ____ Locate , provided these were kept away from lynx habitats. Furthermore, the reintroduction programme would also link efficiently with initiatives to return native 9 ____ Locate to certain areas of the country.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3832e1b-76a7-566b-bcb8-c49215f4a1e6', 'a6aac0a0-0c29-58cc-b6cd-bf20f1bc892e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b249c39b-f1e7-5e3c-bd80-515baf706577', 'a6aac0a0-0c29-58cc-b6cd-bf20f1bc892e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b34f1b2-7ddb-5527-bb3f-5d5806934a91', 'a6aac0a0-0c29-58cc-b6cd-bf20f1bc892e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40553941-daf1-5211-966d-fd32a134df08', 'a6aac0a0-0c29-58cc-b6cd-bf20f1bc892e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f446613-1fb4-5d32-9146-1e926b670505', 'a6aac0a0-0c29-58cc-b6cd-bf20f1bc892e', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5990090-fa61-5e5a-b186-8d4e953f7ba6', 'a6aac0a0-0c29-58cc-b6cd-bf20f1bc892e', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('42833ff9-a3a5-5b82-b3c1-716036bc1451', '05cadf11-d415-5b0b-834e-192e03f977d9', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Britain could become the first European country to reintroduce the lynx.
Locate
11
The large growth in the European lynx population since 1970 has exceeded conservationists’ expectations.
12
Changes in agricultural practices have extended the habitat of the lynx in Europe.
Locate
13
It has become apparent that species reintroduction has commercial advantages.
Locate

10 ____ Britain could become the first European country to reintroduce the lynx. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd9e3817-5ac4-5afa-8c99-c9a6954ef0f5', '42833ff9-a3a5-5b82-b3c1-716036bc1451', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba6cc75f-e9bd-5633-b924-021bf89a8cc5', '42833ff9-a3a5-5b82-b3c1-716036bc1451', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe656a7-ea25-5abf-9f19-2eac49791254', '42833ff9-a3a5-5b82-b3c1-716036bc1451', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('931883cb-f156-5c59-b83c-362ad237f3d4', '05cadf11-d415-5b0b-834e-192e03f977d9', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Britain could become the first European country to reintroduce the lynx.
Locate
11
The large growth in the European lynx population since 1970 has exceeded conservationists’ expectations.
12
Changes in agricultural practices have extended the habitat of the lynx in Europe.
Locate
13
It has become apparent that species reintroduction has commercial advantages.
Locate

11 ____ The large growth in the European lynx population since 1970 has exceeded conservationists’ expectations.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a64a688c-929f-52f1-9bf6-82627405b7ff', '931883cb-f156-5c59-b83c-362ad237f3d4', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2eb61be-3135-5b9e-9f79-216d841f3814', '931883cb-f156-5c59-b83c-362ad237f3d4', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6db30119-46d8-5d47-af6c-e3a7b8b24a78', '931883cb-f156-5c59-b83c-362ad237f3d4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f648093f-762e-5d62-ad46-0259079b5f6e', '05cadf11-d415-5b0b-834e-192e03f977d9', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Britain could become the first European country to reintroduce the lynx.
Locate
11
The large growth in the European lynx population since 1970 has exceeded conservationists’ expectations.
12
Changes in agricultural practices have extended the habitat of the lynx in Europe.
Locate
13
It has become apparent that species reintroduction has commercial advantages.
Locate

12 ____ Changes in agricultural practices have extended the habitat of the lynx in Europe. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92d0c517-ff09-51db-ad4c-627b4f090f3e', 'f648093f-762e-5d62-ad46-0259079b5f6e', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27944aab-0174-564a-8b3e-f75a14b9c9fe', 'f648093f-762e-5d62-ad46-0259079b5f6e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dc60c83-a2d4-5109-a4b9-8ef670572934', 'f648093f-762e-5d62-ad46-0259079b5f6e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aad8b424-7ae3-5b17-848a-3eee4c0a67dd', '05cadf11-d415-5b0b-834e-192e03f977d9', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Britain could become the first European country to reintroduce the lynx.
Locate
11
The large growth in the European lynx population since 1970 has exceeded conservationists’ expectations.
12
Changes in agricultural practices have extended the habitat of the lynx in Europe.
Locate
13
It has become apparent that species reintroduction has commercial advantages.
Locate

13 ____ It has become apparent that species reintroduction has commercial advantages. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c267cf8-34b6-5eff-af99-a0d0cddcfe3f', 'aad8b424-7ae3-5b17-848a-3eee4c0a67dd', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('268eb7dd-d867-52a2-b198-5d8a309699b4', 'aad8b424-7ae3-5b17-848a-3eee4c0a67dd', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f6d755c-9d34-56dd-a00d-0527a6625d03', 'aad8b424-7ae3-5b17-848a-3eee4c0a67dd', 3, $md$NOT GIVEN$md$, false);

COMMIT;

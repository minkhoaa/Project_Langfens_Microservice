BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-australian-artist-margaret-preston-1518'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-australian-artist-margaret-preston-1518';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-australian-artist-margaret-preston-1518';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-australian-artist-margaret-preston-1518';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7a46a139-a15f-5caf-a7ba-a44ca2307929', 'ielts-reading-australian-artist-margaret-preston-1518', $t$Australian artist Margaret Preston$t$, $md$## Australian artist Margaret Preston

Nguồn:
- Test: https://mini-ielts.com/1518/reading/australian-artist-margaret-preston
- Solution: https://mini-ielts.com/1518/view-solution/reading/australian-artist-margaret-preston$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('147d47e8-e693-5990-b426-fb9c2adf8062', '7a46a139-a15f-5caf-a7ba-a44ca2307929', 1, $t$Reading — Australian artist Margaret Preston$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Australian artist Margaret Preston

Margaret Preston's vibrant paintings and prints of Australian flowers, animals and landscapes have delighted the Australian public since the early 1920s.

Margaret Preston was born Margaret Rose McPherson in Port Adelaide, South Australia in 1875, the daughter of David McPherson, a Scottish marine engineer and his wife Prudence Lyle. She and her sister were sent at first to a private school, but when family circumstances changed, her mother took the girls to Sydney where Margaret attended a public high school. She decided early in life to become an artist and took private art lessons. In 1888, she trained for several months with Sydney landscape painter William Lister, and in 1893 enrolled at the National Gallery of Victoria Art School, where she studied for just over four years.

In 1898, after her father died, Margaret returned to Adelaide to study and then teach at the Adelaide School of Design. Her early artwork was influenced by the German aesthetic tradition, in which subjects of the natural world were depicted in a true to life manner.

Margaret's first visit to Europe in 1904, and her studies in Paris, France had little impact on this naturalism that dominated her work from this early period. However some eight years later, after returning to Paris, she began to recognise the decorative possibilities of art.

With the outbreak of the First World War, Margaret traveled to England, where she had exhibitions and continued her studies of art. She was a student of pottery, but at some time developed her interest in various techniques of printmaking and design. In England's West Country, she taught basket weaving at a rehabilitation unit for servicemen. It was on board a boat returning to Australia that she met wealthy businessman William Preston, whom she married in 1919. Together Margaret and William settled in the Sydney harbourside suburb of Mosman. The most characteristic prints from her early years in Sydney are views of boats floating on Sydney Harbour and of houses clustered on foreshore hills. Although Sydney was their home, the couple traveled regularly, both overseas and within Australia.

Her first major showing in Australia was with her friend Thea Proctor, in exhibitions in Melbourne and Sydney in 1925. Many of Preston's prints were hand-coloured in rich scarlet reds, blues and greens, and all of them were set in Chinese red lacquer frames. Harbour views were again prominent, but in comparison with earlier artworks, they were compact and busy. using striking contrasts of black and white combined with elaborate patterns and repetitions. Other prints from this period featured native flora. It was with these still-life subjects that she convinced the public that Australian native flowers were equal in beauty to any exotic species.

From 1932 to 1939, Preston moved away from Sydney and lived with her husband at Berowra, on the upper reaches of the Hawkesbury River. The area was one of rugged natural beauty, and for the first time Preston found herself living in a home surrounded bush. Prior to this, the native flowers that featured in her paintings and prints had been purchased from local florists; they now grew in abundance around her home. Preston's prints became larger, less complex and less reliant on the use of bright colours. Flowers were no longer arranged in vases, and Preston began to concentrate instead on flowers that were growing wild.

While living at Berowra, and undoubtedly prompted by the Aboriginal' rock engravings found near her property, Preston also developed what was to he a lifelong interest in Aboriginal art. On returning to Sydney in 1939, she became a member of the Anthropological Society of New South Wales, and later visited many important Aboriginal sites throughout Australia. Preston believed that Aboriginal art provided the key to establishing a national body of art that reflected the vast and ancient continent of Australia.

During the 1940s, symbols used by Aboriginal people, together with dried, burnt colours found in traditional Aboriginal paintings, became increasingly prominent in her prints. The artist's titles from this period frequently acknowledge her sources, and reveal the extent to which she drew inspiration from traditional Aboriginal art to create her own art.

It was in 1953, at the age of 78, that Preston produced her most significant prints. The exhibition at Macquarie Galleries in Sydney included 29 prints made using the ancient technique known as stenciling. Many of the artworks in the exhibition incorporated her fusion of Aboriginal and Chinese concepts. Preston had admired Chinese art since 1915, when she acquired the first of her many books on the subject, and she had visited China on two occasions. Chinese elements may be found in several of her earlier paintings.

However, in her prints of the 1950s, Preston combined Chinese ideas with her understanding of the Dreamtime' creation stories of Aboriginal Australians. Preston did not let age alter her habit of working hard. As she got older, her love of painting, printmaking and travel continued. By the time of her death in 1963, when she was 88, she had produced over 400 paintings and prints. In a career spanning almost 60 years, she created a body of work that demonstrates her extraordinary originality and the intensity of her commitment to Australian art.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('502fd2a2-1b29-5ca9-a564-e633286fbaad', '147d47e8-e693-5990-b426-fb9c2adf8062', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1 - 7
Questions 1 - 7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Artists in the German aesthetic tradition portrayed nature realistically.
2
Margaret attended a famous art college in Paris.
3
Margaret met her husband William while teaching a craft at a rehabilitation unit.
4
Margaret Preston and Thea Proctor explored similar themes in their art.
5
Margaret's 1925 artworks of Sydney Harbour were simpler than her previous ones.
6
The colours in Margaret's Berowra prints were very bright.
7
When living in Berowra, Margaret painted flowers in their natural location.

1 ____ Artists in the German aesthetic tradition portrayed nature realistically.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71245aec-dc06-559a-b309-e7c2f2be6b73', '502fd2a2-1b29-5ca9-a564-e633286fbaad', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0567464-428d-535b-86d3-db371ae5917a', '502fd2a2-1b29-5ca9-a564-e633286fbaad', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4665935-bfd5-5e14-b3df-4ffebe16bf50', '502fd2a2-1b29-5ca9-a564-e633286fbaad', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d7feed7b-9f30-5c80-b974-f8aeb2599812', '147d47e8-e693-5990-b426-fb9c2adf8062', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1 - 7
Questions 1 - 7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Artists in the German aesthetic tradition portrayed nature realistically.
2
Margaret attended a famous art college in Paris.
3
Margaret met her husband William while teaching a craft at a rehabilitation unit.
4
Margaret Preston and Thea Proctor explored similar themes in their art.
5
Margaret's 1925 artworks of Sydney Harbour were simpler than her previous ones.
6
The colours in Margaret's Berowra prints were very bright.
7
When living in Berowra, Margaret painted flowers in their natural location.

2 ____ Margaret attended a famous art college in Paris.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c29d49f-a2b1-5311-8244-7756a526e6e4', 'd7feed7b-9f30-5c80-b974-f8aeb2599812', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8ac7483-8474-5e0c-963a-d45e2f2a253c', 'd7feed7b-9f30-5c80-b974-f8aeb2599812', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1632e5dc-15b5-59f5-99e9-bfb3102b47f6', 'd7feed7b-9f30-5c80-b974-f8aeb2599812', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fbdfe641-289e-59ea-b8ad-18fd19cb0dd3', '147d47e8-e693-5990-b426-fb9c2adf8062', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1 - 7
Questions 1 - 7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Artists in the German aesthetic tradition portrayed nature realistically.
2
Margaret attended a famous art college in Paris.
3
Margaret met her husband William while teaching a craft at a rehabilitation unit.
4
Margaret Preston and Thea Proctor explored similar themes in their art.
5
Margaret's 1925 artworks of Sydney Harbour were simpler than her previous ones.
6
The colours in Margaret's Berowra prints were very bright.
7
When living in Berowra, Margaret painted flowers in their natural location.

3 ____ Margaret met her husband William while teaching a craft at a rehabilitation unit.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87f0411e-d0e9-540d-953c-7add82eda443', 'fbdfe641-289e-59ea-b8ad-18fd19cb0dd3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29ae290c-3e3f-55c3-8143-e4810c14713a', 'fbdfe641-289e-59ea-b8ad-18fd19cb0dd3', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bad4f60a-240e-59c4-8912-ad73ae96fce8', 'fbdfe641-289e-59ea-b8ad-18fd19cb0dd3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8f3d650e-ffe2-56fc-8de3-bde6278b6162', '147d47e8-e693-5990-b426-fb9c2adf8062', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1 - 7
Questions 1 - 7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Artists in the German aesthetic tradition portrayed nature realistically.
2
Margaret attended a famous art college in Paris.
3
Margaret met her husband William while teaching a craft at a rehabilitation unit.
4
Margaret Preston and Thea Proctor explored similar themes in their art.
5
Margaret's 1925 artworks of Sydney Harbour were simpler than her previous ones.
6
The colours in Margaret's Berowra prints were very bright.
7
When living in Berowra, Margaret painted flowers in their natural location.

4 ____ Margaret Preston and Thea Proctor explored similar themes in their art.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('590729f5-6c8e-5688-b8b0-6c8e7714ab4c', '8f3d650e-ffe2-56fc-8de3-bde6278b6162', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c576c308-a93f-56fd-b56d-ecc4494e712a', '8f3d650e-ffe2-56fc-8de3-bde6278b6162', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93551a13-0d77-5e64-a6b6-1eba4d761401', '8f3d650e-ffe2-56fc-8de3-bde6278b6162', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a796e5bd-4089-55c5-93c3-0dec9e1346b3', '147d47e8-e693-5990-b426-fb9c2adf8062', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1 - 7
Questions 1 - 7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Artists in the German aesthetic tradition portrayed nature realistically.
2
Margaret attended a famous art college in Paris.
3
Margaret met her husband William while teaching a craft at a rehabilitation unit.
4
Margaret Preston and Thea Proctor explored similar themes in their art.
5
Margaret's 1925 artworks of Sydney Harbour were simpler than her previous ones.
6
The colours in Margaret's Berowra prints were very bright.
7
When living in Berowra, Margaret painted flowers in their natural location.

5 ____ Margaret's 1925 artworks of Sydney Harbour were simpler than her previous ones.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cb1ecfb-d80c-5de1-9a10-dda236a91f2b', 'a796e5bd-4089-55c5-93c3-0dec9e1346b3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a1968b3-b7db-535e-a314-d65af69901e8', 'a796e5bd-4089-55c5-93c3-0dec9e1346b3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18b51d08-7782-56c4-ba28-9a081e9b7c5d', 'a796e5bd-4089-55c5-93c3-0dec9e1346b3', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8e88efa-b685-5237-ad8a-d6daece9a3a3', '147d47e8-e693-5990-b426-fb9c2adf8062', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1 - 7
Questions 1 - 7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Artists in the German aesthetic tradition portrayed nature realistically.
2
Margaret attended a famous art college in Paris.
3
Margaret met her husband William while teaching a craft at a rehabilitation unit.
4
Margaret Preston and Thea Proctor explored similar themes in their art.
5
Margaret's 1925 artworks of Sydney Harbour were simpler than her previous ones.
6
The colours in Margaret's Berowra prints were very bright.
7
When living in Berowra, Margaret painted flowers in their natural location.

6 ____ The colours in Margaret's Berowra prints were very bright.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42d64dd8-dc43-5121-b43b-83b38de78506', 'd8e88efa-b685-5237-ad8a-d6daece9a3a3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91c7f7e5-2062-52ad-abe3-2fa72142b652', 'd8e88efa-b685-5237-ad8a-d6daece9a3a3', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e2e215d-65f4-5d1e-9266-7179e1cbb16e', 'd8e88efa-b685-5237-ad8a-d6daece9a3a3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d263ca3-8dbf-524d-9079-ccc4647a0da9', '147d47e8-e693-5990-b426-fb9c2adf8062', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1 - 7
Questions 1 - 7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Artists in the German aesthetic tradition portrayed nature realistically.
2
Margaret attended a famous art college in Paris.
3
Margaret met her husband William while teaching a craft at a rehabilitation unit.
4
Margaret Preston and Thea Proctor explored similar themes in their art.
5
Margaret's 1925 artworks of Sydney Harbour were simpler than her previous ones.
6
The colours in Margaret's Berowra prints were very bright.
7
When living in Berowra, Margaret painted flowers in their natural location.

7 ____ When living in Berowra, Margaret painted flowers in their natural location.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63eda864-7717-52a2-a76a-252d89bd37ca', '2d263ca3-8dbf-524d-9079-ccc4647a0da9', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38f436e4-ed21-58b3-b53d-b97e36806790', '2d263ca3-8dbf-524d-9079-ccc4647a0da9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ce87833-a40c-53fc-8a07-ade5df171a6e', '2d263ca3-8dbf-524d-9079-ccc4647a0da9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('338f6f70-acc3-5f79-b34a-8f5848fafd98', '147d47e8-e693-5990-b426-fb9c2adf8062', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8 - 13
Questions 8 - 13
Complete the notes below.
Choose ONE WORD AND/OR A NUMBER from the passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Margaret Preston's later life
Aboriginal influence
interest in Aboriginal art was inspired by seeing rock engravings close to her Berowra home
incorporated
8
and colours from Aboriginal art in her own work often referred to Aboriginal sources in the
9
she gave her artworks
1953 exhibition
very old method of
10
was used for some prints
was inspired by
11
about Chinese art that she had started collecting in 1915
combination of Chinese and Aboriginal elements
Old age
still interested in
12
and art
worked for nearly six decades making more than
13
artworks
dedicated n to Australian art and the originality of her work is seen in Preston's long career

incorporated 8 ____ and colours from Aboriginal art in her own work often referred to Aboriginal sources in the 9 ____ she gave her artworks$md$, NULL, ARRAY['.*symbols.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('92703219-6364-51c2-a015-8661149e65a1', '147d47e8-e693-5990-b426-fb9c2adf8062', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8 - 13
Questions 8 - 13
Complete the notes below.
Choose ONE WORD AND/OR A NUMBER from the passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Margaret Preston's later life
Aboriginal influence
interest in Aboriginal art was inspired by seeing rock engravings close to her Berowra home
incorporated
8
and colours from Aboriginal art in her own work often referred to Aboriginal sources in the
9
she gave her artworks
1953 exhibition
very old method of
10
was used for some prints
was inspired by
11
about Chinese art that she had started collecting in 1915
combination of Chinese and Aboriginal elements
Old age
still interested in
12
and art
worked for nearly six decades making more than
13
artworks
dedicated n to Australian art and the originality of her work is seen in Preston's long career

incorporated 8 ____ and colours from Aboriginal art in her own work often referred to Aboriginal sources in the 9 ____ she gave her artworks$md$, NULL, ARRAY['.*symbols.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('52cbfcd6-da0a-59ae-8e33-5b15b1bb9210', '147d47e8-e693-5990-b426-fb9c2adf8062', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8 - 13
Questions 8 - 13
Complete the notes below.
Choose ONE WORD AND/OR A NUMBER from the passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Margaret Preston's later life
Aboriginal influence
interest in Aboriginal art was inspired by seeing rock engravings close to her Berowra home
incorporated
8
and colours from Aboriginal art in her own work often referred to Aboriginal sources in the
9
she gave her artworks
1953 exhibition
very old method of
10
was used for some prints
was inspired by
11
about Chinese art that she had started collecting in 1915
combination of Chinese and Aboriginal elements
Old age
still interested in
12
and art
worked for nearly six decades making more than
13
artworks
dedicated n to Australian art and the originality of her work is seen in Preston's long career

very old method of 10 ____$md$, NULL, ARRAY['.*stenciling.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fa7af222-2406-5e86-b12f-0a474a5ad40b', '147d47e8-e693-5990-b426-fb9c2adf8062', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8 - 13
Questions 8 - 13
Complete the notes below.
Choose ONE WORD AND/OR A NUMBER from the passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Margaret Preston's later life
Aboriginal influence
interest in Aboriginal art was inspired by seeing rock engravings close to her Berowra home
incorporated
8
and colours from Aboriginal art in her own work often referred to Aboriginal sources in the
9
she gave her artworks
1953 exhibition
very old method of
10
was used for some prints
was inspired by
11
about Chinese art that she had started collecting in 1915
combination of Chinese and Aboriginal elements
Old age
still interested in
12
and art
worked for nearly six decades making more than
13
artworks
dedicated n to Australian art and the originality of her work is seen in Preston's long career

was inspired by 11 ____ about Chinese art that she had started collecting in 1915$md$, NULL, ARRAY['.*books.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2c4ac3d2-57d1-5fe1-93ac-599dbb2391df', '147d47e8-e693-5990-b426-fb9c2adf8062', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8 - 13
Questions 8 - 13
Complete the notes below.
Choose ONE WORD AND/OR A NUMBER from the passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Margaret Preston's later life
Aboriginal influence
interest in Aboriginal art was inspired by seeing rock engravings close to her Berowra home
incorporated
8
and colours from Aboriginal art in her own work often referred to Aboriginal sources in the
9
she gave her artworks
1953 exhibition
very old method of
10
was used for some prints
was inspired by
11
about Chinese art that she had started collecting in 1915
combination of Chinese and Aboriginal elements
Old age
still interested in
12
and art
worked for nearly six decades making more than
13
artworks
dedicated n to Australian art and the originality of her work is seen in Preston's long career

still interested in 12 ____ and art$md$, NULL, ARRAY['.*painting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0bdcc83d-eb24-5de4-bb83-1d5b638097bd', '147d47e8-e693-5990-b426-fb9c2adf8062', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8 - 13
Questions 8 - 13
Complete the notes below.
Choose ONE WORD AND/OR A NUMBER from the passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Margaret Preston's later life
Aboriginal influence
interest in Aboriginal art was inspired by seeing rock engravings close to her Berowra home
incorporated
8
and colours from Aboriginal art in her own work often referred to Aboriginal sources in the
9
she gave her artworks
1953 exhibition
very old method of
10
was used for some prints
was inspired by
11
about Chinese art that she had started collecting in 1915
combination of Chinese and Aboriginal elements
Old age
still interested in
12
and art
worked for nearly six decades making more than
13
artworks
dedicated n to Australian art and the originality of her work is seen in Preston's long career

worked for nearly six decades making more than 13 ____ artworks$md$, NULL, ARRAY['.*400.*']);

COMMIT;

-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:27.228134
-- Source: ielts-mentor.com
-- Title: Letter To Your Friend Describing Your Experience Of Attending A Marriage Ceremony
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Your Friend Describing Your Experience Of Attending A Marriage Ceremony';

-- Insert into writing_exams table
INSERT INTO "writing_exams" (
  "Id",
  "Title", 
  "TaskText",
  "ExamType",
  "Level",
  "Tags",
  "ModelAnswers",
  "CreatedAt",
  "CreatedBy"
)
VALUES (
  gen_random_uuid(),
  E'Letter To Your Friend Describing Your Experience Of Attending A Marriage Ceremony',
  E'You should spend about\n20\nminutes on this task.\nYou have recently attended a marriage ceremony in your country. You have an English-speaking friend who you want to describe your experience of attending this marriage ceremony.\nWrite a letter to this English-speaking friend. In your letter,\nwhose marriage ceremony it was\ngive details of this marriage ceremony\ninvite your friend to come and visit your country\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Emily,\\nI hope you''re doing great! I was so excited to receive your letter yesterday. Today, I''m writing to tell you about an amazing wedding ceremony I recently attended and it was truly a celebration to remember!\\nIt was the marriage of my cousin, Priya, and it took place here in Jaipur, the cultural heart of Rajasthan. The entire event spanned three days, beginning with the Mehendi ceremony, where all the women had their hands beautifully decorated with henna. The next day was the Sangeet, which was filled with music, dance, and performances by family members. The final day was the wedding itself, held in a traditional palace venue, adorned with vibrant marigold garlands and fairy lights. Everyone wore colourful ethnic attire, and the food - oh, you would have loved it! From spicy curries to sweet gulab jamuns, every dish was mouthwatering.\\nI truly wish you could have been here. It made me realise how much you would enjoy the culture, colours, and warmth of Indian celebrations. Why don’t you plan a visit sometime soon? I’d love to show you around and give you a real taste of our traditions.\\nLooking forward to hearing from you!\\nWarm wishes,\\nNandini", "Dear Jonathan,\\nI hope everything is going great with you in Canada! I recently attended a traditional Vietnamese wedding here in Hanoi and thought you’d be interested in hearing about it. Truly speaking, it was such a beautiful and meaningful experience.\\nThe ceremony was for my close childhood friend, Linh. It was a mix of traditional customs and modern touches. In the morning, the groom’s family came to the bride’s house with gifts, including fruits, tea, and even roasted pigs, which are symbolic in our culture. The bride wore a stunning red áo dài (our traditional dress), and the couple performed a tea ceremony to honour their parents and elders. Later in the evening, we all moved to a banquet hall for the reception. There were more than 300 guests, and we enjoyed a delicious 8-course meal while watching live performances and heartfelt speeches. It was joyful, emotional, and full of laughter.\\nI’d love for you to visit Vietnam someday and experience our culture firsthand. Weddings here are just one of the many things that make Vietnam unique. Let me know if you''re ever planning a trip. I’d be thrilled to show you around!\\nBest wishes,\\nMinh", "Dear Sarah,\\nI hope you and your family are doing well by the grace of the Almighty! I wanted to share an unforgettable experience with you. I recently attended the wedding of my cousin, Ayesha, here in Lahore, and it was absolutely magical. I thought you’d enjoy hearing about it, especially since you’ve always been curious about South Asian traditions.\\nPakistani weddings are grand, colourful, and full of life. Ayesha’s wedding was spread over three days, starting with the Mehndi night, where everyone wore vibrant clothes, danced to traditional songs, and had henna designs applied. The next day was the Baraat - the main wedding event - where the groom arrived with his family in a beautifully decorated procession. Ayesha looked stunning in her red bridal dress, and the entire ceremony was emotional yet joyous. The final event was the Walima, a reception hosted by the groom’s family. The food throughout was incredible which included biryani, kebabs, korma, and traditional desserts like gulab jamun and ras malai. Everything was full of flavour and celebration.\\nI’d love for you to visit Pakistan someday. Our weddings are just one part of our rich culture, and I’m sure you’d enjoy exploring it all. Let me know if you ever plan a trip. I’ll make sure it’s a memorable one!\\nWarm regards,\\nSamira\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.85 (10 Votes)\\nIELTS Letter Writing\\nInformal Letter\\nLetter Writing Sample\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nDF\\n4 months 8 days\\nDear Eline,\\nI hope you''re doing great. Recently, I attended a truly memorable marriage ceremony here in my country, and I thought you''d enjoy hearing about it. It was the wedding of my cousin, who is very close to me, and the whole event brought together family members and friends from across the region.\\nThe ceremony was full of traditional customs that reflected our culture. The bride looked stunning in a beautifully embroidered dress, while the groom wore formal attire that highlighted his family’s heritage. The wedding hall was decorated with colourful lights, flowers, and music that created a joyful atmosphere. One of the highlights was the traditional dance performed by the guests, which added to the celebration. Of course, the food was abundant, with dishes ranging from local specialities to modern favourites, and everyone enjoyed sharing this rich feast.\\nAs I experienced this wonderful event, I wished so much that you could have been there to see it. I would love for you to visit my country in the near future so you can witness such traditions firsthand. I''m sure you''ll enjoy the warm hospitality, the culture, and the history we have to offer.\\nLooking forward to hearing from you soon.\\nWarm regards,\\nJohny\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;

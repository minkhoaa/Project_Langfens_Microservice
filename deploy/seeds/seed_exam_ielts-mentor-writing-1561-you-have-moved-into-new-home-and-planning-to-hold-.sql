-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:58.181966
-- Source: ielts-mentor.com
-- Title: You Have Moved Into New Home And Planning To Hold Party
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Moved Into New Home And Planning To Hold Party';

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
  E'You Have Moved Into New Home And Planning To Hold Party',
  E'You should spend about\n20\nminutes on this task.\nYou have just moved into a new home and are planning to hold a party. You are worried that the noise may disturb your neighbour.\nWrite a letter to your neighbour. In your letter,\nintroduce yourself\ndescribe your plans for the party\ninvite your neighbour to come\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ....................,\nSample Answer 1:\nDear Mr and Mrs Simpson,\nI am your next-door neighbour and we have recently moved into this house. I regret that I did not get the opportunity to be acquainted with you. In fact, we are a family of three - me, my wife and our 8 years old son. We are planning to hold a party next Monday and would like to invite you.\nMy son’s birthday will be on next Monday. Hence, my spouse and I have decided to celebrate this special occasion and invite some friends and relatives. The party will commence at 7:00 pm and continue till midnight. It will consist of some music and dancing in which a local music band will perform. The dinner will be served at around 08:00 pm in the garden and the concert will be held afterwards. Although the participants are comparatively limited, we are afraid the noises from the music performance might disturb you. We apologize in advance for any inconvenience created by this.\nI initially intended to invite you and your family to the party over the phone, but I hesitated whether it could be a good idea or not. My wife suggested that it would be more appropriate if I write a letter to do so.\nWe will be genuinely pleased if you kindly accept our invitation to our beloved son''s birthday ceremony. This way, we will not only find the chance to become familiar but enjoy the occasion together.\nBest Regards,\nAli Kazemian\n[ by - Naaz ]',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr and Mrs Simpson,\\nI am your next-door neighbour and we have recently moved into this house. I regret that I did not get the opportunity to be acquainted with you. In fact, we are a family of three - me, my wife and our 8 years old son. We are planning to hold a party next Monday and would like to invite you.\\nMy son’s birthday will be on next Monday. Hence, my spouse and I have decided to celebrate this special occasion and invite some friends and relatives. The party will commence at 7:00 pm and continue till midnight. It will consist of some music and dancing in which a local music band will perform. The dinner will be served at around 08:00 pm in the garden and the concert will be held afterwards. Although the participants are comparatively limited, we are afraid the noises from the music performance might disturb you. We apologize in advance for any inconvenience created by this.\\nI initially intended to invite you and your family to the party over the phone, but I hesitated whether it could be a good idea or not. My wife suggested that it would be more appropriate if I write a letter to do so.\\nWe will be genuinely pleased if you kindly accept our invitation to our beloved son''s birthday ceremony. This way, we will not only find the chance to become familiar but enjoy the occasion together.\\nBest Regards,\\nAli Kazemian\\n[ by - Naaz ]", "Dear Mr and Mrs Oliver,\\nI hope this letter finds you well. My name is Daniel, and I have recently moved into the house next to yours. I wanted to take a moment to introduce myself and also inform you about a small gathering I am planning.\\nI will be hosting a housewarming party on 14th March to celebrate my move and get to know friends and colleagues better. The event will begin around 6.30 PM, and more than 40 guests are expected to be present. We will host a dinner party that will include some music and game shows. While I will ensure that the noise remains at a reasonable level, I wanted to let you know in advance in case there is any disturbance.\\nFurthermore, I would love you to join us. It would be a great opportunity to meet properly, and I am sure you would enjoy the food and company. Please let me know if you are available - I would be delighted to have you there.\\nLooking forward to meeting you soon.\\nYours sincerely,\\nDaniel Campbell", "Dear Ms Meena,\\nI am Priya and I have recently moved with my family into the house next to yours. I am a doctor and I live with my daughter, and husband, who is a lawyer. I have planned to throw a party and invite some guests on the 10th of June and I would really appreciate your presence at that party.\\nSince this is the first time our family is moving into a house that we own, we have planned to throw a party and invite some friends, colleagues, relatives and neighbours. We have arranged a dinner party and want to share this special moment with the people we care about and love. I have also planned to arrange a music show which would make the event more enjoyable. I hope you would not mind the concert! I would feel very delighted if you could join the party.\\nMy apology for any inconvenience it might cause to you, but I assure you that I have already made arrangements to make it less noisy by a plan to conduct games for children and keep them engaged. We will also place soundproof coverage at the entrance of my house.\\nHope you will accept my invitation and join the party.\\nYours sincerely,\\nPriya Roy\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;

-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-24
-- Source: ielts-mentor.com
-- Title: Letter To Your Friend Describing Your Experience Of Attending A Marriage Ceremony
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same slug
DELETE FROM "writing_exams" WHERE "Slug" = 'ielts-mentor-writing-4135-letter-to-your-friend-describing-your-experience-o';

-- Insert into writing_exams table
INSERT INTO "writing_exams" (
  "Id",
  "Title", 
  "Slug",
  "TaskText",
  "ExamType",
  "Level",
  "Tags",
  "ModelAnswers",
  "ImageUrl",
  "CreatedAt",
  "CreatedBy",
  "SourceExamId",
  "SourceSectionId"
)
VALUES (
  gen_random_uuid(),
  E'Letter To Your Friend Describing Your Experience Of Attending A Marriage Ceremony',
  'ielts-mentor-writing-4135-letter-to-your-friend-describing-your-experience-o',
  E'You should spend about 20 minutes on this task.\n\nYou have recently attended a marriage ceremony in your country. You have an English-speaking friend who you want to describe your experience of attending this marriage ceremony.\n\nWrite a letter to this English-speaking friend. In your letter,\n- whose marriage ceremony it was\n- give details of this marriage ceremony\n- invite your friend to come and visit your country\n\nWrite at least 150 words.\n\nYou do NOT need to write any addresses.\n\nBegin your letter as follows:\nDear .......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sarah,\\n\\nI hope this letter finds you in good health. I am writing to share with you my wonderful experience of attending my cousin''s wedding ceremony last weekend.\\n\\nMy cousin, Huy, got married to his long-time girlfriend, Linh. The ceremony was held at a beautiful venue in Hanoi and was attended by over 200 guests, including family members and close friends.\\n\\nThe wedding followed traditional Vietnamese customs. The groom''s family arrived with a procession carrying symbolic gifts like betel leaves, areca nuts, wedding cakes, and fruits. The bride looked absolutely stunning in her traditional red ao dai, while the groom wore a matching outfit. After the tea ceremony where the couple paid respects to both families'' ancestors, there was a grand banquet with live music and dancing.\\n\\nI would love for you to visit Vietnam and experience our culture firsthand. Perhaps you could come during the next wedding season, which is usually in spring or autumn when the weather is pleasant.\\n\\nLooking forward to hearing from you soon.\\n\\nBest regards,\\nMinh"]'::jsonb,
  'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
  now(),
  '00000000-0000-0000-0000-000000000000',
  NULL,
  NULL
);

COMMIT;

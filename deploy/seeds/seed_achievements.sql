-- =============================================
-- ACHIEVEMENTS SEED DATA
-- Run this in gamification-service database
-- =============================================

-- Clear existing to avoid duplicates
DELETE FROM "Achievements" WHERE 1=1;

-- =============================================
-- CATEGORY: STREAK (Daily Learning)
-- =============================================
INSERT INTO "Achievements" ("Id", "Slug", "Title", "Description", "IconUrl", "Category", "Tier", "RequiredValue", "XpReward") VALUES
('11111111-0001-0001-0001-000000000001', 'streak-3', 'First Steps 🚶', 'Study for 3 consecutive days', 'footprint', 'STREAK', 'COMMON', 3, 50),
('11111111-0001-0001-0001-000000000002', 'streak-7', 'Week Warrior ⚔️', 'Maintain a 7-day learning streak', 'local_fire_department', 'STREAK', 'RARE', 7, 100),
('11111111-0001-0001-0001-000000000003', 'streak-14', 'Unstoppable 🔥', '14 days without missing a day', 'local_fire_department', 'STREAK', 'RARE', 14, 200),
('11111111-0001-0001-0001-000000000004', 'streak-30', 'Monthly Master 📅', 'Study consistently for 30 days straight', 'calendar_month', 'STREAK', 'EPIC', 30, 500),
('11111111-0001-0001-0001-000000000005', 'streak-60', 'Habit Builder 🏗️', '60-day streak - Habits are formed!', 'published_with_changes', 'STREAK', 'EPIC', 60, 1000),
('11111111-0001-0001-0001-000000000006', 'streak-100', 'Legend 🏆', 'Legendary 100-day learning streak', 'workspace_premium', 'STREAK', 'LEGENDARY', 100, 2000);

-- =============================================
-- CATEGORY: TEST (Exam Completion)
-- =============================================
INSERT INTO "Achievements" ("Id", "Slug", "Title", "Description", "IconUrl", "Category", "Tier", "RequiredValue", "XpReward") VALUES
('22222222-0002-0002-0002-000000000001', 'test-1', 'First Test ✅', 'Complete your first test', 'edit_document', 'TEST', 'COMMON', 1, 30),
('22222222-0002-0002-0002-000000000002', 'test-5', 'Getting Serious 📚', 'Complete 5 tests', 'library_books', 'TEST', 'COMMON', 5, 100),
('22222222-0002-0002-0002-000000000003', 'test-10', 'Practice Champion 🎯', 'Complete 10 tests', 'target', 'TEST', 'RARE', 10, 200),
('22222222-0002-0002-0002-000000000004', 'test-25', 'Test Expert 🧠', 'Conquer 25 tests', 'psychology', 'TEST', 'EPIC', 25, 500),
('22222222-0002-0002-0002-000000000005', 'test-50', 'Test Master 👨‍🎓', '50 tests completed', 'school', 'TEST', 'EPIC', 50, 1000),
('22222222-0002-0002-0002-000000000006', 'test-100', 'Century Club 💯', '100 tests - You are a legend!', 'history_edu', 'TEST', 'LEGENDARY', 100, 2000);

-- =============================================
-- CATEGORY: VOCABULARY (Flashcard Reviews)
-- =============================================
INSERT INTO "Achievements" ("Id", "Slug", "Title", "Description", "IconUrl", "Category", "Tier", "RequiredValue", "XpReward") VALUES
('33333333-0003-0003-0003-000000000001', 'vocab-10', 'Word Explorer 🔍', 'Review 10 vocabulary words', 'search', 'VOCABULARY', 'COMMON', 10, 20),
('33333333-0003-0003-0003-000000000002', 'vocab-50', 'Vocabulary Builder 📖', 'Review 50 vocabulary words', 'menu_book', 'VOCABULARY', 'RARE', 50, 100),
('33333333-0003-0003-0003-000000000003', 'vocab-100', 'Word Collector 📚', 'Accumulate 100 reviewed words', 'collections_bookmark', 'VOCABULARY', 'RARE', 100, 200),
('33333333-0003-0003-0003-000000000004', 'vocab-500', 'Vocabulary Expert 🎓', '500 words reviewed', 'translate', 'VOCABULARY', 'EPIC', 500, 500),
('33333333-0003-0003-0003-000000000005', 'vocab-1000', 'Lexicon Master 📕', '1000 words - Walking Dictionary!', 'auto_stories', 'VOCABULARY', 'LEGENDARY', 1000, 1000);

-- =============================================
-- CATEGORY: COURSE (Lessons Completed)
-- =============================================
INSERT INTO "Achievements" ("Id", "Slug", "Title", "Description", "IconUrl", "Category", "Tier", "RequiredValue", "XpReward") VALUES
('44444444-0004-0004-0004-000000000001', 'lesson-1', 'First Lesson 🎬', 'Complete your first lesson', 'play_circle', 'COURSE', 'COMMON', 1, 30),
('44444444-0004-0004-0004-000000000002', 'lesson-5', 'Quick Learner ⚡', 'Complete 5 lessons', 'bolt', 'COURSE', 'RARE', 5, 100),
('44444444-0004-0004-0004-000000000003', 'lesson-10', 'Course Champion 🥇', '10 lessons completed', 'emoji_events', 'COURSE', 'RARE', 10, 200),
('44444444-0004-0004-0004-000000000004', 'lesson-25', 'Knowledge Seeker 🧭', 'Conquer 25 lessons', 'explore', 'COURSE', 'EPIC', 25, 500),
('44444444-0004-0004-0004-000000000005', 'lesson-50', 'Course Master 🎓', 'Complete 50 lessons', 'military_tech', 'COURSE', 'LEGENDARY', 50, 1000);
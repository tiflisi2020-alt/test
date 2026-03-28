-- საერთო ჩატის სრული გასუფთავება (ყველა შეტყობინება)
-- Dashboard → SQL Editor → Run
--
-- TRUNCATE: სწრაფი, id კვლავ 1-დან დაიწყება (RESTART IDENTITY).
-- ალტერნატივა: ქვემოთ არის მხოლოდ DELETE (id-ები არ ირესეტება).

TRUNCATE TABLE public.main_chat_messages RESTART IDENTITY;

-- ალტერნატივა — ყველა ხაზის წაშლა id-ის რიცხვის შენარჩუნებით:
-- DELETE FROM public.main_chat_messages;

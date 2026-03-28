-- ═══════════════════════════════════════════════════════════════════════════
-- საწყისი თანამშრომლები (ერთხელ გაშვება SQL Editor-ში)
-- არ ქმნის დუბლიკატს: იგივე name თუ უკვე არსებობს, ხაზი არ ემატება.
-- გაშვებამდე: all_departments.sql (ცხრილები + RLS + GRANT)
-- ═══════════════════════════════════════════════════════════════════════════

-- მიმტანები
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'ლაშა სვანიძე', '558 667 748', 1 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'ლაშა სვანიძე');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'ირაკლი ბერიძე', '557 613 585', 2 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'ირაკლი ბერიძე');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'კახი კახაძე', '514 280 066', 3 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'კახი კახაძე');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'დეა ჟღენტი', '579 047 426', 4 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'დეა ჟღენტი');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'ლუკა არძენაძე', '599 400 361', 5 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'ლუკა არძენაძე');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'ბაჩი რომანაძე', '555 664 576', 6 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'ბაჩი რომანაძე');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'რატი ტაკიძე', '571 181 397', 7 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'რატი ტაკიძე');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'ნატა შარაბიძე', '555 867 676', 8 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'ნატა შარაბიძე');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'ხვიჩა შარაძე', '597 041 719', 9 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'ხვიჩა შარაძე');
INSERT INTO public.waiters (name, phone, position_order)
SELECT 'ლუკა გოგუაძე', '558 474 651', 10 WHERE NOT EXISTS (SELECT 1 FROM public.waiters w WHERE w.name = 'ლუკა გოგუაძე');

-- მზარეულები
INSERT INTO public.chefs (name, phone, position_order)
SELECT 'გიორგი უსუფაშვილი', '555 201 101', 1 WHERE NOT EXISTS (SELECT 1 FROM public.chefs c WHERE c.name = 'გიორგი უსუფაშვილი');
INSERT INTO public.chefs (name, phone, position_order)
SELECT 'ლევან ბაკურაძე', '555 201 102', 2 WHERE NOT EXISTS (SELECT 1 FROM public.chefs c WHERE c.name = 'ლევან ბაკურაძე');
INSERT INTO public.chefs (name, phone, position_order)
SELECT 'დავით ხაჭაპურიძე', '555 201 103', 3 WHERE NOT EXISTS (SELECT 1 FROM public.chefs c WHERE c.name = 'დავით ხაჭაპურიძე');
INSERT INTO public.chefs (name, phone, position_order)
SELECT 'ნიკოლოზ გოგოლაძე', '555 201 104', 4 WHERE NOT EXISTS (SELECT 1 FROM public.chefs c WHERE c.name = 'ნიკოლოზ გოგოლაძე');
INSERT INTO public.chefs (name, phone, position_order)
SELECT 'შოთა მელაძე', '555 201 105', 5 WHERE NOT EXISTS (SELECT 1 FROM public.chefs c WHERE c.name = 'შოთა მელაძე');

-- დასუფთავება
INSERT INTO public.cleaners (name, phone, position_order)
SELECT 'მარინა ვადაჭკორია', '577 939 359', 1 WHERE NOT EXISTS (SELECT 1 FROM public.cleaners c WHERE c.name = 'მარინა ვადაჭკორია');
INSERT INTO public.cleaners (name, phone, position_order)
SELECT 'მზია სოითურქ', '555 958 990', 2 WHERE NOT EXISTS (SELECT 1 FROM public.cleaners c WHERE c.name = 'მზია სოითურქ');
INSERT INTO public.cleaners (name, phone, position_order)
SELECT 'ნათია ჯორბენაძე', '599 279 981', 3 WHERE NOT EXISTS (SELECT 1 FROM public.cleaners c WHERE c.name = 'ნათია ჯორბენაძე');
INSERT INTO public.cleaners (name, phone, position_order)
SELECT 'ლეილა თავართქილაძე', NULL, 4 WHERE NOT EXISTS (SELECT 1 FROM public.cleaners c WHERE c.name = 'ლეილა თავართქილაძე');
INSERT INTO public.cleaners (name, phone, position_order)
SELECT 'გულნაზ ქუთელია', '568 466 565', 5 WHERE NOT EXISTS (SELECT 1 FROM public.cleaners c WHERE c.name = 'გულნაზ ქუთელია');
INSERT INTO public.cleaners (name, phone, position_order)
SELECT 'დარინა ჩიტაძე', '555 210 017', 6 WHERE NOT EXISTS (SELECT 1 FROM public.cleaners c WHERE c.name = 'დარინა ჩიტაძე');

-- ჰოსტესები
INSERT INTO public.hostesses (name, phone, position_order)
SELECT 'მარიამ ხაბაზი', '555 401 101', 1 WHERE NOT EXISTS (SELECT 1 FROM public.hostesses h WHERE h.name = 'მარიამ ხაბაზი');
INSERT INTO public.hostesses (name, phone, position_order)
SELECT 'ანა გაგუა', '555 401 102', 2 WHERE NOT EXISTS (SELECT 1 FROM public.hostesses h WHERE h.name = 'ანა გაგუა');

-- მოლარეები
INSERT INTO public.cashiers (name, phone, position_order)
SELECT 'ლამზირა კოჩალიძე', '555 302 101', 1 WHERE NOT EXISTS (SELECT 1 FROM public.cashiers c WHERE c.name = 'ლამზირა კოჩალიძე');
INSERT INTO public.cashiers (name, phone, position_order)
SELECT 'მადონა სურმანიძე', '555 302 102', 2 WHERE NOT EXISTS (SELECT 1 FROM public.cashiers c WHERE c.name = 'მადონა სურმანიძე');
INSERT INTO public.cashiers (name, phone, position_order)
SELECT 'მარიამ მუფთიშვილი', '555 302 103', 3 WHERE NOT EXISTS (SELECT 1 FROM public.cashiers c WHERE c.name = 'მარიამ მუფთიშვილი');

--
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.team (id, name) VALUES (1, 'Avengers');
INSERT INTO public.team (id, name) VALUES (2, 'Justice League');


--
-- Data for Name: superhero; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.superhero (id, name, team_id) VALUES (1, 'Captain America', 1);
INSERT INTO public.superhero (id, name, team_id) VALUES (2, 'Black Widow', 1);
INSERT INTO public.superhero (id, name, team_id) VALUES (3, 'Batman', 2);
INSERT INTO public.superhero (id, name, team_id) VALUES (4, 'Wonder Woman', 2);


--
-- Name: superhero_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.superhero_id_seq', 4, true);


--
-- Name: team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.team_id_seq', 2, true);

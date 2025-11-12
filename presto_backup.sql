--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (aa1f746)
-- Dumped by pg_dump version 17.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO neondb_owner;

--
-- Name: deposits; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.deposits (
    id integer NOT NULL,
    user_id integer NOT NULL,
    amount double precision NOT NULL,
    status character varying(50),
    date timestamp without time zone
);


ALTER TABLE public.deposits OWNER TO neondb_owner;

--
-- Name: deposits_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.deposits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.deposits_id_seq OWNER TO neondb_owner;

--
-- Name: deposits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.deposits_id_seq OWNED BY public.deposits.id;


--
-- Name: historique; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.historique (
    id integer NOT NULL,
    user_id integer,
    date timestamp without time zone,
    description character varying(255),
    montant double precision,
    type character varying(50),
    status character varying(50),
    solde_apres double precision
);


ALTER TABLE public.historique OWNER TO neondb_owner;

--
-- Name: historique_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.historique_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historique_id_seq OWNER TO neondb_owner;

--
-- Name: historique_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.historique_id_seq OWNED BY public.historique.id;


--
-- Name: investissements; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.investissements (
    id integer NOT NULL,
    user_email character varying(120) NOT NULL,
    nom character varying(100) NOT NULL,
    montant double precision NOT NULL,
    date_debut timestamp without time zone,
    duree_jours integer NOT NULL,
    revenu_quotidien double precision NOT NULL,
    rendement_total double precision NOT NULL,
    status character varying(50),
    last_credit timestamp without time zone
);


ALTER TABLE public.investissements OWNER TO neondb_owner;

--
-- Name: investissements_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.investissements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.investissements_id_seq OWNER TO neondb_owner;

--
-- Name: investissements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.investissements_id_seq OWNED BY public.investissements.id;


--
-- Name: referrals; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.referrals (
    id integer NOT NULL,
    parrain_email character varying(120),
    filleul_email character varying(120),
    date character varying(30)
);


ALTER TABLE public.referrals OWNER TO neondb_owner;

--
-- Name: referrals_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.referrals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.referrals_id_seq OWNER TO neondb_owner;

--
-- Name: referrals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.referrals_id_seq OWNED BY public.referrals.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.transactions (
    id character varying(32) NOT NULL,
    user_email character varying(120) NOT NULL,
    type character varying(100) NOT NULL,
    amount double precision NOT NULL,
    date timestamp without time zone NOT NULL,
    status character varying(50) NOT NULL,
    reference character varying(100),
    sender_phone character varying(20),
    description character varying(255)
);


ALTER TABLE public.transactions OWNER TO neondb_owner;

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transactions_id_seq OWNER TO neondb_owner;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(100),
    email character varying(120) NOT NULL,
    phone character varying(20),
    password character varying(200),
    balance double precision,
    parrain character varying(120),
    withdraw_number character varying(50),
    date_inscription character varying(50),
    has_made_first_deposit boolean,
    last_bonus_date character varying(50)
);


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO neondb_owner;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: withdrawals; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.withdrawals (
    id character varying(64) NOT NULL,
    user_email character varying(120) NOT NULL,
    amount double precision NOT NULL,
    method character varying(50),
    receiver character varying(120),
    status character varying(20),
    "timestamp" timestamp without time zone
);


ALTER TABLE public.withdrawals OWNER TO neondb_owner;

--
-- Name: deposits id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.deposits ALTER COLUMN id SET DEFAULT nextval('public.deposits_id_seq'::regclass);


--
-- Name: historique id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.historique ALTER COLUMN id SET DEFAULT nextval('public.historique_id_seq'::regclass);


--
-- Name: investissements id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.investissements ALTER COLUMN id SET DEFAULT nextval('public.investissements_id_seq'::regclass);


--
-- Name: referrals id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.referrals ALTER COLUMN id SET DEFAULT nextval('public.referrals_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.alembic_version (version_num) FROM stdin;
2c579ca12444
\.


--
-- Data for Name: deposits; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.deposits (id, user_id, amount, status, date) FROM stdin;
\.


--
-- Data for Name: historique; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.historique (id, user_id, date, description, montant, type, status, solde_apres) FROM stdin;
1	6	2025-11-07 23:59:32.400242	Bonus Quotidien réclamé	50	credit	Validé	350
6	1	2025-11-08 05:21:26.668971	Bonus Quotidien réclamé	50	credit	Validé	2981120
13	8	2025-11-08 06:27:54.498366	Bonus Quotidien réclamé	50	credit	Validé	9975350
2	1	2025-11-08 01:56:25.559865	Investissement VIP1 (plan_60_jours)	-3000	credit	réussi	2984070
3	1	2025-11-08 01:56:30.549833	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	credit	En cours	2984070
4	1	2025-11-08 01:57:08.886193	Investissement VIP1 (plan_60_jours)	-3000	credit	réussi	2981070
5	1	2025-11-08 01:57:12.732842	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	credit	En cours	2981070
7	1	2025-11-08 05:22:05.898724	Investissement VIP1 (plan_60_jours)	-3000	credit	réussi	2978120
8	1	2025-11-08 05:22:10.97597	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	credit	En cours	2978120
9	8	2025-11-08 06:11:41.783299	Investissement VIP1 (plan_60_jours)	-3000	credit	réussi	9994300
10	8	2025-11-08 06:11:45.862717	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	credit	En cours	9994300
11	8	2025-11-08 06:17:53.194712	Investissement VIP1 (plan_60_jours)	-3000	credit	réussi	9988300
12	8	2025-11-08 06:17:57.388503	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	credit	En cours	9988300
14	1	2025-11-08 07:47:29.362222	Retrait via Mix by YAS	-9000	debit	En attente	5692691.2
15	1	2025-11-08 07:47:43.170792	Retrait validé (admin)	-10000	debit	validé	5682691.2
16	1	2025-11-08 07:50:13.7635	Retrait via Mix by YAS	-1800	debit	En attente	5680891.2
17	1	2025-11-08 07:57:06.148705	Retrait via Mix by YAS	-1800	debit	En attente	5679091.2
18	1	2025-11-08 07:57:46.532787	Retrait via Mix by YAS	-8100	debit	En attente	5670991.2
19	1	2025-11-08 07:58:34.610492	Investissement VIP: VIP Découverte	-10000	debit	En cours	5660991.2
20	8	2025-11-08 08:49:36.884704	Investissement VIP: VIP Découverte	-10000	debit	En cours	9959350
22	8	2025-11-08 08:54:19.671974	Confirmation de l'investissement VIP1 (plan_60_jours)	-3000	debit	réussi	9956350
23	8	2025-11-08 09:06:49.654998	Confirmation de l'investissement VIP1 (plan_60_jours)	-3000	debit	réussi	9953350
24	8	2025-11-08 09:12:35.25491	Confirmation de l'investissement VIP1 (plan_60_jours)	-3000	debit	réussi	9950350
25	8	2025-11-08 09:12:40.138519	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	9950350
26	8	2025-11-08 09:15:17.211816	Investissement VIP: VIP Découverte	-10000	debit	En cours	9940350
27	8	2025-11-08 09:15:28.937961	Investissement rapide : VIP Mini	-3000	debit	En cours	9937350
28	8	2025-11-08 09:20:35.758165	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	9934350
29	8	2025-11-08 09:20:40.001399	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	9934350
30	9	2025-11-08 10:08:06.855905	Bonus Quotidien réclamé	50	credit	Validé	350
31	2	2025-11-08 10:23:58.811855	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	19990150
32	2	2025-11-08 10:24:03.894377	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	19990150
33	12	2025-11-08 10:32:36.921828	Bonus Quotidien réclamé	50	credit	Validé	350
34	14	2025-11-08 10:42:15.960036	Bonus Quotidien réclamé	50	credit	Validé	350
35	15	2025-11-08 10:56:18.295544	Bonus Quotidien réclamé	50	credit	Validé	350
36	17	2025-11-08 11:39:35.630791	Bonus Quotidien réclamé	50	credit	Validé	350
37	18	2025-11-08 11:45:11.522183	Bonus Quotidien réclamé	50	credit	Validé	350
38	2	2025-11-08 11:48:21.807725	Investissement VIP: VIP Prestige	-500000	debit	En cours	19490150
39	2	2025-11-08 11:48:51.450795	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	18470150
40	2	2025-11-08 11:48:56.154417	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	18470150
41	2	2025-11-08 11:49:56.161789	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	17570150
42	2	2025-11-08 11:50:00.702404	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	17570150
43	2	2025-11-08 11:50:08.689518	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	16670150
44	2	2025-11-08 11:50:13.312985	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	16670150
45	2	2025-11-08 11:51:07.884617	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	15770150
46	2	2025-11-08 11:51:12.848361	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	15770150
47	2	2025-11-08 11:51:24.077794	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	14870150
48	2	2025-11-08 11:51:31.225473	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	14870150
49	2	2025-11-08 11:51:39.495505	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	13970150
50	2	2025-11-08 11:51:44.116424	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	13970150
51	2	2025-11-08 11:51:53.281001	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	13070150
52	2	2025-11-08 11:51:58.07746	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	13070150
53	2	2025-11-08 11:52:06.849421	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	12170150
54	2	2025-11-08 11:52:11.340602	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	12170150
55	2	2025-11-08 11:52:21.823955	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	11270150
56	2	2025-11-08 11:52:26.515313	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	11270150
57	2	2025-11-08 11:52:37.766875	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	10370150
58	2	2025-11-08 11:52:42.374351	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	10370150
59	2	2025-11-08 11:52:49.388984	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	9470150
60	2	2025-11-08 11:52:54.57147	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	9470150
61	2	2025-11-08 11:53:03.166137	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	8570150
62	2	2025-11-08 11:53:07.962005	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	8570150
63	2	2025-11-08 11:53:16.650714	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	7670150
64	2	2025-11-08 11:53:21.376822	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	7670150
65	2	2025-11-08 11:53:35.145446	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	6770150
66	2	2025-11-08 11:53:40.160064	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	6770150
67	2	2025-11-08 11:53:48.720375	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	5870150
68	2	2025-11-08 11:53:53.642035	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	5870150
69	2	2025-11-08 11:54:02.07202	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	4970150
70	2	2025-11-08 11:54:07.240415	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	4970150
71	2	2025-11-08 11:54:15.30951	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	4070150
72	2	2025-11-08 11:54:20.574171	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	4070150
73	2	2025-11-08 11:54:28.361258	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	3170150
74	2	2025-11-08 11:54:33.460648	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	3170150
75	2	2025-11-08 11:54:45.444063	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	2270150
76	2	2025-11-08 11:54:50.523141	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	2270150
77	2	2025-11-08 11:54:57.373396	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	1370150
78	2	2025-11-08 11:55:03.986666	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	1370150
79	2	2025-11-08 11:55:12.253509	Investissement VIP8 (plan_60_jours)	-900000	debit	réussi	470150
80	2	2025-11-08 11:55:18.566829	Confirmation de l'investissement VIP8 (plan_60_jours)	900000	debit	En cours	470150
81	2	2025-11-08 11:55:29.88031	Investissement VIP7 (plan_60_jours)	-300000	debit	réussi	170150
82	2	2025-11-08 11:55:35.09799	Confirmation de l'investissement VIP7 (plan_60_jours)	300000	debit	En cours	170150
83	2	2025-11-08 11:55:59.17174	Investissement VIP5 (plan_60_jours)	-90000	debit	réussi	80150
84	2	2025-11-08 11:56:03.970433	Confirmation de l'investissement VIP5 (plan_60_jours)	90000	debit	En cours	80150
85	22	2025-11-08 12:07:20.84055	Bonus Quotidien réclamé	50	credit	Validé	350
86	2	2025-11-08 12:09:19.216577	Investissement VIP3 (plan_60_jours)	-15000	debit	réussi	65150
87	2	2025-11-08 12:09:25.135734	Confirmation de l'investissement VIP3 (plan_60_jours)	15000	debit	En cours	65150
88	1	2025-11-08 12:16:45.368457	Retrait via Mix by YAS	-14850	debit	En attente	5646141.2
89	26	2025-11-08 12:58:05.470349	Bonus Quotidien réclamé	50	credit	Validé	350
90	27	2025-11-08 13:45:14.641344	Bonus Quotidien réclamé	50	credit	Validé	350
91	28	2025-11-08 14:08:09.110553	Bonus Quotidien réclamé	50	credit	Validé	350
92	29	2025-11-08 14:53:58.181749	Bonus Quotidien réclamé	50	credit	Validé	350
93	31	2025-11-08 16:22:01.996063	Bonus Quotidien réclamé	50	credit	Validé	350
94	32	2025-11-08 16:50:34.530404	Bonus Quotidien réclamé	50	credit	Validé	350
95	37	2025-11-08 17:44:45.514389	Bonus Quotidien réclamé	50	credit	Validé	350
96	38	2025-11-08 17:51:24.723717	Bonus Quotidien réclamé	50	credit	Validé	350
97	41	2025-11-08 19:26:55.20463	Bonus Quotidien réclamé	50	credit	Validé	350
98	43	2025-11-08 20:23:18.212234	Bonus Quotidien réclamé	50	credit	Validé	350
99	45	2025-11-08 20:46:59.361761	Bonus Quotidien réclamé	50	credit	Validé	350
100	46	2025-11-08 21:03:56.948964	Bonus Quotidien réclamé	50	credit	Validé	350
101	14	2025-11-09 06:10:17.659039	Bonus Quotidien réclamé	50	credit	Validé	400
102	1	2025-11-09 10:22:57.003449	Retrait via Mix by YAS	-25200	debit	En attente	5620941.2
103	52	2025-11-09 10:48:31.368387	Bonus Quotidien réclamé	50	credit	Validé	350
104	53	2025-11-09 10:55:46.613116	Bonus Quotidien réclamé	50	credit	Validé	350
105	13	2025-11-09 11:22:55.159073	Bonus Quotidien réclamé	50	credit	Validé	350
106	55	2025-11-09 11:24:44.202354	Bonus Quotidien réclamé	50	credit	Validé	350
107	57	2025-11-09 11:47:04.780938	Bonus Quotidien réclamé	50	credit	Validé	350
108	58	2025-11-09 11:48:20.487378	Bonus Quotidien réclamé	50	credit	Validé	350
109	1	2025-11-09 11:51:13.885548	Retrait validé (admin)	-28000	debit	validé	5592941.2
110	1	2025-11-09 11:51:21.008856	Retrait validé (admin)	-16500	debit	validé	5576441.2
111	1	2025-11-09 11:51:42.494295	Retrait validé (admin)	-2000	debit	validé	5574441.2
112	1	2025-11-09 11:51:44.240963	Retrait validé (admin)	-9000	debit	validé	5565441.2
113	1	2025-11-09 11:51:53.008651	Retrait validé (admin)	-2000	debit	validé	5563441.2
114	59	2025-11-09 11:54:42.741053	Bonus Quotidien réclamé	50	credit	Validé	350
115	2	2025-11-09 12:41:40.5086	Investissement VIP: VIP Découverte	-10000	debit	En cours	40150
116	63	2025-11-09 13:37:48.672531	Bonus Quotidien réclamé	50	credit	Validé	350
117	64	2025-11-09 13:53:19.333781	Bonus Quotidien réclamé	50	credit	Validé	350
118	68	2025-11-09 15:32:59.100967	Bonus Quotidien réclamé	50	credit	Validé	350
119	69	2025-11-09 17:19:29.403063	Bonus Quotidien réclamé	50	credit	Validé	350
120	70	2025-11-09 19:45:29.213813	Bonus Quotidien réclamé	50	credit	Validé	350
121	71	2025-11-09 19:54:56.009276	Bonus Quotidien réclamé	50	credit	Validé	350
122	9	2025-11-09 21:07:08.883235	Bonus Quotidien réclamé	50	credit	Validé	400
123	72	2025-11-09 21:12:56.170017	Bonus Quotidien réclamé	50	credit	Validé	350
124	73	2025-11-10 00:43:34.23571	Bonus Quotidien réclamé	50	credit	Validé	350
125	2	2025-11-10 07:41:08.248256	Bonus Quotidien réclamé	50	credit	Validé	10200
126	13	2025-11-10 07:46:19.105231	Bonus Quotidien réclamé	50	credit	Validé	400
127	1	2025-11-10 08:28:02.613043	Bonus Quotidien réclamé	50	credit	Validé	5563491.2
128	14	2025-11-10 09:07:40.048073	Bonus Quotidien réclamé	50	credit	Validé	450
129	75	2025-11-10 09:42:30.340737	Bonus Quotidien réclamé	50	credit	Validé	350
130	76	2025-11-10 10:12:15.971883	Bonus Quotidien réclamé	50	credit	Validé	350
131	77	2025-11-10 10:33:51.447076	Bonus Quotidien réclamé	50	credit	Validé	350
132	80	2025-11-10 10:36:43.765071	Bonus Quotidien réclamé	50	credit	Validé	350
133	81	2025-11-10 10:39:11.221704	Bonus Quotidien réclamé	50	credit	Validé	350
134	79	2025-11-10 10:43:04.038729	Bonus Quotidien réclamé	50	credit	Validé	350
135	9	2025-11-10 12:29:10.134661	Bonus Quotidien réclamé	50	credit	Validé	450
136	28	2025-11-10 13:03:28.707399	Bonus Quotidien réclamé	50	credit	Validé	400
137	28	2025-11-10 13:12:02.26565	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	400
138	82	2025-11-10 13:21:17.048549	Bonus Quotidien réclamé	50	credit	Validé	350
139	83	2025-11-10 15:02:39.367494	Bonus Quotidien réclamé	50	credit	Validé	350
140	84	2025-11-10 15:07:00.304665	Bonus Quotidien réclamé	50	credit	Validé	350
141	86	2025-11-10 18:01:30.333151	Bonus Quotidien réclamé	50	credit	Validé	350
142	88	2025-11-10 19:03:44.486078	Bonus Quotidien réclamé	50	credit	Validé	350
143	43	2025-11-10 19:21:05.74567	Bonus Quotidien réclamé	50	credit	Validé	400
144	54	2025-11-10 19:30:53.94121	Bonus Quotidien réclamé	50	credit	Validé	350
145	87	2025-11-10 19:53:52.627583	Bonus Quotidien réclamé	50	credit	Validé	350
146	3	2025-11-10 20:05:08.479249	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	13200
147	3	2025-11-10 20:05:14.46631	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	13200
148	89	2025-11-10 20:54:24.249422	Bonus Quotidien réclamé	50	credit	Validé	350
149	90	2025-11-10 21:07:13.247369	Bonus Quotidien réclamé	50	credit	Validé	350
150	93	2025-11-10 21:07:19.832107	Bonus Quotidien réclamé	50	credit	Validé	350
151	97	2025-11-10 21:08:54.780972	Bonus Quotidien réclamé	50	credit	Validé	350
152	92	2025-11-10 21:10:55.919053	Bonus Quotidien réclamé	50	credit	Validé	350
153	98	2025-11-10 21:11:39.277838	Bonus Quotidien réclamé	50	credit	Validé	350
154	99	2025-11-10 21:14:26.801893	Bonus Quotidien réclamé	50	credit	Validé	350
155	100	2025-11-10 21:17:04.073254	Bonus Quotidien réclamé	50	credit	Validé	350
156	102	2025-11-10 21:21:06.859446	Bonus Quotidien réclamé	50	credit	Validé	350
157	91	2025-11-10 21:26:37.515697	Bonus Quotidien réclamé	50	credit	Validé	350
158	105	2025-11-10 21:32:54.73904	Bonus Quotidien réclamé	50	credit	Validé	350
159	106	2025-11-10 21:35:47.477588	Bonus Quotidien réclamé	50	credit	Validé	350
160	109	2025-11-10 21:43:31.917455	Bonus Quotidien réclamé	50	credit	Validé	350
161	110	2025-11-10 21:45:26.413471	Bonus Quotidien réclamé	50	credit	Validé	350
162	104	2025-11-10 21:46:38.091257	Bonus Quotidien réclamé	50	credit	Validé	350
163	113	2025-11-10 22:17:42.219547	Bonus Quotidien réclamé	50	credit	Validé	350
164	108	2025-11-10 22:18:47.903594	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	300
165	114	2025-11-10 22:41:36.895569	Bonus Quotidien réclamé	50	credit	Validé	350
166	1	2025-11-10 22:46:11.397039	Dépôt validé (admin)	3000	dépôt	Validé	5566491.2
167	116	2025-11-10 22:53:16.79716	Bonus Quotidien réclamé	50	credit	Validé	350
168	118	2025-11-10 22:59:50.457884	Bonus Quotidien réclamé	50	credit	Validé	350
169	119	2025-11-10 23:03:09.413885	Bonus Quotidien réclamé	50	credit	Validé	350
170	120	2025-11-10 23:04:20.794835	Bonus Quotidien réclamé	50	credit	Validé	350
171	117	2025-11-10 23:09:08.973242	Bonus Quotidien réclamé	50	credit	Validé	350
172	123	2025-11-10 23:19:03.605788	Bonus Quotidien réclamé	50	credit	Validé	350
173	37	2025-11-10 23:19:08.551873	Bonus Quotidien réclamé	50	credit	Validé	400
174	121	2025-11-10 23:19:52.142609	Bonus Quotidien réclamé	50	credit	Validé	350
175	126	2025-11-10 23:24:19.664299	Bonus Quotidien réclamé	50	credit	Validé	350
176	128	2025-11-10 23:27:31.487264	Bonus Quotidien réclamé	50	credit	Validé	350
177	129	2025-11-10 23:30:30.895311	Bonus Quotidien réclamé	50	credit	Validé	350
178	131	2025-11-10 23:34:15.863009	Bonus Quotidien réclamé	50	credit	Validé	350
179	127	2025-11-10 23:37:53.766271	Bonus Quotidien réclamé	50	credit	Validé	350
180	136	2025-11-10 23:46:22.172925	Bonus Quotidien réclamé	50	credit	Validé	350
181	122	2025-11-10 23:47:06.160418	Bonus Quotidien réclamé	50	credit	Validé	350
182	139	2025-11-11 00:00:56.02157	Bonus Quotidien réclamé	50	credit	Validé	350
183	138	2025-11-11 00:01:16.84371	Bonus Quotidien réclamé	50	credit	Validé	350
184	37	2025-11-11 00:05:24.005898	Bonus Quotidien réclamé	50	credit	Validé	450
185	143	2025-11-11 00:21:20.651172	Bonus Quotidien réclamé	50	credit	Validé	350
186	141	2025-11-11 00:36:25.510683	Bonus Quotidien réclamé	50	credit	Validé	350
187	144	2025-11-11 00:45:51.740345	Bonus Quotidien réclamé	50	credit	Validé	350
188	145	2025-11-11 00:50:56.039294	Bonus Quotidien réclamé	50	credit	Validé	350
189	57	2025-11-11 01:11:09.428854	Bonus Quotidien réclamé	50	credit	Validé	400
190	147	2025-11-11 02:16:11.074223	Bonus Quotidien réclamé	50	credit	Validé	350
191	148	2025-11-11 02:41:24.925956	Bonus Quotidien réclamé	50	credit	Validé	350
192	150	2025-11-11 02:49:04.705742	Bonus Quotidien réclamé	50	credit	Validé	350
193	151	2025-11-11 03:13:24.493622	Bonus Quotidien réclamé	50	credit	Validé	350
194	83	2025-11-11 03:14:37.452405	Bonus Quotidien réclamé	50	credit	Validé	400
195	152	2025-11-11 03:29:01.507079	Bonus Quotidien réclamé	50	credit	Validé	350
196	153	2025-11-11 04:10:44.657831	Bonus Quotidien réclamé	50	credit	Validé	350
197	155	2025-11-11 04:26:28.305436	Bonus Quotidien réclamé	50	credit	Validé	350
198	156	2025-11-11 04:39:05.577246	Bonus Quotidien réclamé	50	credit	Validé	350
199	157	2025-11-11 05:04:36.87409	Bonus Quotidien réclamé	50	credit	Validé	350
200	132	2025-11-11 05:06:37.473644	Bonus Quotidien réclamé	50	credit	Validé	350
201	160	2025-11-11 05:27:10.802269	Bonus Quotidien réclamé	50	credit	Validé	350
202	161	2025-11-11 05:33:57.381224	Bonus Quotidien réclamé	50	credit	Validé	350
203	105	2025-11-11 05:43:19.325709	Bonus Quotidien réclamé	50	credit	Validé	400
204	162	2025-11-11 05:43:29.445523	Bonus Quotidien réclamé	50	credit	Validé	350
205	96	2025-11-11 05:46:17.243477	Bonus Quotidien réclamé	50	credit	Validé	350
206	163	2025-11-11 05:46:47.570378	Bonus Quotidien réclamé	50	credit	Validé	350
207	164	2025-11-11 05:51:48.013082	Bonus Quotidien réclamé	50	credit	Validé	350
208	165	2025-11-11 06:12:07.391941	Bonus Quotidien réclamé	50	credit	Validé	350
209	167	2025-11-11 06:22:09.247637	Bonus Quotidien réclamé	50	credit	Validé	350
210	169	2025-11-11 06:25:37.541046	Bonus Quotidien réclamé	50	credit	Validé	350
211	171	2025-11-11 06:27:33.436538	Bonus Quotidien réclamé	50	credit	Validé	350
212	122	2025-11-11 06:43:55.171415	Bonus Quotidien réclamé	50	credit	Validé	400
213	180	2025-11-11 06:50:10.551881	Bonus Quotidien réclamé	50	credit	Validé	350
214	28	2025-11-11 06:52:16.667801	Bonus Quotidien réclamé	50	credit	Validé	450
215	184	2025-11-11 06:52:32.973492	Bonus Quotidien réclamé	50	credit	Validé	350
216	118	2025-11-11 06:56:00.956596	Bonus Quotidien réclamé	50	credit	Validé	400
217	17	2025-11-11 07:15:28.935744	Bonus Quotidien réclamé	50	credit	Validé	400
218	18	2025-11-11 07:16:00.203151	Bonus Quotidien réclamé	50	credit	Validé	400
219	191	2025-11-11 07:22:02.317117	Bonus Quotidien réclamé	50	credit	Validé	350
220	193	2025-11-11 07:27:24.434205	Bonus Quotidien réclamé	50	credit	Validé	350
221	109	2025-11-11 07:30:15.536576	Bonus Quotidien réclamé	50	credit	Validé	400
222	93	2025-11-11 07:37:35.063793	Bonus Quotidien réclamé	50	credit	Validé	400
223	136	2025-11-11 07:42:49.765309	Bonus Quotidien réclamé	50	credit	Validé	400
224	194	2025-11-11 07:44:40.239163	Bonus Quotidien réclamé	50	credit	Validé	350
225	196	2025-11-11 07:51:28.903492	Bonus Quotidien réclamé	50	credit	Validé	350
226	87	2025-11-11 07:55:07.755527	Bonus Quotidien réclamé	50	credit	Validé	400
227	195	2025-11-11 07:57:28.878564	Bonus Quotidien réclamé	50	credit	Validé	350
228	89	2025-11-11 08:00:14.47595	Bonus Quotidien réclamé	50	credit	Validé	400
229	200	2025-11-11 08:02:15.107869	Bonus Quotidien réclamé	50	credit	Validé	350
230	201	2025-11-11 08:05:58.27124	Bonus Quotidien réclamé	50	credit	Validé	350
231	100	2025-11-11 08:06:20.929446	Bonus Quotidien réclamé	50	credit	Validé	400
232	202	2025-11-11 08:12:33.88844	Bonus Quotidien réclamé	50	credit	Validé	350
233	203	2025-11-11 08:12:47.247583	Bonus Quotidien réclamé	50	credit	Validé	350
234	204	2025-11-11 08:14:35.740854	Bonus Quotidien réclamé	50	credit	Validé	350
235	136	2025-11-11 08:15:03.086637	Investissement VIP3 (plan_60_jours)	-15000	debit	réussi	400
236	89	2025-11-11 08:15:43.180604	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	4900
237	89	2025-11-11 08:16:13.609798	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	4900
238	153	2025-11-11 08:19:45.217648	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	350
239	153	2025-11-11 08:19:55.707359	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	350
240	92	2025-11-11 08:23:44.747116	Bonus Quotidien réclamé	50	credit	Validé	400
241	128	2025-11-11 08:26:18.868349	Bonus Quotidien réclamé	50	credit	Validé	400
242	174	2025-11-11 08:29:41.392177	Bonus Quotidien réclamé	50	credit	Validé	350
243	14	2025-11-11 08:36:08.520454	Bonus Quotidien réclamé	50	credit	Validé	500
244	207	2025-11-11 08:42:05.538299	Bonus Quotidien réclamé	50	credit	Validé	350
245	153	2025-11-11 08:44:13.423615	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	350
246	153	2025-11-11 08:44:21.24629	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
247	153	2025-11-11 08:44:23.341816	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
248	153	2025-11-11 08:44:24.04668	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
249	112	2025-11-11 08:53:05.073491	Bonus Quotidien réclamé	50	credit	Validé	350
250	209	2025-11-11 08:59:24.251892	Bonus Quotidien réclamé	50	credit	Validé	350
251	112	2025-11-11 09:19:18.570584	Investissement VIP3 (plan_60_jours)	-15000	debit	réussi	350
252	112	2025-11-11 09:19:37.328334	Confirmation de l'investissement VIP3 (plan_60_jours)	15000	debit	En cours	350
253	126	2025-11-11 09:29:00.728351	Bonus Quotidien réclamé	50	credit	Validé	400
254	104	2025-11-11 09:35:24.594403	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	350
255	104	2025-11-11 09:36:23.834225	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
256	104	2025-11-11 09:36:25.903317	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
257	104	2025-11-11 09:36:27.092353	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
258	126	2025-11-11 09:36:38.350925	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	400
259	126	2025-11-11 09:36:58.644338	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	400
260	104	2025-11-11 09:39:40.461781	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
261	104	2025-11-11 09:39:41.35735	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
262	104	2025-11-11 09:41:24.240765	Bonus Quotidien réclamé	50	credit	Validé	400
263	213	2025-11-11 10:00:40.02771	Bonus Quotidien réclamé	50	credit	Validé	350
264	174	2025-11-11 10:06:45.975613	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	350
265	174	2025-11-11 10:08:09.753836	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
266	151	2025-11-11 10:46:05.723333	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	350
267	54	2025-11-11 11:00:45.630414	Bonus Quotidien réclamé	50	credit	Validé	3100
268	54	2025-11-11 11:02:06.399789	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	100
269	2	2025-11-11 11:40:07.980418	Bonus Quotidien réclamé	50	credit	Validé	17250
270	1	2025-11-11 11:48:19.536862	Retrait via Mix by YAS	-3600	debit	En attente	5562891.2
271	1	2025-11-11 11:49:33.727991	Retrait validé (admin)	-4000	debit	validé	5558891.2
272	97	2025-11-11 12:02:31.473264	Bonus Quotidien réclamé	50	credit	Validé	400
273	116	2025-11-11 12:13:00.217565	Bonus Quotidien réclamé	50	credit	Validé	400
274	89	2025-11-11 12:13:04.738837	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	4900
275	89	2025-11-11 12:13:09.853459	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	4900
276	89	2025-11-11 12:25:48.288547	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	1900
277	89	2025-11-11 12:25:56.678046	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	1900
278	223	2025-11-11 12:37:00.910381	Bonus Quotidien réclamé	50	credit	Validé	350
279	219	2025-11-11 12:39:10.097013	Investissement VIP4 (plan_60_jours)	-30000	debit	réussi	300
280	219	2025-11-11 12:39:21.717718	Confirmation de l'investissement VIP4 (plan_60_jours)	30000	debit	En cours	300
281	162	2025-11-11 12:51:24.663545	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	350
282	162	2025-11-11 12:51:38.61826	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
283	218	2025-11-11 13:23:24.294639	Investissement Rapide - VIP Mini (5 jours)	-3000	Débit	En cours	7300
284	218	2025-11-11 13:23:30.626275	Investissement Rapide - VIP Mini (5 jours)	-3000	Débit	En cours	4300
285	185	2025-11-11 15:05:51.27048	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	1300
286	185	2025-11-11 15:06:02.246253	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	1300
287	98	2025-11-11 15:51:11.112484	Bonus Quotidien réclamé	50	credit	Validé	400
288	9	2025-11-11 16:05:12.796955	Bonus Quotidien réclamé	50	credit	Validé	500
289	75	2025-11-11 16:05:46.431114	Bonus Quotidien réclamé	50	credit	Validé	400
290	230	2025-11-11 16:08:34.676827	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	7300
291	2	2025-11-11 16:20:04.997702	Investissement Rapide - VIP Pro (5 jours)	-15000	Débit	En cours	5250
292	237	2025-11-11 17:27:34.027623	Bonus inscription	300	Crédit	Credité	300
293	238	2025-11-11 17:29:21.706591	Bonus inscription	300	Crédit	Credité	300
294	239	2025-11-11 17:30:27.637842	Bonus inscription	300	Crédit	Credité	300
295	240	2025-11-11 17:30:39.787263	Bonus inscription	300	Crédit	Credité	300
296	241	2025-11-11 17:33:25.406783	Bonus inscription	300	Crédit	Credité	300
297	242	2025-11-11 17:34:50.817339	Bonus inscription	300	Crédit	Credité	300
298	243	2025-11-11 17:35:14.169768	Bonus inscription	300	Crédit	Credité	300
299	240	2025-11-11 17:35:17.96149	Bonus Quotidien réclamé	50	credit	Validé	350
300	244	2025-11-11 17:35:36.515792	Bonus inscription	300	Crédit	Credité	300
301	237	2025-11-11 17:36:28.043255	Bonus Quotidien réclamé	50	credit	Validé	350
302	245	2025-11-11 17:36:55.501719	Bonus inscription	300	Crédit	Credité	300
303	245	2025-11-11 17:37:24.709446	Bonus Quotidien réclamé	50	credit	Validé	350
304	246	2025-11-11 17:38:03.863162	Bonus inscription	300	Crédit	Credité	300
305	246	2025-11-11 17:43:30.457839	Bonus Quotidien réclamé	50	credit	Validé	350
306	247	2025-11-11 17:44:39.48374	Bonus inscription	300	Crédit	Credité	300
307	247	2025-11-11 17:45:53.247633	Bonus Quotidien réclamé	50	credit	Validé	350
308	248	2025-11-11 17:51:35.07861	Bonus inscription	300	Crédit	Credité	300
309	249	2025-11-11 17:56:35.311839	Bonus inscription	300	Crédit	Credité	300
310	250	2025-11-11 17:57:57.599444	Bonus inscription	300	Crédit	Credité	300
311	87	2025-11-11 18:00:16.513999	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	400
312	251	2025-11-11 18:04:05.533602	Bonus inscription	300	Crédit	Credité	300
313	252	2025-11-11 18:04:48.605923	Bonus inscription	300	Crédit	Credité	300
314	253	2025-11-11 18:07:59.282554	Bonus inscription	300	Crédit	Credité	300
315	230	2025-11-11 18:17:01.921262	Bonus Quotidien réclamé	50	credit	Validé	7350
316	254	2025-11-11 18:17:41.376883	Bonus inscription	300	Crédit	Credité	300
317	255	2025-11-11 18:18:41.422027	Bonus inscription	300	Crédit	Credité	300
318	256	2025-11-11 18:18:54.912065	Bonus inscription	300	Crédit	Credité	300
319	255	2025-11-11 18:19:06.91696	Bonus Quotidien réclamé	50	credit	Validé	350
320	257	2025-11-11 18:23:51.179367	Bonus inscription	300	Crédit	Credité	300
321	257	2025-11-11 18:26:57.537913	Bonus Quotidien réclamé	50	credit	Validé	350
322	258	2025-11-11 18:26:59.101043	Bonus inscription	300	Crédit	Credité	300
323	259	2025-11-11 18:31:37.048594	Bonus inscription	300	Crédit	Credité	300
324	260	2025-11-11 18:32:30.095564	Bonus inscription	300	Crédit	Credité	300
325	261	2025-11-11 18:33:48.042689	Bonus inscription	300	Crédit	Credité	300
326	262	2025-11-11 18:37:09.535293	Bonus inscription	300	Crédit	Credité	300
327	231	2025-11-11 18:37:55.85866	Bonus Quotidien réclamé	50	credit	Validé	350
328	253	2025-11-11 18:38:31.543053	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	1300
329	215	2025-11-11 18:49:34.548257	Bonus Quotidien réclamé	50	credit	Validé	30350
330	215	2025-11-11 18:50:08.850446	Investissement VIP4 (plan_60_jours)	-30000	debit	réussi	350
331	215	2025-11-11 18:50:33.37378	Confirmation de l'investissement VIP4 (plan_60_jours)	30000	debit	En cours	350
332	258	2025-11-11 18:51:10.554352	Bonus Quotidien réclamé	50	credit	Validé	350
333	162	2025-11-11 18:53:32.516175	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	350
334	162	2025-11-11 18:53:41.066663	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
335	263	2025-11-11 18:55:02.988651	Bonus inscription	300	Crédit	Credité	300
336	264	2025-11-11 18:58:36.542771	Bonus inscription	300	Crédit	Credité	300
337	263	2025-11-11 18:59:51.015625	Bonus Quotidien réclamé	50	credit	Validé	350
338	265	2025-11-11 18:59:56.633479	Bonus inscription	300	Crédit	Credité	300
339	266	2025-11-11 19:00:00.048764	Bonus inscription	300	Crédit	Credité	300
340	267	2025-11-11 19:00:48.24447	Bonus inscription	300	Crédit	Credité	300
341	268	2025-11-11 19:00:52.464317	Bonus inscription	300	Crédit	Credité	300
342	268	2025-11-11 19:02:57.18805	Bonus Quotidien réclamé	50	credit	Validé	350
343	43	2025-11-11 19:03:38.22301	Bonus Quotidien réclamé	50	credit	Validé	450
344	269	2025-11-11 19:04:28.816967	Bonus inscription	300	Crédit	Credité	300
345	270	2025-11-11 19:05:54.133222	Bonus inscription	300	Crédit	Credité	300
346	271	2025-11-11 19:09:04.365004	Bonus inscription	300	Crédit	Credité	300
347	272	2025-11-11 19:09:39.531702	Bonus inscription	300	Crédit	Credité	300
348	273	2025-11-11 19:12:16.071429	Bonus inscription	300	Crédit	Credité	300
349	274	2025-11-11 19:12:38.13044	Bonus inscription	300	Crédit	Credité	300
350	275	2025-11-11 19:13:20.470832	Bonus inscription	300	Crédit	Credité	300
351	276	2025-11-11 19:13:50.546616	Bonus inscription	300	Crédit	Credité	300
352	277	2025-11-11 19:13:59.184368	Bonus inscription	300	Crédit	Credité	300
353	278	2025-11-11 19:17:08.043328	Bonus inscription	300	Crédit	Credité	300
354	258	2025-11-11 19:18:46.834822	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	1350
355	279	2025-11-11 19:19:13.150208	Bonus inscription	300	Crédit	Credité	300
356	265	2025-11-11 19:19:35.008431	Bonus Quotidien réclamé	50	credit	Validé	350
357	280	2025-11-11 19:24:02.417575	Bonus inscription	300	Crédit	Credité	300
358	137	2025-11-11 19:26:58.270025	Bonus Quotidien réclamé	50	credit	Validé	350
359	281	2025-11-11 19:27:21.16743	Bonus inscription	300	Crédit	Credité	300
360	282	2025-11-11 19:28:23.645171	Bonus inscription	300	Crédit	Credité	300
361	283	2025-11-11 19:31:49.228629	Bonus inscription	300	Crédit	Credité	300
362	284	2025-11-11 19:32:05.200061	Bonus inscription	300	Crédit	Credité	300
363	284	2025-11-11 19:33:59.00999	Bonus Quotidien réclamé	50	credit	Validé	350
364	283	2025-11-11 19:34:27.903459	Bonus Quotidien réclamé	50	credit	Validé	350
365	285	2025-11-11 19:35:38.94529	Bonus inscription	300	Crédit	Credité	300
366	286	2025-11-11 19:36:20.453166	Bonus inscription	300	Crédit	Credité	300
367	287	2025-11-11 19:41:32.368195	Bonus inscription	300	Crédit	Credité	300
368	288	2025-11-11 19:45:46.420513	Bonus inscription	300	Crédit	Credité	300
369	289	2025-11-11 19:47:11.437046	Bonus inscription	300	Crédit	Credité	300
370	287	2025-11-11 19:47:36.080657	Bonus Quotidien réclamé	50	credit	Validé	350
371	289	2025-11-11 19:48:37.954494	Bonus Quotidien réclamé	50	credit	Validé	350
372	290	2025-11-11 19:49:03.064488	Bonus inscription	300	Crédit	Credité	300
373	291	2025-11-11 19:49:26.734651	Bonus inscription	300	Crédit	Credité	300
374	292	2025-11-11 19:53:58.643824	Bonus inscription	300	Crédit	Credité	300
375	293	2025-11-11 19:57:38.508964	Bonus inscription	300	Crédit	Credité	300
376	294	2025-11-11 19:58:25.547701	Bonus inscription	300	Crédit	Credité	300
377	295	2025-11-11 19:59:57.599601	Bonus inscription	300	Crédit	Credité	300
378	98	2025-11-11 20:01:50.425497	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	400
379	98	2025-11-11 20:02:25.608667	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	400
380	288	2025-11-11 20:03:02.957808	Bonus Quotidien réclamé	50	credit	Validé	350
381	295	2025-11-11 20:03:32.241889	Bonus Quotidien réclamé	50	credit	Validé	350
382	292	2025-11-11 20:05:13.588692	Investissement VIP4 (plan_60_jours)	-30000	debit	réussi	300
383	292	2025-11-11 20:05:25.703624	Confirmation de l'investissement VIP4 (plan_60_jours)	30000	debit	En cours	300
384	162	2025-11-11 20:06:50.467039	Investissement VIP2 (plan_60_jours)	-9000	debit	réussi	350
385	162	2025-11-11 20:07:00.007234	Confirmation de l'investissement VIP2 (plan_60_jours)	9000	debit	En cours	350
386	296	2025-11-11 20:07:30.274681	Bonus inscription	300	Crédit	Credité	300
387	297	2025-11-11 20:14:59.268851	Bonus inscription	300	Crédit	Credité	300
388	298	2025-11-11 20:26:10.941015	Bonus inscription	300	Crédit	Credité	300
389	299	2025-11-11 20:28:02.371664	Bonus inscription	300	Crédit	Credité	300
390	300	2025-11-11 20:28:23.303729	Bonus inscription	300	Crédit	Credité	300
391	301	2025-11-11 20:29:16.791924	Bonus inscription	300	Crédit	Credité	300
392	302	2025-11-11 20:29:39.331753	Bonus inscription	300	Crédit	Credité	300
393	303	2025-11-11 20:30:04.122225	Bonus inscription	300	Crédit	Credité	300
394	108	2025-11-11 20:33:22.572698	Bonus Quotidien réclamé	50	credit	Validé	350
395	292	2025-11-11 20:39:19.695091	Bonus Quotidien réclamé	50	credit	Validé	350
396	304	2025-11-11 20:40:10.760219	Bonus inscription	300	Crédit	Credité	300
397	304	2025-11-11 20:41:15.299846	Bonus Quotidien réclamé	50	credit	Validé	350
398	305	2025-11-11 20:51:07.326371	Bonus inscription	300	Crédit	Credité	300
399	306	2025-11-11 20:52:12.198689	Bonus inscription	300	Crédit	Credité	300
400	307	2025-11-11 21:03:45.444514	Bonus inscription	300	Crédit	Credité	300
401	308	2025-11-11 21:10:03.924474	Bonus inscription	300	Crédit	Credité	300
402	309	2025-11-11 21:12:01.093666	Bonus inscription	300	Crédit	Credité	300
403	310	2025-11-11 21:20:16.560049	Bonus inscription	300	Crédit	Credité	300
404	311	2025-11-11 21:22:19.232154	Bonus inscription	300	Crédit	Credité	300
405	310	2025-11-11 21:24:45.16172	Bonus Quotidien réclamé	50	credit	Validé	350
406	273	2025-11-11 21:25:26.229396	Bonus Quotidien réclamé	50	credit	Validé	350
407	131	2025-11-11 21:33:54.689277	Bonus Quotidien réclamé	50	credit	Validé	400
408	312	2025-11-11 21:41:39.468778	Bonus inscription	300	Crédit	Credité	300
409	313	2025-11-11 21:42:14.491597	Bonus inscription	300	Crédit	Credité	300
410	314	2025-11-11 21:47:34.880343	Bonus inscription	300	Crédit	Credité	300
411	308	2025-11-11 21:50:37.91194	Bonus Quotidien réclamé	50	credit	Validé	350
412	308	2025-11-11 21:58:48.204934	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	350
413	308	2025-11-11 21:59:05.235871	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	350
414	131	2025-11-11 22:02:00.689507	Investissement VIP1 (plan_60_jours)	-3000	debit	réussi	1300
415	131	2025-11-11 22:02:19.951118	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	1300
416	131	2025-11-11 22:03:00.560583	Confirmation de l'investissement VIP1 (plan_60_jours)	3000	debit	En cours	1300
417	315	2025-11-11 22:27:27.687416	Bonus inscription	300	Crédit	Credité	300
418	316	2025-11-11 22:37:58.094146	Bonus inscription	300	Crédit	Credité	300
419	317	2025-11-11 22:41:12.683356	Bonus inscription	300	Crédit	Credité	300
420	1	2025-11-11 22:43:12.987954	Retrait via Mix by YAS	-3600	debit	En attente	5555291.2
421	1	2025-11-11 22:43:46.716004	Retrait via Mix by YAS	-4500	debit	En attente	5550791.2
422	79	2025-11-11 22:44:24.19136	Bonus Quotidien réclamé	50	credit	Validé	400
423	1	2025-11-11 22:49:06.409425	Retrait via Mix by YAS	-7011.9	debit	En attente	5543779.3
424	318	2025-11-11 22:51:18.255335	Bonus inscription	300	Crédit	Credité	300
425	319	2025-11-11 22:51:54.106574	Bonus inscription	300	Crédit	Credité	300
426	320	2025-11-11 22:58:08.324593	Bonus inscription	300	Crédit	Credité	300
427	319	2025-11-11 23:00:14.326003	Bonus Quotidien réclamé	50	credit	Validé	350
428	168	2025-11-11 23:09:01.771115	Bonus Quotidien réclamé	50	credit	Validé	350
429	318	2025-11-11 23:09:25.65067	Bonus Quotidien réclamé	50	credit	Validé	350
430	321	2025-11-11 23:11:02.098583	Bonus inscription	300	Crédit	Credité	300
431	321	2025-11-11 23:14:15.379622	Bonus Quotidien réclamé	50	credit	Validé	350
432	322	2025-11-11 23:15:38.058183	Bonus inscription	300	Crédit	Credité	300
433	323	2025-11-11 23:20:07.770571	Bonus inscription	300	Crédit	Credité	300
434	323	2025-11-11 23:20:29.780755	Bonus Quotidien réclamé	50	credit	Validé	350
435	324	2025-11-11 23:20:57.853602	Bonus inscription	300	Crédit	Credité	300
436	133	2025-11-11 23:26:00.30898	Bonus Quotidien réclamé	50	credit	Validé	350
437	325	2025-11-11 23:37:18.370959	Bonus inscription	300	Crédit	Credité	300
438	325	2025-11-11 23:39:07.795672	Bonus Quotidien réclamé	50	credit	Validé	350
439	326	2025-11-11 23:44:26.07437	Bonus inscription	300	Crédit	Credité	300
440	327	2025-11-11 23:45:29.999164	Bonus inscription	300	Crédit	Credité	300
441	326	2025-11-11 23:57:05.257369	Bonus Quotidien réclamé	50	credit	Validé	350
442	328	2025-11-12 00:10:58.628757	Bonus inscription	300	Crédit	Credité	300
443	327	2025-11-12 00:14:24.168096	Bonus Quotidien réclamé	50	credit	Validé	350
444	326	2025-11-12 00:18:57.911757	Bonus Quotidien réclamé	50	credit	Validé	400
445	329	2025-11-12 00:19:00.077557	Bonus inscription	300	Crédit	Credité	300
446	132	2025-11-12 00:19:13.172255	Bonus Quotidien réclamé	50	credit	Validé	400
447	330	2025-11-12 00:52:43.662052	Bonus inscription	300	Crédit	Credité	300
448	330	2025-11-12 00:56:11.306471	Bonus Quotidien réclamé	50	credit	Validé	350
449	104	2025-11-12 01:07:54.769346	Bonus Quotidien réclamé	50	credit	Validé	450
450	331	2025-11-12 01:21:07.458739	Bonus inscription	300	Crédit	Credité	300
451	331	2025-11-12 01:23:37.221417	Bonus Quotidien réclamé	50	credit	Validé	350
452	332	2025-11-12 02:59:07.830807	Bonus inscription	300	Crédit	Credité	300
453	332	2025-11-12 03:01:00.796988	Bonus Quotidien réclamé	50	credit	Validé	350
454	83	2025-11-12 03:05:52.71878	Bonus Quotidien réclamé	50	credit	Validé	450
455	333	2025-11-12 04:37:48.008179	Bonus inscription	300	Crédit	Credité	300
456	204	2025-11-12 04:46:50.280109	Bonus Quotidien réclamé	50	credit	Validé	400
457	334	2025-11-12 05:21:31.227699	Bonus inscription	300	Crédit	Credité	300
458	98	2025-11-12 05:33:14.312715	Bonus Quotidien réclamé	50	credit	Validé	450
459	168	2025-11-12 05:44:36.27156	Bonus Quotidien réclamé	50	credit	Validé	400
460	335	2025-11-12 05:46:27.116043	Bonus inscription	300	Crédit	Credité	300
461	314	2025-11-12 05:57:58.748501	Bonus Quotidien réclamé	50	credit	Validé	350
462	161	2025-11-12 06:07:40.560195	Bonus Quotidien réclamé	50	credit	Validé	400
463	319	2025-11-12 06:08:48.222357	Bonus Quotidien réclamé	50	credit	Validé	400
464	112	2025-11-12 06:11:52.080641	Bonus Quotidien réclamé	50	credit	Validé	400
465	336	2025-11-12 06:19:04.714573	Bonus inscription	300	Crédit	Credité	300
466	336	2025-11-12 06:21:10.036172	Bonus Quotidien réclamé	50	credit	Validé	350
467	73	2025-11-12 06:21:33.204668	Bonus Quotidien réclamé	50	credit	Validé	400
468	337	2025-11-12 06:45:27.164829	Bonus inscription	300	Crédit	Credité	300
469	337	2025-11-12 06:45:45.008778	Bonus Quotidien réclamé	50	credit	Validé	350
470	338	2025-11-12 06:57:27.385758	Bonus inscription	300	Crédit	Credité	300
471	153	2025-11-12 07:01:19.874027	Bonus Quotidien réclamé	50	credit	Validé	400
472	153	2025-11-12 07:17:52.302866	Investissement VIP3 (plan_60_jours)	-15000	debit	réussi	400
473	153	2025-11-12 07:18:02.523702	Confirmation de l'investissement VIP3 (plan_60_jours)	15000	debit	En cours	400
474	265	2025-11-12 07:22:51.126272	Bonus Quotidien réclamé	50	credit	Validé	400
475	328	2025-11-12 07:27:30.395583	Bonus Quotidien réclamé	50	credit	Validé	350
476	87	2025-11-12 07:41:23.281904	Bonus Quotidien réclamé	50	credit	Validé	450
477	339	2025-11-12 07:42:47.772858	Bonus inscription	300	Crédit	Credité	300
478	339	2025-11-12 07:44:23.613032	Bonus Quotidien réclamé	50	credit	Validé	350
479	151	2025-11-12 07:48:30.671203	Bonus Quotidien réclamé	50	credit	Validé	400
\.


--
-- Data for Name: investissements; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.investissements (id, user_email, nom, montant, date_debut, duree_jours, revenu_quotidien, rendement_total, status, last_credit) FROM stdin;
1	prestocashfinance@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-08 08:54:19.671372	60	600	36000	En cours	\N
2	prestocashfinance@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-08 09:06:49.654395	60	600	36000	En cours	\N
3	prestocashfinance@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-08 09:12:35.254173	60	600	36000	En cours	\N
4	prestocashfinance@gmail.com	VIP Découverte	10000	2025-11-08 09:15:17.210112	21	0	33600	En cours	\N
5	prestocashfinance@gmail.com	VIP Mini	3000	2025-11-08 09:15:28.937199	3	1800	5400	En cours	\N
6	prestocashfinance@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-08 09:20:35.757706	60	600	36000	En cours	\N
7	1xthom14@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-08 10:23:58.811653	60	600	36000	En cours	\N
8	1xthom14@gmail.com	VIP Prestige	500000	2025-11-08 11:48:21.807582	21	0	1050000	En cours	\N
9	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:48:51.450681	60	180000	10800000	En cours	\N
10	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:49:56.161655	60	180000	10800000	En cours	\N
11	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:50:08.689386	60	180000	10800000	En cours	\N
12	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:51:07.884476	60	180000	10800000	En cours	\N
13	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:51:24.077677	60	180000	10800000	En cours	\N
14	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:51:39.495387	60	180000	10800000	En cours	\N
15	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:51:53.280892	60	180000	10800000	En cours	\N
16	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:52:06.849281	60	180000	10800000	En cours	\N
17	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:52:21.823809	60	180000	10800000	En cours	\N
18	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:52:37.766757	60	180000	10800000	En cours	\N
19	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:52:49.388833	60	180000	10800000	En cours	\N
20	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:53:03.166012	60	180000	10800000	En cours	\N
21	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:53:16.650588	60	180000	10800000	En cours	\N
22	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:53:35.145319	60	180000	10800000	En cours	\N
23	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:53:48.720212	60	180000	10800000	En cours	\N
24	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:54:02.071853	60	180000	10800000	En cours	\N
25	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:54:15.309385	60	180000	10800000	En cours	\N
26	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:54:28.361115	60	180000	10800000	En cours	\N
27	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:54:45.443947	60	180000	10800000	En cours	\N
28	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:54:57.373291	60	180000	10800000	En cours	\N
29	1xthom14@gmail.com	VIP8 (plan_60_jours)	900000	2025-11-08 11:55:12.253397	60	180000	10800000	En cours	\N
30	1xthom14@gmail.com	VIP7 (plan_60_jours)	300000	2025-11-08 11:55:29.88017	60	60000	3600000	En cours	\N
31	1xthom14@gmail.com	VIP5 (plan_60_jours)	90000	2025-11-08 11:55:59.171596	60	18000	1080000	En cours	\N
32	1xthom14@gmail.com	VIP3 (plan_60_jours)	15000	2025-11-08 12:09:19.216471	60	3000	180000	En cours	\N
33	1xthom14@gmail.com	VIP Découverte	10000	2025-11-09 12:41:40.50844	21	0	33600	En cours	\N
34	kombwoyofficiel1@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-10 13:12:02.265482	60	600	36000	En cours	\N
35	prestocashfinance1@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-10 20:05:08.479075	60	600	36000	En cours	\N
36	agbegniganfrederic@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-10 22:18:47.903442	60	600	36000	En cours	\N
37	sophieyelihani@gmail.com	VIP3 (plan_60_jours)	15000	2025-11-11 08:15:03.086425	60	3000	180000	En cours	\N
38	bassoprofesseur@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 08:15:43.180417	60	1800	108000	En cours	\N
39	ddjau420@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 08:19:45.217509	60	600	36000	En cours	\N
40	ddjau420@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 08:44:13.423509	60	1800	108000	En cours	\N
41	stephanieadjogah924@gmail.com	VIP3 (plan_60_jours)	15000	2025-11-11 09:19:18.570266	60	3000	180000	En cours	\N
42	tinafaou228@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 09:35:24.594225	60	1800	108000	En cours	\N
43	tairoumamah3@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 09:36:38.350779	60	600	36000	En cours	\N
44	tsathokossididier1@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 10:06:45.975397	60	1800	108000	En cours	\N
45	bienvenueamen@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 10:46:05.723016	60	600	36000	En cours	\N
46	delphinyao2@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 11:02:06.399591	60	600	36000	En cours	\N
47	bassoprofesseur@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 12:13:04.738646	60	1800	108000	En cours	\N
48	bassoprofesseur@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 12:25:48.28842	60	600	36000	En cours	\N
49	assouagbehonouassouh0@gmail.com	VIP4 (plan_60_jours)	30000	2025-11-11 12:39:10.096904	60	6000	360000	En cours	\N
50	guykondo92@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 12:51:24.663338	60	1800	108000	En cours	\N
51	azokolo1@gmail.com	VIP Mini	3000	2025-11-11 13:23:24.292922	5	1080	5400	En cours	\N
52	azokolo1@gmail.com	VIP Mini	3000	2025-11-11 13:23:30.625649	5	1080	5400	En cours	\N
53	kenkorodriguez7@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 15:05:51.270269	60	1800	108000	En cours	\N
54	zerboelie281@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 16:08:34.676543	60	600	36000	En cours	\N
55	1xthom14@gmail.com	VIP Pro	15000	2025-11-11 16:20:04.997457	5	5400	27000	En cours	\N
56	waitybns@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 18:00:16.513868	60	600	36000	En cours	\N
57	dongmocristabelle6@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 18:38:31.542944	60	1800	108000	En cours	\N
58	amousunday16@gmail.com	VIP4 (plan_60_jours)	30000	2025-11-11 18:50:08.850344	60	6000	360000	En cours	\N
59	guykondo92@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 18:53:32.516076	60	1800	108000	En cours	\N
60	marieedoh@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 19:18:46.834688	60	1800	108000	En cours	\N
61	sodahlonprosper99@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 20:01:50.425401	60	600	36000	En cours	\N
62	messanhmawugna@gmail.com	VIP4 (plan_60_jours)	30000	2025-11-11 20:05:13.588584	60	6000	360000	En cours	\N
63	guykondo92@gmail.com	VIP2 (plan_60_jours)	9000	2025-11-11 20:06:50.466895	60	1800	108000	En cours	\N
64	bebekeizen@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 21:58:48.204831	60	600	36000	En cours	\N
65	kokouivesahadji12@gmail.com	VIP1 (plan_60_jours)	3000	2025-11-11 22:02:00.689374	60	600	36000	En cours	\N
66	ddjau420@gmail.com	VIP3 (plan_60_jours)	15000	2025-11-12 07:17:52.30269	60	3000	180000	En cours	\N
\.


--
-- Data for Name: referrals; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.referrals (id, parrain_email, filleul_email, date) FROM stdin;
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.transactions (id, user_email, type, amount, date, status, reference, sender_phone, description) FROM stdin;
6577527a06244a64a9f2c86ecd438755	1xthom14@gmail.com	Dépôt via xof	10000000	2025-11-08 01:35:05	accepted	293538658121	71339325	\N
25884180ad66429cb9d5172d463d74b3	prestocashfinance@gmail.com	Dépôt via xof	10000000	2025-11-08 05:38:41	accepted	198495282001	71339325	\N
ad6ac3603512443f815bd7cf87eb80c2	prestocashfinance@gmail.com	Investissement rapide : VIP Mini	-3000	2025-11-08 06:03:04.510031	En cours	\N	\N	\N
b70eaff1154a45d38b9599e2d0c70407	prestocashfinance@gmail.com	Investissement rapide : VIP Mini	-3000	2025-11-08 06:11:58.444252	En cours	\N	\N	\N
c8b01dbabe084fa19d6ce848e79badad	prestocashfinance@gmail.com	Investissement rapide : VIP Mini	-3000	2025-11-08 06:18:25.625474	En cours	\N	\N	\N
bd5d8ec4f6074f66aca0822aee87fc5b	prestocashfinance@gmail.com	Investissement rapide : VIP Mini	-3000	2025-11-08 06:28:52.856207	En cours	\N	\N	\N
6a21122a02c2427283ed56ab2a556b7b	prestocashfinance@gmail.com	Investissement rapide : VIP Mini	-3000	2025-11-08 08:49:08.713399	En cours	\N	\N	\N
14c9c3e86e354d0cbb288a7b7ca70d47	ameket5@gmail.com	Dépôt via euro	10000	2025-11-08 10:43:00	accepted	891370574896	72199198	\N
38cedf44d6c249469d740bf25d246ef9	1xthom14@gmail.com	Investissement rapide : VIP Ultime	-120000	2025-11-08 11:48:36.516808	En cours	\N	\N	\N
0cc6f33bde1f4460a24daba099173325	1xthom14@gmail.com	Investissement rapide : VIP Pro	-15000	2025-11-08 16:51:13.702412	En cours	\N	\N	\N
0481fd9bca0841c3848a8163ce3ae8fc	ahamaniprince7@gmail.com	Dépôt via euro	3000	2025-11-09 10:30:51	rejected	79652238	79652238	\N
2e286785739b4e0c837ed88042af2d26	prestocashfinance0@gmail.com	Dépôt via Kkiapay	4000	2025-11-09 07:02:18	rejected	191426033783	72199198	\N
d6c0a62d1eb7402c9f336dc93fe5b61c	prestocashfinance0@gmail.com	Dépôt via Kkiapay	4000	2025-11-09 07:00:41	rejected	143788877583	72199198	\N
9e9555bb4bfe483e87ab858ba72a824e	prestocashfinance0@gmail.com	Dépôt via xof	10000000	2025-11-08 00:25:48	rejected	12373562763	71339325	\N
0cb1a5038afb452891ff19bbec17dcbd	1xthom14@gmail.com	Investissement rapide : VIP Expert	-30000	2025-11-09 12:42:06.877411	En cours	\N	\N	\N
7c2f5ec17384485eadf394c94c8cee4b	1xthom14@gmail.com	Dépôt via euro	10000	2025-11-10 07:56:00	accepted	311872290046	72199198	\N
fdff2bd6f35942189240df312415d9d1	1xthom14@gmail.com	Investissement rapide : VIP Mini	-3000	2025-11-10 12:34:01.733308	En cours	\N	\N	\N
ccb162699f0e4130a75e1a1a4a874846	kombwoyofficiel1@gmail.com	Dépôt via euro	3000	2025-11-10 13:08:59	accepted	040246286193	99225912	\N
8fc6750828b34b4a92ae02ac99b4677b	prestocashfinance1@gmail.com	Dépôt via euro	15000	2025-11-10 20:03:52	accepted	162799362960	72199198	\N
e5b95473ba22491c9ae9667c5a09a118	legendekabore5@gmail.com	Dépôt via euro	4000	2025-11-10 21:54:23	rejected	Dépôt 	+22675865299	\N
0abc9893ea8d4bd6b11bc19d587af96b	agbegniganfrederic@gmail.com	Dépôt via euro	3000	2025-11-10 22:11:44	accepted	Frédéric 	93479201	\N
9db7901e355940a397b4cb93d8a2b705	prestocashfinance0@gmail.com	Dépôt via euro	3000	2025-11-10 22:45:53	accepted	171850273763	72199198	\N
1a37347ab87948989b026375790edaf7	livepoppo531@gmail.com	Dépôt via euro	3000	2025-11-11 00:17:59	rejected	13770996786	+228 71568176 	\N
35ff5aef0ee04161b977741b5ad13404	donyohfaustin@gmail.com	Dépôt via euro	4000	2025-11-11 03:00:38	rejected	mix by yas	91861850	\N
4abd06175eb5467cb983c817a97719d3	ddjau420@gmail.com	Dépôt via euro	3000	2025-11-11 04:35:17	rejected	Ddjau420@gmail.com 	92196614 	\N
2494187dcd1d445cb75699893baaac7a	ddjau420@gmail.com	Dépôt via euro	3000	2025-11-11 07:20:58	accepted	14142218183	92196614 	\N
acdde96c1a444af18c96136d52379632	lucien@email.com	Dépôt via euro	3000	2025-11-11 05:56:04	rejected	Togo 	70519445	\N
afb1a57d170d46f1a2d96635b02aef80	lucien@email.com	Dépôt via euro	3000	2025-11-11 05:57:10	rejected	285968227908	70519445	\N
f1effa8a1cc44da29f98760d2ea545de	sophieyelihani@gmail.com	Dépôt via euro	15000	2025-11-11 08:10:26	accepted	14142584741	91085965	\N
3ba01cad0e434b23bb6905593296ecd3	bassoprofesseur@gmail.com	Dépôt via euro	9000	2025-11-11 08:12:54	accepted	040248570295	72 18 29 84 	\N
caff56a858eb4d81a244d58d6e261081	ddjau420@gmail.com	Dépôt via euro	9000	2025-11-11 08:37:01	accepted	14143412085	92196614 	\N
3b865a580b484aea8ea2092d20405921	stephanieadjogah924@gmail.com	Dépôt via euro	15000	2025-11-11 09:12:07	accepted	14143965892	90237053	\N
02bb4e90f79d4824bde942a417af40c7	tinafaou228@gmail.com	Dépôt via euro	9000	2025-11-11 09:30:22	accepted	14144120789	70814292	\N
cc76c0755c734c6886bc412e5bf49e0d	tairoumamah3@gmail.com	Dépôt via euro	3000	2025-11-11 09:33:48	accepted	14144406710	93182660	\N
c13cb6eb036a430998a28b3a72cf0dd8	tinafaou228@gmail.com	Dépôt via euro	9000	2025-11-11 09:30:23	rejected	200186714323	70814292	\N
b10313e88a7a4102b429bff0bd2a39f5	tairoumamah3@gmail.com	Dépôt via euro	3000	2025-11-11 09:35:22	rejected	904817210566	93182660	\N
74d27fd3308443fb976c914923dfb678	tairoumamah3@gmail.com	Dépôt via euro	3000	2025-11-11 09:35:05	rejected	267934896205	93182660	\N
eaae0ebb81c04c36bf41d79f7ae46e75	tairoumamah3@gmail.com	Dépôt via euro	3000	2025-11-11 09:35:03	rejected	153083791282	93182660	\N
c4da4fb838844a1b955b406d1207ccba	tairoumamah3@gmail.com	Dépôt via euro	3000	2025-11-11 09:33:52	rejected	282101666126	93182660	\N
e8571db3e02549568efa439b24381248	tairoumamah3@gmail.com	Dépôt via euro	3000	2025-11-11 09:33:51	rejected	225902759464	93182660	\N
7b3b7d4f6ffb46698bba13d8833c93c0	tairoumamah3@gmail.com	Dépôt via euro	3000	2025-11-11 09:33:50	rejected	371555713120	93182660	\N
81e95e93cefb46be86ab0ca67b8c81ce	tinafaou228@gmail.com	Dépôt via euro	9000	2025-11-11 09:30:24	rejected	560309264190	70814292	\N
6418b71d1a97465cb25b33e9c4da5db1	tsathokossididier1@gmail.com	Dépôt via euro	9000	2025-11-11 09:58:21	accepted	14144687736	92005760	\N
ad8bdc2db7744babb0cf199b1a5613ec	tsathokossididier1@gmail.com	Dépôt via euro	9000	2025-11-11 09:58:53	rejected	221546000571	92005760	\N
ccfbc0aec7db40b0b66ff3bb6da7f16e	bienvenueamen@gmail.com	Dépôt via crypto	3000	2025-11-11 10:40:21	accepted	113061757	92954693	\N
75745de20ad145b6bfa3f97c5369c221	azokolo1@gmail.com	Dépôt via euro	10000	2025-11-11 11:55:58	accepted	170497857638	72199198	\N
f0c42a43144944b2a3f11997482cab6d	assouagbehonouassouh0@gmail.com	Dépôt via euro	30000	2025-11-11 12:35:11	accepted	14147196770	90128604	\N
5dfea665af9e4df2a4eecac74cd77773	kenkorodriguez7@gmail.com	Dépôt via euro	10000	2025-11-11 14:42:18	accepted	14143257506	656191992	\N
dba2649c08484c26b2ed3a65b1d72256	djiwonoudodji@gmail.com	Dépôt via euro	3000	2025-11-11 15:02:06	rejected	14149324077	71515683	\N
127608f8b21f4b8ba1d4cfd1e13cb4e5	djiwonoudodji@gmail.com	Dépôt via euro	3000	2025-11-11 15:09:32	rejected	326173364404	71515683	\N
77a2fcd69b584546afe8cb8ded0fa595	djiwonoudodji@gmail.com	Dépôt via euro	3000	2025-11-11 15:02:12	rejected	372210600296	71515683	\N
8216884f2eb74bd19be2a10e36f54a81	djiwonoudodji@gmail.com	Dépôt via euro	3000	2025-11-11 15:02:12	rejected	181812500221	71515683	\N
cdba428cf8794f2994ab7d4acab3c82a	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:48	accepted	110049672293	44956945	\N
2024bb67bfd64b288a953b16c8c1e3de	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:43:17	rejected	632120366604	44956945	\N
488bef4f180a456481f51bff4f0555a7	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:30	rejected	197186022984	44956945	\N
aeeec0cd63c147bd88ecd20b78a24b07	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:38	rejected	243980143772	44956945	\N
16431cff73534d009ae113f4c2a82891	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:39	rejected	272497771661	44956945	\N
f642a3b097884592afc461d232814c96	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:40	rejected	252656670404	44956945	\N
3f1501e0487d4623b48f5d37f66c6321	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:42	rejected	132777770300	44956945	\N
80bffa0b685f457690bfac9e6d525d69	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:43	rejected	699818796717	44956945	\N
fc95f16d70a04fdc9d48a6276727bf17	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:44	rejected	175629932809	44956945	\N
1cc5eb8129ba454ebe273cf8b3053172	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:45	rejected	277529510506	44956945	\N
ce3e527cf4f949608b1864d2fa85ebd9	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:46	rejected	128111427608	44956945	\N
ad7bf8ca7a9845848fe8888b35eb0cab	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:47	rejected	227661039244	44956945	\N
35dcc4a567ea4362bc7631df71c5e077	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:49	rejected	654390024698	44956945	\N
c694c95efd7a458d8369edc868674629	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:50	rejected	242506818525	44956945	\N
20030b705e6846b991ba00196d862953	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:50	rejected	131959663542	44956945	\N
63c816a38cc14d4fb0fc234a2a296c2a	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:51	rejected	237421860477	44956945	\N
2c3c6ef5aa564c209d16652b712be3ee	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:52	rejected	462375212200	44956945	\N
3721426cad104d0eb454ac1a0ab06ce0	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:53	rejected	302454442861	44956945	\N
7c8522e177af44c1907c20b9db6a3cc5	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:54	rejected	220584569853	44956945	\N
bcbc16f6c7804312be23a2ceb1803921	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:54	rejected	253200291646	44956945	\N
4850e8550b624564981c6b5d7f3e186a	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:55	rejected	153512534420	44956945	\N
fb3e4c7340a74a38b737f63913f1505b	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:56	rejected	104019169271	44956945	\N
1632023745954514b88589841d2fd70e	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:57	rejected	323684654154	44956945	\N
1e518c2c742c414cb42318dd7ee550a3	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:58	rejected	180933614783	44956945	\N
a055615e62544bb68f719883ca6543e2	zerboelie281@gmail.com	Dépôt via euro	10000	2025-11-11 15:49:58	rejected	132488857626	44956945	\N
96fab7828e98499ca8e741121180d9d9	waitybns@gmail.com	Dépôt via euro	3000	2025-11-11 17:19:22	rejected	12345678910	98436291	\N
c5beda0e7f5944019717dc5955d12166	ebola2@icloud.com	Dépôt via euro	10000	2025-11-11 17:34:48	accepted	270475679595	Ndi ondobo 	\N
fe137901322e435d92f15e7538789006	waitybns@gmail.com	Dépôt via euro	3000	2025-11-11 17:53:20	accepted	0190075829	98436291	\N
a47a9dba72b744d18867a504783adf8b	kombwoyofficiel1@gmail.com	Dépôt via euro	3000	2025-11-11 17:56:42	rejected	311996680858	99225912	\N
ce7900b86ca3467d9903a776b9ca3ad0	dongmocristabelle6@gmail.com	Dépôt via euro	10000	2025-11-11 18:11:49	accepted	298842768236	652330326	\N
3b3fd4f9a7ec4c17954120526c389c1e	kombwoyofficiel1@gmail.com	Dépôt via euro	3000	2025-11-11 18:07:08	rejected	a47a9dba72b744d18867a504783adf8b	99225912	\N
8aac51b053e04fb8b67876499578c39a	amousunday16@gmail.com	Dépôt via euro	30000	2025-11-11 18:48:25	accepted	14153565235	Amou	\N
4b36e57a90c84ac7803ad106aff520cc	marieedoh@gmail.com	Dépôt via euro	10000	2025-11-11 19:13:35	accepted	4472997388	93738252	\N
1080ffb47ff54786a6a46f12f6fb9def	djiwonoudodji@gmail.com	Dépôt via euro	3000	2025-11-11 19:15:07	rejected	154944461925	71515682	\N
52b6b564fd72405a98f8ccc45dc7c0fe	amidepare058@gmail.com	Dépôt via euro	3000	2025-11-11 19:37:58	rejected	Orange money 	76163727	\N
72bac8c443a14388a7916793d0dcf214	sodahlonprosper99@gmail.com	Dépôt via euro	3000	2025-11-11 20:00:56	accepted	040250724924	99988744	\N
3b0d6e086e2e49c8b54f47a7f93446a0	messanhmawugna@gmail.com	Dépôt via euro	30000	2025-11-11 20:04:01	accepted	14155110433	91668655	\N
97c31e116a59449e948175b7ce1a1733	marieedoh@gmail.com	Dépôt via euro	10000	2025-11-11 20:05:41	accepted	195137917609	93738252	\N
9b4cb62199f64e33aa474b7fcf2400d6	kokouivesahadji12@gmail.com	Dépôt via euro	3000	2025-11-11 21:33:34	accepted	14156283844	93812243	\N
4b4e6b2a0ed745b8a882e81d297b1755	kokouivesahadji12@gmail.com	Dépôt via euro	3000	2025-11-11 21:35:46	rejected	305849442252	93812243	\N
78d953669dfa46b0b899398a070d305c	bebekeizen@gmail.com	Dépôt via euro	3000	2025-11-11 21:54:54	accepted	113075924	92039803	\N
a56c0a4d27ee40f98aa62d228d295246	guyakaye12@gmail.com	Dépôt via crypto	200	2025-11-11 23:03:07	rejected	Flooz	79711122	\N
e54f5138ec994a24b0c64b1f850144d9	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-11 23:16:13	rejected	641727032658	91566935	\N
deac38c4753b4449b4b1a4ad8ddbd405	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-11 23:14:33	rejected	14156760442	91566935	\N
976ba2da2cfe4fcb8ea94905fd2764ce	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-11 23:32:51	rejected	334821267331	91566935	\N
3744c9cef7cb46dc80021ba9b3e27028	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-11 23:40:23	rejected	263763470590	91566935	\N
ca457407d78b4b2197e6391d7913d45e	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-12 00:19:50	rejected	662114565030	91566935	\N
9ce47ad9716c45e3b583d5be59d52cf7	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-12 00:20:32	rejected	14156760443	91566935	\N
e790fa1b31d44849963b8cb99ec123f7	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-12 05:19:16	rejected	186603917479	91566935	\N
c1ad3cff7a9e4cbda89b0e3e06edac38	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-12 05:47:01	rejected	105743203354	91566935	\N
e347bcd3ad3047c383224ef01a112522	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-12 05:59:09	rejected	191379025902	91566935	\N
55c39a9027424953a84351082d43bebb	ddjau420@gmail.com	Dépôt via euro	15000	2025-11-12 06:59:03	accepted	 14157578262	92196614 	\N
716d473540c147c8976f1b261a6b1ea1	rogerdadjera46@gmail.com	Dépôt via euro	3000	2025-11-12 07:26:01	rejected	112687239669	91566935	\N
f2243befc60f4cf38865bff0507fe5ee	c18125210@gmail.com	Dépôt via euro	3000	2025-11-12 07:37:27	accepted	14157923618	93720193	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.users (id, username, email, phone, password, balance, parrain, withdraw_number, date_inscription, has_made_first_deposit, last_bonus_date) FROM stdin;
18	Mirad	lmira8819@gmail.com	+22891432265	228800	400	\N	\N	2025-11-08 11:45:01	f	2025-11-11
38	Israel	pachouawuito@gmail.com	+22891062900	paCH92@&	350	1xthom14	\N	2025-11-08 17:51:00	f	2025-11-08
40	fiafomekomlandavid@gmail.com	villajr@gmail.com	+22892404609	davide	300	Kombwoy	\N	2025-11-08 19:25:12	f	\N
8	aline	prestocashfinance@gmail.com	+22891123568	123	9934350	prestocash	\N	2025-11-08 05:38:27	t	2025-11-08
4	test	test@prestocash.com	+22872211538	Mthom14	300	\N		2025-11-07 23:28:21	f	\N
5	nina14	fredogary7@gmail.com	+22872199198	Mthom14	300	\N		2025-11-07 23:37:39	f	\N
6	pthom14	azokolo91@gmail.com	+22899540580	Mthom14	350	\N		2025-11-07 23:43:58	f	2025-11-07
7	momo	test@prestocash11.com	+22899545898	Mthom14	300	\N	\N	2025-11-08 00:08:29	f	\N
13	Rolando12	sauveuragb1991@gmail.com	+22898272969	Agb98272969	400	1xthom14	\N	2025-11-08 10:40:01	f	2025-11-10
19	Bernard	pepeboukari@gmail.com	+22871183468	Lometogo.228	300	1xthom14	\N	2025-11-08 12:00:08	f	\N
10	Joshua	joshuaentreprise9@gmail.com	+22892360282	Joshuapc9	300	\N	\N	2025-11-08 10:09:33	f	\N
11	Dossou	amedonouabla51@gmail.com	+22898907909	Azert123@	300	1xthom14	\N	2025-11-08 10:12:41	f	\N
20	Samboe	samboeflorent8@gmail.com	+22896496136	f_roi_roi_dmith	300	1xthom14	\N	2025-11-08 12:00:12	f	\N
21	Bernard	ablogame@gmail.com	+22871183468	Lometogo.228	300	\N	\N	2025-11-08 12:01:21	f	\N
51	Abdoulaye	abnouhou6@gmail.com	+22872121163	ABcfe100	300	1xthom14	\N	2025-11-09 10:44:25	f	\N
12	nina15	ameket5@gmail.com	+22899540236	Mthom14	10350	\N	\N	2025-11-08 10:32:15	f	2025-11-08
15	Hervé	herveking485@gmail.com	+22870664097	123456	350	1xthom14	\N	2025-11-08 10:55:02	f	2025-11-08
16	Edem	mongloedem1@gmail.com	+22870526306	160904	1200	1xthom14	\N	2025-11-08 11:04:00	f	\N
14	Passo	josueapelete24@gmail.com	+22871427703	jojo9835	500	1xthom14	\N	2025-11-08 10:41:47	f	2025-11-11
24	Viviane	vivianeafanou21@gmail.com	+22898717769	vivi9871	300	1xthom14	\N	2025-11-08 12:20:27	f	\N
26	Benito	lawsonbenilecanadien@gmail.com	+22892182192	Lwn57@6623	350	1xthom14	\N	2025-11-08 12:54:24	f	2025-11-08
27	THOMAS	thomaselangamedou@gmail.com	+237689433691	Cameroon+237	350	\N	\N	2025-11-08 13:44:53	f	2025-11-08
29	Adokou	adokoumarc@gmail.com	+22871218379	azer1234@	350	1xthom14	\N	2025-11-08 14:52:36	f	2025-11-08
30	Adokou	adokoumarc@icloud.com	+22890035006	azer1234@	300	\N	\N	2025-11-08 15:53:39	f	\N
41	FIAFOME	fiafomekomlandavid@gmail.com	+22892404609	davide	350	\N	\N	2025-11-08 19:26:04	f	2025-11-08
31	Alrus	azanbidjialphonse@gmail.com	+22871876004	Kossi2004@	350	1xthom14	\N	2025-11-08 16:19:31	f	2025-11-08
42	Gatien	elfybassole@gmail.com	+22654523302	Glory2024	300	Kombwoy	\N	2025-11-08 19:30:10	f	\N
32	PARFAIT	graceeria719@gmail.com	+22871456198	0852	350	1xthom14	\N	2025-11-08 16:44:40	f	2025-11-08
54	Coordo	delphinyao2@gmail.com	+22893341913	123456	100	1xthom14	\N	2025-11-09 10:58:31	f	2025-11-11
33	Ametepe	thibault@gmail.com	+22898117532	thi2	300	1xthom14	\N	2025-11-08 16:56:32	f	\N
34	Mohamed	awalitecco@gmail.com	+22872131421	1234moha	300	1xthom14	\N	2025-11-08 17:04:49	f	\N
35	Ametepe	amega@gmail.com	+22898117532	thib@€$2	300	1xthom14	\N	2025-11-08 17:15:50	f	\N
36	Joel	joeldzreke71@gmail.com	+22891571026	joel9157	300	1xthom14	\N	2025-11-08 17:29:13	f	\N
25	HOUDEAïthemeElisée	eliseehoude17@gmail.com	+22893492756	Yasmine61	300	1xthom14	\N	2025-11-08 12:38:30	f	\N
44	Aimé	aimeteteh8@gmail.com	+22879983044	Aimelebg	300	\N	\N	2025-11-08 20:39:11	f	\N
45	emmanuel0305	emma92655113@gmail.com	+22871556202	jason03	350	\N	\N	2025-11-08 20:42:31	f	2025-11-08
46	Hounkadji	jacqueshounkadji733@gmail.com	+22899719915	jacques@99	350	\N	\N	2025-11-08 21:03:32	f	2025-11-08
47	Kisto	wilsonange05@gmail.com	+22892164427	cesar1999	300	1xthom14	\N	2025-11-09 01:02:31	f	\N
43	BRUNO'S	johnsonbruno132@gmail.com	+22893051615	Azerty123	450	1xthom14	\N	2025-11-08 20:20:46	f	2025-11-11
59	Claire	laulau@gmail.com	+22897136605	1008	350	1xthom14	\N	2025-11-09 11:51:33	f	2025-11-09
49	Prince	ahamaniprince7@gmail.com	+22879652238	prince_228	300	1xthom14	\N	2025-11-09 10:28:39	f	\N
50	Radiatou	nouhouradiatou@gmail.com	+22871519430	rachou@228	300	1xthom14	\N	2025-11-09 10:34:53	f	\N
52	amoussou	amoussouorine2@gmail.com	+22897854513	97854513	350	1xthom14	\N	2025-11-09 10:46:00	f	2025-11-09
53	Pharaonmary	pharaonmary@gmail.com	+22891548368	90123330a	350	1xthom14	\N	2025-11-09 10:55:29	f	2025-11-09
55	Alpha_thug	koumavolucia6@gmail.com	+22870273953	Skblacke1	350	1xthom14	\N	2025-11-09 11:21:05	f	2025-11-09
56	David	hevidave@email.com	+22871407229	fetia1806	300	Alpha_thug	\N	2025-11-09 11:43:43	f	\N
60	Kelly	kellydjoka120@gmail.com	+22870895374	kelly	300	David	\N	2025-11-09 11:55:51	f	\N
39	BigSerg	serge2008@gmail.com	+22872354504	big2008	300	1xthom14	\N	2025-11-08 19:13:54	f	\N
23	EzuiKomi	ezuidorake@gmail.com	+22870510997	sebastien12@	300	1xthom14	\N	2025-11-08 12:11:27	f	\N
58	Donatien	domserif4@gmail.com	+22893890723	@dom2005	350	Alpha_thug	\N	2025-11-09 11:47:45	f	2025-11-09
105	Nissao	nabinenissao79@gmail.com	+22893003811	1515Niss	400	Leader	\N	2025-11-10 21:32:00	f	2025-11-11
61	Jonathan	adjeteyj390@gmail.com	+22893863296	123456	300	1xthom14	\N	2025-11-09 12:06:03	f	\N
84	Aurel	aurelgeraldonoumon@gmail.com	+22962295551	Azerty123@	350	1xthom14	\N	2025-11-10 15:05:21	f	2025-11-10
62	Gdskanovisch	phoenixgdska@gmail.com	+22871152238	prestocash	300	1xthom14	\N	2025-11-09 13:11:15	f	\N
63	Claire	claire@gmail.com	+22897136605	1008	350	1xthom14	\N	2025-11-09 13:37:17	f	2025-11-09
64	Lawson	lawson@gmail.com	+22891023348	tychus	350	Alpha_thug	\N	2025-11-09 13:51:50	f	2025-11-09
65	Yoo	tipo@gmail.com	+22898325232	tychus	300	Clifford	\N	2025-11-09 13:58:02	f	\N
66	Yao	yao@gmail.com	+22897235689	tychus	300	Clifford	\N	2025-11-09 13:59:35	f	\N
67	Woo	woo@gmail.com	+22893235689	tychus	300	Clifford	\N	2025-11-09 14:00:40	f	\N
97	Shariel21	kloutseetienne984@gmail.com	+233556144446	976606	400	Leader	\N	2025-11-10 21:07:38	f	2025-11-11
83	Chaab	chaabadam@gmail.com	+22891627552	12345	450	Kombwoy	\N	2025-11-10 14:52:47	f	2025-11-12
70	Blaise050	blaiseadoh227@gmail.com	+22871793725	blaise227	350	1xthom14	\N	2025-11-09 19:45:02	f	2025-11-09
71	Laurent	dossoulaurent56@gmail.com	+22893107661	@Laurel.b14	350	Alpha_thug	\N	2025-11-09 19:54:23	f	2025-11-09
73	Parfait10	cakpo.parfait.10@gmail.com	+22891196348	Avoxe prod	400	\N	\N	2025-11-10 00:43:03	f	2025-11-12
87	Leaderns	waitybns@gmail.com	+22898436291	922526	450	\N	\N	2025-11-10 18:02:05	f	2025-11-12
85	admin	admin123456@gmail.com	+22898126485	Azerty	300	\N	\N	2025-11-10 15:27:48	f	\N
57	Clifford	lawsonclifford49@gmail.com	+22879959732	tychus45	400	\N	\N	2025-11-09 11:45:27	f	2025-11-11
74	Venci	vencignaletassi@gmail.com	+22898756250	220122	300	presto	\N	2025-11-10 09:19:03	f	\N
2	1xthom14	1xthom14@gmail.com	+22896009868	Mthom14	5250	prestocash		2025-11-07 12:34:20	t	2025-11-11
76	Gaet	fabiennedupez21@gmail.com	+22947077784	123456	350	Justino	\N	2025-11-10 10:03:18	f	2025-11-10
78	Anasthase	anasthasededieuazonwai@gmail.com	+22963466223	5765p844	300	\N	\N	2025-11-10 10:31:46	f	\N
77	Wilfried	willybiofficiel@gmail.com	+22870272472	Wilfried@99	350	\N	\N	2025-11-10 10:30:55	f	2025-11-10
80	Loko Aristide	dilwidoabraham@gmail.com	+22953458599	abra53	350	\N	\N	2025-11-10 10:36:18	f	2025-11-10
81	Jojo228	djimbatatoa@gmail.com	+22871603504	Tatoa1	350	1xthom14	\N	2025-11-10 10:38:46	f	2025-11-10
104	Tina222	tinafaou228@gmail.com	+22870814292	tina22	450	Leader	\N	2025-11-10 21:27:31	t	2025-11-12
3	presto	prestocashfinance1@gmail.com	+22892339345	Mthom14	16200	\N		2025-11-07 22:57:42	f	\N
91	LeaderHerman	assogbaherman4@gmail.com	+22384287660	H90086837e	350	Leader	\N	2025-11-10 21:03:09	f	2025-11-10
82	Henok228	dossehhenok@gmail.com	+22893389689	Dosseh@9933	350	1xthom14	\N	2025-11-10 13:17:30	f	2025-11-10
86	Avrel	averelyodo7@gmail.com	+22892404351	Akazoo12	350	1xthom14	\N	2025-11-10 17:57:34	f	2025-11-10
88	Clément	clementgbiedid@gmail.com	+22891254999	Clement23@	350	\N	\N	2025-11-10 19:01:10	f	2025-11-10
100	SOULEMANE	soulemanefataou92@gmail.com	+22898449559	soul34	400	Leader	\N	2025-11-10 21:14:50	f	2025-11-11
108	Agbegnigan	agbegniganfrederic@gmail.com	+22893479201	nabgag-tegsow-tovQo4	350	\N	\N	2025-11-10 21:39:44	f	2025-11-11
92	legendekabore5@gmail.com	legendekabore5@gmail.com	+22675865299	123ABDid.,	400	Leader	\N	2025-11-10 21:03:23	f	2025-11-11
94	YAYA VATMARA	vatmara1232@gmail.com	+237658994295	yaya1232	300	Leader	\N	2025-11-10 21:04:07	f	\N
95	Armel	armelzakary938@gmail.com	+22870730987	armelzakary12	300	Leader	\N	2025-11-10 21:04:29	f	\N
90	Zagré	zagreedith66@gmail.com	+22676447355	ZAgre226	350	Leader	\N	2025-11-10 21:02:55	f	2025-11-10
75	Justino	segnonjustino99@gmail.com	+22892213291	justin2001	400	presto	\N	2025-11-10 09:40:30	f	2025-11-11
69	KALAMPAIAbdoulSalam	kalampaiabdoulsalam6@gmail.com	+22890226825	90226825	350	Kombwoy	\N	2025-11-09 16:43:51	f	2025-11-09
1	prestocash	prestocashfinance0@gmail.com	+22871339325	123	5543779.3	\N		2025-11-07 12:33:32	f	2025-11-10
99	Fabinoss	yapofabino@gmail.com	+22870074230	fabinoss1998	350	Leader	\N	2025-11-10 21:13:33	f	2025-11-10
101	Agbamaro	agbamaroblaki@gmail.com	+22890552711	koke#228	300	Leader	\N	2025-11-10 21:16:44	f	\N
72	Delor	justinodelor@gmail.com	+22898201064	justin2001	350	Leader	\N	2025-11-09 21:10:07	f	2025-11-09
102	Calvin	kalvintohouede@gmail.com	+22870550080	98039792	350	Leader	\N	2025-11-10 21:20:04	f	2025-11-10
103	Yannick	bbkoussi@gmail.commaman20	+22872402961	yanorach12	300	Leader	\N	2025-11-10 21:25:28	f	\N
93	Assiwoe	assiwoe@gmal.com	+22898763413	98763413@	400	Leader	\N	2025-11-10 21:03:37	f	2025-11-11
96	GUIDO	ministerelanouvellesemence@gmail.com	+22890620556	fafazozo	350	Leader	\N	2025-11-10 21:06:07	f	2025-11-11
106	Nezha	kogbeemmanuel56@gmail.com	+22899653640	Nezha228	350	Leader	\N	2025-11-10 21:34:24	f	2025-11-10
107	Agbegnigan	agbegniganfrederic@gimail.com	+22893479201	nabgag-tegsow-tovQo4	300	Leader	\N	2025-11-10 21:35:58	f	\N
98	prosperito	sodahlonprosper99@gmail.com	+22899988744	S@dah9090	450	Leader	\N	2025-11-10 21:08:09	t	2025-11-12
28	Kombwoy	kombwoyofficiel1@gmail.com	+22899225912	71515683	450	presto	\N	2025-11-08 14:07:16	t	2025-11-11
110	Ayena	ayenamikael@70gmail.com	+22870188771	9344mike	350	\N	\N	2025-11-10 21:43:03	f	2025-11-10
113	Same	sameagbo045@gmail.com	+22893032110	same@45	350	Leader	\N	2025-11-10 22:15:50	f	2025-11-10
114	Alphonse	alphonseassogba400@gmail.com	+22360118312	Winner3@?	350	Leader	\N	2025-11-10 22:39:57	f	2025-11-10
137	Abraham@gmail.com	abraham@gmail.com	+22872405201	968545	350	Leader	\N	2025-11-10 23:48:45	f	2025-11-11
109	Sababe	foussenisababe3@gmail.com	+22893068655	200593	400	Leader	\N	2025-11-10 21:42:42	f	2025-11-11
119	CHAKOURCEE	sidambachakour@icloud.com	+22896709185	CHAKOURCEE	350	Lise	\N	2025-11-10 23:01:19	f	2025-11-10
120	beau4	starkesalphonse@gmail.com	+22394394878	Winner3@?	350	Alphonse	\N	2025-11-10 23:03:45	f	2025-11-10
117	agbegniganfrederic@gmail.com	agbegniganfredric@gimail.com	+22893479201	bocqax-9cajvi-feGkew	350	\N	\N	2025-11-10 22:53:47	f	2025-11-10
123	Achirama	zekiaisifou@gmail.com	+22897572566	34ea	350	agbegniganfrederic@gmail.com	\N	2025-11-10 23:18:11	f	2025-11-10
124	Justin	jkusiaku@gmail.com	+22891404915	123456	300	Edem	\N	2025-11-10 23:19:17	f	\N
121	Akande	modiradeakande@gmail.com	+22897050406	rp5e5iK.rWMS	350	agbegniganfrederic@gmail.com	\N	2025-11-10 23:08:42	f	2025-11-10
125	STAR_GENIE	gouvernancg@gmail.com	+22870363611	018952	300	Edem	\N	2025-11-10 23:22:23	f	\N
126	Moumouni	tairoumamah3@gmail.com	+22893182660	mamah99@@	400	Leader	\N	2025-11-10 23:23:48	t	2025-11-11
151	Bienvenue	bienvenueamen@gmail.com	+22892954693	bonjoure	400	Leader	\N	2025-11-11 03:09:22	t	2025-11-12
129	Djapoy	daopierre417@gmail.com	+22871797540	12pierre@	350	Leader	\N	2025-11-10 23:29:51	f	2025-11-10
133	Ro_ger_23	atokouedoh@gmail.com	+22890858865	roger23	350	\N	\N	2025-11-10 23:36:31	f	2025-11-11
127	Grand13	gerardkodjo28@gmail.com	+22892233467	123640	350	Lise	\N	2025-11-10 23:26:34	f	2025-11-10
134	Anthonio9	brunocooper2007@gmail.com	+22893908608	Anthonio9	300	Dr	\N	2025-11-10 23:38:35	f	\N
135	adessola	adessolaabdoullatifa@gmail.com	+22892108918	123456	300	Lise	\N	2025-11-10 23:38:53	f	\N
136	Sophie	sophieyelihani@gmail.com	+22890494234	Kambi97	400	Leader	\N	2025-11-10 23:45:04	t	2025-11-11
118	Kissere	barthelemykissere567@gmail.com	+22893987296	123456	400	Leader	\N	2025-11-10 22:54:41	f	2025-11-11
139	Boris235	soliboris8@gmail.com	+22892553851	92553851	350	Lise	\N	2025-11-11 00:00:24	f	2025-11-11
138	deborah	dzinakud@gmail.com	+22893545204	debo2003A	350	Leaderns	\N	2025-11-10 23:55:31	f	2025-11-11
140	kalashmanu	livepoppo531@gmail.com	+22871568176	90164878	300	Leader	\N	2025-11-11 00:14:11	f	\N
142	Hhhhh	theophieabibou@gmailcom	+22890386818	12345678	300	\N	\N	2025-11-11 00:17:32	f	\N
141	Théorie	theophileabibou@gmailcom	+22893837993	12345678	350	Leader	\N	2025-11-11 00:15:12	f	2025-11-11
144	Martin	docteurclache@gml.com	+22891922218	226600	350	Leader	\N	2025-11-11 00:40:23	f	2025-11-11
145	Marcelin	marcelinkamato@gmail.com	+22872210230	kamora9814	350	Edem⁠	\N	2025-11-11 00:50:15	f	2025-11-11
146	Koku25	vpn@protommail.com	+22893831653	fofo53	300	Leader	\N	2025-11-11 01:30:25	f	\N
116	Lise	djokpoelie0@gmail.com	+22896096282	Lillibae91	400	\N	\N	2025-11-10 22:52:42	f	2025-11-11
149	Rodriguez280	gadegbekurodriguez122@gmail.com	+22891273306	123456	300	Leader	\N	2025-11-11 02:41:04	f	\N
148	Michel	michelkarabou18@gmail.com	+22896446084	achwin	350	Nissao	\N	2025-11-11 02:39:44	f	2025-11-11
150	Donyoh	donyohfaustin@gmail.com	+22891861850	@Donyoh12	350	Leader	\N	2025-11-11 02:46:21	f	2025-11-11
131	koko	kokouivesahadji12@gmail.com	+22893812243	KoKou12@	1300	Edem	\N	2025-11-10 23:32:32	t	2025-11-11
132	Roger	rogerdadjera46@gmail.com	+22891566935	0987654321	400	Edem⁠	\N	2025-11-10 23:33:01	f	2025-11-12
128	Enesta	12sexualitesexe@gmail.com	+22892109781	Enesta223	400	Leader	\N	2025-11-10 23:26:53	f	2025-11-11
154	Jonathan	agonkpahounj@gmail.com	+22960262522	presto77	300	Lise	\N	2025-11-11 04:21:54	f	\N
155	Ghislain	ghislainvigno@gmail.com	+22879837231	poete612	350	Leader	\N	2025-11-11 04:25:52	f	2025-11-11
156	Ghis-thug	ghiixfree@gmail.com	+22891916921	05Mai2010@	350	Leader	\N	2025-11-11 04:37:38	f	2025-11-11
158	Kpaonou	abelkpoanou@gmail.com	+22899808479	12abel28	300	SalomonAziamadzi	\N	2025-11-11 05:03:17	f	\N
157	SalomonAziamadzi	salomonaziamadzi0@gmail.com	+22891360693	12345678	350	Edem⁠	\N	2025-11-11 05:00:35	f	2025-11-11
161	DylanRyder	dylanryder654@gmail.com	+22891245679	@Leseul228	400	Leaderns	\N	2025-11-11 05:33:22	f	2025-11-12
159	agbegniganfrederic@gmail.com	agbegniganfrederic-ging@gmail.com	+22893479201	nabgag-tegsow-tovQo4	300	\N	\N	2025-11-11 05:24:38	f	\N
160	amos123	beteamorel@gmail.com	+22952121717	AMOS123AMOS	350	Leaderns	\N	2025-11-11 05:26:01	f	2025-11-11
112	Dieu Merci	stephanieadjogah924@gmail.com	+22893471854	mawuakpe	400	Leader	\N	2025-11-10 22:13:37	t	2025-11-12
122	Kyrie	lorihurih23@gmail.com	+22892896693	lorihhhhhhhhhhh3456	400	Lise	\N	2025-11-10 23:11:51	f	2025-11-11
143	AzokinzoAbdoulaye	midjiyawaaziz@gmail.com	+22891001235	Azokinz10	350	Leader	\N	2025-11-11 00:19:45	f	2025-11-11
111	AthoRoland	athoroland2@gmail.com	+22891215634	@12AZazert	300	Leader	\N	2025-11-10 21:43:41	f	\N
163	Arim	amoukouarim@gmail.com	+22870037464	700374	350	Edem	\N	2025-11-11 05:43:56	f	2025-11-11
166	AzoLeBon	kouyakoutoulivictor28@gmail.com	+22892905596	VK2008	300	Lise	\N	2025-11-11 06:07:20	f	\N
165	Ulrich	talbiaulrich1@gmail.com	+22898097689	ulriCH@12	350	Leader	\N	2025-11-11 06:06:23	f	2025-11-11
167	Aïcha	batchaa35@gmail.com	+22870124578	Aicha@123	350	Edem⁠	\N	2025-11-11 06:09:40	f	2025-11-11
170	NYB228	kyamakou3@gmail.com	+22890922148	bruno1999	300	Leader	\N	2025-11-11 06:22:22	f	\N
169	Gifty_97	giftychristiekennedy@gmail.com	+22893652851	19maman@	350	Dr	\N	2025-11-11 06:20:08	f	2025-11-11
171	BRUNO	komlanyamakou3@gmail.com	+22890922148	bruno1999	350	\N	\N	2025-11-11 06:25:39	f	2025-11-11
172	Atchonyawo	atshomensha@gmail.com	+22890541459	905414	300	Lise	\N	2025-11-11 06:31:49	f	\N
173	Sadatetchaou@gmail.com	sadatetchaou@gmail.com	+22871093424	sadate328	300	Anthonio9	\N	2025-11-11 06:38:27	f	\N
176	Stéphane26	sidibeabdoulayeaks225@gmail.com	+2250172933192	262005	300	Lise	\N	2025-11-11 06:41:31	f	\N
177	Savio	savioekoue87@gmail.com	+22890094788	*dede*	300	Edem⁠	\N	2025-11-11 06:42:31	f	\N
178	Musa	lyla25109@gmaiil.com	+22870757846	musa0004	300	Edem	\N	2025-11-11 06:46:10	f	\N
182	Razinho	yakpopaul37@gmail.com	+22898055453	120220	300	Stéphane26	\N	2025-11-11 06:48:38	f	\N
183	Jacob	hermanassogba5@gmail.com	+22367697660	H84287660e	300	Leader	\N	2025-11-11 06:49:07	f	\N
180	Musa	lyla25109@gmail.com	+22870757846	musa0004	350	\N	\N	2025-11-11 06:47:45	f	2025-11-11
174	TSATHO	tsathokossididier1@gmail.com	+22892005760	Kossigan1	350	Edem⁠	\N	2025-11-11 06:40:16	t	2025-11-11
186	Cadet	dotsekokou03@gmail.com	+22898201085	042119	300	Leader	\N	2025-11-11 06:55:26	f	\N
188	Eljezz	expedikirikou@gmail.com	+22871494758	azerty	300	Lise	\N	2025-11-11 07:07:05	f	\N
189	Ashura	lessagahmaurice@gmail.com	+22897119240	momo77	300	Leader	\N	2025-11-11 07:10:52	f	\N
48	Nouhouradiatou	nouhouradiatou80@gmail.com	+22871519430	radia@228	300	1xthom14	\N	2025-11-09 10:27:19	f	\N
22	PromaxOP	olodoprosper@gmail.com	+22892312215	EmiliE2005	350	1xthom14	\N	2025-11-08 12:06:25	f	2025-11-08
37	DrD	djiwonoudodji@gmail.com	+22890622991	Christ406	450	\N	\N	2025-11-08 17:43:27	f	2025-11-11
17	Lmira	dugarboy228@gmail.com	+22896324325	228800	400	\N	\N	2025-11-08 11:38:52	f	2025-11-11
190	Raoul	raoulaho44@gmail.com	+22896798089	967980	300	Morning	\N	2025-11-11 07:18:22	f	\N
191	Raoul	raoulkobissam7@gmail.com	+22896798089	967980	350	Morning	\N	2025-11-11 07:19:28	f	2025-11-11
192	Ekoue	domisavio471@gmail.com	+22890094788	428845	300	Edem⁠	\N	2025-11-11 07:24:02	f	\N
193	Ricardo	ricardobondjare@gmail.com	+22892527927	Ricardo915	350	Nissao	\N	2025-11-11 07:26:03	f	2025-11-11
194	Boris#	borisdavi18@gmail.com	+22897561188	00000000	350	Lise	\N	2025-11-11 07:39:13	f	2025-11-11
197	André	kokousokou45@gmail.com	+22871865972	kolou9858	300	Leader	\N	2025-11-11 07:47:56	f	\N
115	Lise	djokpoelie@gmail.com	+22896096282	Lillibae91	1200	Leader	\N	2025-11-10 22:51:51	f	\N
196	Marley	omarkalaga3@gmail.com	+22675336795	121212	350	Lise	\N	2025-11-11 07:46:31	f	2025-11-11
198	Sewodo	sewodokomialex@gmail.com	+22896512904	Derivation	300	Leader	\N	2025-11-11 07:53:03	f	\N
199	WENAWO	wenawosilvain@gmail.com	+22892156843	921568	300	Leader	\N	2025-11-11 07:56:49	f	\N
195	Mawulolo	adomevictoire7700@gmail.com	+22893367744	yawomawulolo	350	Leaderns	\N	2025-11-11 07:41:42	f	2025-11-11
200	Bruno	kpirabruno@gmail.com	+22870938570	123456	350	\N	\N	2025-11-11 08:00:43	f	2025-11-11
201	Vale	valerietatianamakpe@gmail.com	+22967199808	Valerie12	350	Edem⁠	\N	2025-11-11 08:03:19	f	2025-11-11
202	Kafui	kafui1974@gmail.com	+22893547900	vivi74	350	Leaderns	\N	2025-11-11 08:09:56	f	2025-11-11
203	Wissako	atakoucezard@gmail.com	+22896517949	wissako12	350	Lise	\N	2025-11-11 08:10:52	f	2025-11-11
153	Djau	ddjau420@gmail.com	+22892196614	989898	400	Lise	\N	2025-11-11 04:08:20	t	2025-11-12
206	Youmssieu	kambueuvaidese@gmail.com	+237677803832	677803832	300	Edem	\N	2025-11-11 08:40:39	f	\N
205	Hyacinthe	hyacinthezovoei@gmail.com	+22870942185	yayaro96	300	Leaderns	\N	2025-11-11 08:27:56	f	\N
204	ODANOU	odanoularbli@gmail.com	+22893518042	93518042	400	Leaderns	\N	2025-11-11 08:12:04	f	2025-11-12
208	Eva	denisekpogo16@gmail.com	+22897318902	1235	300	Martin	\N	2025-11-11 08:50:58	f	\N
207	Commando	commandob2b@gmail.com	+22892493961	979597	350	Edem	\N	2025-11-11 08:41:16	f	2025-11-11
89	Leader	bassoprofesseur@gmail.com	+22896083151	123456	3700	Coordo	\N	2025-11-10 20:27:19	t	2025-11-11
164	Flambeigneza	lucien@email.com	+22870519445	Raster	350	Edem	\N	2025-11-11 05:48:33	f	2025-11-11
162	Guillaume	guykondo92@gmail.com	+22893466200	elmensko23	350	GUIDO	\N	2025-11-11 05:42:51	f	2025-11-11
175	Stéphane26	andohkonanstephaneaks225@gmail.com	+2250172933192	262005	3300	Lise	\N	2025-11-11 06:40:42	f	\N
9	LeaderJustino	justingaib@gmail.com	+22870636321	justin2001	500	1xthom14	\N	2025-11-08 10:07:53	f	2025-11-11
185	rodriguez	kenkorodriguez7@gmail.com	+237656191992	princesse237	1300	Stéphane26	\N	2025-11-11 06:51:16	t	\N
210	Mnuel2.0	doubletorno@gmail.com	+22899935673	AAbb11##	300	Leaderns	\N	2025-11-11 08:56:25	f	\N
209	Hubert	hubertakara99@gmail.com	+22870738577	161068	350	Kombwoy	\N	2025-11-11 08:53:54	f	2025-11-11
211	Coulibaly	drissatogo121@gmail.com	+22391635080	9541	300	Leader	\N	2025-11-11 08:59:52	f	\N
212	Dieudonné	ddrtechinfo@gmail.com	+22893194872	ddrd ha10	300	Leader	\N	2025-11-11 09:06:53	f	\N
187	AGBEGNIDOSamuelPapo	agbegnidosamuel@gmail.com	+22892689348	Papo463144	300	Leader	\N	2025-11-11 07:01:24	f	\N
147	Morningstar 	djinkporemmanuel@gmail.com	+22893779281	310720	350	Leaderns	\N	2025-11-11 02:15:19	f	2025-11-11
179	Heroofficial	kwasitchato@gmail.com	+22892005760	Kossigan1.	300	Edem	\N	2025-11-11 06:46:36	f	\N
181	DESISTAFABIANO	desistafabiano9@gmail.com	+22991238599	Desista22	300	Stéphane26	\N	2025-11-11 06:48:11	f	\N
68	Théolebon	priscachou@gmail.com	+22896570879	200818	350	1xthom14	\N	2025-11-09 15:31:49	f	2025-11-09
152	MohamedLamineDao	mohamedlaminedao9267@gmail.com	+22392678684	Genie@9267	350	Lise	\N	2025-11-11 03:28:09	f	2025-11-11
130	agbegniganFrederic	agbegniganfrederic@gmail.comgmail	+22893479281	bocqax-9cajvi-feGkew	300	\N	\N	2025-11-10 23:32:13	f	\N
184	Aminatasanou	sanou9590@gmail.com	+22655237925	121212	350	Edem⁠	\N	2025-11-11 06:50:46	f	2025-11-11
235	123456	dzoumedojean@gmail.com	+22893196367	Aa41bb42	300	Edem	\N	2025-11-11 16:15:31	f	\N
236	mahamadou	mahamadouridwan2@gmail.com	+22870714730	=idwn2010	300	Leader	\N	2025-11-11 16:50:02	f	\N
238	dessiska	boydessiska@gmail.com		mar202	300	Lise	\N	2025-11-11 17:29:21.179284	f	\N
239	omar123	omaryasso005@icloud.com		yasso12	300	Leader	\N	2025-11-11 17:30:27.120766	f	\N
213	georges	georgesedjeou@gmail.com	+22893091387	01051999	350	Kombwoy	\N	2025-11-11 09:59:45	f	2025-11-11
214	coulibaly	cheickhamalacoulibaly116@gmail.com	+22391635080	7676	300	LeaderHerman	\N	2025-11-11 10:03:18	f	\N
216	9019	allehamirat5@gmail.com	+22891272309	Amirat228	300	Leader	\N	2025-11-11 11:36:02	f	\N
217	seidou	seidousaman19@gmail.com	+22872105025	11457790	300	Leader	\N	2025-11-11 11:43:23	f	\N
241	jeandedilas	jeandedilas@gmail.com		123456	300	Leader	\N	2025-11-11 17:33:24.887627	f	\N
220	agbegnigan	agbegniganfrederic@gmail.comm	+22893479201	nabgag-tegsow-tovQo4	300	\N	\N	2025-11-11 12:30:00	f	\N
221	steph	samylyon06@gmail.vom	+22870724142	Samy@2008	300	Edem	\N	2025-11-11 12:32:13	f	\N
222	agbegnigan	agbegnigniganfrederic@gimail	+22893479201	nabgag-tegsow-tovQo4	300	\N	\N	2025-11-11 12:33:01	f	\N
247	kenshi228	tomymerline298@gmail.com		popo123	350	Stéphane26	\N	2025-11-11 17:44:38.96466	f	2025-11-11
242	flex	jakojacques535@gmail.com		Kola1234	300	Lise	\N	2025-11-11 17:34:50.298999	f	\N
223	saints	samylyon06@gmail.com	+22870724142	Samy@2008	350	Edem	\N	2025-11-11 12:34:09	f	2025-11-11
219	assou2	assouagbehonouassouh0@gmail.com	+22890128604	528338	300	Guillaume	\N	2025-11-11 12:18:23	t	\N
224	seidou	boonbeter@gmail.com	+22872105025	12457790	300	Leader	\N	2025-11-11 12:49:05	f	\N
243	agbegnigan	agbegniganfrderic@gimail.com		bocqax-9cajvi-feGkew	300	Leader	\N	2025-11-11 17:35:13.65207	f	\N
218	apeti	azokolo1@gmail.com	+22892169488	123	4300	1xthom14	\N	2025-11-11 11:55:07	t	\N
225	ibh9398	ibrahimouroma@gmail.com	+22870194770	ibro1998	300	Lise	\N	2025-11-11 13:43:44	f	\N
227	tchodie99	justintchod@gmail.com	+22891382934	30mars	300	Leader	\N	2025-11-11 14:51:25	f	\N
232	blondelle	busnesenligne@gmail.com	+237652330326	Lovelove	300	presto	\N	2025-11-11 15:39:00	f	\N
248	low	low@gmail.com		lololo	300	presto	\N	2025-11-11 17:51:34.556581	f	\N
249	jdieu23	agbanoujeandedieu141@gmail.com		985791	300	kenshi228	\N	2025-11-11 17:56:34.789741	f	\N
233	blondelle	blondelletoukam713@gmail.com	+237652330326	lovelove	300	presto	\N	2025-11-11 15:55:05	f	\N
234	saney	landrignassingbe@gmail.com	+22892499950	924999	300	\N	\N	2025-11-11 16:03:59	f	\N
254	djamilou228	tchamouzadjamilou233@gmail.com		A977080@	300	Leader	\N	2025-11-11 18:17:40.854643	f	\N
244	dessiska	hbaofficiel@gmail.com		mar202	300	Lise	\N	2025-11-11 17:35:35.996427	f	\N
240	oudy	ebola2@icloud.com	Ndi ondobo 	oudy1999@	10350	\N	\N	2025-11-11 17:30:39.269312	f	2025-11-11
237	merveildjokpo	merveildjokpo7@gmail.com		scan222444	350	Lise	\N	2025-11-11 17:27:33.502189	f	2025-11-11
245	eric	erichourgnamba8@gmail.com		@Apo1234	350	Lise	\N	2025-11-11 17:36:54.983052	f	2025-11-11
246	emmanuel	adodoemmanuel0301@gmail.com		kardascha	350	Edem	\N	2025-11-11 17:38:03.345846	f	2025-11-11
250	princefico	ficoroland10@gmail.com		Prince90	300	Kombwoy	\N	2025-11-11 17:57:57.077822	f	\N
251	emmanuel	adodoemmanuel2009@gmail.com		kardascha	300	\N	\N	2025-11-11 18:04:05.012177	f	\N
252	lea	mauricelessagah@gmail.com		leavi777	300	\N	\N	2025-11-11 18:04:48.084337	f	\N
230	yoss	zerboelie281@gmail.com	+22644956945	Choco226	7350	presto	\N	2025-11-11 15:14:14	t	2025-11-11
79	FADEGNONSOUROUROLAND	rolandfadegnon@gmail.com	+22962109680	62109680	400	\N	\N	2025-11-10 10:35:59	f	2025-11-11
256	shaddai78	shadaishaddai78@gmail.com		Shaddai78	300	Kombwoy	\N	2025-11-11 18:18:54.39157	f	\N
255	djamilou228	tchamouzadjamilou400@gmail.com		A977080@	350	\N	\N	2025-11-11 18:18:40.901793	f	2025-11-11
257	mahamadou	mahamadouridwan2@email.com		Mahamadou 	350	\N	\N	2025-11-11 18:23:50.656862	f	2025-11-11
253	nathanlove	dongmocristabelle6@gmail.com	652330326	nathanlove	1300	\N	\N	2025-11-11 18:07:58.758907	f	\N
258	edoh	marieedoh@gmail.com	93738252	Aubin228	11350	ronaldo50	\N	2025-11-11 18:26:58.579894	t	2025-11-11
168	GnawoDohoé	gafagibril@gmail.com	+22871447354	199215	400	Edem⁠	\N	2025-11-11 06:16:58	f	2025-11-12
259	bobsavage	bobsavageoo228@gmail.com		togo00228	300	Alpha_thug	\N	2025-11-11 18:31:36.527083	f	\N
260	richard	rkpelehoungue@gmail.com		richard15.0	300	ronaldo50	\N	2025-11-11 18:32:29.575397	f	\N
261	sossou	sossoudonald06@gmail.com		00000000	300	ronaldo50	\N	2025-11-11 18:33:47.523	f	\N
262	benibokam	benibokam@gmail.com		benibokam250	300	Leaderns	\N	2025-11-11 18:37:09.014404	f	\N
306	mikederenom	johnsonpaypal2021@gmail.com		Argent2025@	300	Edem⁠	\N	2025-11-11 20:52:11.680103	f	\N
215	amou	amousunday16@gmail.com	+22893130552	99999999	350	Guillaume	\N	2025-11-11 10:03:49	t	2025-11-11
264	noel	patricknzuko@gmail.com		420022	300	\N	\N	2025-11-11 18:58:36.022501	f	\N
263	stanmvk	stanmvk8@gmail.com		Stanlad15@	350	edoh	\N	2025-11-11 18:55:02.459803	f	2025-11-11
266	nick	nickbalotelli12@gmail.com		Mopo9090	300	low	\N	2025-11-11 18:59:59.526674	f	\N
267	chriiiiii	christakado@gmail.com		huguES@99	300	edoh	\N	2025-11-11 19:00:47.723765	f	\N
314	fred	adandefreddy5@gmail.com		Adande2002$	350	edoh	\N	2025-11-11 21:47:34.359346	f	2025-11-12
269	king	anselmedubois6@gmail.com		111111111	300	edoh	\N	2025-11-11 19:04:28.296424	f	\N
270	raifatou	kaboreraifa2@gmail.com		raifatou	300	edoh	\N	2025-11-11 19:05:53.612509	f	\N
271	papa	bebe2@icloud.com		123456	300	\N	\N	2025-11-11 19:09:03.843767	f	\N
272	wewe	bikbokdavido500@gmail.com		davidoi12	300	edoh	\N	2025-11-11 19:09:39.011732	f	\N
274	mickao	espoiruriel7@gmail.com		mickao	300	edoh	\N	2025-11-11 19:12:37.609342	f	\N
275	mathias	adegankomlan08@gmail.com		Sertis343$	300	Leader	\N	2025-11-11 19:13:19.950712	f	\N
276	baron	neglojean20@gmail.com		baron45@M	300	Kombwoy	\N	2025-11-11 19:13:50.028559	f	\N
277	mano	ahlinwilfried1@gmail.com		240297	300	edoh	\N	2025-11-11 19:13:58.666961	f	\N
231	ronaldo50	ronaldopackoeur78@gmail.com	+237675649395	11085Mbawo	3350	Rodriguez	\N	2025-11-11 15:22:19	f	2025-11-11
278	stive	stivejoel01@gmail.com		AZERty128	300	stanmvk	\N	2025-11-11 19:17:07.526085	f	\N
279	tiendrebeogo	abdoulhacktiendrebeogo3@gmail.com		Abdoul77	300	edoh	\N	2025-11-11 19:19:12.633265	f	\N
280	armel	armeldario97@gmail.com		Nouveau444	300	edoh	\N	2025-11-11 19:24:01.899844	f	\N
281	belvianekengne	belviane950@gmail.com		200156	300	edoh	\N	2025-11-11 19:27:20.649416	f	\N
282	richardson	fakpelehoungue@gmail.com		57964416	300	presto	\N	2025-11-11 19:28:23.128508	f	\N
307	sam20	assogbasamuel655@gmail.com		Asso@sam2006	300	LeaderHerman	\N	2025-11-11 21:03:44.921191	f	\N
283	ralph	ralphduval021@gmail.com		123456x	350	edoh	\N	2025-11-11 19:31:48.710051	f	2025-11-11
285	arnold	arnoldbaioule@gmail.com		445566	300	edoh	\N	2025-11-11 19:35:38.428154	f	\N
286	ok	arsenebatan@gmail.com		aniversaire	300	Leaderns	\N	2025-11-11 19:36:19.937023	f	\N
284	amigos	amidepare058@gmail.com	76163727	@am76*2#	350	emmanuel	\N	2025-11-11 19:32:04.681352	f	2025-11-11
287	ruben	amedjiruben0@gmail.com		Bsb150308	350	emmanuel	\N	2025-11-11 19:41:31.845851	f	2025-11-11
289	ango121212	dagnonkomlan1@gmail.com		99615065	350	Leader	\N	2025-11-11 19:47:10.914656	f	2025-11-11
290	lidye	afilidianne@gmail.com		98401485	300	Guillaume	\N	2025-11-11 19:49:02.540997	f	\N
291	leccia	lexia.foro@gmail.com		Leccia98@	300	Kombwoy	\N	2025-11-11 19:49:26.212287	f	\N
293	ngome7	merveilngome@gmail.com		Merveil237@	300	ronaldo50	\N	2025-11-11 19:57:37.985763	f	\N
294	fabio23	fabiolemineur740@gmail.com		azerty@009	300	agbegniganfrederic@gmail.com	\N	2025-11-11 19:58:25.022811	f	\N
288	brondon	brondonguilin@gmail.com		BvhvkNh23v3ipz3	350	edoh	\N	2025-11-11 19:45:45.896702	f	2025-11-11
295	fabio228	fabiolemineur140@gmail.com		azerty@009	350	\N	\N	2025-11-11 19:59:57.074475	f	2025-11-11
309	bogar	fabricebogar1@gmail.com		fabrice	300	Lise	\N	2025-11-11 21:12:00.570716	f	\N
296	omarlad	arounamorou67@gmeil.com		OmarLaD7	300	Leader	\N	2025-11-11 20:07:29.748848	f	\N
297	leavi	alexandrelessagah@gmail.com		leavi7777	300	Ashura	\N	2025-11-11 20:14:58.743487	f	\N
298	cherif	samiracherif222@gmail.com		7111	300	Leader	\N	2025-11-11 20:26:10.41697	f	\N
299	mohamed	assoumamohamed15@gmail.com		Mohamex	300	edoh	\N	2025-11-11 20:28:01.847517	f	\N
300	dangote	massedefredy@gmaul.cim		Masko@12	300	Leader	\N	2025-11-11 20:28:22.77764	f	\N
301	dangote	massedefredy@gmail.com		Masko@12	300	\N	\N	2025-11-11 20:29:16.265178	f	\N
302	benjamin25	wudorbenjamin@gmail.com		benjamin	300	Leader	\N	2025-11-11 20:29:38.803842	f	\N
303	fangayeliba	fangayelibasilue@gmail.com		Silurees@2	300	emmanuel	\N	2025-11-11 20:30:03.594245	f	\N
292	messanh	messanhmawugna@gmail.com	91668655	mesno23	350	Guillaume	\N	2025-11-11 19:53:58.121386	t	2025-11-11
304	dgking13	dgkingdass8@gmail.com		702173	350	Leader	\N	2025-11-11 20:40:10.232051	f	2025-11-11
305	kossi43	kossiyovonou3@gmail.com		kossi1	300	Leader	\N	2025-11-11 20:51:06.807272	f	\N
311	bigarokomi	bigaro@76komi		976158	300	\N	\N	2025-11-11 21:22:18.705311	f	\N
310	degnidefrancois	francoisdegnide6@gmail.com		Deg200	350	edoh	\N	2025-11-11 21:20:16.03627	f	2025-11-11
273	wewe	davidwewe399@gmail.com		wewe12	350	sossou	\N	2025-11-11 19:12:15.5504	f	2025-11-11
312	agbegnigan228	agbegniganfrederic@gmailcom		rixwoj-3bopgi-xepsAg	300	agbegniganfrederic@gmail.com	\N	2025-11-11 21:41:38.945441	f	\N
313	bella20	afiwasikaafokpodzi@gmail.com		1987	300	Martin	\N	2025-11-11 21:42:13.968327	f	\N
268	guy	guyakaye12@gmail.com	79711122	guygmix003	350	Leader	\N	2025-11-11 19:00:51.943666	f	2025-11-11
308	keizen	bebekeizen@gmail.com	92039803	Bebe0917	350	koko	\N	2025-11-11 21:10:03.401363	t	2025-11-11
315	hyenefer14	loguebenalea@gmail.com		hyene22	300	Ashura	\N	2025-11-11 22:27:27.144395	f	\N
316	dansoufelix	dansoufelix074@gmail.con		TONI1234	300	Leader	\N	2025-11-11 22:37:57.570018	f	\N
317	dansoumicheal	felixdansou074@gmail.com		Dansou1234	300	\N	\N	2025-11-11 22:41:12.162729	f	\N
320	geoffroy	julesafanvi65@gmail.com		geoffroy@1	300	Joshua	\N	2025-11-11 22:58:07.803516	f	\N
318	gbaguidi	mouftaougbaguidi33@gmail.com		@97713056a	350	Leader	\N	2025-11-11 22:51:17.732368	f	2025-11-11
321	aquereburu	debyprcs@gmail.com		200223	350	deborah	\N	2025-11-11 23:11:01.577593	f	2025-11-11
322	aziagba	yaoaziagba@2gmail.com		AZ12()ia	300	Roger	\N	2025-11-11 23:15:37.539601	f	\N
323	charles	charle@email.com		charle	350	\N	\N	2025-11-11 23:20:07.250465	f	2025-11-11
324	komla	komlahodor926@gmail.com		AZ12()ia	300	Roger	\N	2025-11-11 23:20:57.333895	f	\N
325	winner21	princekouassi2105@gmail.com		Winner2105@	350	edoh	\N	2025-11-11 23:37:17.844155	f	2025-11-11
327	koumedjinaaugustin	augustinkoumedjina242@gmail.com		yaoAUG1225	350	Leader	\N	2025-11-11 23:45:29.476218	f	2025-11-12
326	parfaitsamala	parfaitsamala@gmail.com		kosPAR1825	400	Leader	\N	2025-11-11 23:44:25.551051	f	2025-11-12
329	layton	essosimina02@gmail.com		730867	300	Leaderns	\N	2025-11-12 00:18:59.562315	f	\N
330	hodor	hodorkomla916@gmail.com		20082008	350	Roger	\N	2025-11-12 00:52:43.110652	f	2025-11-12
331	jule	ahiandekjean9@gmail.com		90268123	350	DylanRyder	\N	2025-11-12 01:21:06.934336	f	2025-11-12
332	bernard	btyv052@gmail.com		@berna14	350	Leader	\N	2025-11-12 02:59:07.302698	f	2025-11-12
333	tanko	tankogoumi56@gmail.com		presto	300	edoh	\N	2025-11-12 04:37:47.476534	f	\N
334	mounirboy90	ouroboukari90@icloud.com		123456&	300	ango121212	\N	2025-11-12 05:21:30.704461	f	\N
335	carteblanche	noellecarinengohogbe@gmail.com		567890	300	edoh	\N	2025-11-12 05:46:26.594424	f	\N
319	nudo	nudo02@gmail.com		999000	400	edoh	\N	2025-11-11 22:51:53.586597	f	2025-11-12
336	mael	ismepro009@gmail.com		Ismepro009	350	edoh	\N	2025-11-12 06:19:04.174111	f	2025-11-12
337	yaodenis	mawussiyaodenis81@gmail.com		721888	350	Edem⁠	\N	2025-11-12 06:45:26.638732	f	2025-11-12
338	gerre12	gerardy309@gmail.com		Gerre191	300	edoh	\N	2025-11-12 06:57:26.868395	f	\N
328	komla	hodorkomla916@gmailcom		20082008	350	Roger	\N	2025-11-12 00:10:58.106225	f	2025-11-12
265	ami12	c18125210@gmail.com	93720193	93720193	3400	Leader	\N	2025-11-11 18:59:56.110615	t	2025-11-12
339	faith	togbevij14@gmail.com		just2@@2	350	dgking13	\N	2025-11-12 07:42:47.250532	f	2025-11-12
\.


--
-- Data for Name: withdrawals; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.withdrawals (id, user_email, amount, method, receiver, status, "timestamp") FROM stdin;
127cd36d-3504-42a6-9b32-eaf9ff7ce62d	prestocashfinance0@gmail.com	10000	Mix by YAS	71339325	accepted	2025-11-08 07:47:29.361778
68449d88-f1d8-4ca9-9d86-329c35b08547	prestocashfinance0@gmail.com	28000	Mix by YAS	72199198	accepted	2025-11-09 10:22:57.003146
64fa9b5a-dbc4-4f75-92be-eba6283a5acc	prestocashfinance0@gmail.com	16500	Mix by YAS	72199198	accepted	2025-11-08 12:16:45.368279
f7b7b905-66d5-4dc2-a56a-2b6b2dc9dbd9	prestocashfinance0@gmail.com	2000	Mix by YAS	71339325	accepted	2025-11-08 07:50:13.763073
f59053ec-cfe8-44a1-b660-eb9085fdc2eb	prestocashfinance0@gmail.com	9000	Mix by YAS	71339325	accepted	2025-11-08 07:57:46.531491
88a251af-24c0-489e-ba38-ed6b6623a944	prestocashfinance0@gmail.com	2000	Mix by YAS	71339325	accepted	2025-11-08 07:57:06.147852
260e94dc-2367-4ed3-82f4-b0be985cfd7e	prestocashfinance0@gmail.com	4000	Mix by YAS	72199198	accepted	2025-11-11 11:48:19.536694
1174d262-8e6e-4b72-92b7-17c04bef0a54	prestocashfinance0@gmail.com	4000	Mix by YAS	72199198	En attente	2025-11-11 22:43:12.986418
987c40ea-1825-432d-b013-285dd7546dc4	prestocashfinance0@gmail.com	5000	Mix by YAS	71339325	En attente	2025-11-11 22:43:46.713622
b66eff43-a22a-4db5-8c9e-2ad38042ac79	prestocashfinance0@gmail.com	7791	Mix by YAS	71339325	En attente	2025-11-11 22:49:06.40923
\.


--
-- Name: deposits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.deposits_id_seq', 1, false);


--
-- Name: historique_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.historique_id_seq', 479, true);


--
-- Name: investissements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.investissements_id_seq', 66, true);


--
-- Name: referrals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.referrals_id_seq', 1, false);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.transactions_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.users_id_seq', 339, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: deposits deposits_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.deposits
    ADD CONSTRAINT deposits_pkey PRIMARY KEY (id);


--
-- Name: historique historique_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_pkey PRIMARY KEY (id);


--
-- Name: investissements investissements_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.investissements
    ADD CONSTRAINT investissements_pkey PRIMARY KEY (id);


--
-- Name: referrals referrals_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT referrals_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_reference_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_reference_key UNIQUE (reference);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: withdrawals withdrawals_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.withdrawals
    ADD CONSTRAINT withdrawals_pkey PRIMARY KEY (id);


--
-- Name: deposits deposits_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.deposits
    ADD CONSTRAINT deposits_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: historique historique_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: investissements investissements_user_email_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.investissements
    ADD CONSTRAINT investissements_user_email_fkey FOREIGN KEY (user_email) REFERENCES public.users(email);


--
-- Name: referrals referrals_filleul_email_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT referrals_filleul_email_fkey FOREIGN KEY (filleul_email) REFERENCES public.users(email);


--
-- Name: referrals referrals_parrain_email_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT referrals_parrain_email_fkey FOREIGN KEY (parrain_email) REFERENCES public.users(email);


--
-- Name: transactions transactions_user_email_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_email_fkey FOREIGN KEY (user_email) REFERENCES public.users(email);


--
-- Name: withdrawals withdrawals_user_email_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.withdrawals
    ADD CONSTRAINT withdrawals_user_email_fkey FOREIGN KEY (user_email) REFERENCES public.users(email);


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--


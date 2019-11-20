--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.10
-- Dumped by pg_dump version 9.5.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = lexicon, pg_catalog;

--
-- Data for Name: registered_legal_positions; Type: TABLE DATA; Schema: lexicon; Owner: -
--

COPY registered_legal_positions (id, name, nature, country, code, insee_code, fiscal_positions) FROM stdin;
1	{"fra": "Entreprise individuelle (ou micro-entreprise)"}	individual	fra	EI	1000	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
2	{"fra": "Groupement Agricole d'Exploitation en Commun"}	person	fra	GAEC	6533	{fr_ba_ir,fr_ba_is}
3	{"fra": "Exploitation agricole à responsabilité limitée"}	person	fra	EARL	6598	{fr_ba_ir,fr_ba_is}
4	{"fra": "Groupement foncier agricole"}	person	fra	GFA	6534	{fr_ba_ir,fr_ba_is}
5	{"fra": "Société civile d'exploitation agricole"}	person	fra	SCEA	6597	{fr_ba_ir,fr_ba_is}
6	{"fra": "Société à responsabilité limitée"}	capital	fra	SARL	5499	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
7	{"fra": "Entreprise unipersonnelle à responsabilité limitée"}	person	fra	EURL	5498	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
8	{"fra": "Société anonyme"}	capital	fra	SA	5510	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
9	{"fra": "Société par actions simplifiées"}	capital	fra	SAS	5710	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
10	{"fra": "Société en nom collectif"}	person	fra	SNC	5202	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
11	{"fra": "Entreprise individuelle à responsabilité limitée"}	capital	fra	EIRL	5498	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
12	{"fra": "Société par actions simplifiées unipersonnelle"}	capital	fra	SASU	5720	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
13	{"fra": "Société en participation"}	person	fra	SEP	2310	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
14	{"fra": "Société civile immobilière"}	person	fra	SCI	6540	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
15	{"fra": "Association"}	person	fra	ASSO	9220	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
16	{"fra": "Société civile d'intérêt collectif agricole "}	person	fra	SICA	6532	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
17	{"fra": "Société en commandite par actions"}	capital	fra	SCA	5308	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
18	{"fra": "Société en commandite simple"}	person	fra	SCS	5306	{fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
19	{"fra": "Coopérative"}	person	fra	COOP	6317	{fr_ba_ir,fr_ba_is,fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
20	{"fra": "Coopérative d'utilisation de matériel agricole en commun"}	person	fra	CUMA	6316	{fr_ba_ir,fr_ba_is}
21	{"fra": "Groupement d'intérêt économique"}	person	fra	GIE	6220	{fr_ba_ir,fr_ba_is,fr_bic_ir,fr_bic_is,fr_bnc_ir,fr_bnc_is}
\.

COPY "lexicon"."master_vine_varieties" FROM stdin;
91af4b7acc8b98b0ada3aafe171ad055fc590ccb	TELEKI 5 C	Teleki 5 C	Porte-greffe	Oui	.		9958
a5e0997616696601cd95d89bfb4a26ec3abd9615	34 EM	34 Ecole de Montpellier	Porte-greffe	Oui	.		9927
90d487114c497eb242b44a6dec0940d5a5b008a1	CABESTREL N (= 68-11)	\N	Cépage	Oui	Raisins de cuve	Noir	\N
57cec83dcdae370160062a550a1db5d3e74e7447	BELAIR N	\N	Cépage	Oui	Raisins de table	Noir	\N
509278d8a1d94083f83e6d2a713bf19dc93d53ff	GROS MANSENG BLANC B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
af7ec63f5a7acaf2f0ec0562f88a04e7b3a5cdc8	COURBU B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
ed4e806d7c7a1e571948350ba63279f8b073e307	PHILIPP N	\N	Hybride	Oui	Variété agrément	Noir	\N
c428b284687f9f32019c9a543683bd6ae41ce288	MULLER-THURGAU B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
fdec15afc633bd35b8810bfc87834df091a4fc9a	PANSE PRECOCE B	\N	Cépage	Oui	Raisins de table	Blanc	\N
aa65fa99aeda180fde4b3006eaa695be87c6250b	MORRASTEL N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
481a8bdca5c800a300de4bf268f0e9a78ea57bed	MADELEINE ANGEVINE B	\N	Cépage	Oui	Raisins de table	Blanc	\N
38099dc41d51e8f440771f8b952595971a0dd498	PRECOCE DE MALINGRE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
7009a27607d6b65a34da24323dbe610e0c1b730e	PETIT COURBU B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
130a4b157e69dec7b893b20e6c8e5e4732fd9fba	PINOT NOIR N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
825182a24ead598ac01d358128f711b50f1166ab	ROUSSANNE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
c6e56bde2a5a49713b5e20b7dfaaf9ef09492596	SEMILLON B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
85da98f7e3dacb3f018526c83f61e9bf8e9ca5ba	ARRILOBA B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
d6e65737f2bcf02e2b8d7bae3ba276523c7ec5c9	ALVINA N	\N	Cépage	Oui	Raisins de table	Noir	\N
7c64cd28ecfaa8892bfd4c4f6e2ab101531f6dc9	ALVAL N	\N	Cépage	Oui	Raisins de table	Noir	\N
93ea894e915211e37e0d3858d4750edb6e682a0f	SAUVIGNON GRIS G	\N	Cépage	Oui	Raisins de cuve	Gris	\N
940047fba0e0715b06c65511d84cbb4bf69b7a67	TEMPRANILLO N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
66baca3e2bb7ba6de49c89425380e418789e87ad	SYRAH N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
a38d99935526c5e01b286eec1eaeeda53cc7f1b2	CALABRESE N (= NERO D'AVOLA)	\N	Cépage	Oui	Raisins de cuve	Noir	\N
f474ff5caf2b2e9c2a41b4a4524e037306b28500	BOUILLET N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
871d6c2a6213e09e78dd052127e76cb594ea7941	MUSCAT DE HAMBOURG N	\N	Cépage	Oui	Raisins de cuve & table	Noir	\N
252060dfb1df8aa199a0fbad2d7e4cc507323809	MONDEUSE GRISE G	\N	Cépage	Oui	Raisins de cuve	Gris	\N
017dfaf3f77d487f1da1acee8a7b782f5742458c	MUSCADELLE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
360cdb3b2c193bc28e47f9e0930f44b52c780f5d	MOURVAISON N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
1a27b86a028b0b5eadc581720cf309abefa1702f	PERDEA B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
58a744cd7c0ffca31792933311b4fd38191ba8cc	PELOURSIN	\N	Cépage	Oui	Raisins de cuve	Noir	\N
6abd5bf52c8610f6691e5e27ee3e6cfed1befb1f	FANNY B	\N	Hybride	Oui	Variété agrément	Blanc	\N
2acf05ef1e46e19d2a28b14b6848416d650c064d	FLORENTAL N	\N	Hybride	Oui	Raisins de cuve	Noir	\N
bf1aa1660e6105e82997a7bb8cd6ad1285eac676	41 B MGT	41 B Millardet et de Grasset	Porte-greffe	Oui	.		9903
760cc3c50980856d3fbd92fc28ecda32aa41ff61	GREZOT 1	Grezot 1	Porte-greffe	Oui	.		9945
637baf8459f47b3fbfd2531325b99a5509741ffa	GROLLEAU N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
9d8b8e9f9ef8aa0914fca1ca26f6f4fed2ecd2ca	JAOUMET B	\N	Cépage	Oui	Raisins de table	Blanc	\N
699229db899c6a82ba268af3ac24ba1c5e814b13	GOLDRIESLING B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
99e93edc26c43cdf2a8387e0d123ce1bfac64e0b	ELBLING B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
d7b079fbe016e37f4a5acdba05dc0541fc9004d8	TROUSSEAU GRIS G (= Chauché gris)	\N	Cépage	Oui	Raisins de cuve	Gris	\N
e21985dea2f40fa3099ede06e9c62af3cce49f0e	LILLA B	\N	Hybride	Oui	Variété agrément	Blanc	\N
15eaf807afedbcebd06c60d05af874e59d13a6a0	110 RICHTER	110 Richter	Porte-greffe	Oui	.		9909
840092fa2d9e5bc3cb784a2314519ae1bc85f95a	140 RUGGERI	140 Ruggeri	Porte-greffe	Oui	.		9950
c1b0f55d71204558d489c5f04f3a626690023b66	MUSCAT CENDRE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
c26e711e82b97a2b5611aaf8a8bfa32efdeb1e48	MONTILS B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
ca00c220d7303ae8371cc7f3a0d013c51c1cab30	CLAIRETTE B	\N	Cépage	Oui	Raisins de cuve & table	Blanc	\N
ac771eb532dda3b6be3e001373c00afc348997db	CARIGNAN GRIS G	\N	Cépage	Oui	Raisins de cuve	Gris	\N
0c91a75c98737c1320bd29ac8f8ac353cb06105d	SULIMA B	\N	Cépage	Oui	Raisins de table	Blanc	\N
5ddcdb63ea195f3adab84b0138b2a84d15f85bae	PETIT MANSENG B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
d7b61b2b79aaf15ce25d9ea517a3c937c5355f65	ONCHETTE N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
8ee2466f4e2108556c163e8dd8278fea6df45b27	BIA BLANC B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
221924ae3b4185b753804bd00a5f930960084d52	ZINFANDEL  N (= PRIMITIVO)	\N	Cépage	Oui	Raisins de cuve	Noir	\N
e5516c073c1b56092d2e5f0e105556860223f03f	VERDESSE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
12aca93aa31161ac10895aaa80228ee51656bd4a	SERENEZE N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
ffdbec6f305c572a2a9a2ec3c6f8ac25e8fc4f10	SERVANIN N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
eb90e0050f2bd81754efd015659bd0f2f925f8ca	TEOULIER N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
1d79824400ef4ba3d09056309530817e20f8667d	RAYON D'OR B	\N	Hybride	Oui	Raisins de cuve	Blanc	\N
cd07065888cdf1fe66fe27a1b9efc7bc634e02bd	BC 2	Berlandieri-Colombard 2	Porte-greffe	Oui	.		9954
92c865cdf5c9a9377369314de5539320d5da1f7f	PICARDAN B (= Araignan blanc)	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
ed816f680f79fd7ae1bbf115fce210883e93cec1	PINOT BLANC B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
5c473f456cdfba3d112b8df5696d0ccfb4b5dd2c	ORA B	\N	Cépage	Oui	Raisins de table	Blanc	\N
1f80505a5e05c6e813f8965032b757f1162f7a44	GEWURZTRAMINER RS	\N	Cépage	Oui	Raisins de cuve	Rose	\N
08e2d7c049be3b245f9110129d796ea56df013cf	CALADOC N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
7948eb55194df2e847ab19796e060f4911ce732a	PRECOCE BOUSQUET B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
46f28a6f9ad2e23eca7b1d699fdda72988819383	PRUNELARD N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
2dd3b4d21ebf84be5907154942ead67d8b25400f	OLIVETTE NOIRE N	\N	Cépage	Oui	Raisins de table	Noir	\N
a94d48f07f744112840a09d7ebe92f4c6cad51e0	KADARKA N (= Gamza)	\N	Cépage	Oui	Raisins de cuve	Noir	\N
93ab717f05635877b5dc7060019f81c71704a164	KNIPPERLE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
c5b8b15b04902d22ab5723e4cc88ffb26569e0c9	PICARLAT N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
269638626fd28e53c15ea1206127dad5cee3dd5e	ALEDO B	\N	Cépage	Oui	Raisins de table	Blanc	\N
f6312d2ec064f5f872ffa64e0cfac28a91ea0f72	BACHET N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
15a3574a50e046de0cf5457506efeec2b1abeeff	MOSCHOFILERO RS	\N	Cépage	Oui	Raisins de cuve	Rose	\N
1c6e5d5c6c4b32c147b2278447231ff6d4fc4549	PASCAL B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
a4c30b66c5b267f7c2db54c58b240ef8f17439bb	NEMADEX AB	Nemadex Alain Bouquet	Porte-greffe	Oui	.		9929
3dfcd462d665fff8bda497b661c111223b574c28	216-3 CASTEL	216-3 Castel	Porte-greffe	Oui	.		9919
510cce92238381c802b8b388018053660ac920b5	125 AA	Kober 125 AA	Porte-greffe	Oui	.		9928
f824d22c8cdba2b076141e5f45090d09b171966d	TROUSSEAU N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
8a4fd883868cfe27c19be4c6d5d43df2ede4dd49	RIVAIRENC N (= Aspiran noir)	\N	Cépage	Oui	Raisins de cuve	Noir	\N
2d11219c7de85e4d4bbadea7431c00064988866c	RIBOL N	\N	Cépage	Oui	Raisins de cuve & table	Noir	\N
6b2bec0354c982821d64581d88fc8dbacde758c0	CENTENNIAL SEEDLESS B	\N	Cépage	Oui	Raisins de table	Blanc	\N
9743558e0d5db6803cf1b933b4f7ade67b355594	CHASAN B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
84919e0e9b1a9caf4bf6ac2e45bdc9fce9b0a891	CHENIN B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
62418397964233b8b2faa0ca1b21142fb28fede4	FLAME SEEDLESS RS	\N	Cépage	Oui	Raisins de table	Rose	\N
4bf080cb68b5646d4b2cc7f68bc13dfa23ae4b40	FURMINT BLANC B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
6a1c6bd2d88036e03922d77c31a5f1a291a323d1	MADELEINE ROYALE B	\N	Cépage	Oui	Raisins de table	Blanc	\N
76f2ac6ba05b799ff719ce6161cee7fb120ea008	BOUYSSELET B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
4b042b9690d98a1ff4c3a2e7ad033cd5affb1ce8	AUXERROIS B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
abea217ab4861291ab0808aebdfaf21cbead7d65	ATTIKI N	\N	Cépage	Oui	Raisins de table	Noir	\N
8fa0d97d2259c07a4c9e737fa54e1d58f4934ad9	GRAND NOIR DE LA CALMETTE N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
70130a0681405ec5406acafdac28573de78e9d9e	GENOUILLET N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
c56389e3669845c3cb80e0132a3ab2f27699b094	GARONNET N	\N	Hybride	Oui	Raisins de cuve	Noir	\N
d43d49b1493d4fab99e29674ab22be48a30b4ef9	196-17 CASTEL	196-17 Castel	Porte-greffe	Oui	.		9926
69e02e280c7903e99ea9efb4bc02471b6d8927ba	MUSCAT A PETITS GRAINS ROSE RS	\N	Cépage	Oui	Raisins de cuve	Rose	\N
d286d6e9ca5c3804794da63b7fb4345d2e1ecf45	MOURVEDRE N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
17ddd0548b1cc270e10acf8619ff9084db652a59	MONDEUSE BLANCHE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
26b5389721376d45b6eb7f6af2968259519cdf31	GROS VERT B	\N	Cépage	Oui	Raisins de cuve & table	Blanc	\N
2d7be04950b6e21faa836665e0d36a37379b0226	PINOTAGE N	\N	Cépage	Oui	Raisins de cuve	Noir	\N
3c3691c24aae566d034a59f9679dd81d70442415	ALTESSE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
ac6dc7ca57774d1b6d4cd6448b5e0414f9e941b1	ARVINE B	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
76be9aaacab3bf9f351986b6a5021a5f9bba689d	SULTANINE B (=Thomson seedless)	\N	Cépage	Oui	Raisins de table	Blanc	\N
3c72cd4fa9a09eec3bf42623985e214b36324b4f	RIVAIRENC B (= Aspiran blanc)	\N	Cépage	Oui	Raisins de cuve	Blanc	\N
\.


COPY "lexicon"."registred_protected_designation_of_origins" FROM stdin;
1645	-------	\N	IGP -	{"fra": "Pâté de Campagne Breton"}	Pâté de Campagne Breton	\N
1645	-------	\N	STG -	{"fra": "Moules de bouchot"}	Moules de bouchot	STG7784
1645	-------	LR - 	\N	{"fra": " Chapon fermier élevé en plein air, entier et découpes, frais ou surgelé"}	 Chapon fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/14/88
1645	-------	LR - 	\N	{"fra": " Découpes et morceaux de poulet fermier aromatisés ou condimentés ou marinés"}	 Découpes et morceaux de poulet fermier aromatisés ou condimentés ou marinés	LA/32/99
1645	-------	LR - 	\N	{"fra": " Poulet blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	 Poulet blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/22/92
1645	-------	LR - 	\N	{"fra": " Poulet blanc fermier élevé en plein air, entier et découpes, frais ou surgelé "}	 Poulet blanc fermier élevé en plein air, entier et découpes, frais ou surgelé 	LA/16/92
1645	-------	LR - 	\N	{"fra": " Poulet blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	 Poulet blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/04/04
1645	-------	LR - 	\N	{"fra": " Poulet noir fermier élevé en plein air, entier et découpes, frais ou surgelé"}	 Poulet noir fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/07/71
1645	-------	LR - 	\N	{"fra": " Salaisons sèches à base de viande de porc"}	 Salaisons sèches à base de viande de porc	LA/07/91
1645	-------	LR - 	\N	{"fra": " Viande et abats frais et surgelées d'agneau de 14 à 22 kg de carcasse, nourri par tétée au pis au moins 90 jours ou jusqu'à abattage si abattu entre 70 et 89 jours "}	 Viande et abats frais et surgelées d'agneau de 14 à 22 kg de carcasse, nourri par tétée au pis au moins 90 jours ou jusqu'à abattage si abattu entre 70 et 89 jours 	LA/05/07
1645	-------	LR - 	\N	{"fra": " Viande et abats frais et surgelés d'agneau de 13 à 22 kg de carcasse, nourri par tétée au pis au moins 70 jours ou jusqu'à abattage si abattu entre 60 et 69 jours"}	 Viande et abats frais et surgelés d'agneau de 13 à 22 kg de carcasse, nourri par tétée au pis au moins 70 jours ou jusqu'à abattage si abattu entre 60 et 69 jours	LA/07/07
1645	-------	LR - 	\N	{"fra": " Viande fraîche de gros bovins fermiers"}	 Viande fraîche de gros bovins fermiers	LA/16/93
1645	-------	LR - 	\N	{"fra": " Viande fraîche de veau nourri par tétée au pis pouvant recevoir un aliment complémentaire liquide"}	 Viande fraîche de veau nourri par tétée au pis pouvant recevoir un aliment complémentaire liquide	LA/20/92
1645	-------	LR - 	\N	{"fra": " Viande hachée fraîche et surgelée de gros bovins de boucherie"}	 Viande hachée fraîche et surgelée de gros bovins de boucherie	LA/29/01
1645	-------	LR - 	\N	{"fra": "Abricot"}	Abricot	LA/04/01
1645	-------	LR - 	\N	{"fra": "Ail rose"}	Ail rose	LA/02/66
1645	-------	LR - 	\N	{"fra": "Andouillette supérieure pur porc"}	Andouillette supérieure pur porc	LA/06/16
1645	-------	LR - 	\N	{"fra": "Baguette de pain de tradition française"}	Baguette de pain de tradition française	LA/22/01
1645	-------	LR - 	\N	{"fra": "Bar d'aquaculture marine "}	Bar d'aquaculture marine 	LA/01/11
1645	-------	LR - 	\N	{"fra": "Betteraves rouges"}	Betteraves rouges	LA/03/03
1645	-------	LR - 	\N	{"fra": "Betteraves rouges cuites sous vide"}	Betteraves rouges cuites sous vide	LA/21/99
1645	-------	LR - 	\N	{"fra": "Betteraves rouges cuites sous vide"}	Betteraves rouges cuites sous vide	LA/05/97
1645	-------	LR - 	\N	{"fra": "Betteraves rouges cuites sous vide"}	Betteraves rouges cuites sous vide	LA/08/98
1645	-------	LR - 	\N	{"fra": "Blanc de poulet cuit"}	Blanc de poulet cuit	LA/03/07
1645	-------	LR - 	\N	{"fra": "Brie au lait thermisé, crème et protéines de lait pasteurisées"}	Brie au lait thermisé, crème et protéines de lait pasteurisées	LA/28/99
1645	-------	LR - 	\N	{"fra": "Brioche"}	Brioche	LA/02/02
1645	-------	LR - 	\N	{"fra": "Bulbes à fleurs de dahlias"}	Bulbes à fleurs de dahlias	LA/07/10
1645	-------	LR - 	\N	{"fra": "Cabécou"}	Cabécou	LA/25/05
1645	-------	LR - 	\N	{"fra": "Caille fermière élevée en plein air, entière et découpes, fraîche ou surgelée"}	Caille fermière élevée en plein air, entière et découpes, fraîche ou surgelée	LA/20/90
1645	-------	LR - 	\N	{"fra": "Caille jaune fermière élevée en plein air, entière, fraîche ou surgelée"}	Caille jaune fermière élevée en plein air, entière, fraîche ou surgelée	LA/13/78
1645	-------	LR - 	\N	{"fra": "Canard de Barbarie fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Canard de Barbarie fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/04/74
1645	-------	LR - 	\N	{"fra": "Canard fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Canard fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/02/85
1645	-------	LR - 	\N	{"fra": "Canard mulard gavé entier, foie gras cru et produits de découpes crus frais et magrets surgelés"}	Canard mulard gavé entier, foie gras cru et produits de découpes crus frais et magrets surgelés	LA/12/89
1645	-------	LR - 	\N	{"fra": "Canette et canard de Barbarie fermiers élevés en plein air, entiers et découpes, frais ou surgelés"}	Canette et canard de Barbarie fermiers élevés en plein air, entiers et découpes, frais ou surgelés	LA/09/04
1645	-------	LR - 	\N	{"fra": "Carottes des sables"}	Carottes des sables	LA/04/67
1645	-------	LR - 	\N	{"fra": "Cassoulet appertisé"}	Cassoulet appertisé	LA/02/12
1645	-------	LR - 	\N	{"fra": "Cassoulet au porc appertisé"}	Cassoulet au porc appertisé	LA/03/15
1645	-------	LR - 	\N	{"fra": "Cerises"}	Cerises	LA/08/17
1645	-------	LR - 	\N	{"fra": "Chapon blanc à pattes bleues fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc à pattes bleues fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/06/04
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air entier et découpes, frais ou surgelé	LA/55/88
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais	LA/14/98
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais	LA/13/98
1645	-------	LR - 	\N	{"fra": "Emmental"}	Emmental	LA/04/79
1645	-------	LR - 	\N	{"fra": "Pâté de campagne supérieur"}	Pâté de campagne supérieur	LA/03/10
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/32/88
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/02/01
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/16/88
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/13/00
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/29/89
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/26/99
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/11/06
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/04/06
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/18/92
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/38/89
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/16/00
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/06/98
1645	-------	LR - 	\N	{"fra": "Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon blanc fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/29/88
1645	-------	LR - 	\N	{"fra": "Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/15/94
1645	-------	LR - 	\N	{"fra": "Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/05/13
1645	-------	LR - 	\N	{"fra": "Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/01/14
1645	-------	LR - 	\N	{"fra": "Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/02/97
1645	-------	LR - 	\N	{"fra": "Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/16/94
1645	-------	LR - 	\N	{"fra": "Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/08/95
1645	-------	LR - 	\N	{"fra": "Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/04/07
1645	-------	LR - 	\N	{"fra": "Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/19/94
1645	-------	LR - 	\N	{"fra": "Chapon de pintade jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon de pintade jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/17/94
1645	-------	LR - 	\N	{"fra": "Pommes"}	Pommes	LA/04/96
1645	-------	LR - 	\N	{"fra": "Chapon fermier élevé en plein air, entier et découpes, frais"}	Chapon fermier élevé en plein air, entier et découpes, frais	LA/28/88
1645	-------	LR - 	\N	{"fra": "Chapon fermier élevé en plein air, entier et découpes, frais"}	Chapon fermier élevé en plein air, entier et découpes, frais	LA/17/97
1645	-------	LR - 	\N	{"fra": "Chapon fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/30/88
1645	-------	LR - 	\N	{"fra": "Chapon fermier élevé en plein air, entier et découpes, surgelé"}	Chapon fermier élevé en plein air, entier et découpes, surgelé	LA/14/91
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/19/00
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/31/88
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/04/17
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/14/89
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/03/97
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/21/94
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/18/02
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/17/00
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/12/02
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/12/06
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/05/06
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon jaune fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/28/89
1645	-------	LR - 	\N	{"fra": "Chapon jaune fermier élevé en plein air, entier, frais"}	Chapon jaune fermier élevé en plein air, entier, frais	LA/48/88
1645	-------	LR - 	\N	{"fra": "Chapon noir fermier élevé en plein air, entier et découpes, frais"}	Chapon noir fermier élevé en plein air, entier et découpes, frais	LA/54/88
1645	-------	LR - 	\N	{"fra": "Chapon noir fermier élevé en plein air, entier et découpes, frais"}	Chapon noir fermier élevé en plein air, entier et découpes, frais	LA/18/06
1645	-------	LR - 	\N	{"fra": "Chapon noir fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon noir fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/23/90
1645	-------	LR - 	\N	{"fra": "Chapon noir fermier élevé en plein air, entier et découpes, frais ou surgelé"}	Chapon noir fermier élevé en plein air, entier et découpes, frais ou surgelé	LA/17/88
1645	-------	LR - 	\N	{"fra": "Choucroute"}	Choucroute	LA/01/09
1645	-------	LR - 	\N	{"fra": "Cidre de variété Guillevic"}	Cidre de variété Guillevic	LA/15/99
1645	-------	LR - 	\N	{"fra": "Conserves de maquereaux"}	Conserves de maquereaux	LA/02/16 
1645	-------	LR - 	\N	{"fra": "Conserves de sardines pêchées à la bolinche"}	Conserves de sardines pêchées à la bolinche	LA/01/03
1645	-------	LR - 	\N	{"fra": "Conserves de thon"}	Conserves de thon	LA/27/06
1645	-------	LR - 	\N	{"fra": "Coppa"}	Coppa	LA/08/09
1645	-------	LR - 	\N	{"fra": "Coquille Saint-Jacques entière et fraîche"}	Coquille Saint-Jacques entière et fraîche	LA/11/02
1645	-------	LR - 	\N	{"fra": "Crème anglaise"}	Crème anglaise	LA/03/18
1645	-------	LR - 	\N	{"fra": "Crème fluide"}	Crème fluide	LA/10/89
1645	-------	LR - 	\N	{"fra": "Crevette d'élevage Penaeus monodon présentée entière crue surgelée ou entière crue surgelée "}	Crevette d'élevage Penaeus monodon présentée entière crue surgelée ou entière crue surgelée 	LA/05/03
1645	-------	LR - 	\N	{"fra": "Daurade daquaculture marine"}	Daurade daquaculture marine	LA/02/11
1645	-------	LR - 	\N	{"fra": "Dinde de découpe fermière élevée en plein air, fraîche ou surgelée"}	Dinde de découpe fermière élevée en plein air, fraîche ou surgelée	LA/02/98
\.

COPY "lexicon"."cadastral_land_parcel_zones" FROM stdin;
401340000A0260	A	260	732	0106000020E610000001000000010300000001000000040000002B7D321015F4ECBF9FE925C632204640240A2DEBFEF1ECBFB84890002420464024D813B8D0F0ECBF945B49E1302046402B7D321015F4ECBF9FE925C632204640	0101000020E6100000D21FD13B4CF2ECBFF9D9FF372D204640
40326000AB0456	AB	456	119	0106000020E610000001000000010300000001000000050000007C1574D602D6F4BF082EA0617BF94540F21F77B6ECD5F4BF61B5E8537DF9454030C099F3E7D6F4BF5A208B7E7EF945402A3D2E05FFD6F4BF3750E09D7CF945407C1574D602D6F4BF082EA0617BF94540	0101000020E61000001B44A3F974D6F4BFD84167F37CF94540
401290000A0208	A	208	1000	0106000020E610000001000000010300000001000000050000007BA6F2D13DE6F3BF96F8927CDBD1454034CC1A063DE5F3BFAA471ADCD6D145407DBC4681F4E3F3BFCFA2772AE0D14540C4961E4DF5E4F3BF91D442C9E4D145407BA6F2D13DE6F3BF96F8927CDBD14540	0101000020E6100000F52E1D2B19E5F3BF6B10F3D2DDD14540
40300000AB0262	AB	262	790	0106000020E61000000100000001030000000100000005000000A1AAF87596EFF0BF0B3895568DD745402723788DA7EFF0BF2AEA27F796D745408565C7A1D9F0F0BF25EB707495D74540B0D3FEBDCAF0F0BFE262FB7F8BD74540A1AAF87596EFF0BF0B3895568DD74540	0101000020E61000008495356739F0F0BF05DB8D4D91D74540
401290000A0213	A	213	1000	0106000020E610000001000000010300000001000000050000002529441BDBE6F3BF7E80FFF7F1D145402612F17B40E5F3BFE1308793EAD14540483657CD73E4F3BFAF0AD462F0D145400BABC2B00DE6F3BF639C1AC3F7D145402529441BDBE6F3BF7E80FFF7F1D14540	0101000020E6100000648EF54AA7E5F3BFA5E0112CF1D14540
400950000B0322	B	322	60	0106000020E61000000100000001030000000100000005000000FEB5BC72BD2DEDBF052857C224CE4540BE83447F0D2DEDBF3B9D75D723CE45409795815E132DEDBF106E7C3727CE4540164ED2FC312DEDBFFC8051932ACE4540FEB5BC72BD2DEDBF052857C224CE4540	0101000020E6100000FFF6EB78502DEDBFC384927226CE4540
400180000A0392	A	392	6	0106000020E61000000100000001030000000100000004000000A034D4282459EABF53F64CE5A3E64540C99C1D5F3159EABF53F64CE5A3E64540B50DEDAD9259EABF5DA38A879CE64540A034D4282459EABF53F64CE5A3E64540	0101000020E61000005E4A4A674D59EABFADDAB670A1E64540
40001000BY0161	BY	161	605	0106000020E6100000010000000103000000010000000500000065074B2B7494D0BFFCAFCE8CD9DA4540422D61C84590D0BFDF9C5B32D8DA454004A50D2CEC8ED0BFCFFE9B72E0DA454090CCD9F11593D0BF638A28DCE1DA454065074B2B7494D0BFFCAFCE8CD9DA4540	0101000020E610000099EAFCBBAF91D0BF4F245E03DDDA4540
40250000AB0369	AB	369	62	0106000020E6100000010000000103000000010000000400000095511B8B5CA6DCBFF676F0B84DF8454076CAFED4D3A2DCBFCD7344BE4BF8454008FAB083EFA2DCBF020B05114EF8454095511B8B5CA6DCBFF676F0B84DF84540	0101000020E610000007B243A10AA4DCBF42A7682D4DF84540
401000000A0493	A	493	195	0106000020E6100000010000000103000000010000000500000068C240214C1BD1BFEF8A85C6B8F64540DAA84E07B21ED1BF00F03E7DBAF64540AA0194D0A71FD1BF36F5CB71B8F64540290FC1278C1CD1BF4A6C2D82B5F6454068C240214C1BD1BFEF8A85C6B8F64540	0101000020E61000009BFA31F6701DD1BF86A06C36B8F64540
40231000AH0084	AH	84	1525	0106000020E61000000100000001030000000100000005000000EF4163810A02F3BF32AA0CE36EC845409AF4520CEB01F3BF3FD7080E79C84540D90352071E04F3BF621D7D827AC84540AFD2DD753604F3BF56664AEB6FC84540EF4163810A02F3BF32AA0CE36EC84540	0101000020E6100000E5416A4B1403F3BF773DF69B74C84540
400850000C0177	C	177	1458	0106000020E61000000100000001030000000100000005000000105839B4C8B6E9BF33B385D6791F4640352B36412FB7E9BFBFBA2A508B1F4640E4BED53A71B9E9BF12A5187B8A1F4640F7A9CF7A9DB9E9BF152411757A1F4640105839B4C8B6E9BF33B385D6791F4640	0101000020E6100000AEEB2C593CB8E9BF9BD7CA36821F4640
40212000AA0638	AA	638	1032	0106000020E610000001000000010300000001000000050000005D4A02791B80F2BFD10BD2E7FEC6454002E1F9FB7B7FF2BF511AC5CD04C745405C7924B95781F2BF531B41CF0BC745406ACCDA5CEB81F2BFC7D45DD905C745405D4A02791B80F2BFD10BD2E7FEC64540	0101000020E6100000EAEF31D4B580F2BF885D1C5805C74540
400600000A0032	A	32	78	0106000020E61000000100000001030000000100000005000000D34444D6BF50E0BF325C78B9E3294640A700BD152E50E0BFE5D8D53FE32946405CB68C8AEE4FE0BFF56569A7E6294640E6D07D946C50E0BF0D326E0FE7294640D34444D6BF50E0BF325C78B9E3294640	0101000020E6100000300522235350E0BFBDC88A21E5294640
403050000A0165	A	165	1162	0106000020E61000000100000001030000000100000005000000B4626EADE504D5BFDEFC2BD093D34540CE6F98689002D5BF635D818D90D345409F477B7203F4D4BFD5F9015999D345401CFF4F0F1BF6D4BFAA543F259DD34540B4626EADE504D5BFDEFC2BD093D34540	0101000020E61000006B598AA54DFCD4BF429577C896D34540
400020000A0549	A	549	75	0106000020E6100000010000000103000000010000000400000085BB69E9C0E8E7BFCD316A08D8CC454077AFA4260BE9E7BF928F824CD7CC4540FB56900B73E7E7BF83AC0210D2CC454085BB69E9C0E8E7BFCD316A08D8CC4540	0101000020E6100000A8408A5E6AE8E7BF4CCF4FCCD5CC4540
400600000A0036	A	36	15	0106000020E61000000100000001030000000100000004000000FB95CE876749E0BFC0AA1F402B2A4640F689F2BB9F49E0BF208B7E7E292A46404A8D1A5DEF48E0BF61EA9DC02A2A4640FB95CE876749E0BFC0AA1F402B2A4640	0101000020E6100000148F9E355249E0BF6AB5BE7F2A2A4640
402480000A0249	A	249	1125	0106000020E610000001000000010300000001000000040000008AD8710D7D01F6BF53F64CE5A3C94540D3AB5C03B6FEF5BFF8AF07EE9BC94540D3C32BA457FEF5BF9E9B919CA7C945408AD8710D7D01F6BF53F64CE5A3C94540	0101000020E6100000BCC2A89183FFF5BFF715A27AA2C94540
402740000A0899	A	899	20	0106000020E6100000010000000103000000010000000400000055849B8C2A43E4BF76AE83DE76F64540065B36847442E4BF23884E2A75F64540830D993CAF42E4BFB122597677F6454055849B8C2A43E4BF76AE83DE76F64540	0101000020E6100000A1F978C4C442E4BFC31DB97F76F64540
400020000A0476	A	476	72	0106000020E610000001000000010300000001000000040000009A661591BCCEE7BFE9DC4834DCCC45409D92BDEF29CAE7BFE877ABF8D0CC45407B01AC448FCEE7BF65129AC9DCCC45409A661591BCCEE7BFE9DC4834DCCC4540	0101000020E61000003CFED44127CDE7BF12CD84A7D8CC4540
400060000A0095	A	95	2800	0106000020E61000000100000001030000000100000004000000A8A55E5C4F99E9BFF9AD8CFCB008464025BB88A53792E9BF2DBB16E3B20846408AD5D5D3FD92E9BFA4E3C51DCA084640A8A55E5C4F99E9BFF9AD8CFCB0084640	0101000020E6100000C7BCE9F1D694E9BF981923FFB9084640
401360000A0281	A	281	1223	0106000020E6100000010000000103000000010000000500000051B2E611ED74DBBF7D0E87003BCC45406E371CF1BF70DBBF2C50E67A36CC45402E9FF6A5C86BDBBF19BA23AD42CC454098480E7D1C72DBBFD6D2927D46CC454051B2E611ED74DBBF7D0E87003BCC4540	0101000020E6100000B81AE95CBA70DBBFA87B5CE43ECC4540
401490000A0131	A	131	954	0106000020E61000000100000001030000000100000004000000AD252E11B92AD6BF23CCA3D1D31446403ABEAC3F7823D6BFFCEE0C09CE1446400695021C8C22D6BF1256BEC2DD144640AD252E11B92AD6BF23CCA3D1D3144640	0101000020E610000050289F799425D6BF105B7A34D5144640
403050000A0172	A	172	1446	0106000020E61000000100000001030000000100000005000000049C9438E114D5BF9D8F21B6AAD34540A0DE8C9AAF12D5BF2D9E3017A7D3454008D5BC998702D5BF9E149CB0B3D3454033BCFEC98404D5BF25485B4BB7D34540049C9438E114D5BF9D8F21B6AAD34540	0101000020E6100000C93B0546B30BD5BF5E54FA29AFD34540
401490000A0358	A	358	875	0106000020E61000000100000001030000000100000004000000013E2E60B829D6BFD3E92FAAFB1446405CBDD4192925D6BFE8F4BC1B0B1546405D8539E6E129D6BF3A43CC800E154640013E2E60B829D6BFD3E92FAAFB144640	0101000020E6100000E82A14204128D6BF520B931707154640
401850000A0145	A	145	2790	0106000020E61000000100000001030000000100000005000000A24F9ABCB758D4BF763980D998CE4540B9EF07F2A265D4BF18DB5A1597CE4540A8D8E2642C64D4BF488AC8B08ACE4540ABF0C2312658D4BF834655B88ACE4540A24F9ABCB758D4BF763980D998CE4540	0101000020E6100000F590E4B98B5ED4BFCBDD936F91CE4540
400470000A0510	A	510	29	0106000020E61000000100000001030000000100000004000000FC6F253B36C2E6BF222B099AE0C94540AD6301B8FEC2E6BFC0DCDDB9E6C9454091D7DE0264C3E6BFEA471EE3E5C94540FC6F253B36C2E6BF222B099AE0C94540	0101000020E6100000123957A7DDC2E6BFEF6FAC67E4C94540
402460000A0074	A	74	2914	0106000020E610000001000000010300000001000000050000008ED948C8F650E7BF51908E61041746403C5A8B057455E7BF6B77B4160B174640688BB5094158E7BF88C0ECF9F5164640BD18CA897655E7BF30534953F31646408ED948C8F650E7BF51908E6104174640	0101000020E6100000FD0E5E3CE454E7BF031B5717FF164640
402460000A0238	A	238	86	0106000020E61000000100000001030000000100000004000000C696D4BFDA47E8BFA3A190AEE3164640926D2A9CEE46E8BF8C5FC2B2E3164640281A5A530F47E8BF3BC43F6CE9164640C696D4BFDA47E8BFA3A190AEE3164640	0101000020E61000002A0A733A4847E8BF2497DB99E5164640
40004000AB0132	AB	132	11	0106000020E610000001000000010300000001000000050000005C5DA9C2FADAF5BF154FE2186ED4454076CE05E401DBF5BF278CC11E6ED445402A690FC52EDBF5BF4EDCE0FA66D4454091B6F1272ADBF5BF661EAFF666D445405C5DA9C2FADAF5BF154FE2186ED44540	0101000020E61000008A810CC113DBF5BFFCA33ECB6AD44540
400250000A0153	A	153	78	0106000020E610000001000000010300000001000000050000006A02FB9E477BDBBF54573ECBF3EB4540516C6006BE7DDBBF4705A96FF4EB454046668929EC7DDBBF72E6B22CF3EB454075F002DB777BDBBF54B99A86F2EB45406A02FB9E477BDBBF54573ECBF3EB4540	0101000020E610000083D7A00E9A7CDBBFB876897BF3EB4540
401430000A0099	A	99	655	0106000020E61000000100000001030000000100000004000000B631D17BBEC1E5BF74A8F0B105E74540AAD72D0263BDE5BFA1B888940BE74540CCA43CA9E5BDE5BFD76432C115E74540B631D17BBEC1E5BF74A8F0B105E74540	0101000020E61000000F3A696202BFE5BF4E978E020DE74540
403020000A0398	A	398	395	0106000020E610000001000000010300000001000000040000001B9C887E6D7DEFBF475E317E7503464000CEE6CCD17EEFBF2D91B0146E034640C0812447957CEFBF8259FC016A0346401B9C887E6D7DEFBF475E317E75034640	0101000020E610000049F9DB309C7DEFBFA86D9F316F034640
403060000B0014	B	14	2240	0106000020E61000000100000001030000000100000005000000E48D829664F3F0BF39E686F079C545405B0C1EA67DF3F0BF01BEDBBC71C545401EFE9AAC51EFF0BF790E1B1B70C545408F119A6E23EFF0BFCE4F711C78C54540E48D829664F3F0BF39E686F079C54540	0101000020E61000006650109157F1F0BFDE527AFD74C54540
40001000CC0081	CC	81	931	0106000020E6100000010000000103000000010000000500000099CB57135589D0BFB6566AACB3D9454032E2A716B68BD0BF990C6C3AA7D94540CE7EEE152788D0BF705177AFA4D945407EF156A71485D0BFD5EB1681B1D9454099CB57135589D0BFB6566AACB3D94540	0101000020E610000042BA9F098588D0BF56ED7468ACD94540
402860000A0010	A	10	3355	0106000020E61000000100000001030000000100000005000000A992B71270FEE0BF21938C9C85D34540ADD227035101E1BF1AD01CA386D34540C8EC2C7AA702E1BF157AB3BC61D34540D926158DB5FFE0BF3AE004F060D34540A992B71270FEE0BF21938C9C85D34540	0101000020E6100000C57E027E8800E1BF52BBACAB73D34540
403240000A0268	A	268	33	0106000020E61000000100000001030000000100000004000000A2E1DE461424EBBF8458479FA0E445407961C66F6524EBBF637A67599CE4454028356A74BD23EBBF3DDA931BA0E44540A2E1DE461424EBBF8458479FA0E44540	0101000020E6100000C1D2AF631224EBBF61E4C0069FE44540
401610000A0337	A	337	35	0106000020E610000001000000010300000001000000040000006E7A06C36FF98EBFE9407B9A380E464053DB3CC4F5DE8EBFEE9B56653A0E46400EAA6807B7108FBFD69B07663B0E46406E7A06C36FF98EBFE9407B9A380E4640	0101000020E6100000455539DA5EF88EBF3A28F3213A0E4640
40310000AB0267	AB	267	20	0106000020E61000000100000001030000000100000005000000CF60F82DDF3FF5BF90AD1D7BACE04540365C3F582140F5BFA703594FADE045405A0751082E40F5BFE3D98AA2ACE045400FBD207DEE3FF5BF84BDE4DAABE04540CF60F82DDF3FF5BF90AD1D7BACE04540	0101000020E6100000142379510740F5BFBC52F192ACE04540
335010000A1428	A	1428	442162	0106000020E6100000010000000103000000010000004F02000048EF65EC9503E4BF0877C2A629534640DCDF8F91A204E4BFE61368661C534640C9682E81A504E4BF51267F411C534640318969954F05E4BF3140A209145346408FA9BBB20B06E4BF778192020B53464035232823D306E4BF170E846401534640B3D881CEFF06E4BF8FA67A32FF5246409C583BE52C07E4BF6142BBF9FC524640CE1F2E94A707E4BFBDB90908F7524640A5FED53E7808E4BF1C295B24ED52464090CB6E1C6709E4BF3B06BF68EA524640CD806907120AE4BF069D103AE8524640709A99F4520CE4BF750FBF51E1524640E39304977D0DE4BF7D96E7C1DD5246401A4F04711E0EE4BFA18CA7D4DB52464022ABB6F6990EE4BF37F69100DA524640766968A8F60EE4BFD9F39084D8524640F7E2303D0610E4BF40F9BB77D4524640AEA069899511E4BF4972AF82CE5246407440B73C7B13E4BFFF4EA445C7524640C39B35785F15E4BFBB5E9A22C0524640D90528B27B17E4BF1924D813B852464047F3B688DE18E4BF81B971E6B252464062AEFB7DB519E4BFAC167DAAAF5246404D66BCADF41AE4BFD879C0E1AA524640DF28C302A91EE4BFB6D4E6A49C524640FEAA6DD45420E4BF3C139A2496524640CDBE3CAE5722E4BF9F67FD778E524640B17E7DBE7725E4BF052A2D6D825246406F0C01C0B127E4BF86DFF2FD795246404A26A7768629E4BF36131D13735246401B82E3326E2AE4BFA9C0C936705246409665E31CD02DE4BFB98C9B1A6852464009771D609C2EE4BF5BA43FEA655246403BD56BC4DD2AE4BF40D4C78D6C5246408BDF14562A28E4BFCC4EF51A71524640CB0924720B27E4BF9CC420B072524640386167AFE324E4BFFADA8E047552464030CE29125D21E4BFE6BF513C785246402AE09EE74F1BE4BF43CA4FAA7D5246407866DD9ACF14E4BF462D2867835246400B4048BB760EE4BF0DD4731C89524640E87D2DF9E909E4BFB20639398D524640317491E79F05E4BFEB6E9EEA905246406D59BE2EC3FFE3BFBF95911F965246409F2E9CB525FCE3BF8800964B9952464055072FB07DF7E3BFC120448D9D524640A6C86B6F01F2E3BFD1A79F81A2524640B7E809F082EDE3BF109F2A95A6524640829DAC623BE9E3BF1AB10573AA52464026796462A9E4E3BFD625998BAE5246407B4386FA02DFE3BF511B30A3B35246401211FE45D0D8E3BF30D63730B9524640163834C060D2E3BF21FC30E7BE52464030C26F9E45CAE3BF1E26D016C65246404A69EC01A9C3E3BF0F7ADBF1CB524640B8D38CFB45BFE3BF30FC96EFCF52464075F574BF54BDE3BF8F5ABCB3D15246400140040B16BDE3BF183EC7ECD15246402D2059654BBBE3BFD576137CD352464062C90B9F63B6E3BF8C14CAC2D7524640AA8A5F67F9B0E3BF18192EBCDC52464098C51FA056ACE3BF40CEEAD3E05246405DDA159FA7A6E3BF018AECDEE5524640EBF18CC756A1E3BF76F05D94EA524640DE0B827D2A9DE3BF9816F549EE5246400ED18D55EF95E3BF6BDB8BC3F4524640B4F4B2374290E3BFB075A911FA52464022516859F78FE3BFD9507B5BFA52464095720866968EE3BFE4260FB0FB5246402F974341DF8CE3BFDEEDD522FD524640C1525DC0CB8CE3BF7EE59C33FD5246405A057B5DD08CE3BFA273C817FE524640182A5A14D18AE3BFDC0F7860005346407EA1ECD22B8AE3BFD0EBF42801534640B88F81E1018AE3BF88539C590153464094EC2296DE88E3BF4CBFE902035346401767672CF587E3BF5DC87E71045346403DAC81F79F86E3BFC1E3DBBB0653464076210CF26984E3BF5FC9FA720B53464039B302E89C84E3BFBDB156A30D5346403C3080F0A184E3BFBDB156A30D5346409D2919A5F085E3BFA5F9BE130E534640196A5E1FE787E3BF28486C770F534640CD075FF30588E3BF697FB1080F534640CAFE791A3088E3BFCF30B5A50E5346407E9C7AEE4E88E3BF588A89720E534640333A7BC26D88E3BFFF2A1B310E53464015C039C89088E3BF70E6FCB90D534640CA5D3A9CAF88E3BFA0E062450D5346408278B878D388E3BF1D0247020D534640239F573CF588E3BF351603DA0C534640C73F7D152A89E3BF82E15CC30C53464060692AD54F89E3BF6B717CA30C534640E39EF87B7389E3BF9A99F4520C534640CD21A9859289E3BF001DE6CB0B534640F486FBC8AD89E3BF6BA5C63A0B5346408A332B80CE89E3BFEFCB99ED0A534640DB00C7F9F689E3BF1E2224C10A534640A21232EB208AE3BF12EA33B10A5346408B92EB014E8AE3BF775380DE0A5346405624CBEE6E8AE3BF77AFA4260B53464007454EBA888AE3BF53BF1C870B5346406D8C4237A08AE3BF3B0785F70B534640B65FE39FBE8AE3BF0CDF0C480C534640B6D37BCFED8AE3BF114020860C5346404380C28F208BE3BF9AF5189B0C5346409DC4D622588BE3BF656C8DAD0C534640E911FEA0898BE3BFFF3053A40C5346400E7162FEC08BE3BFB83CD68C0C5346403CCDB85FF48BE3BFE89260600C5346400ADC15551A8CE3BF65B4441D0C5346408C0EED084C8CE3BF6B5D0FCB0B5346401D3BA8C4758CE3BFB3F5679A0B5346405A91E22DA18CE3BFC43247A00B5346408C6DAD8ACB8CE3BFA7EB89AE0B53464076F05D94EA8CE3BF4D1652D90B534640706DF2A5018DE3BF476D872B0C534640865EDACB118DE3BF94C217810C5346404AF6BEA7288DE3BF941E3CC90C534640130B218C448DE3BF88145EDD0C534640FD8DD195638DE3BF88145EDD0C534640F70A66A77A8DE3BF88145EDD0C534640A02EF76E988DE3BF88145EDD0C534640E7841ACFB18DE3BF2FE301C00C534640FC7502F5C18DE3BF898A27710C53464094282092C68DE3BFDCFE4B080C5346403855AD3BCC8DE3BF89A4CCBC0B5346408FA5B4A3DD8DE3BF8F7BA98E0B5346406DAEF5A0FB8DE3BF36785F950B53464063AB15B71B8EE3BFBE2D58AA0B53464042B456B4398EE3BF1E92B5E10B5346408E017E326B8EE3BF18E9EA330C5346407F7E294D948EE3BF5F0B7A6F0C534640CACB50CBC58EE3BF656C8DAD0C53464081E3D7B4F78EE3BF2F3F26080D5346408CD1DFF0278FE3BF40344E9E0D5346405863BFDD488FE3BF2EDDC94C0E534640555DD1F7648FE3BF5814C0DE0E534640F08975AA7C8FE3BF2E4D5B6D0F534640A1AAF875968FE3BFD4015A041053464088B02B77B08FE3BF2157EA59105346406FB65E78CA8FE3BF15A930B610534640929B3CC0EE8FE3BF4589F1F510534640EEE247461890E3BF39DB3752115346408E06F0164890E3BF802BD9B111534640D25625917D90E3BF5C6963361253464065FD6662BA90E3BFBB57F7D912534640E0354305E290E3BF14B7651B13534640626B11AC0591E3BF5BABE232135346409D47C5FF1D91E3BFB5AE2C2C13534640377172BF4391E3BFB5AE2C2C13534640E09403876191E3BFB5AE2C2C13534640674A46297C91E3BFA3714D261353464005F467E49891E3BF087F750B135346409BA0979BB991E3BF3EDAEED4125346402A53CC41D091E3BF97AF26AA12534640A68E9FD7E991E3BFAFC3E281125346407E9DE5C3FD91E3BF2C41EB8612534640E76157491A92E3BFBB29E5B512534640B079B0202892E3BF440DF0EE12534640FB4F487C3892E3BFA9A44E401353464006CAB7883992E3BFE4BCFF8F13534640850B79043792E3BF37177FDB13534640E9DBDD5E2D92E3BFEAA7493A145346401FC484871F92E3BF617C8791145346401FC484871F92E3BF251C1FD214534640DAE4F0492792E3BFC06A1B3515534640AF76B92D3692E3BF4277499C15534640DED8FD744D92E3BF60483DFA15534640E74C7F9B6A92E3BFE9595A5716534640AE5EEA8C9492E3BFE9B57E9F165346407D6D4782BA92E3BF18682DBB165346403D85B762DA92E3BF1E6D1CB116534640EDA2433B0293E3BF00F84C9B16534640118B18761893E3BFADCBDF7316534640B4B4AE2C2C93E3BFA165DD3F1653464030F081C24593E3BFFB0C03F1155346402A6D16D45C93E3BF7E61E8C7155346409EABF7657A93E3BF785CF9D11553464056C675429E93E3BFBF5076E91553464020555E3CCD93E3BF72851C0016534640C078060DFD93E3BF36C98FF8155346403BB1E2AF2494E3BF2A919FE81553464019BA23AD4294E3BF96A3B6C31553464036A506E45C94E3BF7800D5891553464084F81B487294E3BF31B0332A155346401BA842F28494E3BF6CE289C5145346400034EFDD8B94E3BF0D501A6A14534640A8E0F0828894E3BFA257A8DA135346401CAB39E57694E3BF4FA10447135346405A8DDB1E7394E3BF6254ADE0125346403F19880A7A94E3BFE57A8093125346400034EFDD8B94E3BF9D58F157125346402319CD25B094E3BF9D2ADF33125346407069EB96D394E3BFE5C23703125346406AE67FA8EA94E3BF1B1EB1CC115346400890A1630795E3BFD9001187115346408F45E4052295E3BF279E584C115346402DEF05C13E95E3BFD471EB2411534640C718B3806495E3BF2D75351E115346405D3C725AA695E3BF7A6EA12B115346406BA400ACE995E3BF5C55F65D115346409977E62F3E96E3BF989BB9D11153464010A7DDF98F96E3BF7ADE324C1253464056719989D896E3BF8BA548BE1253464096B8E92A3897E3BFD223FC411353464062C1583A7A97E3BFF6F9DE951353464004E8F7FD9B97E3BFEAEF00AA1353464032474552C197E3BFC07053A8135346402F41576CDD97E3BF2C836A8313534640858E67E1FC97E3BF4469143713534640C3E7983D1A98E3BF6D8C9DF0125346402F2988CB3B98E3BFE5A892B7125346404A11740F6498E3BF6E026784125346403B8E1F2A8D98E3BFA990E1671253464010977730BD98E3BFEB515D651253464037F9D280E698E3BFA38BF27112534640D02280400C99E3BF68CF656A1253464011F637B23C99E3BF26E0D74812534640B599547E6399E3BF32BCA31012534640B88A6AB69799E3BFFDA8E1B611534640FE542646E099E3BF03249A40115346405C16B8E11C9AE3BF80176CD910534640359C8DF0519AE3BF63748A9F10534640F62A8DF3929AE3BF7B884677105346407AD7EABCD79AE3BFBC49C2741053464085398B28379BE3BFE6F6819A105346404DC57C2F749BE3BF75B169A5105346400E547C32B59BE3BF21B30EA210534640A3FDB4F6E39BE3BF92F826971053464097F7DD19129CE3BF694B6771105346402127A7D13F9CE3BFB0E3BF4010534640E53224DD859CE3BF9945CDFC0F5346408F56B5A4A39CE3BF0A8BE5F10F534640C82F7205CA9CE3BF21FBC51110534640D0A0FC38F59CE3BFC2209F461053464053D6CADF189DE3BF694B677110534640AE1DD665429DE3BFECCD5E6C105346409E978A8D799DE3BFF8D73C5810534640F2553C3FD69DE3BF396BA63110534640C9D81A5B199EE3BF1BF6D61B10534640A958EB7A589EE3BF5DB752191053464082DEC0898D9EE3BFFEAE192A105346401D0B653CA59EE3BF929C024F10534640E2A5400BAE9EE3BF27B8FD9710534640C834E4E9A69EE3BFFD9474DE1053464045FC1E50919EE3BF39DB37521153464044858F2D709EE3BF328E91EC11534640231A38FB5E9EE3BF4455A75E12534640846D1F4D509EE3BF91065CFC125346409A61FE65529EE3BF4397265B13534640F42E83D6689EE3BF8BE7C7BA13534640032670EB6E9EE3BFAE8F98EA13534640B74CE19C6C9EE3BF856C0F3114534640816731676C9EE3BFC084C08014534640159ADA087A9EE3BFA29927D714534640BB40EEC7929EE3BFEF1CCA5015534640C4B46FEEAF9EE3BF4EDD4BD015534640D1A86510C49EE3BF60483DFA155346402B76EA80DA9EE3BF5A434E0416534640F00DCF5CF19EE3BF8AC7EAFB15534640B1283630039FE3BF54104DEA15534640FF7B4B94189FE3BF6C521BE615534640793D98141F9FE3BFD1BB6713165346404ECF60F82D9FE3BFDD4F7C6B16534640DA0418963F9FE3BF95E535C016534640F6EFFACC599FE3BFA77E390E17534640BC8AD69B629FE3BF00DEA74F17534640A813758B659FE3BF1277AB9D17534640921F9672639FE3BF8F50D8EA175346406437D8405F9FE3BF531E824F1853464023D8B8FE5D9FE3BFCA20D2CA185346409D99057F649FE3BF70A7BE3D195346408022BB77799FE3BF8E78B29B195346405F2BFC74979FE3BF34FF9E0E1A53464055281C8BB79FE3BF8D5E0D501A53464037AEDA90DA9FE3BF2E84E6841A5346405F132DD4F59FE3BF40EFD7AE1A5346403D1C6ED113A0E3BF2E0E1DF11A5346402F9C10DF2EA0E3BFC229183A1B5346400FA848CF3EA0E3BF8196AE601B5346401D9C3EF152A0E3BF8DCE9E701B534640B1CEE79260A0E3BFBC523B681B5346408D5DA27A6BA0E3BF0A1E95511B53464038842A357BA0E3BF63F3CC261B53464069E9656F84A0E3BF34411E0B1B5346406B63EC8497A0E3BFD40AD3F71A534640C1B3F3ECA8A0E3BF934957FA1A5346406BD784B4C6A0E3BF0AC270091B53464043E6CAA0DAA0E3BF346F302F1B5346402E6C729DEBA0E3BFD49409641B534640D298FF46F1A0E3BFE62D0DB21B53464022EF0B9EF8A0E3BFC20F73EE1B534640067BB889FFA0E3BF9E1FEB4E1C534640FD7ACF9211A1E3BF927131AB1C534640485167EE21A1E3BF684EA8F11C53464085A7A1574DA1E3BF15DA835A1D534640CF7A42C06BA1E3BF092CCAB61D534640F36217FB81A1E3BF44728D2A1E53464043B9235289A1E3BFF6306AAD1E534640D0F1D1E28CA1E3BF5B52FF6A1F53464099092BBA9AA1E3BFBA6EA53220534640BA7482ECABA1E3BF195D39D620534640838CDBC3B9A1E3BFCB1B165921534640CAE2FE23D3A1E3BFA182C30B22534640B7E22C36F7A1E3BF59A2B3CC2253464064833B061AA2E3BF1E9E6F5523534640BE50C07630A2E3BF8335CEA6235346405BFAE1314DA2E3BFD68F4DF223534640C73BD1BF6EA2E3BFA639C31E24534640F79D150786A2E3BF1DB2DC2D24534640A8BE98D29FA2E3BFD6EB713A24534640EF14BC32B9A2E3BFA062E64C24534640B3ACA00ED0A2E3BF8E812B8F2453464065CD23DAE9A2E3BFC466DBC424534640A8A6C931FEA2E3BF3BDFF4D324534640086E49B31EA3E3BFC394EDE8245346401AE2B3D029A3E3BFD5FFDE1225534640434AFD0637A3E3BF7020C9512553464028D6A9F23DA3E3BFDBBC1699255346404DC1752046A3E3BFF8BB1C1B2653464079A63C5F58A3E3BF3A07CF8426534640FF58880E81A3E3BFE6C0BC1127534640D2E4620CACA3E3BFBCF957A02753464013BB1171CEA3E3BF392FA93528534640FAC04472E8A3E3BF2DDD13DA2853464089737918FFA3E3BF97D5856929534640D0C99C7818A4E3BF7AEAECBF29534640C5C6BC8E38A4E3BF8522DDCF295346409F4F89905FA4E3BF382971C229534640586A076D83A4E3BF91FEA897295346409346BBC09BA4E3BFD39112712953464022F9EF66B2A4E3BF205D6C5A2953464046E1C4A1C8A4E3BF389F3A5629534640A8AB3B16DBA4E3BF0949B08229534640186D9F9FF3A4E3BFD92038D329534640E981EA7AFDA4E3BFFCF61A272A534640A125D93400A5E3BFFC8051932A5346403B527DE717A5E3BF795A7EE02A53464024D236FE44A5E3BFF000AA132B534640A40117BF84A5E3BF6DACC43C2B5346405D9324BEC9A5E3BF912683482B534640E13F82870EA6E3BF0E7679292B534640E9279CDD5AA6E3BF268A35012B534640EB15BB229DA6E3BFEA9F96D52A53464071C806D2C5A6E3BF3238EFA42A534640723F96F4E6A6E3BF7FA724462A534640494BE5ED08A7E3BF621EE857295346406433D13131A7E3BF0F6844C428534640D66EBBD05CA7E3BF51717731285346406621F07673A7E3BF9EB29AAE27534640E25CC30C8DA7E3BF345E04D726534640FACA283BA2A7E3BFF212526D26534640F0C74851C2A7E3BFB7FAA01D26534640D4C78D6CF8A7E3BF529154F025534640E5AC99C640A8E3BF64CE33F6255346402580513871A8E3BFFE92F9EC255346405062218491A8E3BFE1EF17B3255346408544DAC69FA8E3BFA5D766632553464015FA0560A8A8E3BF179348EC24534640C81D801EB4A8E3BFC40AB77C24534640714111E6D1A8E3BF4D0867012453464038537CD7FBA8E3BF4D501E712353464019D643EA2CA9E3BF0CD759E322534640B6DB2E34D7A9E3BF7274F0A721534640E9A518D643AAE3BF3DD7F7E120534640F28D322C90AAE3BF4352B06B20534640C693933FCEAAE3BF25AFCE312053464064B14D2A1AABE3BF2581BC0D20534640F1D4230D6EABE3BF613D491520534640AADAC93BE2ABE3BF67704A2F20534640913FBDBE7BACE3BF1FD8F15F205346400363D8BC05ADE3BF61996D5D20534640213CDA3862ADE3BF0D9B125A20534640F6B8CA6EC1ADE3BF3D1FAF51205346400B92E3F32FAEE3BF49579F6120534640FA08A12875AEE3BFDE1676622053464098B2C2E391AEE3BF0163224A20534640A4A3C112B4AEE3BF49FB7A192053464073B21E08DAAEE3BFBA1281EA1F534640D276A79608AFE3BFF09B0CD81F534640E055C50A6DAFE3BF1316CBE31F534640C43D3B8501B0E3BF96C6D40220534640A4349BC761B0E3BFF0C91EFC1F534640E18AD5308DB0E3BFBA40930E2053464093AB58FCA6B0E3BFB469B63C20534640E378F475CFB0E3BFA8BBFC9820534640244CACE7FFB0E3BF662893BF20534640F8510DFB3DB1E3BF49E1D5CD205346404D13B69F8CB1E3BF726083CF205346403113FBBAC2B1E3BF6656A5E320534640218DAFE2F9B1E3BF3DD7F7E120534640B8B06EBC3BB2E3BFC630CCAE205346409AAAC5F18DB2E3BF7E0E3D7320534640832A7F08BBB2E3BF0163224A2053464024511ECCDCB2E3BF2B86AB0320534640D571A197F6B2E3BFC6EE4CB21F534640B9FA56900BB3E3BFA91D59541F53464091099D7C1FB3E3BF7F42870A1F534640EAD621ED35B3E3BF975643E21E534640BE65F3DD52B3E3BFE4219DCB1E534640D4CD6A2684B3E3BFE4219DCB1E534640FEAC437FB2B3E3BFD212D0E91E53464079E51F22DAB3E3BF61FBC9181F53464047F47C1700B4E3BF0E59935D1F534640EA1D13CE13B4E3BFC0E95DBC1F53464082D0306B18B4E3BF7E84060720534640337A241411B4E3BF61996D5D2053464037FA980F08B4E3BF13FC259820534640ACC4E171F6B3E3BFE3D3ADE820534640C5BEAE70DCB3E3BF7218CC5F215346407568A219D5B3E3BF3CEB64BA2153464097D6F03ED8B3E3BF424C78F821534640019E59B7E6B3E3BF7D361724225346402106BAF605B4E3BF9BABE639225346407653CA6B25B4E3BF3670AC3022534640B82979D047B4E3BF00B90E1F22534640E108522976B4E3BFE39F6351225346407B32FFE89BB4E3BF3CD1BF6E22534640A1945A39C5B4E3BFC586B88322534640831A193FE8B4E3BF30C7E18222534640838EB16E17B5E3BF775F3A5222534640A3F611AE36B5E3BFC558A65F22534640AFE710DD58B5E3BF7DC04D90225346408276E2CD75B5E3BF3C2DE4B6225346403F11D5A590B5E3BF65AC91B822534640BFCC1C37A1B5E3BF5F79909E22534640F72B5382B4B5E3BF95D40968225346405D763EF2BDB5E3BF54B7692222534640F1A8E793CBB5E3BF3C1977DE21534640E8A8FE9CDDB5E3BFD7AF2AB121534640A1C6736CF3B5E3BFD781188D21534640CCA843B813B6E3BF1E488380215346408ABAC5B24FB6E3BF247B849A215346400AEAA5738FB6E3BFE3152DE521534640632BC313D5B6E3BFA7B5C4252253464052A280481AB7E3BFEEA9413D2253464026A8E15B58B7E3BF7D923B6C2253464082638511B1B7E3BFB3D30FEA225346409EC20078FAB7E3BF307F2A13235346402AE3DF675CB8E3BF592CEA3823534640FF5FD09DBBB8E3BFD0D2156C23534640F1530BDB05B9E3BFEE75F7A5235346404221A7542EB9E3BF3BCB87FB23534640E347461850B9E3BF76114B6F24534640A0E238F06AB9E3BF88D860E12453464086E86BF184B9E3BF17EF6C3425534640171230BABCB9E3BF704EDB752553464025F14D2E21BAE3BF76DD00D8255346408C2661F07ABAE3BF3AABAA3C265346404441DFCC9EBAE3BF34D4CD6A265346406AA33A1DC8BAE3BF1CC011932653464040AC9223F8BAE3BF4C44AE8A26534640BC5EF5DB32BBE3BF9F42098E26534640ACD8A9036ABBE3BF75F16DB026534640A2D5C9198ABBE3BF8D614ED0265346403BFF76D9AFBBE3BF9F2864422753464014854CE8E4BBE3BFD43B269C2753464050D88F5E1EBCE3BF7B66EEC6275346402F58607E5DBCE3BF337271AF2753464025C918C4ACBCE3BF3F4E3D77275346401F31D52714BDE3BF2DE34B4D27534640E0336D5A84BDE3BFBC6F213427534640913C2185FCBDE3BFCEAC003A27534640E5E5FA88A9BEE3BF45813E9127534640C2D375F233BFE3BF031CE7DB27534640C1470E2263BFE3BFAAEA8ABE27534640FF8870DDDEBFE3BF1587D80528534640AA8251499DC0E3BF217711A628534640A5D535FF54C1E3BFD996016729534640CD9948C4EFC1E3BFFCF61A272A5346403E46D49F58C2E3BFC6F7C5A52A5346407F901B34AAC2E3BF674BB1FE2A534640DAD42FC7E1C2E3BF7FE9A3422B5346408BF5B292FBC2E3BFB4FC659C2B5346402E1F49490FC3E3BFCCC86A042C5346406781768714C3E3BFCB80B3942C534640956C2BAC0AC3E3BF007AD0A22D53464046161F5503C3E3BFCA04B28D2E53464073FEDC8607C3E3BF6BE2D3522F534640E5C2370312C3E3BF5F622CD32F534640EE36B9292FC3E3BF1D59F9653053464073E60DE665C3E3BF6A0AAE03315346400310D2AE9DC3E3BF1CF79CAA31534640E11813ACBBC3E3BFCFB5792D32534640EF0C09CECFC3E3BFE07C8F9F325346403D601E32E5C3E3BF81D07AF83253464030E0C03F00C4E3BFB0B03B3833534640CB83F41439C4E3BF8C92A174335346407D1B070374C4E3BF513239B533534640D6E5948098C4E3BF8645FB0E34534640E4501AC5CDC4E3BF440EB67D345346406A77FEA325C5E3BF14426216355346408259FC016AC5E3BF3818456A35534640C4A34396BBC5E3BF26097888355346401168FA360EC6E3BFC1CD3D7F355346406FA01BF56BC6E3BF7AABAE43355346407EC9213DA0C7E3BFD39A8B64345346406A3AF18B01C8E3BFD33E671C34534640721F14EF5BC8E3BF50BC6F213453464082042049A4C8E3BF33A3C4533453464093E92BA3ECC8E3BFC1B9D0A63453464021F829D890C9E3BF9149A187355346408F2738ABF4C9E3BFAF48A709365346409509641B5DCAE3BF4FF8B6AA36534640D3C155F9F9CAE3BF0746B98F37534640EBA05C644CCBE3BF5AA038DB375346403E5F0E16A9CBE3BFE3834314385346401F566E5809CCE3BF96E6FB4E38534640591A530B80CCE3BF13EE3AC038534640C6466AEBF1CCE3BF42CEFBFF385346409FCC3FFA26CDE3BF848F77FD38534640E6F8B2FEE0CDE3BF722486D3385346402655DB4DF0CDE3BF30630AD6385346409F1628CEF6CDE3BF5AE2B7D73853464087F2AA73B1CEE3BF661AA8E7385346409EE6898CB3CEE3BFD15AD1E638534640FD1EAB4A11CFE3BFB91803EB38534640CE33F6251BCFE3BF6015B9F138534640BEADAA4D52CFE3BFCB83F4143953464009CB338A40D0E3BFDCE8ADCB3A534640718FA50F5DD0E3BFE8209EDB3A5346407786A92D75D0E3BF6BA395D63A534640785CF9D115D1E3BF6B7583B23A534640E78EFE976BD1E3BF59DC7F643A53464017DC6A31D3D1E3BFE34FF97C39534640124427953AD2E3BF9C7521B138534640A576D03648D2E3BF1983989537534640DB5B806C48D2E3BF792FAD3C37534640DB5B806C48D2E3BF5CEE27BE35534640104130A248D2E3BF5CF45F31345346406605D03989D2E3BF99E436D0325346401AFF999C35D3E3BF46A45CD031534640443D3377E3D3E3BFE1F890A630534640745DF8C1F9D4E3BF53FC299F2F53464073D30BE313D7E3BF60CAC0012D53464032474552C1D7E3BFB9E177D32D534640B6DECA6D56D8E3BF36BBA4202E53464008550F3DCED9E3BF0D288A462D5346404B789D68B2DAE3BFD15790662C5346404AD466F73FDBE3BF556AF6402B5346408627AA6D79DBE3BFD996016729534640CFF753E3A5DBE3BFB608D682285346403D2762B609DCE3BF2163A4CD275346402C89473D9FDCE3BF0FF8B2A327534640052C5ED152DEE3BFF88D0AF725534640C212B46E28E1E3BFE2F54F26245346401FC1E84DA0E3E3BF5FA7A2C22253464085DE2C6F58E4E3BFFAC78C01235346408BDAA2714DE6E3BF83D9A95E23534640E403F170F1E6E3BFCA71022E23534640A4EEB902C0E7E3BF29BCBA192453464044FD892540E8E3BF11A8FE41245346406AD37DA598E8E3BFA60BB1FA235346403A419B1C3EE9E3BFC5E2DCCB225346401AAC938ECDE9E3BFB9C491072253464096BABFD595EAE3BF42A89C40225346402849320631EBE3BF4865D4C62253464021C8410933EDE3BFB377EBA122534640A968ACFD9DEDE3BF306BBD3A2253464094D684590DEEE3BF7731282E22534640267ACF3758EEE3BF4DF4F9282353464042D94A9EA1EEE3BFE842F68B23534640C976BE9F1AEFE3BFB271B32E24534640BD70E7C248EFE3BF5882D60D255346408FE4F21FD2EFE3BF1C92FF6E265346404FCFBBB1A0F0E3BF5D95FA682753464070253B3602F1E3BF7B809312275346405A7B44F1CFF1E3BF0ADF56D5265346400E4867052BF3E3BF4C022F8E25534640DC9DB5DB2EF4E3BFA062E64C2453464022DC099BA6F4E3BF53831F8B23534640FD4FFEEE1DF5E3BF1E00CC1022534640697C15CF8FF5E3BF42380B20215346405CD207814BF6E3BFDD2AE33A2153464068AB370FCCF6E3BF9CF9D51C2053464059FB3BDBA3F7E3BF7394CD661F53464007FE012038F8E3BFF6CE0DF21F53464057276728EEF8E3BF42A89C4022534640FBB2B45373F9E3BFCA856F06245346407C2C7DE882FAE3BF7C58B96125534640C0DB72E437FBE3BFAB7AF99D2653464035F0A31AF6FBE3BF4B2A093F275346408C16FB26A8FCE3BFAAA2D34E285346400722307B7EFDE3BF5C61B0D12853464017DA948675FEE3BF6899A0E128534640E0979FC0E0FFE3BFEB916170285346409D64ABCB2901E4BF620A7B7F285346404137EAD78C02E4BF323E27182953464048EF65EC9503E4BF0877C2A629534640	0101000020E6100000E9A5ADA10DDFE3BFD09327C0E6524640
401110000C0396	C	396	261	0106000020E610000001000000010300000001000000050000008B750536421AE4BF18BFDF1E3AFA4540F9484A7A181AE4BFDCA0F65B3BFA4540C70446A8631FE4BF91042B9842FA4540D2F24DE4931FE4BF14BB6C2A41FA45408B750536421AE4BF18BFDF1E3AFA4540	0101000020E6100000B374E1B9E41CE4BFAAF11B653EFA4540
401330000A1503	A	1503	1277	0106000020E61000000100000001030000000100000005000000C84109336D9FF6BF7DFA19283ACE45407B4B395FEC9DF6BFACC0351C3BCE4540096F0F42409EF6BF87E123624ACE454011A6CDDD539EF6BF38AE354A4DCE4540C84109336D9FF6BF7DFA19283ACE4540	0101000020E610000019746F5D8E9EF6BFDA0CF4E440CE4540
40297000AD0030	AD	30	11038	0106000020E61000000100000001030000000100000004000000C608F2FD1E86E0BFF980E5AD5F13464030687CBA159DE0BF2D8837216313464013002DA74E91E0BFA2DFADE243134640C608F2FD1E86E0BFF980E5AD5F134640	0101000020E6100000037BDE1F8191E0BF43F8989057134640
403020000A0309	A	309	10	0106000020E61000000100000001030000000100000005000000A2C2C716388FEFBF73B8FBC1650346406C51B010678FEFBF73486AA1640346406B6688BE168FEFBF2CCAB61D64034640F12DAC1BEF8EEFBF313F373465034640A2C2C716388FEFBF73B8FBC165034640	0101000020E6100000DB9E59E0298FEFBF0169A8EC64034640
402060000C0574	C	574	9	0106000020E610000001000000010300000001000000040000005138166FBF97F1BF2AA50CC116C445407A7E62AE5697F1BFCAC4AD8218C4454066040AAB6797F1BFE795A1E018C445405138166FBF97F1BF2AA50CC116C44540	0101000020E6100000663ED6427F97F1BF9EAA1E0C18C44540
400080000B0112	B	112	32	0106000020E6100000010000000103000000010000000400000046D09849D48BE4BFAF3D586BCD324640BE5CD5A3BA8AE4BF50977B37CC3246400A3664F2BC8AE4BF3DC4F5DECE32464046D09849D48BE4BFAF3D586BCD324640	0101000020E61000005A769B4A198BE4BF6A889880CD324640
401330000A1934	A	1934	35	0106000020E6100000010000000103000000010000000400000078D0ECBAB7A2F6BF435E6ADF37CE4540A25D2ADB2CA3F6BFB82638503BCE45407F29A84D41A3F6BF3C81559A39CE454078D0ECBAB7A2F6BF435E6ADF37CE4540	0101000020E6100000DDC73FA10CA3F6BF1302A89839CE4540
402990000A0536	A	536	457	0106000020E610000001000000010300000001000000040000005B947E67203BE4BFA723809BC5D44540C3C2A453B237E4BFD904BDDCCCD445404BEF7618EE37E4BF11BDD6EFD3D445405B947E67203BE4BFA723809BC5D44540	0101000020E6100000CD6C33F1EA38E4BF2FF75BCDCCD44540
402990000A0530	A	530	600	0106000020E61000000100000001030000000100000005000000A4D6451B9139E4BF4CFBE6FEEAD44540480845A9733BE4BF2ABBAAFDE7D445403ADDC36F5438E4BF4FAE2990D9D445408A929048DB38E4BF93FA57FBE0D44540A4D6451B9139E4BF4CFBE6FEEAD44540	0101000020E6100000C55A976FC839E4BF18F5002FE4D44540
402710000A0180	A	180	1140	0106000020E61000000100000001030000000100000005000000C1F40714FBF5F3BFFFA6C17E99C94540CDC01259B5F5F3BF7093F6ABA5C945403FF152A005F7F3BFCFC941BFA5C9454063C44F2D6CF7F3BF4CCE3FB099C94540C1F40714FBF5F3BFFFA6C17E99C94540	0101000020E6100000467C48FC88F6F3BFB262ED8D9FC94540
403290000A0811	A	811	922	0106000020E61000000100000001030000000100000005000000D84D846808A2D2BF451D0C2BCBE345406B871AE0DDA5D2BF749B70AFCCE345409932CBF9BDA8D2BFD4A6A091BEE345409CA5643909A5D2BF5258F32DBDE34540D84D846808A2D2BF451D0C2BCBE34540	0101000020E610000020B18D6869A5D2BF59360CF2C4E34540
402930000A0619	A	619	104	0106000020E610000001000000010300000001000000050000008C32761D0503F3BF9AAF37D66AD545405D0F7052E204F3BF2F6F0ED76AD545403A89528C3D05F3BF9A3FA6B569D54540FFE66AD03C05F3BFB8FC2C3B69D545408C32761D0503F3BF9AAF37D66AD54540	0101000020E6100000C623ACC96B04F3BF97ED37486AD54540
400280000C0272	C	272	30	0106000020E6100000010000000103000000010000000400000009DA8937D715E9BFA9C4D0459ED1454064F1F67BBD16E9BFBA579C20A0D145401C391CA73216E9BFE02582829CD1454009DA8937D715E9BFA9C4D0459ED14540	0101000020E61000002DAC89734216E9BF1716A54D9ED14540
403330000A0104	A	104	4	0106000020E610000001000000010300000001000000050000002011AEDBFB2FE7BFF8E69205A70546401E238F96B92FE7BFF82E4A75A6054640718280C6962FE7BF6988CF42A7054640321180C9D72FE7BF570339CDA70546402011AEDBFB2FE7BFF8E69205A7054640	0101000020E6100000FD06CE03C92FE7BF12E92922A7054640
40187000AH0024	AH	24	38	0106000020E61000000100000001030000000100000005000000BB80971936AAF5BF0FA03AB1E2EE4540A45F11B2E2AAF5BF9044D4E9E5EE4540EE32B21A01ABF5BF258EE156E6EE454038F92D3A59AAF5BFF849FFDCE1EE4540BB80971936AAF5BF0FA03AB1E2EE4540	0101000020E6100000F84B40F788AAF5BFB5D803BCE3EE4540
401650000A0916	A	916	11164	0106000020E61000000100000001030000000100000005000000EC23A6FA8462E7BF831CEFE9450E4640DD81959E445FE7BF155C0762340E4640987D68305750E7BF8A4A34924E0E46402C5B35199F53E7BFB7BF69B05F0E4640EC23A6FA8462E7BF831CEFE9450E4640	0101000020E61000002D494E977459E7BF5FC9EF184A0E4640
40001000CI0044	CI	44	789	0106000020E61000000100000001030000000100000005000000640D72721A7DD1BF8A3842AB38D94540C37BB372D476D1BFCC47AD8B36D94540792F08F6A974D1BF52F932AC3DD94540335CD372567AD1BFB68A598A3FD94540640D72721A7DD1BF8A3842AB38D94540	0101000020E6100000EBB51D5CC078D1BFF256A50B3BD94540
401170000A0188	A	188	144	0106000020E6100000010000000103000000010000000400000037F5262B2B72DCBFE0D0008349E545401E47BDF1FF74DCBFB6C1E4A14AE54540D571A197F672DCBF2506819543E5454037F5262B2B72DCBFE0D0008349E54540	0101000020E6100000B8E481916073DCBF94DDCCE847E54540
401980000A0193	A	193	3195	0106000020E61000000100000001030000000100000005000000DD730580CFB4E1BFD2A0B2ABDACD45409946938B31B0E1BF42FD78F9E7CD4540AD855968E7B4E1BF3E0D73DDEFCD4540A2E826D64EB9E1BFB5DE6FB4E3CD4540DD730580CFB4E1BFD2A0B2ABDACD4540	0101000020E6100000CE772B15C9B4E1BF3959B779E5CD4540
401980000A0470	A	470	1907	0106000020E6100000010000000103000000010000000500000018AA07718AB3E1BFCDB7F41E1DCE454097080A7206B5E1BF79E173CC1ECE4540EE81B1193BBCE1BF662D05A4FDCD45406D945055FCBAE1BFBB794F8AFBCD454018AA07718AB3E1BFCDB7F41E1DCE4540	0101000020E6100000CD7DC3B7E4B7E1BFEE114F800DCE4540
402110000A1404	A	1404	500	0106000020E61000000100000001030000000100000005000000D6DE4CF15DCFF2BFC9433A973DD24540715D8CDC2ECFF2BFAE45B01644D2454041A1F9F774D0F2BF19B4EB3944D2454015F6FE507AD0F2BFFEB220393ED24540D6DE4CF15DCFF2BFC9433A973DD24540	0101000020E6100000770C1B86DCCFF2BF534DC21841D24540
40212000AA0667	AA	667	73	0106000020E610000001000000010300000001000000040000000548D9C7AF64F2BFCD069964E4C645407851AA33AD63F2BFB3C986DADBC6454036C2ECAF6864F2BFDE29D31EE5C645400548D9C7AF64F2BFCD069964E4C64540	0101000020E6100000911ED0E34164F2BFCAA8FBC9E1C64540
402330000A0344	A	344	340	0106000020E6100000010000000103000000010000000500000033535A7F4B60F0BF08FAB083EFCF45408D45D3D9C960F0BF07A348ADE6CF45401C5F7B664960F0BF9CF28D8DE5CF4540B9324D7DC55FF0BF27D1DC54EECF454033535A7F4B60F0BF08FAB083EFCF4540	0101000020E61000005AA3AA9A4860F0BF80EA048DEACF4540
401530000B0129	B	129	453	0106000020E610000001000000010300000001000000040000007F935CB4B6DFE4BF3868AF3E1EEA4540EEF77AAD3AE1E4BF1A355F251FEA4540D19A7A38DCE2E4BF11829F820DEA45407F935CB4B6DFE4BF3868AF3E1EEA4540	0101000020E6100000BF0CC68844E1E4BFCC5F8FF718EA4540
40001000CL0102	CL	102	56	0106000020E6100000010000000103000000010000000500000096FECAEFD9DFD0BF9D972FD406DA4540347B455CA5E0D0BF1452C8DF07DA45400AB6B69503E2D0BF27F73B1405DA454070B6B9313DE1D0BF5D9A6C4D04DA454096FECAEFD9DFD0BF9D972FD406DA4540	0101000020E6100000AE552D45EDE0D0BF9BCCB30D06DA4540
401740000A0519	A	519	9	0106000020E6100000010000000103000000010000000400000033F4F4B63E51D5BF9DA62AC82ACF454007DD1445FE4FD5BF5BB79CA62ACF4540DBE275583C50D5BF37514B732BCF454033F4F4B63E51D5BF9DA62AC82ACF4540	0101000020E6100000063CD5C67D50D5BF653A06F62ACF4540
400830000A0099	A	99	1360	0106000020E610000001000000010300000001000000050000006919A9F754CED7BFF0B03F3F42CF454080684183A8D6D7BFFF147DF43CCF45402346747401D4D7BF9DDDB5DF35CF45400E277A2AF1CAD7BFBEE9A7493ACF45406919A9F754CED7BFF0B03F3F42CF4540	0101000020E6100000418F70B6DFD0D7BF1FEAFBDF3BCF4540
400950000D0184	D	184	15	0106000020E610000001000000010300000001000000050000002DEE3F321DBAECBF0298D7B6CDCC4540C4FC265EAFBAECBF31A6AA1ACECC45405BAC4D08C2BAECBF265A4D32CDCC4540644D767D30BAECBF504FC4C7CCCC45402DEE3F321DBAECBF0298D7B6CDCC4540	0101000020E610000092E6EF6B6FBAECBFBDA6A872CDCC4540
403150000A1412	A	1412	90	0106000020E61000000100000001030000000100000005000000D64FA4A08052EFBF2889DB57D4E14540D214A6947C51EFBFFE37407AD4E1454079BEB0468751EFBFC2E50C20D7E145404814FF1C8B52EFBF80F67EFED6E14540D64FA4A08052EFBF2889DB57D4E14540	0101000020E61000006120ACEC0352EFBF57A91CBCD5E14540
400260000A0445	A	445	6	0106000020E61000000100000001030000000100000005000000404F030649DFE1BFE0CA23C9BDE545406043CB1539DFE1BFF8962831BEE54540C1690B19D9DFE1BFC8F8E6EDBEE5454095FBD3FCE7DFE1BF87AD3484BEE54540404F030649DFE1BFE0CA23C9BDE54540	0101000020E6100000349460D690DFE1BFE0E7375BBEE54540
401240000A0241	A	241	970	0106000020E61000000100000001030000000100000005000000D0C254E9DD0EABBFF58F74BCB80146406EC72F174C57ABBF52448655BC014640689604A8A965ABBF44AFF5FBB40146401A8C6C42B51CABBF5E5F9099B0014640D0C254E9DD0EABBFF58F74BCB8014640	0101000020E6100000BDD081A59F39ABBFF787429EB6014640
402860000A0948	A	948	20	0106000020E61000000100000001030000000100000004000000EDB204BE4722E0BF4AFFDCE1C0D145401723B7CB2324E0BFFB6FCA81C3D14540E9A91FE57122E0BFA41CCC26C0D14540EDB204BE4722E0BF4AFFDCE1C0D14540	0101000020E6100000A42A497AF422E0BF4ED97B83C1D14540
400790000A0080	A	80	4040	0106000020E61000000100000001030000000100000005000000442A31749127E5BFCBA54CC521D14540B2C9D067F62FE5BF386BF0BE2AD1454062314514EE30E5BFC299A95A1CD1454011ACAA97DF29E5BF3D8CFFF114D14540442A31749127E5BFCBA54CC521D14540	0101000020E6100000F1359ADA902CE5BFD88AC5A81FD14540
401650000A0005	A	5	4770	0106000020E61000000100000001030000000100000005000000A24621C9AC5EE7BFD542C9E4D40E4640B9AC1D20F35CE7BF6CE3F49AC30E4640B18119F8F653E7BFDD6A8C8CC40E4640106ED7F09951E7BF6D4892D6CE0E4640A24621C9AC5EE7BFD542C9E4D40E4640	0101000020E610000098EDF04FB058E7BF93F34781CB0E4640
400140000B0248	B	248	700	0106000020E61000000100000001030000000100000004000000B8D15B9775DAD6BF7D9D8A0A8B04464006BF68EAD0C4D6BFA06D35EB8C044640ACCB84BAA3DAD6BFE03CE64D8F044640B8D15B9775DAD6BF7D9D8A0A8B044640	0101000020E6100000227418144ED3D6BFA9C28C168D044640
401070000C0568	C	568	233	0106000020E6100000010000000103000000010000000500000062759ABB4CC3EDBF0ACBE9FC2502464053510658F5C3EDBFE0E9DF3F2702464003B68311FBC4EDBFF0E3C3471F0246408A24D5D237C4EDBF441669E21D02464062759ABB4CC3EDBF0ACBE9FC25024640	0101000020E6100000129E503120C4EDBF20CF3E8222024640
402180000B0554	B	554	3504	0106000020E61000000100000001030000000100000005000000FEE263C10EADAB3F5F5E807D74FB4540D072EA14F593AB3F982DFE5B6EFB4540F54C8AEA083BAC3F2161736957FB454062CCA7D8E264AC3FE322ADE75AFB4540FEE263C10EADAB3F5F5E807D74FB4540	0101000020E6100000BC79CE7105F8AB3FBF78B96665FB4540
40004000AE0080	AE	80	20	0106000020E6100000010000000103000000010000000500000017A9E628F606F6BFA900738813D445404354E1CFF006F6BFD35746D911D445403763E2A0CE06F6BFC705B17D12D445403A2F04EF9A06F6BF3288597913D4454017A9E628F606F6BFA900738813D44540	0101000020E610000092B118EFD506F6BF595575F312D44540
400110000A0795	A	795	51	0106000020E610000001000000010300000001000000050000003E7F3562C158E9BFB9FFC874E8C84540224D614AC957E9BF060A61DADCC8454030CDBE3CAE57E9BFE8C2A3E8DCC84540D5BAC3DCA458E9BFBF32CA8EE8C845403E7F3562C158E9BFB9FFC874E8C84540	0101000020E610000003DE4C253958E9BFD5F03AC6E2C84540
40036000AB0951	AB	951	191	0106000020E61000000100000001030000000100000005000000C8A6A66E78EBF5BF8B3CA473D9D04540264BF78436EAF5BF550F3DCED9D045402F85AC133CEAF5BF72924149DCD04540928433AE6EEBF5BF66FE2CF1DBD04540C8A6A66E78EBF5BF8B3CA473D9D04540	0101000020E6100000E5C6315CD6EAF5BF4AF383DCDAD04540
401180000A0456	A	456	572	0106000020E6100000010000000103000000010000000500000010392284ECE1EDBF0EEE186888C94540BDF1FFF4B0E1EDBFA93121E692C9454034C7A82160E3EDBF4A9FB18A92C945409AF9C4F0C7E3EDBFB4A217FF88C9454010392284ECE1EDBF0EEE186888C94540	0101000020E610000067030CA5AEE2EDBF3988519D8DC94540
401040000B0312	B	312	285	0106000020E6100000010000000103000000010000000400000008605EDB3627ECBFFBC67CE5E6DE45404B242C859B27ECBF9E18A3BFE1DE45408D7C5EF1D423ECBF9DB00E91E4DE454008605EDB3627ECBFFBC67CE5E6DE4540	0101000020E6100000A155F8C53726ECBFBBDA6467E4DE4540
402180000B0555	B	555	315	0106000020E6100000010000000103000000010000000500000077AB9D17DD30AC3F8C8D2F9056FB454029931ADA006CAC3F6774513E4EFB45401BCFB1CDD776AC3F963A6D324FFB4540F54C8AEA083BAC3F2161736957FB454077AB9D17DD30AC3F8C8D2F9056FB4540	0101000020E6100000502234221954AC3F3D61C1CB52FB4540
400150000A0996	A	996	195	0106000020E6100000010000000103000000010000000400000014E6E214C20FB13FD9582EC0E30D46409586753E9704B13F9F6692A2DF0D4640CF3DDAEED412B13F30FFD76FDC0D464014E6E214C20FB13FD9582EC0E30D4640	0101000020E6100000D338666B0F0DB13FE394DDF0DF0D4640
400870000A0234	A	234	2360	0106000020E61000000100000001030000000100000005000000F77D9301FB43B8BF13DD6921B700464094580861246AB8BFCE458D53BE004640DE6C18AA0771B8BF8F311C74AE004640719989D81654B8BF2DF41CECA8004640F77D9301FB43B8BF13DD6921B7004640	0101000020E6100000143B7FF7885CB8BF8132478CB3004640
401310000A0374	A	374	12	0106000020E61000000100000001030000000100000005000000CDEC4ED257EBC7BF683403A61DFC4540209331E312ECC7BF1478279F1EFC4540E4E59FCF36EDC7BF2C30BF2E1EFC454059E0867368ECC7BF7AE7AB3F1DFC4540CDEC4ED257EBC7BF683403A61DFC4540	0101000020E61000006E78838243ECC7BF03027CEE1DFC4540
403250000C0539	C	539	1376	0106000020E610000001000000010300000001000000050000000BEE073C3000DEBF4A9C700A86D845408E791D71C806DEBFFE0DDAAB8FD84540316B18F4940BDEBFD7CEE6278BD84540032D13341C05DEBF1ED48F977FD845400BEE073C3000DEBF4A9C700A86D84540	0101000020E6100000A283F193DE05DEBFDE25AFED87D84540
40004000AL0004	AL	4	2602	0106000020E610000001000000010300000001000000050000001DDCE742F6ABF5BF9E87C90A34D445400B7A14538EAEF5BFB5AFF2BA34D445406926CE401BAFF5BFDAFE959526D445402D42B11534ADF5BF0C67C8C221D445401DDCE742F6ABF5BF9E87C90A34D44540	0101000020E61000002FB9747EA3ADF5BFAD673C792CD44540
40004000AM0038	AM	38	106	0106000020E610000001000000010300000001000000040000004B992F8A7911F6BFD6F95C120CD3454025027A861513F6BF28EC472F0FD345402AF97DA42D13F6BF4C101A660DD345404B992F8A7911F6BFD6F95C120CD34540	0101000020E6100000DE86623C9412F6BF6DA73F8D0DD34540
40029000ZH0044	ZH	44	3463	0106000020E610000001000000010300000001000000050000005F73B3E496FBDEBF396D7CDC6DD3454080249122D7F2DEBF9175824765D345406FB72407ECEADEBFACDBEA8376D34540AC23A2F375F4DEBF315F5E807DD345405F73B3E496FBDEBF396D7CDC6DD34540	0101000020E610000046444DE25FF3DEBFB43738BB71D34540
402960000H0367	H	367	9	0106000020E61000000100000001030000000100000005000000475DC6A8C646F6BFF1248EE156DB45409C09979F6547F6BF84BE4FB05ADB4540CAF154D16947F6BF3769BF5A5ADB45405B4BB7DBE446F6BF38D1538957DB4540475DC6A8C646F6BFF1248EE156DB4540	0101000020E61000005110D2553347F6BF82A4075759DB4540
400520000A0328	A	328	75	0106000020E6100000010000000103000000010000000500000084FD8D2C4FD6C9BF31DB04CE08EC45401FF818AC38D5C9BF0848EAF307EC4540BFC579EEF3CEC9BFD72DA7A90AEC4540FD7D6BCC90CFC9BFCB0924720BEC454084FD8D2C4FD6C9BF31DB04CE08EC4540	0101000020E6100000432D3C59A3D2C9BF0B3645AB09EC4540
401560000C0125	C	125	5055	0106000020E61000000100000001030000000100000005000000BBCA7FED05CBEBBFFEA666C526294640A2B8E34D7ECBEBBFDB24F5543D294640C811C6AA9CD1EBBF55D2D4FC42294640CBC05CE6CFD2EBBF18D00B772E294640BBCA7FED05CBEBBFFEA666C526294640	0101000020E6100000A920AB21BBCEEBBF1BEADCF134294640
401970000C0635	C	635	6365	0106000020E610000001000000010300000001000000050000001C53C1F23169ECBFD5F89683EA064640CEC29E76F86BECBF371B2B31CF064640A8AAD0402C5BECBFAE940ACFF0064640E3BD0FAC4F5EECBF021D9C3EF10646401C53C1F23169ECBFD5F89683EA064640	0101000020E6100000B8779B362565ECBFCF313F41E4064640
40224000AC0042	AC	42	171	0106000020E610000001000000010300000001000000050000000E187F36CDB6F1BFC1F1C693EEC54540E9595A5716B6F1BF69119BD9F8C54540471BECF252B6F1BFFE2C9622F9C545407A933A5C06B7F1BF92C94EE4EEC545400E187F36CDB6F1BFC1F1C693EEC54540	0101000020E61000003163F1808EB6F1BF001111E7F3C54540
402880000B0329	B	329	2760	0106000020E610000001000000010300000001000000040000001829EF3E2201D4BF4613DED4F6FE4540E9B1D2495B01D4BF66ED0099E7FE4540FC04AB459FEAD3BF6002B7EEE6FE45401829EF3E2201D4BF4613DED4F6FE4540	0101000020E610000054F5CE44B4F9D3BF05013274ECFE4540
40307000AB0276	AB	276	2	0106000020E610000001000000010300000001000000040000000E542179428AE2BF5AE14C028A2946400F57186C348AE2BFCA202D848B29464063A131EE618AE2BFB9B53B5A8B2946400E542179428AE2BF5AE14C028A294640	0101000020E610000081197946488AE2BFF3E791F58A294640
40082000ZH0131	ZH	131	313	0106000020E610000001000000010300000001000000050000009CBFAECB9566DABF993AD9171ADB454007431D56B865DABF39B69E211CDB454078A4B041156DDABFC073942820DB4540580FA9B3A46DDABFA34CB4F51DDB45409CBFAECB9566DABF993AD9171ADB4540	0101000020E6100000212B3400C169DABFB0A0A0171DDB4540
401570000C0796	C	796	1110	0106000020E6100000010000000103000000010000000400000027B6CC3340D3F3BF1660692AD50546400450317326D2F3BFA425451ACB0546402396DE48EACEF3BFBCDDDCA9CA05464027B6CC3340D3F3BF1660692AD5054640	0101000020E61000001B34F44F70D1F3BFD3CB834FCE054640
400530000B0565	B	565	166	0106000020E61000000100000001030000000100000004000000D18AB9B59613D0BFF266C3503D13464051B0B5AD1C10D0BFECACCC4A49134640922C16759C11D0BFE6A7DD5449134640D18AB9B59613D0BFF266C3503D134640	0101000020E6100000E6772C48C511D0BFEC93245045134640
\.


COPY "lexicon"."registered_postal_zones" FROM stdin;
FR	91121	BUNO BONNEVAUX	91720	BUNO BONNEVAUX	\N	0101000020E6100000D4CA4904754103408BC19131AF2D4840
FR	91122	BURES SUR YVETTE	91440	BURES SUR YVETTE	\N	0101000020E6100000E762A65460440140BCB37F28B4584840
FR	91248	LA FORET STE CROIX	91150	LA FORET STE CROIX	\N	0101000020E6100000FED1B38F22D80140D21A648A29314840
FR	91340	LISSES	91090	LISSES	\N	0101000020E610000048E1E15DC4650340AD1863A55F4C4840
FR	91521	RIS ORANGIS	91130	RIS ORANGIS	\N	0101000020E61000005A9AB91D74430340F81DDAB695524840
FR	91639	VAYRES SUR ESSONNE	91820	VAYRES SUR ESSONNE	\N	0101000020E6100000EA05DFCEF9C30240BE326A1C3C374840
FR	91665	LA VILLE DU BOIS	91620	LA VILLE DU BOIS	\N	0101000020E610000056A5E84ECA1E0240F3E371499C544840
FR	91671	VILLENEUVE SUR AUVERS	91580	VILLENEUVE SUR AUVERS	\N	0101000020E6100000C5E341D97F080240298F888FCA3B4840
FR	91685	VILLIERS SUR ORGE	91700	VILLIERS SUR ORGE	\N	0101000020E6100000FB07A9E3606502408FA5201B47544840
FR	92009	BOIS COLOMBES	92270	BOIS COLOMBES	\N	0101000020E610000022B8CB059B2302403CE5F5C129754840
FR	92012	BOULOGNE BILLANCOURT	92100	BOULOGNE BILLANCOURT	\N	0101000020E610000089B35621C0E901400E0FDE31156B4840
FR	92035	LA GARENNE COLOMBES	92250	LA GARENNE COLOMBES	\N	0101000020E61000008A07C4FB08F501400049FDA210744840
FR	93013	LE BOURGET	93350	LE BOURGET	\N	0101000020E61000003161BA4E1D6D0340CF1CD9E6D4774840
FR	93015	COUBRON	93470	COUBRON	\N	0101000020E61000001AE2BDA1499C0440D1FD889E75754840
FR	93074	VAUJOURS	93410	VAUJOURS	\N	0101000020E61000005A14F6ACE4A504403B0E356A5B774840
FR	94042	JOINVILLE LE PONT	94340	JOINVILLE LE PONT	\N	0101000020E6100000C0745A2C7BC303404153A80FE1684840
FR	95040	AVERNES	95450	AVERNES	\N	0101000020E61000003821D17BAEEBFD3FDB430DAA5E8B4840
FR	95055	BELLEFONTAINE	95270	BELLEFONTAINE	\N	0101000020E610000094D3A7B3A7C10340562BCB83D88B4840
FR	95480	PARMAIN	95620	PARMAIN	\N	0101000020E61000007895B094379C0140B0FA7F33BA8F4840
FR	97109	GOURBEYRE	97113	GOURBEYRE	\N	0101000020E610000076E75A8ADCD74EC011EEF7C7E0FC2F40
FR	97133	VIEUX FORT	97141	VIEUX FORT	\N	0101000020E61000000D822103E6D84EC0DEDD6153A2EB2F40
FR	97209	FORT DE FRANCE	97200	FORT DE FRANCE	\N	0101000020E61000008FC5C32EDB884EC081552EC23F482D40
FR	97223	ST ESPRIT	97270	ST ESPRIT	\N	0101000020E61000004A836239F7754EC05396E674271E2D40
FR	97309	REMIRE MONTJOLY	97354	REMIRE MONTJOLY	\N	0101000020E6100000E5A6B509B1234AC0FF5C5AA098891340
FR	97412	ST JOSEPH	97480	ST JOSEPH	\N	0101000020E6100000930E384E2FD24B40AE3BC0486D4E35C0
FR	97415	ST PAUL	97434	ST PAUL	LA SALINE LES BAINS	0101000020E610000002B3C93842A94B402455D36E660B35C0
FR	97417	ST PHILIPPE	97442	ST PHILIPPE	BASSE VALLEE	0101000020E610000080EFEE746BDF4B407419AEFAD24D35C0
FR	97418	STE MARIE	97438	STE MARIE	\N	0101000020E610000067341DB1E2C34B406F94EA7272F234C0
FR	97418	STE MARIE	97438	STE MARIE	LA GRANDE MONTEE	0101000020E610000067341DB1E2C34B406F94EA7272F234C0
FR	98711	ANAA	98786	HITIANAU	ANAA	\N
FR	98713	ARUTUA	98761	RAUTINI	ARUTUA	\N
FR	98726	MAKEMO	98790	HITI	MAKEMO	\N
FR	98745	TAHAA	98733	PATIO	TAHAA	\N
FR	98750	TAPUTAPUATEA	98735	OPOA	TAPUTAPUATEA	\N
FR	2A001	AFA	20167	AFA	\N	0101000020E610000095AE4A62B9982140A4FFA91C01FE4440
FR	2A103	CUTTOLI CORTICCHIATO	20167	CUTTOLI CORTICCHIATO	\N	0101000020E61000003C4F8352A4C42140BC8BFA9B05FD4440
FR	2A200	PALNECA	20134	PALNECA	\N	0101000020E6100000B77806EFD26022409E496794F1FE4440
FR	2A249	PROPRIANO	20110	PROPRIANO	\N	0101000020E610000040F3CD5E9EC921402B69A2DF40D34440
FR	2A270	SARI D'ORCINO	20151	SARI D ORCINO	\N	0101000020E61000001E79F204E4AA2140D43C44BE4B084540
FR	2A276	SERRA DI FERRO	20140	SERRA DI FERRO	\N	0101000020E610000094B89B1001A021406E9E6DA4DADE4440
FR	2A336	VALLE DI MEZZANA	20167	VALLE DI MEZZANA	\N	0101000020E6100000DECA8D3F9CA321400A24E8F403034540
FR	2A345	VERO	20172	VERO	\N	0101000020E6100000A13F7EF5F8D7214076A58EDAD0074540
FR	2B037	BIGUGLIA	20620	BIGUGLIA	\N	0101000020E6100000615DB50287E1224084D684EAE64E4540
FR	2B101	CROCE	20237	CROCE	\N	0101000020E610000090B096D1F1B622401156DB3C32344540
FR	2B147	LOZZI	20224	LOZZI	\N	0101000020E6100000FBC9D711ECF521404115E493682E4540
FR	2B150	LUMIO	20260	LUMIO	\N	0101000020E61000005205C474C9A6214081FA71E03E4A4540
FR	2B152	LURI	20228	LURI	\N	0101000020E6100000BF49A1BEDBD1224012848B5B5C724540
FR	2B164	MONACIA D'OREZZA	20229	MONACIA D OREZZA	\N	0101000020E61000008442338F5FCF2240FF74D515D2304540
FR	2B179	NOVALE	20234	NOVALE	\N	0101000020E610000033DFFF6260D2224082F7F54604274540
FR	2B205	PATRIMONIO	20253	PATRIMONIO	\N	0101000020E6100000C44D29D2EDBB22404D87BDB5745A4540
FR	2B206	PENTA ACQUATELLA	20290	PENTA ACQUATELLA	\N	0101000020E61000000B1A97A588BE22402D2EA9B1583B4540
FR	2B261	ROGLIANO	20248	ROGLIANO	MACINAGGIO	0101000020E61000005D6B3BCCCDD9224041D0012D6C7C4540
FR	2B315	SANTO PIETRO DI VENACO	20250	SANTO PIETRO DI VENACO	\N	0101000020E6100000C8DCB95AF85422407A59B0E0601F4540
FR	49057	CERNUSSON	49310	CERNUSSON	\N	0101000020E61000008063E2CFF5DBDEBF596C91407C954740
FR	49069	OREE D'ANJOU	49530	OREE D ANJOU	BOUZILLE	0101000020E61000008FBC4C9B272BF4BF1F8137D433A94740
FR	49076	LA CHAPELLE ST LAUD	49140	LA CHAPELLE ST LAUD	\N	0101000020E61000006A6AE75D9615D3BFCEB4695A95CE4740
FR	49127	DURTAL	49430	DURTAL	\N	0101000020E610000015EEC1BF804BD0BF33299764CAD64740
FR	49135	FENEU	49460	FENEU	\N	0101000020E61000003D21653C033AE3BF969C052CC1CA4740
FR	49200	LONGUENEE EN ANJOU	49770	LONGUENEE EN ANJOU	LE PLESSIS MACE	0101000020E6100000A8237F53F9DEE5BF2A148A31C7C74740
FR	49226	NOELLET	49520	NOELLET	\N	0101000020E6100000F5E647B98B6FF1BF5892D762D2D84740
FR	49244	MAUGES SUR LOIRE	49620	MAUGES SUR LOIRE	LA POMMERAYE	0101000020E6100000F2411F2461D0EBBF90E22CC5E6AB4740
FR	49299	ST LEGER SOUS CHOLET	49280	ST LEGER SOUS CHOLET	\N	0101000020E61000001EF586A827EFECBFACD1ECAF178D4740
FR	49326	SARRIGNE	49800	SARRIGNE	\N	0101000020E61000008E8E1422EDB0D8BF2A46381251C04740
FR	49328	SAUMUR	49400	SAUMUR	DAMPIERRE SUR LOIRE	0101000020E610000070EA7BC92D42B5BF5E35E8AE39A24740
FR	49329	SAVENNIERES	49170	SAVENNIERES	\N	0101000020E61000003E0ACF2F5759E5BF54B06868F3B34740
FR	50003	AGON COUTAINVILLE	50230	AGON COUTAINVILLE	\N	0101000020E6100000FF6D860E9A4DF9BF8C207378F8844840
FR	50039	BEAUCOUDRAY	50420	BEAUCOUDRAY	\N	0101000020E61000005CBD73232B47F2BF445B68C30E7B4840
FR	50094	CAMPROND	50210	CAMPROND	\N	0101000020E610000008BE1D2A006BF5BFE25DCA92FB8A4840
FR	50115	LE GRIPPON	50320	LE GRIPPON	LES CHAMBRES	0101000020E610000045665681666AF6BF5C7BBBB6D2624840
FR	50166	DOVILLE	50250	DOVILLE	\N	0101000020E61000002D705BE185C5F8BFC9EBDC8B23AB4840
FR	50257	JOBOURG	50440	JOBOURG	\N	0101000020E6100000D405E31725A1FEBF759BF70D21D74840
FR	50259	JUILLEY	50220	JUILLEY	\N	0101000020E61000008F48A3F6808EF5BF5614DDA1A24B4840
FR	50272	LINGREVILLE	50660	LINGREVILLE	\N	0101000020E610000090AF8CDCF374F8BF2A070D9EBD784840
FR	50376	NICORPS	50200	NICORPS	\N	0101000020E6100000998901AC1292F6BFCEC4E79B03844840
FR	50488	ST JEAN DE DAYE	50620	ST JEAN DE DAYE	\N	0101000020E6100000B16C8F0C4A2EF2BFA6C49499A99D4840
FR	50498	ST JOSEPH	50700	ST JOSEPH	\N	0101000020E61000002334C1666860F8BFF321ACAE11C44840
FR	50511	ST MARTIN D'AUDOUVILLE	50310	ST MARTIN D AUDOUVILLE	\N	0101000020E61000008620C22451E9F5BFCDD89690B6C34840
FR	50516	ST MARTIN DES CHAMPS	50300	ST MARTIN DES CHAMPS	\N	0101000020E6100000CC4B42457C63F5BFF187B7775A554840
FR	50540	ST PIERRE LANGERS	50530	ST PIERRE LANGERS	\N	0101000020E6100000DFE5EBAD13D2F7BF193F584064644840
FR	50563	ST VIGOR DES MONTS	50420	ST VIGOR DES MONTS	\N	0101000020E6100000BFFE8F473CE8F0BFADB68C2370744840
FR	50593	TEURTHEVILLE BOCAGE	50630	TEURTHEVILLE BOCAGE	\N	0101000020E6100000CEC4160F0151F6BFDA08E241D5CB4840
FR	50629	VESLY	50430	VESLY	GERVILLE LA FORET	0101000020E61000002F33ECD958D7F7BFA79FDA5A8B9F4840
FR	51005	ALLEMANT	51120	ALLEMANT	\N	0101000020E6100000C2B4B5E735870E40758940F779614840
FR	51031	BACONNES	51400	BACONNES	\N	0101000020E610000009B034DE895A11407E5CBEDD09954840
FR	51036	BARBONNE FAYEL	51120	BARBONNE FAYEL	\N	0101000020E610000037577974B6800D406A3276D1B6534840
FR	51057	BETTANCOURT LA LONGUE	51330	BETTANCOURT LA LONGUE	\N	0101000020E61000001F3791BD2989134046C0B6B8856A4840
FR	51097	BUSSY LE CHATEAU	51600	BUSSY LE CHATEAU	\N	0101000020E6100000DA4CDD800021124043B0DBBC99874840
FR	51102	CAUROY LES HERMONVILLE	51220	CAUROY LES HERMONVILLE	\N	0101000020E61000009B4D0C1AFB6C0F40D9A7C26C99AD4840
FR	51105	CERNAY LES REIMS	51420	CERNAY LES REIMS	\N	0101000020E61000002F8AE17E737010401C9D70407DA04840
FR	51132	LES CHARMONTOIS	51330	LES CHARMONTOIS	\N	0101000020E61000003949495334FD134044DEFD308C7B4840
FR	51139	CHAUDEFONTAINE	51800	CHAUDEFONTAINE	\N	0101000020E6100000BE8C5A32507B13401A86805DDC8C4840
FR	51151	CHICHEY	51120	CHICHEY	\N	0101000020E61000001A896775D5080E402A4DEACE6A574840
FR	51170	CORFELIX	51210	CORFELIX	\N	0101000020E6100000BFB832FDE5930D40C2371D1D686A4840
FR	51274	GIZAUCOURT	51800	GIZAUCOURT	\N	0101000020E610000036971C47A71F1340B90583D640874840
FR	51311	JUSSECOURT MINECOURT	51340	JUSSECOURT MINECOURT	\N	0101000020E610000039541946981F1340DBEC4C4073654840
FR	51348	MARFAUX	51170	MARFAUX	\N	0101000020E6100000802BF23825340F4017ED0695A5954840
FR	51355	MASSIGES	51800	MASSIGES	\N	0101000020E61000001AAE0BB21CF41240F677EDCCC8984840
FR	51379	MONTIGNY SUR VESLE	51140	MONTIGNY SUR VESLE	\N	0101000020E61000005926ED7F46690E40B9BA877725A84840
FR	51409	NUISEMENT SUR COOLE	51240	NUISEMENT SUR COOLE	\N	0101000020E61000009BFE1D90382311408A384E67966F4840
FR	51414	OLIZY	51700	OLIZY	\N	0101000020E6100000C3A7DE1753120E4089784849B8924840
\.
--
-- PostgreSQL database dump complete
--

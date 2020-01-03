CREATE UNLOGGED TABLE cadastral_land_parcel_zones (
    id character varying NOT NULL,
    section character varying,
    work_number character varying,
    net_surface_area integer,
    shape postgis.geometry(MultiPolygon,4326) NOT NULL,
    centroid postgis.geometry(Point,4326)
);


--
-- Name: ephy_cropsets; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE ephy_cropsets (
    id character varying NOT NULL,
    name character varying NOT NULL,
    label jsonb,
    crop_names text[],
    crop_labels jsonb
);


--
-- Name: intervention_model_items; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE intervention_model_items (
    id character varying NOT NULL,
    procedure_item_reference character varying NOT NULL,
    article_reference character varying,
    indicator_name character varying,
    indicator_value numeric(19,4),
    indicator_unit character varying,
    intervention_model_id character varying
);


--
-- Name: intervention_models; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE intervention_models (
    id character varying NOT NULL,
    name jsonb,
    category_name jsonb,
    number character varying,
    procedure_reference character varying NOT NULL,
    working_flow numeric(19,4),
    working_flow_unit character varying
);


--
-- Name: master_production_natures; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE master_production_natures (
    id integer NOT NULL,
    specie character varying NOT NULL,
    human_name jsonb,
    human_name_fra character varying NOT NULL,
    started_on date NOT NULL,
    stopped_on date NOT NULL,
    agroedi_crop_code character varying,
    season character varying,
    pfi_crop_code character varying,
    cap_2017_crop_code character varying,
    cap_2018_crop_code character varying,
    cap_2019_crop_code character varying
);


--
-- Name: master_production_outputs; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE master_production_outputs (
    production_nature_id integer NOT NULL,
    production_system_name character varying NOT NULL,
    name character varying NOT NULL,
    average_yield numeric(19,4),
    main boolean DEFAULT false NOT NULL,
    analysis_items character varying[]
);


--
-- Name: master_vine_varieties; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE master_vine_varieties (
    id character varying NOT NULL,
    specie_name character varying NOT NULL,
    specie_long_name character varying,
    category_name character varying NOT NULL,
    fr_validated character varying,
    utility character varying,
    color character varying,
    customs_code character varying
);


--
-- Name: registered_agroedi_codes; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_agroedi_codes (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    reference_id integer NOT NULL,
    reference_code character varying,
    reference_label character varying,
    ekylibre_scope character varying,
    ekylibre_value character varying
);


--
-- Name: registered_building_zones; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_building_zones (
    nature character varying,
    shape postgis.geometry(MultiPolygon,4326) NOT NULL,
    centroid postgis.geometry(Point,4326)
);


--
-- Name: registered_chart_of_accounts; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_chart_of_accounts (
    id character varying NOT NULL,
    account_number character varying NOT NULL,
    chart_id character varying NOT NULL,
    reference_name character varying,
    previous_reference_name character varying,
    name jsonb
);


--
-- Name: registered_crop_zones; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_crop_zones (
    id character varying NOT NULL,
    city_name character varying,
    shape postgis.geometry(Polygon,4326) NOT NULL,
    centroid postgis.geometry(Point,4326)
);


--
-- Name: registered_enterprises; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_enterprises (
    establishment_number character varying NOT NULL,
    french_main_activity_code character varying NOT NULL,
    name character varying,
    address character varying,
    postal_code character varying,
    city character varying,
    country character varying
);


--
-- Name: registered_hydro_items; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_hydro_items (
    id character varying NOT NULL,
    name jsonb,
    nature character varying,
    point postgis.geometry(Point,4326),
    shape postgis.geometry(MultiPolygonZM,4326),
    lines postgis.geometry(MultiLineStringZM,4326)
);


--
-- Name: registered_legal_positions; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_legal_positions (
    id integer NOT NULL,
    name jsonb,
    nature character varying NOT NULL,
    country character varying NOT NULL,
    code character varying NOT NULL,
    insee_code character varying NOT NULL,
    fiscal_positions text[]
);


--
-- Name: registered_pfi_crops; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_pfi_crops (
    id integer NOT NULL,
    reference_label_fra character varying
);


--
-- Name: registered_pfi_doses; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_pfi_doses (
    maaid integer NOT NULL,
    pesticide_name character varying,
    harvest_year integer NOT NULL,
    active integer NOT NULL,
    crop_id integer NOT NULL,
    target_id integer,
    functions character varying,
    dose_unity character varying,
    dose_quantity numeric(19,4)
);


--
-- Name: registered_pfi_targets; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_pfi_targets (
    id integer NOT NULL,
    reference_label_fra character varying
);


--
-- Name: registered_phytosanitary_products; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_phytosanitary_products (
    id integer NOT NULL,
    name character varying NOT NULL,
    other_name character varying,
    nature character varying,
    active_compounds character varying,
    maaid character varying NOT NULL,
    mix_category_code character varying NOT NULL,
    in_field_reentry_delay integer,
    state character varying NOT NULL,
    started_on date,
    stopped_on date,
    allowed_mentions jsonb,
    restricted_mentions character varying,
    operator_protection_mentions text,
    firm_name character varying,
    product_type character varying
);


--
-- Name: registered_phytosanitary_risks; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_phytosanitary_risks (
    product_id integer NOT NULL,
    risk_code character varying NOT NULL,
    risk_phrase character varying NOT NULL
);


--
-- Name: registered_phytosanitary_usages; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_phytosanitary_usages (
    id character varying NOT NULL,
    product_id integer NOT NULL,
    ephy_usage_phrase character varying NOT NULL,
    species text[],
    target_name jsonb,
    description jsonb,
    treatment jsonb,
    dose_quantity numeric(19,4),
    dose_unit character varying,
    dose_unit_name character varying,
    dose_unit_factor real,
    pre_harvest_delay integer,
    pre_harvest_delay_bbch integer,
    applications_count integer,
    applications_frequency integer,
    development_stage_min integer,
    development_stage_max integer,
    usage_conditions character varying,
    untreated_buffer_aquatic integer,
    untreated_buffer_arthropod integer,
    untreated_buffer_plants integer,
    decision_date date,
    state character varying NOT NULL
);


--
-- Name: registered_postal_zones; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_postal_zones (
    country character varying NOT NULL,
    code character varying NOT NULL,
    city_name character varying NOT NULL,
    postal_code character varying NOT NULL,
    city_delivery_name character varying,
    city_delivery_detail character varying,
    city_centroid postgis.geometry(Point,4326)
);


--
-- Name: registered_protected_designation_of_origins; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE TABLE registered_protected_designation_of_origins (
    id integer NOT NULL,
    ida integer NOT NULL,
    geographic_area character varying,
    fr_sign character varying,
    eu_sign character varying,
    product_human_name jsonb,
    product_human_name_fra character varying,
    reference_number character varying
);


--
-- Name: registered_seeds; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE registered_seeds (
    number integer NOT NULL,
    specie character varying NOT NULL,
    name jsonb,
    complete_name jsonb
);


--
-- Name: technical_workflow_procedure_items; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE technical_workflow_procedure_items (
    id character varying NOT NULL,
    actor_reference character varying,
    procedure_item_reference character varying,
    article_reference character varying,
    quantity numeric(19,4),
    unit character varying,
    procedure_reference character varying NOT NULL,
    technical_workflow_procedure_id character varying NOT NULL
);


--
-- Name: technical_workflow_procedures; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE technical_workflow_procedures (
    id character varying NOT NULL,
    "position" integer NOT NULL,
    name jsonb NOT NULL,
    repetition integer,
    frequency character varying,
    period character varying,
    procedure_reference character varying NOT NULL,
    technical_workflow_id character varying NOT NULL
);


--
-- Name: technical_workflow_sequences; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE technical_workflow_sequences (
    id character varying NOT NULL,
    technical_workflow_sequence_id character varying NOT NULL,
    name jsonb NOT NULL,
    family character varying,
    specie character varying,
    production_system character varying,
    year_start integer,
    year_stop integer,
    technical_workflow_id character varying NOT NULL
);


--
-- Name: technical_workflows; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE technical_workflows (
    id character varying NOT NULL,
    name jsonb NOT NULL,
    family character varying,
    specie character varying,
    production_system character varying,
    start_day integer,
    start_month integer,
    unit character varying,
    life_state character varying,
    life_cycle character varying
);


--
-- Name: variant_categories; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE variant_categories (
    id integer NOT NULL,
    reference_name character varying NOT NULL,
    name jsonb,
    nature character varying NOT NULL,
    fixed_asset_account character varying,
    fixed_asset_allocation_account character varying,
    fixed_asset_expenses_account character varying,
    depreciation_percentage integer,
    purchase_account character varying,
    sale_account character varying,
    stock_account character varying,
    stock_movement_account character varying,
    purchasable boolean,
    saleable boolean,
    depreciable boolean,
    storable boolean
);


--
-- Name: variant_doer_contracts; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE variant_doer_contracts (
    id character varying NOT NULL,
    reference_name character varying NOT NULL,
    name jsonb,
    duration character varying,
    weekly_working_time character varying,
    gross_hourly_wage numeric(19,4),
    net_hourly_wage numeric(19,4),
    coefficient_total_cost numeric(19,4),
    variant_id character varying
);


--
-- Name: variant_natures; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE variant_natures (
    id integer NOT NULL,
    reference_name character varying NOT NULL,
    name jsonb,
    nature character varying,
    population_counting character varying NOT NULL,
    indicators text[],
    abilities text[],
    derivative_of character varying
);


--
-- Name: variant_prices; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE variant_prices (
    id character varying NOT NULL,
    reference_name character varying NOT NULL,
    reference_article_name character varying NOT NULL,
    unit_pretax_amount numeric(19,4) NOT NULL,
    currency character varying NOT NULL,
    reference_packaging_name character varying NOT NULL,
    started_on date NOT NULL,
    variant_id character varying,
    packaging_id character varying,
    usage character varying NOT NULL,
    main_indicator character varying,
    main_indicator_unit character varying,
    main_indicator_minimal_value numeric(19,4),
    main_indicator_maximal_value numeric(19,4),
    working_flow_value numeric(19,4),
    working_flow_unit character varying,
    threshold_min_value numeric(19,4),
    threshold_max_value numeric(19,4)
);


--
-- Name: variant_units; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE variant_units (
    id character varying NOT NULL,
    class_name character varying NOT NULL,
    reference_name character varying NOT NULL,
    name jsonb,
    capacity numeric(25,10),
    capacity_unit character varying,
    dimension character varying,
    symbol character varying,
    a numeric(25,10),
    d numeric(25,10),
    b numeric(25,10),
    unit_id character varying
);


--
-- Name: variants; Type: TABLE; Schema: lexicon; Owner: -
--

CREATE UNLOGGED TABLE variants (
    id character varying NOT NULL,
    class_name character varying,
    reference_name character varying NOT NULL,
    name jsonb,
    category character varying,
    nature character varying,
    default_unit character varying,
    target_specie character varying,
    specie character varying,
    indicators jsonb,
    variant_category_id integer,
    variant_nature_id integer
);


--
-- Name: cadastral_land_parcel_zones cadastral_land_parcel_zones_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY cadastral_land_parcel_zones
    ADD CONSTRAINT cadastral_land_parcel_zones_pkey PRIMARY KEY (id);


--
-- Name: ephy_cropsets ephy_cropsets_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY ephy_cropsets
    ADD CONSTRAINT ephy_cropsets_pkey PRIMARY KEY (id);


--
-- Name: intervention_model_items intervention_model_items_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY intervention_model_items
    ADD CONSTRAINT intervention_model_items_pkey PRIMARY KEY (id);


--
-- Name: intervention_models intervention_models_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY intervention_models
    ADD CONSTRAINT intervention_models_pkey PRIMARY KEY (id);


--
-- Name: master_production_natures master_production_natures_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY master_production_natures
    ADD CONSTRAINT master_production_natures_pkey PRIMARY KEY (id);


--
-- Name: master_production_outputs master_production_outputs_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY master_production_outputs
    ADD CONSTRAINT master_production_outputs_pkey PRIMARY KEY (production_nature_id, production_system_name, name);


--
-- Name: registered_agroedi_codes registered_agroedi_codes_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_agroedi_codes
    ADD CONSTRAINT registered_agroedi_codes_pkey PRIMARY KEY (id);


--
-- Name: registered_chart_of_accounts registered_chart_of_accounts_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_chart_of_accounts
    ADD CONSTRAINT registered_chart_of_accounts_pkey PRIMARY KEY (id);


--
-- Name: registered_enterprises registered_enterprises_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_enterprises
    ADD CONSTRAINT registered_enterprises_pkey PRIMARY KEY (establishment_number);


--
-- Name: registered_hydro_items registered_hydro_items_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_hydro_items
    ADD CONSTRAINT registered_hydro_items_pkey PRIMARY KEY (id);


--
-- Name: registered_legal_positions registered_legal_positions_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_legal_positions
    ADD CONSTRAINT registered_legal_positions_pkey PRIMARY KEY (id);


--
-- Name: registered_pfi_crops registered_pfi_crops_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_pfi_crops
    ADD CONSTRAINT registered_pfi_crops_pkey PRIMARY KEY (id);


--
-- Name: registered_pfi_targets registered_pfi_targets_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_pfi_targets
    ADD CONSTRAINT registered_pfi_targets_pkey PRIMARY KEY (id);


--
-- Name: registered_phytosanitary_products registered_phytosanitary_products_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_phytosanitary_products
    ADD CONSTRAINT registered_phytosanitary_products_pkey PRIMARY KEY (id);


--
-- Name: registered_phytosanitary_usages registered_phytosanitary_usages_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_phytosanitary_usages
    ADD CONSTRAINT registered_phytosanitary_usages_pkey PRIMARY KEY (id);


--
-- Name: registered_protected_designation_of_origins registered_protected_designation_of_origins_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_protected_designation_of_origins
    ADD CONSTRAINT registered_protected_designation_of_origins_pkey PRIMARY KEY (id);


--
-- Name: registered_seeds registered_seeds_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY registered_seeds
    ADD CONSTRAINT registered_seeds_pkey PRIMARY KEY (number);


--
-- Name: technical_workflow_procedure_items technical_workflow_procedure_items_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY technical_workflow_procedure_items
    ADD CONSTRAINT technical_workflow_procedure_items_pkey PRIMARY KEY (id);


--
-- Name: technical_workflow_procedures technical_workflow_procedures_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY technical_workflow_procedures
    ADD CONSTRAINT technical_workflow_procedures_pkey PRIMARY KEY (id);


--
-- Name: technical_workflow_sequences technical_workflow_sequences_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY technical_workflow_sequences
    ADD CONSTRAINT technical_workflow_sequences_pkey PRIMARY KEY (id);


--
-- Name: technical_workflows technical_workflows_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY technical_workflows
    ADD CONSTRAINT technical_workflows_pkey PRIMARY KEY (id);


--
-- Name: variant_categories variant_categories_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY variant_categories
    ADD CONSTRAINT variant_categories_pkey PRIMARY KEY (id);


--
-- Name: variant_doer_contracts variant_doer_contracts_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY variant_doer_contracts
    ADD CONSTRAINT variant_doer_contracts_pkey PRIMARY KEY (id);


--
-- Name: variant_natures variant_natures_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY variant_natures
    ADD CONSTRAINT variant_natures_pkey PRIMARY KEY (id);


--
-- Name: variant_prices variant_prices_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY variant_prices
    ADD CONSTRAINT variant_prices_pkey PRIMARY KEY (id);


--
-- Name: variant_units variant_units_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY variant_units
    ADD CONSTRAINT variant_units_pkey PRIMARY KEY (id);


--
-- Name: variants variants_pkey; Type: CONSTRAINT; Schema: lexicon; Owner: -
--

ALTER TABLE ONLY variants
    ADD CONSTRAINT variants_pkey PRIMARY KEY (id);


--
-- Name: registered_crop_zones_centroid_idx; Type: INDEX; Schema: lexicon; Owner: -
--

CREATE INDEX registered_crop_zones_centroid_idx ON registered_crop_zones USING gist (centroid);


--
-- Name: registered_crop_zones_id_idx; Type: INDEX; Schema: lexicon; Owner: -
--

CREATE INDEX registered_crop_zones_id_idx ON registered_crop_zones USING btree (id);


--
-- PostgreSQL database dump complete
--


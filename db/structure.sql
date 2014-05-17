--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: btrsort(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION btrsort(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ 
      SELECT 
        CASE WHEN char_length($1) > 0 THEN 
          CASE WHEN $1 ~ '^[^0-9]+' THEN 
            RPAD(SUBSTR(COALESCE(SUBSTRING($1 FROM '^[^0-9]+'), ''), 1, 30), 30, ' ') || btrsort(btrsort_nextunit($1)) 
          ELSE 
            LPAD(SUBSTR(COALESCE(SUBSTRING($1 FROM '^[0-9]+'), ''), 1, 30), 30, '0') || btrsort(btrsort_nextunit($1)) 
          END 
        ELSE 
          $1 
        END 
      ; 
    $_$;


--
-- Name: btrsort_nextunit(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION btrsort_nextunit(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ 
            SELECT 
                    CASE WHEN $1 ~ '^[^0-9]+' THEN 
                            COALESCE( SUBSTR( $1, LENGTH(SUBSTRING($1 FROM '[^0-9]+'))+1 ), '' ) 
                    ELSE 
                            COALESCE( SUBSTR( $1, LENGTH(SUBSTRING($1 FROM '[0-9]+'))+1 ), '' ) 
                    END 

    $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authentications (
    id integer NOT NULL,
    user_id integer,
    provider character varying(255),
    uid character varying(255),
    oauth character varying(255),
    oauth_expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: changelogs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changelogs (
    id integer NOT NULL,
    user_id integer,
    action character varying(255),
    target_id integer,
    target_type character varying(255),
    changelog text,
    notified boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original text,
    committed text,
    year integer
);


--
-- Name: changelogs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changelogs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changelogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changelogs_id_seq OWNED BY changelogs.id;


--
-- Name: instances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instances (
    id integer NOT NULL,
    instructable_id integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    location character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    override_location boolean,
    year integer
);


--
-- Name: instances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instances_id_seq OWNED BY instances.id;


--
-- Name: instructables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instructables (
    id integer NOT NULL,
    user_id integer,
    approved boolean DEFAULT false,
    name character varying(255),
    material_limit integer,
    handout_limit integer,
    description_web text,
    handout_fee double precision,
    material_fee double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    duration double precision,
    culture character varying(255),
    topic character varying(255),
    subtopic character varying(255),
    description_book text,
    additional_instructors character varying(255)[],
    camp_name character varying(255),
    camp_address character varying(255),
    camp_reason character varying(255),
    adult_only boolean DEFAULT false,
    adult_reason character varying(255),
    fee_itemization text,
    requested_days date[],
    repeat_count integer DEFAULT 0,
    scheduling_additional text,
    special_needs character varying(255)[],
    special_needs_description text,
    heat_source boolean DEFAULT false,
    heat_source_description text,
    requested_times character varying(255)[],
    track character varying(255),
    scheduled boolean DEFAULT false,
    location_type character varying(255) DEFAULT 'track'::character varying,
    proofread boolean DEFAULT false,
    proofread_by integer[] DEFAULT '{}'::integer[],
    proofreader_comments text,
    year integer,
    schedule character varying(255)
);


--
-- Name: instructables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instructables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instructables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instructables_id_seq OWNED BY instructables.id;


--
-- Name: instructor_profile_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instructor_profile_contacts (
    id integer NOT NULL,
    protocol character varying(255),
    address character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: instructor_profile_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instructor_profile_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instructor_profile_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instructor_profile_contacts_id_seq OWNED BY instructor_profile_contacts.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedules (
    id integer NOT NULL,
    user_id integer,
    instructables integer[] DEFAULT '{}'::integer[],
    published boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    year integer
);


--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedules_id_seq OWNED BY schedules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mundane_name character varying(255),
    access_token character varying(255),
    admin boolean DEFAULT false,
    pu_staff boolean,
    tracks character varying(255)[] DEFAULT '{}'::character varying[],
    sca_name character varying(255),
    sca_title character varying(255),
    phone_number character varying(255),
    class_limit integer,
    kingdom character varying(255),
    phone_number_onsite character varying(255),
    contact_via text,
    no_contact boolean DEFAULT false,
    available_days date[],
    instructor boolean DEFAULT false,
    proofreader boolean DEFAULT false,
    profile_updated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changelogs ALTER COLUMN id SET DEFAULT nextval('changelogs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instances ALTER COLUMN id SET DEFAULT nextval('instances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructables ALTER COLUMN id SET DEFAULT nextval('instructables_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructor_profile_contacts ALTER COLUMN id SET DEFAULT nextval('instructor_profile_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedules ALTER COLUMN id SET DEFAULT nextval('schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: changelogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changelogs
    ADD CONSTRAINT changelogs_pkey PRIMARY KEY (id);


--
-- Name: instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: instructables_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instructables
    ADD CONSTRAINT instructables_pkey PRIMARY KEY (id);


--
-- Name: instructor_profile_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instructor_profile_contacts
    ADD CONSTRAINT instructor_profile_contacts_pkey PRIMARY KEY (id);


--
-- Name: schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_authentications_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authentications_on_user_id ON authentications USING btree (user_id);


--
-- Name: index_instances_on_instructable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_instances_on_instructable_id ON instances USING btree (instructable_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20121023155856');

INSERT INTO schema_migrations (version) VALUES ('20121023155905');

INSERT INTO schema_migrations (version) VALUES ('20121023155910');

INSERT INTO schema_migrations (version) VALUES ('20121201005421');

INSERT INTO schema_migrations (version) VALUES ('20121201010524');

INSERT INTO schema_migrations (version) VALUES ('20121201011034');

INSERT INTO schema_migrations (version) VALUES ('20121230200704');

INSERT INTO schema_migrations (version) VALUES ('20130126001558');

INSERT INTO schema_migrations (version) VALUES ('20130126002331');

INSERT INTO schema_migrations (version) VALUES ('20130126011725');

INSERT INTO schema_migrations (version) VALUES ('20130128030310');

INSERT INTO schema_migrations (version) VALUES ('20130128070308');

INSERT INTO schema_migrations (version) VALUES ('20130128075433');

INSERT INTO schema_migrations (version) VALUES ('20130129031821');

INSERT INTO schema_migrations (version) VALUES ('20130129050031');

INSERT INTO schema_migrations (version) VALUES ('20130129064335');

INSERT INTO schema_migrations (version) VALUES ('20130129224616');

INSERT INTO schema_migrations (version) VALUES ('20130130070328');

INSERT INTO schema_migrations (version) VALUES ('20130204210202');

INSERT INTO schema_migrations (version) VALUES ('20130205055659');

INSERT INTO schema_migrations (version) VALUES ('20130208193322');

INSERT INTO schema_migrations (version) VALUES ('20130225010303');

INSERT INTO schema_migrations (version) VALUES ('20130302203444');

INSERT INTO schema_migrations (version) VALUES ('20130302205953');

INSERT INTO schema_migrations (version) VALUES ('20130303100733');

INSERT INTO schema_migrations (version) VALUES ('20130304033926');

INSERT INTO schema_migrations (version) VALUES ('20130304045507');

INSERT INTO schema_migrations (version) VALUES ('20130305092032');

INSERT INTO schema_migrations (version) VALUES ('20130309232231');

INSERT INTO schema_migrations (version) VALUES ('20130322232227');

INSERT INTO schema_migrations (version) VALUES ('20130323030559');

INSERT INTO schema_migrations (version) VALUES ('20130406022532');

INSERT INTO schema_migrations (version) VALUES ('20130406231036');

INSERT INTO schema_migrations (version) VALUES ('20130408052835');

INSERT INTO schema_migrations (version) VALUES ('20130410012740');

INSERT INTO schema_migrations (version) VALUES ('20130417073037');

INSERT INTO schema_migrations (version) VALUES ('20130426200209');

INSERT INTO schema_migrations (version) VALUES ('20130428100303');

INSERT INTO schema_migrations (version) VALUES ('20130430220849');

INSERT INTO schema_migrations (version) VALUES ('20130712182934');

INSERT INTO schema_migrations (version) VALUES ('20130717162854');

INSERT INTO schema_migrations (version) VALUES ('20140125181600');

INSERT INTO schema_migrations (version) VALUES ('20140130005107');

INSERT INTO schema_migrations (version) VALUES ('20140517150842');
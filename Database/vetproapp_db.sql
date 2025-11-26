--
-- PostgreSQL database cluster dump
--

-- Started on 2025-11-25 12:27:47

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-11-25 12:27:47

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

-- Completed on 2025-11-25 12:27:48

--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-11-25 12:27:48

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

-- Completed on 2025-11-25 12:27:48

--
-- PostgreSQL database dump complete
--

--
-- Database "seguros_abc" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-11-25 12:27:48

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

--
-- TOC entry 4904 (class 1262 OID 16388)
-- Name: seguros_abc; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE seguros_abc WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Spain.1252';


ALTER DATABASE seguros_abc OWNER TO postgres;

\connect seguros_abc

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
-- TOC entry 219 (class 1259 OID 16398)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16390)
-- Name: asegurados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asegurados (
    id integer NOT NULL,
    identificacion numeric NOT NULL,
    primer_nombre character varying(50) NOT NULL,
    segundo_nombre character varying(50),
    primer_apellido character varying(50) NOT NULL,
    segundo_apellido character varying(50) NOT NULL,
    telefono character varying(20) NOT NULL,
    correo_electronico character varying(100) NOT NULL,
    fecha_nacimiento date NOT NULL,
    valor_estimado numeric NOT NULL,
    observaciones text
);


ALTER TABLE public.asegurados OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16389)
-- Name: asegurados_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asegurados_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.asegurados_id_seq OWNER TO postgres;

--
-- TOC entry 4905 (class 0 OID 0)
-- Dependencies: 217
-- Name: asegurados_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asegurados_id_seq OWNED BY public.asegurados.id;


--
-- TOC entry 4746 (class 2604 OID 16393)
-- Name: asegurados id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asegurados ALTER COLUMN id SET DEFAULT nextval('public.asegurados_id_seq'::regclass);


--
-- TOC entry 4898 (class 0 OID 16398)
-- Dependencies: 219
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
\.


--
-- TOC entry 4897 (class 0 OID 16390)
-- Dependencies: 218
-- Data for Name: asegurados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.asegurados (id, identificacion, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, telefono, correo_electronico, fecha_nacimiento, valor_estimado, observaciones) FROM stdin;
17	1002212214	Paulo	Cesar	Urbina	Zuñiga	3046491479	paurbi1101@hotmail.com	2001-10-01	100000000	Se actualiza a 100 millones
\.


--
-- TOC entry 4906 (class 0 OID 0)
-- Dependencies: 217
-- Name: asegurados_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.asegurados_id_seq', 27, true);


--
-- TOC entry 4750 (class 2606 OID 16402)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 4748 (class 2606 OID 16397)
-- Name: asegurados asegurados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asegurados
    ADD CONSTRAINT asegurados_pkey PRIMARY KEY (id);


-- Completed on 2025-11-25 12:27:49

--
-- PostgreSQL database dump complete
--

--
-- Database "vetproapp_db" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-11-25 12:27:49

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

--
-- TOC entry 5224 (class 1262 OID 32782)
-- Name: vetproapp_db; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE vetproapp_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Spain.1252';


ALTER DATABASE vetproapp_db OWNER TO postgres;

\connect vetproapp_db

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

--
-- TOC entry 264 (class 1255 OID 32792)
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_timestamp() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 239 (class 1259 OID 32991)
-- Name: citas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.citas (
    id integer NOT NULL,
    user_id integer NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    estado_id integer,
    notas_cliente text,
    notas_veterinaria text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.citas OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 32990)
-- Name: citas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.citas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.citas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 33076)
-- Name: citas_mascotas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.citas_mascotas (
    id integer NOT NULL,
    cita_id integer NOT NULL,
    mascota_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.citas_mascotas OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 33075)
-- Name: citas_mascotas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.citas_mascotas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.citas_mascotas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 33055)
-- Name: citas_servicios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.citas_servicios (
    id integer NOT NULL,
    cita_id integer NOT NULL,
    servicio_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.citas_servicios OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 33054)
-- Name: citas_servicios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.citas_servicios ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.citas_servicios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 32795)
-- Name: ciudades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ciudades (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL,
    departamento_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ciudades OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 32794)
-- Name: ciudades_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ciudades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ciudades_id_seq OWNER TO postgres;

--
-- TOC entry 5225 (class 0 OID 0)
-- Dependencies: 219
-- Name: ciudades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ciudades_id_seq OWNED BY public.ciudades.id;


--
-- TOC entry 218 (class 1259 OID 32784)
-- Name: departamentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departamentos (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    pais_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.departamentos OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 32783)
-- Name: departamentos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departamentos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departamentos_id_seq OWNER TO postgres;

--
-- TOC entry 5226 (class 0 OID 0)
-- Dependencies: 217
-- Name: departamentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departamentos_id_seq OWNED BY public.departamentos.id;


--
-- TOC entry 221 (class 1259 OID 32835)
-- Name: departamentos_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.departamentos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.departamentos_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 32908)
-- Name: especies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.especies (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.especies OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 32907)
-- Name: especies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.especies ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.especies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 237 (class 1259 OID 32980)
-- Name: estados_citas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estados_citas (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.estados_citas OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 32979)
-- Name: estados_citas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.estados_citas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.estados_citas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 257 (class 1259 OID 33188)
-- Name: historia_clinica_mascota; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historia_clinica_mascota (
    id integer NOT NULL,
    mascota_id integer NOT NULL,
    veterinaria_id integer,
    cita_id integer,
    fecha timestamp without time zone NOT NULL,
    motivo text,
    descripcion text NOT NULL,
    diagnostico text,
    tratamiento text,
    receta_url text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.historia_clinica_mascota OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 33187)
-- Name: historia_clinica_mascota_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.historia_clinica_mascota ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.historia_clinica_mascota_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 251 (class 1259 OID 33129)
-- Name: horarios_veterinaria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.horarios_veterinaria (
    id integer NOT NULL,
    veterinaria_id integer NOT NULL,
    dia_semana smallint NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    disponible boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.horarios_veterinaria OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 33128)
-- Name: horarios_veterinaria_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.horarios_veterinaria ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.horarios_veterinaria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 32937)
-- Name: mascotas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mascotas (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    especie_id integer,
    raza_id integer,
    fecha_nacimiento date,
    sexo character varying(10),
    color character varying(50),
    peso_kg numeric(5,2),
    foto_principal text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mascotas OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 33214)
-- Name: mascotas_fotos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mascotas_fotos (
    id integer NOT NULL,
    mascota_id integer NOT NULL,
    url text NOT NULL,
    descripcion text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mascotas_fotos OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 33213)
-- Name: mascotas_fotos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.mascotas_fotos ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mascotas_fotos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 32936)
-- Name: mascotas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.mascotas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mascotas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 32959)
-- Name: mascotas_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mascotas_users (
    id integer NOT NULL,
    mascota_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mascotas_users OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 32958)
-- Name: mascotas_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.mascotas_users ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.mascotas_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 32919)
-- Name: razas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.razas (
    id integer NOT NULL,
    especie_id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.razas OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 32918)
-- Name: razas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.razas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.razas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 255 (class 1259 OID 33167)
-- Name: recomendaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recomendaciones (
    id integer NOT NULL,
    titulo character varying(150) NOT NULL,
    descripcion text NOT NULL,
    especie_id integer,
    veterinaria_id integer,
    imagen_url text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.recomendaciones OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 33166)
-- Name: recomendaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.recomendaciones ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.recomendaciones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 227 (class 1259 OID 32877)
-- Name: rol_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rol_user (
    id integer NOT NULL,
    user_id integer NOT NULL,
    rol_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.rol_user OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 32876)
-- Name: rol_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rol_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rol_user_id_seq OWNER TO postgres;

--
-- TOC entry 5227 (class 0 OID 0)
-- Dependencies: 226
-- Name: rol_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rol_user_id_seq OWNED BY public.rol_user.id;


--
-- TOC entry 225 (class 1259 OID 32863)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 32862)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- TOC entry 5228 (class 0 OID 0)
-- Dependencies: 224
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- TOC entry 243 (class 1259 OID 33038)
-- Name: servicios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servicios (
    id integer NOT NULL,
    tipo_servicio_id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    activo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.servicios OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 33037)
-- Name: servicios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.servicios ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.servicios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 33027)
-- Name: tipo_servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_servicio (
    id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tipo_servicio OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 33026)
-- Name: tipo_servicio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tipo_servicio ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tipo_servicio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 32837)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    nombre_completo character varying(150) NOT NULL,
    correo character varying(120) NOT NULL,
    password_hash text NOT NULL,
    direccion character varying(200),
    ciudad_id integer,
    departamento_id integer,
    celular character varying(20),
    activo boolean DEFAULT false NOT NULL,
    ultimo_intento_ingreso timestamp without time zone,
    intentos_fallidos integer DEFAULT 0 NOT NULL,
    ultimo_ingreso timestamp without time zone,
    reset_token text,
    reset_token_expira timestamp without time zone,
    ultimo_cambio_contrasena timestamp without time zone,
    activation_token text,
    activation_token_expira timestamp without time zone,
    activado_en timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 32836)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 222
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 261 (class 1259 OID 33230)
-- Name: veterinaria_rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veterinaria_rol (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.veterinaria_rol OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 33229)
-- Name: veterinaria_rol_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.veterinaria_rol ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.veterinaria_rol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 263 (class 1259 OID 33242)
-- Name: veterinaria_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veterinaria_user (
    id integer NOT NULL,
    veterinaria_id integer NOT NULL,
    user_id integer NOT NULL,
    veterinaria_rol_id integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.veterinaria_user OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 33241)
-- Name: veterinaria_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.veterinaria_user ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.veterinaria_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 249 (class 1259 OID 33108)
-- Name: veterinarias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veterinarias (
    id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    direccion character varying(255),
    telefono character varying(50),
    ciudad_id integer,
    latitud numeric(10,7),
    longitud numeric(10,7),
    user_admin_id integer,
    logo_url text,
    descripcion text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.veterinarias OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 33146)
-- Name: veterinarias_citas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.veterinarias_citas (
    id integer NOT NULL,
    veterinaria_id integer NOT NULL,
    cita_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.veterinarias_citas OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 33145)
-- Name: veterinarias_citas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.veterinarias_citas ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.veterinarias_citas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 248 (class 1259 OID 33107)
-- Name: veterinarias_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.veterinarias ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.veterinarias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4856 (class 2604 OID 32798)
-- Name: ciudades id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades ALTER COLUMN id SET DEFAULT nextval('public.ciudades_id_seq'::regclass);


--
-- TOC entry 4867 (class 2604 OID 32880)
-- Name: rol_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol_user ALTER COLUMN id SET DEFAULT nextval('public.rol_user_id_seq'::regclass);


--
-- TOC entry 4864 (class 2604 OID 32866)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- TOC entry 4859 (class 2604 OID 32840)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5194 (class 0 OID 32991)
-- Dependencies: 239
-- Data for Name: citas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.citas (id, user_id, fecha_hora, estado_id, notas_cliente, notas_veterinaria, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5202 (class 0 OID 33076)
-- Dependencies: 247
-- Data for Name: citas_mascotas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.citas_mascotas (id, cita_id, mascota_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5200 (class 0 OID 33055)
-- Dependencies: 245
-- Data for Name: citas_servicios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.citas_servicios (id, cita_id, servicio_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5175 (class 0 OID 32795)
-- Dependencies: 220
-- Data for Name: ciudades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ciudades (id, nombre, departamento_id, created_at, updated_at) FROM stdin;
1	Leticia	1	2025-11-19 12:53:29.052738	2025-11-19 12:53:29.052738
2	Puerto Nariño	1	2025-11-19 12:53:29.052738	2025-11-19 12:53:29.052738
3	Medellín	2	2025-11-19 12:53:40.736538	2025-11-19 12:53:40.736538
4	Bello	2	2025-11-19 12:53:40.736538	2025-11-19 12:53:40.736538
5	Itagüí	2	2025-11-19 12:53:40.736538	2025-11-19 12:53:40.736538
6	Envigado	2	2025-11-19 12:53:40.736538	2025-11-19 12:53:40.736538
7	Rionegro	2	2025-11-19 12:53:40.736538	2025-11-19 12:53:40.736538
8	Turbo	2	2025-11-19 12:53:40.736538	2025-11-19 12:53:40.736538
9	Apartadó	2	2025-11-19 12:53:40.736538	2025-11-19 12:53:40.736538
10	Arauca	3	2025-11-19 12:53:49.056971	2025-11-19 12:53:49.056971
11	Saravena	3	2025-11-19 12:53:49.056971	2025-11-19 12:53:49.056971
12	Tame	3	2025-11-19 12:53:49.056971	2025-11-19 12:53:49.056971
13	Barranquilla	4	2025-11-19 12:53:57.685256	2025-11-19 12:53:57.685256
14	Soledad	4	2025-11-19 12:53:57.685256	2025-11-19 12:53:57.685256
15	Malambo	4	2025-11-19 12:53:57.685256	2025-11-19 12:53:57.685256
16	Sabanalarga	4	2025-11-19 12:53:57.685256	2025-11-19 12:53:57.685256
17	Puerto Colombia	4	2025-11-19 12:53:57.685256	2025-11-19 12:53:57.685256
18	Galapa	4	2025-11-19 12:53:57.685256	2025-11-19 12:53:57.685256
19	Cartagena	5	2025-11-19 12:54:08.828833	2025-11-19 12:54:08.828833
20	Magangué	5	2025-11-19 12:54:08.828833	2025-11-19 12:54:08.828833
21	Turbaco	5	2025-11-19 12:54:08.828833	2025-11-19 12:54:08.828833
22	Arjona	5	2025-11-19 12:54:08.828833	2025-11-19 12:54:08.828833
23	Tunja	6	2025-11-19 12:54:21.053652	2025-11-19 12:54:21.053652
24	Sogamoso	6	2025-11-19 12:54:21.053652	2025-11-19 12:54:21.053652
25	Duitama	6	2025-11-19 12:54:21.053652	2025-11-19 12:54:21.053652
26	Chiquinquirá	6	2025-11-19 12:54:21.053652	2025-11-19 12:54:21.053652
27	Manizales	7	2025-11-19 12:54:29.885448	2025-11-19 12:54:29.885448
28	Villamaría	7	2025-11-19 12:54:29.885448	2025-11-19 12:54:29.885448
29	Chinchiná	7	2025-11-19 12:54:29.885448	2025-11-19 12:54:29.885448
30	Florencia	8	2025-11-19 12:54:38.393429	2025-11-19 12:54:38.393429
31	San Vicente del Caguán	8	2025-11-19 12:54:38.393429	2025-11-19 12:54:38.393429
32	Yopal	9	2025-11-19 12:54:46.571086	2025-11-19 12:54:46.571086
33	Aguazul	9	2025-11-19 12:54:46.571086	2025-11-19 12:54:46.571086
34	Villanueva	9	2025-11-19 12:54:46.571086	2025-11-19 12:54:46.571086
35	Popayán	10	2025-11-19 12:54:57.811987	2025-11-19 12:54:57.811987
36	Santander de Quilichao	10	2025-11-19 12:54:57.811987	2025-11-19 12:54:57.811987
37	Valledupar	11	2025-11-19 12:55:14.27417	2025-11-19 12:55:14.27417
38	Aguachica	11	2025-11-19 12:55:14.27417	2025-11-19 12:55:14.27417
39	Quibdó	12	2025-11-19 12:55:22.009566	2025-11-19 12:55:22.009566
40	Istmina	12	2025-11-19 12:55:22.009566	2025-11-19 12:55:22.009566
41	Montería	13	2025-11-19 12:55:28.79796	2025-11-19 12:55:28.79796
42	Lorica	13	2025-11-19 12:55:28.79796	2025-11-19 12:55:28.79796
43	Sahagún	13	2025-11-19 12:55:28.79796	2025-11-19 12:55:28.79796
45	Soacha	14	2025-11-19 12:55:42.818287	2025-11-19 12:55:42.818287
46	Zipaquirá	14	2025-11-19 12:55:42.818287	2025-11-19 12:55:42.818287
47	Facatativá	14	2025-11-19 12:55:42.818287	2025-11-19 12:55:42.818287
48	Chía	14	2025-11-19 12:55:42.818287	2025-11-19 12:55:42.818287
49	Girardot	14	2025-11-19 12:55:42.818287	2025-11-19 12:55:42.818287
50	Inírida	15	2025-11-19 12:55:58.321019	2025-11-19 12:55:58.321019
51	San José del Guaviare	16	2025-11-19 12:56:11.612546	2025-11-19 12:56:11.612546
52	Neiva	17	2025-11-19 12:56:20.491255	2025-11-19 12:56:20.491255
53	Pitalito	17	2025-11-19 12:56:20.491255	2025-11-19 12:56:20.491255
54	Riohacha	18	2025-11-19 12:56:28.997588	2025-11-19 12:56:28.997588
55	Maicao	18	2025-11-19 12:56:28.997588	2025-11-19 12:56:28.997588
56	Uribia	18	2025-11-19 12:56:28.997588	2025-11-19 12:56:28.997588
57	Santa Marta	19	2025-11-19 12:56:35.803083	2025-11-19 12:56:35.803083
58	Ciénaga	19	2025-11-19 12:56:35.803083	2025-11-19 12:56:35.803083
59	Fundación	19	2025-11-19 12:56:35.803083	2025-11-19 12:56:35.803083
60	Villavicencio	20	2025-11-19 12:56:44.736536	2025-11-19 12:56:44.736536
61	Acacías	20	2025-11-19 12:56:44.736536	2025-11-19 12:56:44.736536
62	Pasto	21	2025-11-19 12:56:52.793778	2025-11-19 12:56:52.793778
63	Tumaco	21	2025-11-19 12:56:52.793778	2025-11-19 12:56:52.793778
64	Cúcuta	22	2025-11-19 12:57:06.054072	2025-11-19 12:57:06.054072
65	Ocaña	22	2025-11-19 12:57:06.054072	2025-11-19 12:57:06.054072
66	Pamplona	22	2025-11-19 12:57:06.054072	2025-11-19 12:57:06.054072
67	Mocoa	23	2025-11-19 12:57:13.87389	2025-11-19 12:57:13.87389
68	Puerto Asís	23	2025-11-19 12:57:13.87389	2025-11-19 12:57:13.87389
69	Armenia	24	2025-11-19 12:57:19.738708	2025-11-19 12:57:19.738708
70	Montenegro	24	2025-11-19 12:57:19.738708	2025-11-19 12:57:19.738708
71	Calarcá	24	2025-11-19 12:57:19.738708	2025-11-19 12:57:19.738708
72	Pereira	25	2025-11-19 12:57:26.696238	2025-11-19 12:57:26.696238
73	Dosquebradas	25	2025-11-19 12:57:26.696238	2025-11-19 12:57:26.696238
74	Santa Rosa de Cabal	25	2025-11-19 12:57:26.696238	2025-11-19 12:57:26.696238
75	San Andrés	26	2025-11-19 12:57:33.780258	2025-11-19 12:57:33.780258
76	Providencia	26	2025-11-19 12:57:33.780258	2025-11-19 12:57:33.780258
77	Bucaramanga	27	2025-11-19 12:57:40.382105	2025-11-19 12:57:40.382105
78	Floridablanca	27	2025-11-19 12:57:40.382105	2025-11-19 12:57:40.382105
79	Girón	27	2025-11-19 12:57:40.382105	2025-11-19 12:57:40.382105
80	Piedecuesta	27	2025-11-19 12:57:40.382105	2025-11-19 12:57:40.382105
81	Barrancabermeja	27	2025-11-19 12:57:40.382105	2025-11-19 12:57:40.382105
82	Sincelejo	28	2025-11-19 12:57:46.6844	2025-11-19 12:57:46.6844
83	Corozal	28	2025-11-19 12:57:46.6844	2025-11-19 12:57:46.6844
84	Ibagué	29	2025-11-19 12:57:52.976425	2025-11-19 12:57:52.976425
85	Espinal	29	2025-11-19 12:57:52.976425	2025-11-19 12:57:52.976425
86	Melgar	29	2025-11-19 12:57:52.976425	2025-11-19 12:57:52.976425
87	Cali	30	2025-11-19 12:58:00.381296	2025-11-19 12:58:00.381296
88	Palmira	30	2025-11-19 12:58:00.381296	2025-11-19 12:58:00.381296
89	Buenaventura	30	2025-11-19 12:58:00.381296	2025-11-19 12:58:00.381296
90	Tuluá	30	2025-11-19 12:58:00.381296	2025-11-19 12:58:00.381296
91	Cartago	30	2025-11-19 12:58:00.381296	2025-11-19 12:58:00.381296
92	Mitú	31	2025-11-19 12:58:08.42525	2025-11-19 12:58:08.42525
93	Puerto Carreño	32	2025-11-19 12:58:15.189974	2025-11-19 12:58:15.189974
44	Bogotá D.C.	33	2025-11-19 12:55:42.818287	2025-11-19 13:10:49.812189
94	Luruaco	4	2025-11-19 13:11:53.067671	2025-11-19 13:11:53.067671
95	Baranoa	4	2025-11-19 13:12:10.473238	2025-11-19 13:12:10.473238
\.


--
-- TOC entry 5173 (class 0 OID 32784)
-- Dependencies: 218
-- Data for Name: departamentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departamentos (id, nombre, pais_id, created_at, updated_at) FROM stdin;
1	Amazonas	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
2	Antioquia	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
3	Arauca	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
4	Atlántico	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
5	Bolívar	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
6	Boyacá	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
7	Caldas	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
8	Caquetá	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
9	Casanare	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
10	Cauca	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
11	Cesar	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
12	Chocó	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
13	Córdoba	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
14	Cundinamarca	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
15	Guainía	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
16	Guaviare	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
17	Huila	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
18	La Guajira	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
19	Magdalena	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
20	Meta	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
21	Nariño	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
22	Norte de Santander	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
23	Putumayo	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
24	Quindío	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
25	Risaralda	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
26	San Andrés y Providencia	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
27	Santander	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
28	Sucre	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
29	Tolima	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
30	Valle del Cauca	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
31	Vaupés	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
32	Vichada	1	2025-11-19 12:51:29.461683	2025-11-19 12:51:29.461683
33	Bogotá D.C.	1	2025-11-19 13:10:42.546663	2025-11-19 13:10:42.546663
\.


--
-- TOC entry 5184 (class 0 OID 32908)
-- Dependencies: 229
-- Data for Name: especies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.especies (id, nombre, descripcion, created_at, updated_at) FROM stdin;
1	Perro	Canis lupus familiaris	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
2	Gato	Felis catus	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
3	Ave	Aves de distintas especies	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
4	Conejo	Oryctolagus cuniculus	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
5	Hamster	Roedores pequeños	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
6	Tortuga	Reptiles quelonios	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
7	Pez	Especies acuáticas	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
8	Erizo	Mamífero insectívoro	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
9	Animal Exótico	Animales salvajes o no convencionales	2025-11-25 12:10:16.30589	2025-11-25 12:10:16.30589
\.


--
-- TOC entry 5192 (class 0 OID 32980)
-- Dependencies: 237
-- Data for Name: estados_citas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estados_citas (id, nombre, descripcion, created_at, updated_at) FROM stdin;
1	Pendiente	La cita ha sido creada y espera confirmación	2025-11-25 12:10:51.385338	2025-11-25 12:10:51.385338
2	Confirmada	La cita ha sido aceptada por la veterinaria	2025-11-25 12:10:51.385338	2025-11-25 12:10:51.385338
3	Completada	La cita fue realizada con éxito	2025-11-25 12:10:51.385338	2025-11-25 12:10:51.385338
4	Cancelada	La cita fue cancelada por el usuario o la veterinaria	2025-11-25 12:10:51.385338	2025-11-25 12:10:51.385338
5	No asistió	El usuario no acudió a la cita	2025-11-25 12:10:51.385338	2025-11-25 12:10:51.385338
\.


--
-- TOC entry 5212 (class 0 OID 33188)
-- Dependencies: 257
-- Data for Name: historia_clinica_mascota; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historia_clinica_mascota (id, mascota_id, veterinaria_id, cita_id, fecha, motivo, descripcion, diagnostico, tratamiento, receta_url, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5206 (class 0 OID 33129)
-- Dependencies: 251
-- Data for Name: horarios_veterinaria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.horarios_veterinaria (id, veterinaria_id, dia_semana, hora_inicio, hora_fin, disponible, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5188 (class 0 OID 32937)
-- Dependencies: 233
-- Data for Name: mascotas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mascotas (id, nombre, especie_id, raza_id, fecha_nacimiento, sexo, color, peso_kg, foto_principal, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5214 (class 0 OID 33214)
-- Dependencies: 259
-- Data for Name: mascotas_fotos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mascotas_fotos (id, mascota_id, url, descripcion, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5190 (class 0 OID 32959)
-- Dependencies: 235
-- Data for Name: mascotas_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mascotas_users (id, mascota_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5186 (class 0 OID 32919)
-- Dependencies: 231
-- Data for Name: razas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.razas (id, especie_id, nombre, descripcion, created_at, updated_at) FROM stdin;
1	1	Labrador Retriever	Raza grande, amigable y activa	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
2	1	Pastor Alemán	Raza inteligente y fuerte	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
3	1	Pug	Raza pequeña braquicéfala	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
4	1	Golden Retriever	Raza amigable y familiar	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
5	1	Bulldog Francés	Raza pequeña braquicéfala	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
6	2	Persa	Raza de pelo largo y cara chata	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
7	2	Siames	Raza oriental delgada y vocal	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
8	2	Maine Coon	Gatos grandes y robustos	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
9	2	Bengala	Pelaje tipo leopardo	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
10	2	Esfinge	Gato sin pelo	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
11	3	Periquito	Ave pequeña doméstica	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
12	3	Cotorra	Ave mediana muy social	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
13	3	Canario	Ave pequeña con canto fuerte	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
14	4	Cabeza de León	Raza pequeña con melena	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
15	4	Enano	Conejo miniatura	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
16	6	Tortuga de Orejas Rojas	Reptil acuático popular	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
17	6	Tortuga Rusa	Reptil terrestre pequeño	2025-11-25 12:10:33.295696	2025-11-25 12:10:33.295696
\.


--
-- TOC entry 5210 (class 0 OID 33167)
-- Dependencies: 255
-- Data for Name: recomendaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recomendaciones (id, titulo, descripcion, especie_id, veterinaria_id, imagen_url, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5182 (class 0 OID 32877)
-- Dependencies: 227
-- Data for Name: rol_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rol_user (id, user_id, rol_id, created_at, updated_at) FROM stdin;
5	14	2	2025-11-21 16:37:25.602973	2025-11-21 16:37:25.602973
1	3	1	2025-11-21 11:29:08.429415	2025-11-21 11:29:08.429415
\.


--
-- TOC entry 5180 (class 0 OID 32863)
-- Dependencies: 225
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, nombre, descripcion, created_at, updated_at) FROM stdin;
1	admin	Acceso total al sistema	2025-11-21 11:28:33.122874	2025-11-21 11:28:33.122874
2	veterinaria	Gestión de citas, pacientes y consultas	2025-11-21 11:28:33.122874	2025-11-21 11:35:36.019867
3	usuario	Usuario estándar de la aplicación	2025-11-21 11:28:33.122874	2025-11-21 11:35:36.028243
\.


--
-- TOC entry 5198 (class 0 OID 33038)
-- Dependencies: 243
-- Data for Name: servicios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.servicios (id, tipo_servicio_id, nombre, descripcion, activo, created_at, updated_at) FROM stdin;
1	1	Consulta General	Exámenes físicos, revisiones de rutina y diagnóstico de problemas de salud iniciales.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
2	1	Medicina Preventiva	Vacunación, desparasitación, asesoramiento nutricional y planes de bienestar.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
3	1	Diagnóstico	Análisis de laboratorio (sangre, orina) y diagnóstico por imagen (rayos X, ecografía).	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
4	1	Farmacología	Prescripción y suministro de medicamentos veterinarios.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
5	1	Odontología	Limpiezas dentales, extracciones y tratamiento de enfermedades periodontales.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
6	2	Cirugía General	Esterilización, castración y cirugías de tejidos blandos como tumores o heridas.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
7	2	Cirugía Especializada	Procedimientos de ortopedia y neurología como cirugía de columna y fracturas.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
8	3	Medicina Interna	Manejo de enfermedades complejas que afectan órganos internos.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
9	3	Cardiología	Diagnóstico y tratamiento de enfermedades del corazón.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
10	3	Oncología	Tratamiento del cáncer, incluyendo quimioterapia y control del dolor.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
11	3	Dermatología	Tratamiento de problemas de piel, pelo y oídos.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
12	3	Oftalmología	Tratamiento de enfermedades y lesiones oculares.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
13	3	Neurología	Diagnóstico y tratamiento de trastornos neurológicos y cerebrales.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
14	3	Etología y Comportamiento Animal	Manejo de problemas de conducta y apoyo en adiestramiento.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
15	3	Fisioterapia y Rehabilitación	Terapia física para la recuperación de lesiones u operaciones.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
16	4	Medicina de Emergencia y Cuidados Críticos	Atención inmediata 24/7 para accidentes y enfermedades graves.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
17	4	Hospitalización	Cuidado y monitoreo continuo de pacientes internados.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
18	5	Animales de Compañía	Servicios centrados en mascotas como perros, gatos, aves y roedores.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
19	5	Animales Exóticos y Fauna Salvaje	Atención a especies menos comunes o animales de zoológico.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
20	5	Animales de Producción y Ganadería	Manejo de la salud de rebaños y programas de producción animal.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
21	5	Animales de Laboratorio	Cuidado y bienestar de animales utilizados en investigación.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
22	6	Inspección Alimentaria	Garantizar la seguridad e inocuidad de los productos de origen animal.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
23	6	Control de Enfermedades Notificables	Vigilancia y respuesta a brotes de enfermedades, incluyendo zoonosis.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
24	6	Certificación y Control	Emisión de certificados sanitarios para el movimiento de animales y productos.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
25	6	Investigación y Epidemiología	Estudio y prevención de enfermedades a gran escala.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
26	7	Peluquería y Estética (Grooming)	Baño, corte de pelo y cuidado estético de las mascotas.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
27	7	Hospedaje y Guardería	Cuidado temporal de animales cuando sus dueños están ausentes.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
28	7	Servicios Funerarios y Cremación	Manejo digno de los restos de mascotas fallecidas.	t	2025-11-25 12:04:01.063991	2025-11-25 12:04:01.063991
\.


--
-- TOC entry 5196 (class 0 OID 33027)
-- Dependencies: 241
-- Data for Name: tipo_servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipo_servicio (id, nombre, descripcion, created_at, updated_at) FROM stdin;
1	Servicios Clínicos y Preventivos	Servicios orientados a la prevención y manejo clínico general de la salud de las mascotas.	2025-11-25 12:03:07.226626	2025-11-25 12:03:07.226626
2	Servicios Quirúrgicos	Procedimientos quirúrgicos generales y especializados para animales.	2025-11-25 12:03:07.226626	2025-11-25 12:03:07.226626
3	Servicios de Especialidad Médica	Atención especializada en distintas áreas de la medicina veterinaria.	2025-11-25 12:03:07.226626	2025-11-25 12:03:07.226626
4	Servicios de Emergencia y Hospitalización	Atención de urgencias y cuidados continuos de pacientes internados.	2025-11-25 12:03:07.226626	2025-11-25 12:03:07.226626
5	Servicios Relacionados con el Tipo de Animal	Servicios específicos según el tipo de animal.	2025-11-25 12:03:07.226626	2025-11-25 12:03:07.226626
6	Servicios de Salud Pública y Gubernamentales	Servicios vinculados a control sanitario, certificaciones y salud pública.	2025-11-25 12:03:07.226626	2025-11-25 12:03:07.226626
7	Otros Servicios Auxiliares	Servicios adicionales para el bienestar y manejo integral de los animales.	2025-11-25 12:03:07.226626	2025-11-25 12:03:07.226626
\.


--
-- TOC entry 5178 (class 0 OID 32837)
-- Dependencies: 223
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, nombre_completo, correo, password_hash, direccion, ciudad_id, departamento_id, celular, activo, ultimo_intento_ingreso, intentos_fallidos, ultimo_ingreso, reset_token, reset_token_expira, ultimo_cambio_contrasena, activation_token, activation_token_expira, activado_en, created_at, updated_at) FROM stdin;
4	Cesar Zuñiga	paurbi1101@gmail.com	$2b$10$de7ICqSiTnhuG6uquPJEkOph8n3RJEUCKd4nWFuqJ7QHIPd3f2eBG	Calle 123	1	1	3001234567	t	2025-11-21 11:39:04.875609	0	2025-11-21 11:39:04.875609	\N	\N	\N	\N	\N	2025-11-21 11:38:35.86711	2025-11-21 11:38:18.225111	2025-11-21 11:39:04.875609
14	Veterinarian 1	vet1@gmail.com	$2b$10$0ew0Yv6WFQV3V40ZEKaHP.6PBjAdcMZBlGkvIeEsUr5vmQJqLWnlS	Calle 58 No. 30-11	14	4	3046491479	t	2025-11-21 16:38:03.260457	0	2025-11-21 16:38:03.260457	\N	\N	\N	\N	\N	2025-11-21 16:37:25.581475	2025-11-21 16:30:31.296342	2025-11-25 09:21:29.515588
3	Paulo Urbina	paurbi_1101@hotmail.com	$2b$10$QHC5Ho6.iGAsaA2cwO2hB.VqS37KgyZClOnCh7rF45aF/3SEijNtq	Calle 58 No. 30-11	14	4	3046491479	t	2025-11-25 11:12:12.63962	0	2025-11-25 11:12:12.63962	\N	\N	2025-11-21 16:24:54.265335	\N	\N	2025-11-20 13:04:43.290003	2025-11-20 12:59:57.26584	2025-11-25 11:12:12.63962
\.


--
-- TOC entry 5216 (class 0 OID 33230)
-- Dependencies: 261
-- Data for Name: veterinaria_rol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veterinaria_rol (id, nombre, descripcion, created_at, updated_at) FROM stdin;
1	Administrador	Encargado principal de la veterinaria	2025-11-25 12:11:26.638423	2025-11-25 12:11:26.638423
2	Veterinario	Profesional médico encargado de las consultas	2025-11-25 12:11:26.638423	2025-11-25 12:11:26.638423
3	Auxiliar Veterinario	Asistente del médico veterinario	2025-11-25 12:11:26.638423	2025-11-25 12:11:26.638423
4	Recepcionista	Atiende clientes y agenda citas	2025-11-25 12:11:26.638423	2025-11-25 12:11:26.638423
5	Estilista/Groomer	Encargado de servicios estéticos	2025-11-25 12:11:26.638423	2025-11-25 12:11:26.638423
6	Especialista	Profesional con especialidad (cardiólogo, dermatólogo, etc.)	2025-11-25 12:11:26.638423	2025-11-25 12:11:26.638423
\.


--
-- TOC entry 5218 (class 0 OID 33242)
-- Dependencies: 263
-- Data for Name: veterinaria_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veterinaria_user (id, veterinaria_id, user_id, veterinaria_rol_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5204 (class 0 OID 33108)
-- Dependencies: 249
-- Data for Name: veterinarias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veterinarias (id, nombre, direccion, telefono, ciudad_id, latitud, longitud, user_admin_id, logo_url, descripcion, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5208 (class 0 OID 33146)
-- Dependencies: 253
-- Data for Name: veterinarias_citas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.veterinarias_citas (id, veterinaria_id, cita_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 238
-- Name: citas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.citas_id_seq', 1, false);


--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 246
-- Name: citas_mascotas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.citas_mascotas_id_seq', 1, false);


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 244
-- Name: citas_servicios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.citas_servicios_id_seq', 1, false);


--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 219
-- Name: ciudades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ciudades_id_seq', 95, true);


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 217
-- Name: departamentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departamentos_id_seq', 32, true);


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 221
-- Name: departamentos_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departamentos_id_seq1', 35, true);


--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 228
-- Name: especies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.especies_id_seq', 9, true);


--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 236
-- Name: estados_citas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estados_citas_id_seq', 5, true);


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 256
-- Name: historia_clinica_mascota_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historia_clinica_mascota_id_seq', 1, false);


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 250
-- Name: horarios_veterinaria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.horarios_veterinaria_id_seq', 1, false);


--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 258
-- Name: mascotas_fotos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mascotas_fotos_id_seq', 1, false);


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 232
-- Name: mascotas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mascotas_id_seq', 1, false);


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 234
-- Name: mascotas_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mascotas_users_id_seq', 1, false);


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 230
-- Name: razas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.razas_id_seq', 17, true);


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 254
-- Name: recomendaciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recomendaciones_id_seq', 1, false);


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 226
-- Name: rol_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rol_user_id_seq', 5, true);


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 224
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 242
-- Name: servicios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.servicios_id_seq', 28, true);


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 240
-- Name: tipo_servicio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipo_servicio_id_seq', 7, true);


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 222
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 14, true);


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 260
-- Name: veterinaria_rol_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veterinaria_rol_id_seq', 6, true);


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 262
-- Name: veterinaria_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veterinaria_user_id_seq', 1, false);


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 252
-- Name: veterinarias_citas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veterinarias_citas_id_seq', 1, false);


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 248
-- Name: veterinarias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.veterinarias_id_seq', 1, false);


--
-- TOC entry 4949 (class 2606 OID 33084)
-- Name: citas_mascotas citas_mascotas_cita_id_mascota_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas_mascotas
    ADD CONSTRAINT citas_mascotas_cita_id_mascota_id_key UNIQUE (cita_id, mascota_id);


--
-- TOC entry 4951 (class 2606 OID 33082)
-- Name: citas_mascotas citas_mascotas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas_mascotas
    ADD CONSTRAINT citas_mascotas_pkey PRIMARY KEY (id);


--
-- TOC entry 4939 (class 2606 OID 32999)
-- Name: citas citas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas
    ADD CONSTRAINT citas_pkey PRIMARY KEY (id);


--
-- TOC entry 4945 (class 2606 OID 33063)
-- Name: citas_servicios citas_servicios_cita_id_servicio_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas_servicios
    ADD CONSTRAINT citas_servicios_cita_id_servicio_id_key UNIQUE (cita_id, servicio_id);


--
-- TOC entry 4947 (class 2606 OID 33061)
-- Name: citas_servicios citas_servicios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas_servicios
    ADD CONSTRAINT citas_servicios_pkey PRIMARY KEY (id);


--
-- TOC entry 4911 (class 2606 OID 32802)
-- Name: ciudades ciudades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades
    ADD CONSTRAINT ciudades_pkey PRIMARY KEY (id);


--
-- TOC entry 4909 (class 2606 OID 32791)
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id);


--
-- TOC entry 4925 (class 2606 OID 32916)
-- Name: especies especies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especies
    ADD CONSTRAINT especies_pkey PRIMARY KEY (id);


--
-- TOC entry 4937 (class 2606 OID 32988)
-- Name: estados_citas estados_citas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estados_citas
    ADD CONSTRAINT estados_citas_pkey PRIMARY KEY (id);


--
-- TOC entry 4965 (class 2606 OID 33196)
-- Name: historia_clinica_mascota historia_clinica_mascota_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historia_clinica_mascota
    ADD CONSTRAINT historia_clinica_mascota_pkey PRIMARY KEY (id);


--
-- TOC entry 4955 (class 2606 OID 33136)
-- Name: horarios_veterinaria horarios_veterinaria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.horarios_veterinaria
    ADD CONSTRAINT horarios_veterinaria_pkey PRIMARY KEY (id);


--
-- TOC entry 4957 (class 2606 OID 33138)
-- Name: horarios_veterinaria horarios_veterinaria_veterinaria_id_dia_semana_hora_inicio__key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.horarios_veterinaria
    ADD CONSTRAINT horarios_veterinaria_veterinaria_id_dia_semana_hora_inicio__key UNIQUE (veterinaria_id, dia_semana, hora_inicio, hora_fin);


--
-- TOC entry 4967 (class 2606 OID 33222)
-- Name: mascotas_fotos mascotas_fotos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas_fotos
    ADD CONSTRAINT mascotas_fotos_pkey PRIMARY KEY (id);


--
-- TOC entry 4931 (class 2606 OID 32945)
-- Name: mascotas mascotas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas
    ADD CONSTRAINT mascotas_pkey PRIMARY KEY (id);


--
-- TOC entry 4933 (class 2606 OID 32967)
-- Name: mascotas_users mascotas_users_mascota_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas_users
    ADD CONSTRAINT mascotas_users_mascota_id_user_id_key UNIQUE (mascota_id, user_id);


--
-- TOC entry 4935 (class 2606 OID 32965)
-- Name: mascotas_users mascotas_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas_users
    ADD CONSTRAINT mascotas_users_pkey PRIMARY KEY (id);


--
-- TOC entry 4927 (class 2606 OID 32929)
-- Name: razas razas_especie_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.razas
    ADD CONSTRAINT razas_especie_id_nombre_key UNIQUE (especie_id, nombre);


--
-- TOC entry 4929 (class 2606 OID 32927)
-- Name: razas razas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.razas
    ADD CONSTRAINT razas_pkey PRIMARY KEY (id);


--
-- TOC entry 4963 (class 2606 OID 33175)
-- Name: recomendaciones recomendaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recomendaciones
    ADD CONSTRAINT recomendaciones_pkey PRIMARY KEY (id);


--
-- TOC entry 4921 (class 2606 OID 32884)
-- Name: rol_user rol_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol_user
    ADD CONSTRAINT rol_user_pkey PRIMARY KEY (id);


--
-- TOC entry 4923 (class 2606 OID 32886)
-- Name: rol_user rol_user_user_id_rol_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol_user
    ADD CONSTRAINT rol_user_user_id_rol_id_key UNIQUE (user_id, rol_id);


--
-- TOC entry 4917 (class 2606 OID 32874)
-- Name: roles roles_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_nombre_key UNIQUE (nombre);


--
-- TOC entry 4919 (class 2606 OID 32872)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4943 (class 2606 OID 33047)
-- Name: servicios servicios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios
    ADD CONSTRAINT servicios_pkey PRIMARY KEY (id);


--
-- TOC entry 4941 (class 2606 OID 33035)
-- Name: tipo_servicio tipo_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_servicio
    ADD CONSTRAINT tipo_servicio_pkey PRIMARY KEY (id);


--
-- TOC entry 4913 (class 2606 OID 32850)
-- Name: users users_correo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_correo_key UNIQUE (correo);


--
-- TOC entry 4915 (class 2606 OID 32848)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4969 (class 2606 OID 33238)
-- Name: veterinaria_rol veterinaria_rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinaria_rol
    ADD CONSTRAINT veterinaria_rol_pkey PRIMARY KEY (id);


--
-- TOC entry 4971 (class 2606 OID 33248)
-- Name: veterinaria_user veterinaria_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinaria_user
    ADD CONSTRAINT veterinaria_user_pkey PRIMARY KEY (id);


--
-- TOC entry 4973 (class 2606 OID 33250)
-- Name: veterinaria_user veterinaria_user_veterinaria_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinaria_user
    ADD CONSTRAINT veterinaria_user_veterinaria_id_user_id_key UNIQUE (veterinaria_id, user_id);


--
-- TOC entry 4959 (class 2606 OID 33154)
-- Name: veterinarias_citas veterinarias_citas_cita_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinarias_citas
    ADD CONSTRAINT veterinarias_citas_cita_id_key UNIQUE (cita_id);


--
-- TOC entry 4961 (class 2606 OID 33152)
-- Name: veterinarias_citas veterinarias_citas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinarias_citas
    ADD CONSTRAINT veterinarias_citas_pkey PRIMARY KEY (id);


--
-- TOC entry 4953 (class 2606 OID 33116)
-- Name: veterinarias veterinarias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinarias
    ADD CONSTRAINT veterinarias_pkey PRIMARY KEY (id);


--
-- TOC entry 5018 (class 2620 OID 33095)
-- Name: citas_mascotas citas_mascotas_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER citas_mascotas_update_timestamp BEFORE UPDATE ON public.citas_mascotas FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5017 (class 2620 OID 33074)
-- Name: citas_servicios citas_servicios_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER citas_servicios_update_timestamp BEFORE UPDATE ON public.citas_servicios FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5014 (class 2620 OID 33010)
-- Name: citas citas_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER citas_update_timestamp BEFORE UPDATE ON public.citas FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5006 (class 2620 OID 32808)
-- Name: ciudades ciudades_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ciudades_update_timestamp BEFORE UPDATE ON public.ciudades FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5005 (class 2620 OID 32793)
-- Name: departamentos departamentos_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER departamentos_update_timestamp BEFORE UPDATE ON public.departamentos FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5009 (class 2620 OID 32917)
-- Name: especies especies_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER especies_update_timestamp BEFORE UPDATE ON public.especies FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5013 (class 2620 OID 32989)
-- Name: estados_citas estados_citas_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER estados_citas_update_timestamp BEFORE UPDATE ON public.estados_citas FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5023 (class 2620 OID 33212)
-- Name: historia_clinica_mascota historia_clinica_mascota_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER historia_clinica_mascota_update_timestamp BEFORE UPDATE ON public.historia_clinica_mascota FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5020 (class 2620 OID 33144)
-- Name: horarios_veterinaria horarios_veterinaria_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER horarios_veterinaria_update_timestamp BEFORE UPDATE ON public.horarios_veterinaria FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5024 (class 2620 OID 33228)
-- Name: mascotas_fotos mascotas_fotos_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER mascotas_fotos_update_timestamp BEFORE UPDATE ON public.mascotas_fotos FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5011 (class 2620 OID 32956)
-- Name: mascotas mascotas_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER mascotas_update_timestamp BEFORE UPDATE ON public.mascotas FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5012 (class 2620 OID 32978)
-- Name: mascotas_users mascotas_users_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER mascotas_users_update_timestamp BEFORE UPDATE ON public.mascotas_users FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5010 (class 2620 OID 32935)
-- Name: razas razas_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER razas_update_timestamp BEFORE UPDATE ON public.razas FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5022 (class 2620 OID 33186)
-- Name: recomendaciones recomendaciones_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER recomendaciones_update_timestamp BEFORE UPDATE ON public.recomendaciones FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5008 (class 2620 OID 32875)
-- Name: roles roles_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER roles_update_timestamp BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5016 (class 2620 OID 33053)
-- Name: servicios servicios_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER servicios_update_timestamp BEFORE UPDATE ON public.servicios FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5015 (class 2620 OID 33036)
-- Name: tipo_servicio tipo_servicio_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tipo_servicio_update_timestamp BEFORE UPDATE ON public.tipo_servicio FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5007 (class 2620 OID 32861)
-- Name: users users_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER users_update_timestamp BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5025 (class 2620 OID 33239)
-- Name: veterinaria_rol veterinaria_rol_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER veterinaria_rol_update_timestamp BEFORE UPDATE ON public.veterinaria_rol FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5026 (class 2620 OID 33266)
-- Name: veterinaria_user veterinaria_user_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER veterinaria_user_update_timestamp BEFORE UPDATE ON public.veterinaria_user FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5021 (class 2620 OID 33165)
-- Name: veterinarias_citas veterinarias_citas_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER veterinarias_citas_update_timestamp BEFORE UPDATE ON public.veterinarias_citas FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 5019 (class 2620 OID 33127)
-- Name: veterinarias veterinarias_update_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER veterinarias_update_timestamp BEFORE UPDATE ON public.veterinarias FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- TOC entry 4984 (class 2606 OID 33005)
-- Name: citas citas_estado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas
    ADD CONSTRAINT citas_estado_id_fkey FOREIGN KEY (estado_id) REFERENCES public.estados_citas(id);


--
-- TOC entry 4989 (class 2606 OID 33085)
-- Name: citas_mascotas citas_mascotas_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas_mascotas
    ADD CONSTRAINT citas_mascotas_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.citas(id) ON DELETE CASCADE;


--
-- TOC entry 4990 (class 2606 OID 33090)
-- Name: citas_mascotas citas_mascotas_mascota_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas_mascotas
    ADD CONSTRAINT citas_mascotas_mascota_id_fkey FOREIGN KEY (mascota_id) REFERENCES public.mascotas(id) ON DELETE CASCADE;


--
-- TOC entry 4987 (class 2606 OID 33064)
-- Name: citas_servicios citas_servicios_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas_servicios
    ADD CONSTRAINT citas_servicios_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.citas(id) ON DELETE CASCADE;


--
-- TOC entry 4988 (class 2606 OID 33069)
-- Name: citas_servicios citas_servicios_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas_servicios
    ADD CONSTRAINT citas_servicios_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicios(id);


--
-- TOC entry 4985 (class 2606 OID 33000)
-- Name: citas citas_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citas
    ADD CONSTRAINT citas_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4974 (class 2606 OID 32803)
-- Name: ciudades ciudades_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades
    ADD CONSTRAINT ciudades_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamentos(id);


--
-- TOC entry 4977 (class 2606 OID 32892)
-- Name: rol_user fk_rol_user_role; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol_user
    ADD CONSTRAINT fk_rol_user_role FOREIGN KEY (rol_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- TOC entry 4978 (class 2606 OID 32887)
-- Name: rol_user fk_rol_user_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol_user
    ADD CONSTRAINT fk_rol_user_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4998 (class 2606 OID 33207)
-- Name: historia_clinica_mascota historia_clinica_mascota_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historia_clinica_mascota
    ADD CONSTRAINT historia_clinica_mascota_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.citas(id);


--
-- TOC entry 4999 (class 2606 OID 33197)
-- Name: historia_clinica_mascota historia_clinica_mascota_mascota_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historia_clinica_mascota
    ADD CONSTRAINT historia_clinica_mascota_mascota_id_fkey FOREIGN KEY (mascota_id) REFERENCES public.mascotas(id) ON DELETE CASCADE;


--
-- TOC entry 5000 (class 2606 OID 33202)
-- Name: historia_clinica_mascota historia_clinica_mascota_veterinaria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historia_clinica_mascota
    ADD CONSTRAINT historia_clinica_mascota_veterinaria_id_fkey FOREIGN KEY (veterinaria_id) REFERENCES public.veterinarias(id);


--
-- TOC entry 4993 (class 2606 OID 33139)
-- Name: horarios_veterinaria horarios_veterinaria_veterinaria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.horarios_veterinaria
    ADD CONSTRAINT horarios_veterinaria_veterinaria_id_fkey FOREIGN KEY (veterinaria_id) REFERENCES public.veterinarias(id) ON DELETE CASCADE;


--
-- TOC entry 4980 (class 2606 OID 32946)
-- Name: mascotas mascotas_especie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas
    ADD CONSTRAINT mascotas_especie_id_fkey FOREIGN KEY (especie_id) REFERENCES public.especies(id);


--
-- TOC entry 5001 (class 2606 OID 33223)
-- Name: mascotas_fotos mascotas_fotos_mascota_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas_fotos
    ADD CONSTRAINT mascotas_fotos_mascota_id_fkey FOREIGN KEY (mascota_id) REFERENCES public.mascotas(id) ON DELETE CASCADE;


--
-- TOC entry 4981 (class 2606 OID 32951)
-- Name: mascotas mascotas_raza_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas
    ADD CONSTRAINT mascotas_raza_id_fkey FOREIGN KEY (raza_id) REFERENCES public.razas(id);


--
-- TOC entry 4982 (class 2606 OID 32968)
-- Name: mascotas_users mascotas_users_mascota_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas_users
    ADD CONSTRAINT mascotas_users_mascota_id_fkey FOREIGN KEY (mascota_id) REFERENCES public.mascotas(id) ON DELETE CASCADE;


--
-- TOC entry 4983 (class 2606 OID 32973)
-- Name: mascotas_users mascotas_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mascotas_users
    ADD CONSTRAINT mascotas_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4979 (class 2606 OID 32930)
-- Name: razas razas_especie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.razas
    ADD CONSTRAINT razas_especie_id_fkey FOREIGN KEY (especie_id) REFERENCES public.especies(id) ON DELETE CASCADE;


--
-- TOC entry 4996 (class 2606 OID 33176)
-- Name: recomendaciones recomendaciones_especie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recomendaciones
    ADD CONSTRAINT recomendaciones_especie_id_fkey FOREIGN KEY (especie_id) REFERENCES public.especies(id);


--
-- TOC entry 4997 (class 2606 OID 33181)
-- Name: recomendaciones recomendaciones_veterinaria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recomendaciones
    ADD CONSTRAINT recomendaciones_veterinaria_id_fkey FOREIGN KEY (veterinaria_id) REFERENCES public.veterinarias(id);


--
-- TOC entry 4986 (class 2606 OID 33048)
-- Name: servicios servicios_tipo_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios
    ADD CONSTRAINT servicios_tipo_servicio_id_fkey FOREIGN KEY (tipo_servicio_id) REFERENCES public.tipo_servicio(id);


--
-- TOC entry 4975 (class 2606 OID 32851)
-- Name: users users_ciudad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_ciudad_id_fkey FOREIGN KEY (ciudad_id) REFERENCES public.ciudades(id);


--
-- TOC entry 4976 (class 2606 OID 32856)
-- Name: users users_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamentos(id);


--
-- TOC entry 5002 (class 2606 OID 33256)
-- Name: veterinaria_user veterinaria_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinaria_user
    ADD CONSTRAINT veterinaria_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5003 (class 2606 OID 33251)
-- Name: veterinaria_user veterinaria_user_veterinaria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinaria_user
    ADD CONSTRAINT veterinaria_user_veterinaria_id_fkey FOREIGN KEY (veterinaria_id) REFERENCES public.veterinarias(id) ON DELETE CASCADE;


--
-- TOC entry 5004 (class 2606 OID 33261)
-- Name: veterinaria_user veterinaria_user_veterinaria_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinaria_user
    ADD CONSTRAINT veterinaria_user_veterinaria_rol_id_fkey FOREIGN KEY (veterinaria_rol_id) REFERENCES public.veterinaria_rol(id);


--
-- TOC entry 4994 (class 2606 OID 33160)
-- Name: veterinarias_citas veterinarias_citas_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinarias_citas
    ADD CONSTRAINT veterinarias_citas_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.citas(id) ON DELETE CASCADE;


--
-- TOC entry 4995 (class 2606 OID 33155)
-- Name: veterinarias_citas veterinarias_citas_veterinaria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinarias_citas
    ADD CONSTRAINT veterinarias_citas_veterinaria_id_fkey FOREIGN KEY (veterinaria_id) REFERENCES public.veterinarias(id) ON DELETE CASCADE;


--
-- TOC entry 4991 (class 2606 OID 33117)
-- Name: veterinarias veterinarias_ciudad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinarias
    ADD CONSTRAINT veterinarias_ciudad_id_fkey FOREIGN KEY (ciudad_id) REFERENCES public.ciudades(id);


--
-- TOC entry 4992 (class 2606 OID 33122)
-- Name: veterinarias veterinarias_user_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.veterinarias
    ADD CONSTRAINT veterinarias_user_admin_id_fkey FOREIGN KEY (user_admin_id) REFERENCES public.users(id);


-- Completed on 2025-11-25 12:27:50

--
-- PostgreSQL database dump complete
--

-- Completed on 2025-11-25 12:27:50

--
-- PostgreSQL database cluster dump complete
--


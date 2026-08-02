--
-- PostgreSQL database dump
--

\restrict bDjK0B92YIsngveVmlLforJw3BLAoSadba6ldzeVBQGetg4PkbhR57CKAEvPDBI

-- Dumped from database version 18.4 (Ubuntu 18.4-0ubuntu0.26.04.1)
-- Dumped by pg_dump version 18.4 (Ubuntu 18.4-0ubuntu0.26.04.1)

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
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_command_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_command_templates (
    id bigint NOT NULL,
    organization_id bigint,
    intent character varying(100) NOT NULL,
    module character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    trigger_phrases json,
    required_entities json,
    optional_entities json,
    action_handler character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN ai_command_templates.intent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_command_templates.intent IS '意图标识';


--
-- Name: COLUMN ai_command_templates.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_command_templates.module IS '目标模块';


--
-- Name: COLUMN ai_command_templates.trigger_phrases; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_command_templates.trigger_phrases IS '触发词数组';


--
-- Name: COLUMN ai_command_templates.required_entities; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_command_templates.required_entities IS '必需实体字段列表';


--
-- Name: COLUMN ai_command_templates.optional_entities; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_command_templates.optional_entities IS '可选实体字段列表';


--
-- Name: COLUMN ai_command_templates.action_handler; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_command_templates.action_handler IS '后端处理类/方法名';


--
-- Name: ai_command_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_command_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_command_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_command_templates_id_seq OWNED BY public.ai_command_templates.id;


--
-- Name: ai_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_messages (
    id bigint NOT NULL,
    session_id bigint NOT NULL,
    role smallint NOT NULL,
    input_type smallint DEFAULT '1'::smallint NOT NULL,
    raw_content text,
    voice_url character varying(500),
    image_urls json,
    transcribed_text text,
    ocr_text text,
    ai_response text,
    intent character varying(100),
    entities json,
    confidence numeric(5,4),
    dispatched_module character varying(50),
    dispatched_action_id bigint,
    processing_time_ms integer,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: COLUMN ai_messages.role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.role IS '1:用户 2:AI助手';


--
-- Name: COLUMN ai_messages.input_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.input_type IS '1:文字 2:语音 3:图片 4:混合';


--
-- Name: COLUMN ai_messages.raw_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.raw_content IS '原始文字输入';


--
-- Name: COLUMN ai_messages.transcribed_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.transcribed_text IS '语音转文字结果';


--
-- Name: COLUMN ai_messages.ocr_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.ocr_text IS '图片OCR结果';


--
-- Name: COLUMN ai_messages.intent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.intent IS '识别的意图类型';


--
-- Name: COLUMN ai_messages.entities; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.entities IS '提取的实体（商品名、数量等）';


--
-- Name: COLUMN ai_messages.confidence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.confidence IS '意图置信度';


--
-- Name: COLUMN ai_messages.dispatched_module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.dispatched_module IS '分发到的功能模块';


--
-- Name: COLUMN ai_messages.dispatched_action_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_messages.dispatched_action_id IS '触发的业务记录ID';


--
-- Name: ai_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_messages_id_seq OWNED BY public.ai_messages.id;


--
-- Name: ai_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_sessions (
    id bigint NOT NULL,
    store_id bigint,
    user_id bigint NOT NULL,
    session_uuid uuid NOT NULL,
    channel smallint DEFAULT '1'::smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    started_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ended_at timestamp(0) without time zone,
    context json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN ai_sessions.channel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_sessions.channel IS '1:APP语音 2:APP文字 3:企业微信 4:Web';


--
-- Name: COLUMN ai_sessions.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_sessions.status IS '1:进行中 2:已完成 3:异常';


--
-- Name: COLUMN ai_sessions.context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ai_sessions.context IS '多轮对话上下文';


--
-- Name: ai_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_sessions_id_seq OWNED BY public.ai_sessions.id;


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_settings (
    id bigint NOT NULL,
    key character varying(100) NOT NULL,
    value text,
    label character varying(100),
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN app_settings.key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.app_settings.key IS '设置键，如 miniprogram_title';


--
-- Name: COLUMN app_settings.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.app_settings.value IS '设置值';


--
-- Name: COLUMN app_settings.label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.app_settings.label IS '后台显示的中文说明';


--
-- Name: app_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_settings_id_seq OWNED BY public.app_settings.id;


--
-- Name: cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL
);


--
-- Name: chat_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_logs (
    id bigint NOT NULL,
    agent_id character varying(100),
    direction character varying(255) NOT NULL,
    channel character varying(50),
    account_id character varying(100),
    conversation_id character varying(100),
    message_id character varying(100),
    sender character varying(200),
    content text,
    success boolean DEFAULT true NOT NULL,
    error_msg character varying(500),
    session_key character varying(200),
    occurred_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT chat_logs_direction_check CHECK (((direction)::text = ANY ((ARRAY['inbound'::character varying, 'outbound'::character varying])::text[])))
);


--
-- Name: chat_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chat_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chat_logs_id_seq OWNED BY public.chat_logs.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: industries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.industries (
    id bigint NOT NULL,
    slug character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    emoji character varying(16),
    title character varying(100),
    description character varying(200),
    sort_order integer DEFAULT 0 NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    api_base character varying(200),
    api_token text,
    ai_path character varying(200),
    ai_media boolean DEFAULT false NOT NULL,
    greeting text
);


--
-- Name: COLUMN industries.slug; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.slug IS '行业标识，如 fresh / restaurant；quick_actions.industry 用它过滤';


--
-- Name: COLUMN industries.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.name IS '行业名称，如 生鲜门店';


--
-- Name: COLUMN industries.emoji; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.emoji IS '行业图标 emoji';


--
-- Name: COLUMN industries.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.title IS '该行业聊天页顶栏品牌标题';


--
-- Name: COLUMN industries.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.description IS '行业说明（选择页副标题）';


--
-- Name: COLUMN industries.api_base; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.api_base IS '该行业菜单/标题/接口的外部后端 base（如 https://app2.xingke888.com/api）；留空=用本项目';


--
-- Name: COLUMN industries.api_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.api_token IS '外部行业服务账号 token；随 /api/industries 返回，小程序无需弹登录框直接使用';


--
-- Name: COLUMN industries.ai_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.ai_path IS '外部行业 AI 聊天接口路径，如 /api/chat/message；留空默认 /ai/message';


--
-- Name: COLUMN industries.ai_media; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.ai_media IS '该行业聊天是否启用语音/拍照/相册/文件输入';


--
-- Name: COLUMN industries.greeting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.industries.greeting IS '行业欢迎语（聊天页登录后展示）；留空小程序用通用兜底';


--
-- Name: industries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.industries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: industries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.industries_id_seq OWNED BY public.industries.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: knowledge_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_categories (
    id bigint NOT NULL,
    parent_id bigint,
    name character varying(100) NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: knowledge_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_categories_id_seq OWNED BY public.knowledge_categories.id;


--
-- Name: knowledge_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_items (
    id bigint NOT NULL,
    category_id bigint,
    content text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    embedding public.vector(1536),
    vectorized_at timestamp without time zone
);


--
-- Name: knowledge_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_items_id_seq OWNED BY public.knowledge_items.id;


--
-- Name: menu_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_templates (
    id bigint NOT NULL,
    industry character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN menu_templates.industry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_templates.industry IS '归属行业 slug（关联 industries.slug）';


--
-- Name: COLUMN menu_templates.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_templates.name IS '模版名，如 默认模版 / 完整版 / 促销版';


--
-- Name: COLUMN menu_templates.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.menu_templates.is_active IS '该行业当前生效的模版（每行业仅一个 true）';


--
-- Name: menu_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menu_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menu_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menu_templates_id_seq OWNED BY public.menu_templates.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    logo_url character varying(500),
    contact_phone character varying(20),
    settings json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN organizations.settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.organizations.settings IS '系统配置：功能开关、AI参数全局默认值';


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    module character varying(50) NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(100) NOT NULL,
    type smallint DEFAULT '2'::smallint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN permissions.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.permissions.module IS '模块标识';


--
-- Name: COLUMN permissions.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.permissions.code IS '如 inventory.product.create';


--
-- Name: COLUMN permissions.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.permissions.type IS '1:菜单 2:操作 3:数据';


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name text NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    content text NOT NULL,
    published boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: quick_action_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quick_action_items (
    id bigint NOT NULL,
    quick_action_id bigint NOT NULL,
    emoji character varying(50),
    label character varying(50) NOT NULL,
    "desc" character varying(100),
    item_type character varying(20) DEFAULT 'prompt'::character varying NOT NULL,
    route character varying(200),
    prompt text,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    show_in_chat boolean DEFAULT true NOT NULL
);


--
-- Name: COLUMN quick_action_items."desc"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_action_items."desc" IS '副标题说明';


--
-- Name: COLUMN quick_action_items.item_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_action_items.item_type IS 'route|prompt';


--
-- Name: COLUMN quick_action_items.route; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_action_items.route IS 'route 类型：小程序页路径，如 /pages/report/report';


--
-- Name: COLUMN quick_action_items.prompt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_action_items.prompt IS 'prompt 类型：发给 AI 的文字';


--
-- Name: quick_action_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quick_action_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_action_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quick_action_items_id_seq OWNED BY public.quick_action_items.id;


--
-- Name: quick_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quick_actions (
    id bigint NOT NULL,
    key character varying(50) NOT NULL,
    emoji character varying(16),
    label character varying(50) NOT NULL,
    badge character varying(20),
    action_type character varying(20) DEFAULT 'prompt'::character varying NOT NULL,
    prompt text,
    target_path character varying(200),
    target_title character varying(50),
    web_label character varying(50),
    admin_only boolean DEFAULT false NOT NULL,
    store_id bigint,
    enabled boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    industry character varying(50),
    menu_template_id bigint,
    show_in_chat boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN quick_actions.key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.key IS '按钮标识（data-key，用于样式 qa-chip-{key}）';


--
-- Name: COLUMN quick_actions.badge; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.badge IS '角标文字，空则不显示';


--
-- Name: COLUMN quick_actions.action_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.action_type IS 'prompt|web|open|menu';


--
-- Name: COLUMN quick_actions.prompt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.prompt IS 'prompt/web 类型：发给 AI 的文字';


--
-- Name: COLUMN quick_actions.target_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.target_path IS 'web/open 类型：web-view 路径，如 /inventory、/admin/sso';


--
-- Name: COLUMN quick_actions.target_title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.target_title IS 'web-view 页标题';


--
-- Name: COLUMN quick_actions.web_label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.web_label IS 'web 类型「打开完整页」按钮文字';


--
-- Name: COLUMN quick_actions.admin_only; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.admin_only IS '仅 is_admin 用户可见';


--
-- Name: COLUMN quick_actions.store_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.store_id IS 'null=全门店通用，否则仅该门店';


--
-- Name: COLUMN quick_actions.industry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quick_actions.industry IS '所属行业 slug（关联 industries.slug）；null=全行业通用';


--
-- Name: quick_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quick_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quick_actions_id_seq OWNED BY public.quick_actions.id;


--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regions (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    name character varying(100) NOT NULL,
    code character varying(50),
    status smallint DEFAULT '1'::smallint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    organization_id bigint,
    name character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    description text,
    scope smallint DEFAULT '3'::smallint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN roles.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.roles.code IS 'SUPER_ADMIN, REGION_BUYER, STORE_MANAGER, STORE_STAFF';


--
-- Name: COLUMN roles.scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.roles.scope IS '1:总部 2:区域 3:门店';


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: saas_integrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saas_integrations (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    store_id bigint,
    platform character varying(50) NOT NULL,
    app_id character varying(200),
    app_secret text,
    access_token text,
    token_expires_at timestamp(0) without time zone,
    webhook_url character varying(500),
    config json,
    status smallint DEFAULT '1'::smallint NOT NULL,
    last_sync_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN saas_integrations.platform; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.saas_integrations.platform IS 'wework, dingtalk, pos_system, erp...';


--
-- Name: COLUMN saas_integrations.app_secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.saas_integrations.app_secret IS '加密存储';


--
-- Name: COLUMN saas_integrations.access_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.saas_integrations.access_token IS '加密存储';


--
-- Name: COLUMN saas_integrations.config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.saas_integrations.config IS '平台特定配置参数';


--
-- Name: COLUMN saas_integrations.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.saas_integrations.status IS '0:禁用 1:正常 2:故障';


--
-- Name: saas_integrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saas_integrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saas_integrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saas_integrations_id_seq OWNED BY public.saas_integrations.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


--
-- Name: sso_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sso_users (
    id bigint NOT NULL,
    sso_user_id character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN sso_users.sso_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sso_users.sso_user_id IS 'Auth Center 用户 ID（JWT sub / login user.id）';


--
-- Name: sso_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sso_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sso_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sso_users_id_seq OWNED BY public.sso_users.id;


--
-- Name: stores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stores (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    region_id bigint,
    name character varying(100) NOT NULL,
    code character varying(50),
    address character varying(300),
    province character varying(50),
    city character varying(50),
    district character varying(50),
    latitude numeric(10,7),
    longitude numeric(10,7),
    manager_user_id bigint,
    business_hours character varying(100),
    status smallint DEFAULT '1'::smallint NOT NULL,
    settings json,
    opened_at date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN stores.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stores.status IS '0:关闭 1:正常 2:装修中';


--
-- Name: COLUMN stores.settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stores.settings IS '门店级配置，覆盖总部默认值';


--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stores_id_seq OWNED BY public.stores.id;


--
-- Name: user_store_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_store_roles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    store_id bigint,
    region_id bigint,
    role_id bigint NOT NULL,
    granted_by bigint,
    granted_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expired_at timestamp(0) without time zone
);


--
-- Name: user_store_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_store_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_store_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_store_roles_id_seq OWNED BY public.user_store_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_admin boolean DEFAULT false NOT NULL,
    username character varying(255),
    menu_template_id bigint
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: weather_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weather_logs (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    date date NOT NULL,
    city character varying(50) DEFAULT '香港'::character varying NOT NULL,
    weather character varying(50) NOT NULL,
    temperature_high smallint NOT NULL,
    temperature_low smallint NOT NULL,
    humidity smallint NOT NULL,
    rain_probability smallint NOT NULL,
    uv_index smallint NOT NULL,
    description character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN weather_logs.weather; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.weather_logs.weather IS '天气状况，如晴、多云、阵雨';


--
-- Name: COLUMN weather_logs.temperature_high; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.weather_logs.temperature_high IS '最高气温（摄氏度）';


--
-- Name: COLUMN weather_logs.temperature_low; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.weather_logs.temperature_low IS '最低气温（摄氏度）';


--
-- Name: COLUMN weather_logs.humidity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.weather_logs.humidity IS '湿度百分比';


--
-- Name: COLUMN weather_logs.rain_probability; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.weather_logs.rain_probability IS '降雨概率百分比';


--
-- Name: COLUMN weather_logs.uv_index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.weather_logs.uv_index IS '紫外线指数 1-11';


--
-- Name: COLUMN weather_logs.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.weather_logs.description IS '门店参考天气提示';


--
-- Name: weather_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weather_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weather_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weather_logs_id_seq OWNED BY public.weather_logs.id;


--
-- Name: wework_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wework_users (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    wework_userid character varying(100) NOT NULL,
    wework_openid character varying(100),
    department_ids json,
    bound_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: wework_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wework_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wework_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wework_users_id_seq OWNED BY public.wework_users.id;


--
-- Name: ai_command_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_command_templates ALTER COLUMN id SET DEFAULT nextval('public.ai_command_templates_id_seq'::regclass);


--
-- Name: ai_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_messages ALTER COLUMN id SET DEFAULT nextval('public.ai_messages_id_seq'::regclass);


--
-- Name: ai_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_sessions ALTER COLUMN id SET DEFAULT nextval('public.ai_sessions_id_seq'::regclass);


--
-- Name: app_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings ALTER COLUMN id SET DEFAULT nextval('public.app_settings_id_seq'::regclass);


--
-- Name: chat_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_logs ALTER COLUMN id SET DEFAULT nextval('public.chat_logs_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: industries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industries ALTER COLUMN id SET DEFAULT nextval('public.industries_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: knowledge_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_categories ALTER COLUMN id SET DEFAULT nextval('public.knowledge_categories_id_seq'::regclass);


--
-- Name: knowledge_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_items ALTER COLUMN id SET DEFAULT nextval('public.knowledge_items_id_seq'::regclass);


--
-- Name: menu_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_templates ALTER COLUMN id SET DEFAULT nextval('public.menu_templates_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: quick_action_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quick_action_items ALTER COLUMN id SET DEFAULT nextval('public.quick_action_items_id_seq'::regclass);


--
-- Name: quick_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quick_actions ALTER COLUMN id SET DEFAULT nextval('public.quick_actions_id_seq'::regclass);


--
-- Name: regions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions ALTER COLUMN id SET DEFAULT nextval('public.regions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: saas_integrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saas_integrations ALTER COLUMN id SET DEFAULT nextval('public.saas_integrations_id_seq'::regclass);


--
-- Name: sso_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_users ALTER COLUMN id SET DEFAULT nextval('public.sso_users_id_seq'::regclass);


--
-- Name: stores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores ALTER COLUMN id SET DEFAULT nextval('public.stores_id_seq'::regclass);


--
-- Name: user_store_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_store_roles ALTER COLUMN id SET DEFAULT nextval('public.user_store_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: weather_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weather_logs ALTER COLUMN id SET DEFAULT nextval('public.weather_logs_id_seq'::regclass);


--
-- Name: wework_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wework_users ALTER COLUMN id SET DEFAULT nextval('public.wework_users_id_seq'::regclass);


--
-- Name: ai_command_templates ai_command_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_command_templates
    ADD CONSTRAINT ai_command_templates_pkey PRIMARY KEY (id);


--
-- Name: ai_messages ai_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_messages
    ADD CONSTRAINT ai_messages_pkey PRIMARY KEY (id);


--
-- Name: ai_sessions ai_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_sessions
    ADD CONSTRAINT ai_sessions_pkey PRIMARY KEY (id);


--
-- Name: ai_sessions ai_sessions_session_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_sessions
    ADD CONSTRAINT ai_sessions_session_uuid_unique UNIQUE (session_uuid);


--
-- Name: app_settings app_settings_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_key_unique UNIQUE (key);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (id);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: chat_logs chat_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_logs
    ADD CONSTRAINT chat_logs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: industries industries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industries
    ADD CONSTRAINT industries_pkey PRIMARY KEY (id);


--
-- Name: industries industries_slug_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industries
    ADD CONSTRAINT industries_slug_unique UNIQUE (slug);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: knowledge_categories knowledge_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_categories
    ADD CONSTRAINT knowledge_categories_pkey PRIMARY KEY (id);


--
-- Name: knowledge_items knowledge_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_items
    ADD CONSTRAINT knowledge_items_pkey PRIMARY KEY (id);


--
-- Name: menu_templates menu_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_templates
    ADD CONSTRAINT menu_templates_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_code_unique UNIQUE (code);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: permissions permissions_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_code_unique UNIQUE (code);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: quick_action_items quick_action_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quick_action_items
    ADD CONSTRAINT quick_action_items_pkey PRIMARY KEY (id);


--
-- Name: quick_actions quick_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quick_actions
    ADD CONSTRAINT quick_actions_pkey PRIMARY KEY (id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_organization_id_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_organization_id_code_unique UNIQUE (organization_id, code);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: saas_integrations saas_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saas_integrations
    ADD CONSTRAINT saas_integrations_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_users sso_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_users
    ADD CONSTRAINT sso_users_pkey PRIMARY KEY (id);


--
-- Name: sso_users sso_users_sso_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_users
    ADD CONSTRAINT sso_users_sso_user_id_unique UNIQUE (sso_user_id);


--
-- Name: stores stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: user_store_roles user_store_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_store_roles
    ADD CONSTRAINT user_store_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: weather_logs weather_logs_date_city_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weather_logs
    ADD CONSTRAINT weather_logs_date_city_unique UNIQUE (date, city);


--
-- Name: weather_logs weather_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weather_logs
    ADD CONSTRAINT weather_logs_pkey PRIMARY KEY (id);


--
-- Name: wework_users wework_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wework_users
    ADD CONSTRAINT wework_users_pkey PRIMARY KEY (id);


--
-- Name: wework_users wework_users_wework_userid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wework_users
    ADD CONSTRAINT wework_users_wework_userid_unique UNIQUE (wework_userid);


--
-- Name: ai_command_templates_intent_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_command_templates_intent_is_active_index ON public.ai_command_templates USING btree (intent, is_active);


--
-- Name: ai_messages_intent_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_messages_intent_created_at_index ON public.ai_messages USING btree (intent, created_at);


--
-- Name: ai_messages_session_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_messages_session_id_index ON public.ai_messages USING btree (session_id);


--
-- Name: ai_sessions_started_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_sessions_started_at_index ON public.ai_sessions USING btree (started_at);


--
-- Name: ai_sessions_store_id_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_sessions_store_id_user_id_index ON public.ai_sessions USING btree (store_id, user_id);


--
-- Name: chat_logs_agent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chat_logs_agent_id_index ON public.chat_logs USING btree (agent_id);


--
-- Name: chat_logs_conversation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chat_logs_conversation_id_index ON public.chat_logs USING btree (conversation_id);


--
-- Name: chat_logs_occurred_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chat_logs_occurred_at_index ON public.chat_logs USING btree (occurred_at);


--
-- Name: industries_enabled_sort_order_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX industries_enabled_sort_order_index ON public.industries USING btree (enabled, sort_order);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: knowledge_items_embedding_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX knowledge_items_embedding_idx ON public.knowledge_items USING ivfflat (embedding public.vector_cosine_ops) WITH (lists='10');


--
-- Name: menu_templates_industry_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX menu_templates_industry_is_active_index ON public.menu_templates USING btree (industry, is_active);


--
-- Name: permissions_module_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_module_index ON public.permissions USING btree (module);


--
-- Name: personal_access_tokens_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_expires_at_index ON public.personal_access_tokens USING btree (expires_at);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: quick_action_items_quick_action_id_sort_order_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX quick_action_items_quick_action_id_sort_order_index ON public.quick_action_items USING btree (quick_action_id, sort_order);


--
-- Name: quick_actions_industry_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX quick_actions_industry_index ON public.quick_actions USING btree (industry);


--
-- Name: quick_actions_store_id_enabled_sort_order_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX quick_actions_store_id_enabled_sort_order_index ON public.quick_actions USING btree (store_id, enabled, sort_order);


--
-- Name: saas_integrations_organization_id_platform_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX saas_integrations_organization_id_platform_index ON public.saas_integrations USING btree (organization_id, platform);


--
-- Name: saas_integrations_store_id_platform_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX saas_integrations_store_id_platform_index ON public.saas_integrations USING btree (store_id, platform);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: stores_organization_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_organization_id_status_index ON public.stores USING btree (organization_id, status);


--
-- Name: stores_region_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stores_region_id_index ON public.stores USING btree (region_id);


--
-- Name: user_store_roles_store_id_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_store_roles_store_id_role_id_index ON public.user_store_roles USING btree (store_id, role_id);


--
-- Name: user_store_roles_user_id_store_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_store_roles_user_id_store_id_index ON public.user_store_roles USING btree (user_id, store_id);


--
-- Name: weather_logs_store_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX weather_logs_store_id_index ON public.weather_logs USING btree (store_id);


--
-- Name: wework_users_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wework_users_user_id_index ON public.wework_users USING btree (user_id);


--
-- Name: ai_command_templates ai_command_templates_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_command_templates
    ADD CONSTRAINT ai_command_templates_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: ai_messages ai_messages_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_messages
    ADD CONSTRAINT ai_messages_session_id_foreign FOREIGN KEY (session_id) REFERENCES public.ai_sessions(id) ON DELETE CASCADE;


--
-- Name: ai_sessions ai_sessions_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_sessions
    ADD CONSTRAINT ai_sessions_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE SET NULL;


--
-- Name: ai_sessions ai_sessions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_sessions
    ADD CONSTRAINT ai_sessions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: knowledge_categories knowledge_categories_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_categories
    ADD CONSTRAINT knowledge_categories_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.knowledge_categories(id) ON DELETE SET NULL;


--
-- Name: knowledge_items knowledge_items_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_items
    ADD CONSTRAINT knowledge_items_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.knowledge_categories(id) ON DELETE SET NULL;


--
-- Name: posts posts_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: quick_action_items quick_action_items_quick_action_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quick_action_items
    ADD CONSTRAINT quick_action_items_quick_action_id_foreign FOREIGN KEY (quick_action_id) REFERENCES public.quick_actions(id) ON DELETE CASCADE;


--
-- Name: quick_actions quick_actions_menu_template_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quick_actions
    ADD CONSTRAINT quick_actions_menu_template_id_foreign FOREIGN KEY (menu_template_id) REFERENCES public.menu_templates(id) ON DELETE SET NULL;


--
-- Name: regions regions_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_foreign FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: roles roles_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: saas_integrations saas_integrations_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saas_integrations
    ADD CONSTRAINT saas_integrations_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: saas_integrations saas_integrations_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saas_integrations
    ADD CONSTRAINT saas_integrations_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: sso_users sso_users_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_users
    ADD CONSTRAINT sso_users_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: stores stores_manager_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_manager_user_id_foreign FOREIGN KEY (manager_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: stores stores_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: stores stores_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.regions(id) ON DELETE SET NULL;


--
-- Name: user_store_roles user_store_roles_granted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_store_roles
    ADD CONSTRAINT user_store_roles_granted_by_foreign FOREIGN KEY (granted_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: user_store_roles user_store_roles_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_store_roles
    ADD CONSTRAINT user_store_roles_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.regions(id) ON DELETE SET NULL;


--
-- Name: user_store_roles user_store_roles_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_store_roles
    ADD CONSTRAINT user_store_roles_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_store_roles user_store_roles_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_store_roles
    ADD CONSTRAINT user_store_roles_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: user_store_roles user_store_roles_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_store_roles
    ADD CONSTRAINT user_store_roles_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_menu_template_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_menu_template_id_foreign FOREIGN KEY (menu_template_id) REFERENCES public.menu_templates(id) ON DELETE SET NULL;


--
-- Name: wework_users wework_users_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wework_users
    ADD CONSTRAINT wework_users_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict bDjK0B92YIsngveVmlLforJw3BLAoSadba6ldzeVBQGetg4PkbhR57CKAEvPDBI

--
-- PostgreSQL database dump
--

\restrict loUbktzMaLmXYNOqfsIsivPdPjeUc02huVLRTohbdgo2Gp1Zg1qz37jDLGqRLtM

-- Dumped from database version 18.4 (Ubuntu 18.4-0ubuntu0.26.04.1)
-- Dumped by pg_dump version 18.4 (Ubuntu 18.4-0ubuntu0.26.04.1)

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
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2025_11_29_220023_create_personal_access_tokens_table	1
5	2025_11_29_220222_create_posts_table	1
6	2026_03_16_000001_create_organizations_table	1
7	2026_03_16_000002_create_regions_table	1
8	2026_03_16_000003_create_stores_table	1
9	2026_03_16_000004_create_roles_permissions_tables	1
10	2026_03_16_000005_create_saas_integrations_tables	1
11	2026_03_16_000010_create_ai_assistant_tables	1
12	2026_03_22_070800_add_is_admin_to_users_table	1
13	2026_04_04_022128_add_username_to_users_table	1
14	2026_04_07_000001_create_chat_logs_table	1
15	2026_04_17_000309_create_weather_logs_table	1
16	2026_05_30_120000_create_quick_actions_tables	1
17	2026_05_30_130000_create_app_settings_table	1
18	2026_06_11_120000_create_industries_table	1
19	2026_06_11_120100_add_industry_to_quick_actions	1
20	2026_06_12_120000_create_menu_templates_table	1
21	2026_06_12_120100_add_menu_template_to_quick_actions	1
22	2026_06_12_130000_add_api_base_to_industries	1
23	2026_06_13_100000_add_api_token_to_industries	1
24	2026_06_13_110000_add_ai_path_to_industries	1
25	2026_06_13_120000_add_ai_media_to_industries	1
26	2026_06_14_130000_add_greeting_to_industries	1
27	2026_06_15_053246_create_sso_users_table	1
28	2026_07_28_100000_add_show_in_chat_to_quick_actions	2
29	2026_07_28_200000_make_ai_sessions_store_id_nullable	3
30	2026_07_28_210000_add_show_in_chat_to_quick_action_items	4
31	2026_08_01_124414_change_emoji_column_length_on_quick_action_items	5
32	2026_08_01_200000_create_knowledge_categories_table	6
33	2026_08_01_200001_create_knowledge_items_table	6
34	2026_08_01_200002_drop_title_from_knowledge_items	7
35	2026_08_01_200003_add_embedding_to_knowledge_items	8
36	2026_08_01_173703_add_menu_template_id_to_users_table	9
\.


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 36, true);


--
-- PostgreSQL database dump complete
--

\unrestrict loUbktzMaLmXYNOqfsIsivPdPjeUc02huVLRTohbdgo2Gp1Zg1qz37jDLGqRLtM


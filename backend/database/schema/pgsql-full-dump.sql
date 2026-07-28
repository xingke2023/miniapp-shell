--
-- PostgreSQL database dump
--

\restrict UeTpp3XWd6IaZg4tdBHngN4lmuZp4gl92IOvHE0xuoNVGgqb4stfdYiR3yaOfF3

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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
    store_id bigint NOT NULL,
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
-- Name: attendance_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendance_records (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    store_id bigint NOT NULL,
    work_date date NOT NULL,
    scheduled_start time(0) without time zone,
    scheduled_end time(0) without time zone,
    clock_in_at timestamp(0) without time zone,
    clock_out_at timestamp(0) without time zone,
    clock_in_source smallint,
    work_hours numeric(4,2),
    overtime_hours numeric(4,2) DEFAULT '0'::numeric NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    exception_reason character varying(200),
    approved_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN attendance_records.clock_in_source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.attendance_records.clock_in_source IS '1:APP 2:企业微信 3:人工补录';


--
-- Name: COLUMN attendance_records.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.attendance_records.status IS '1:正常 2:迟到 3:早退 4:缺勤 5:请假';


--
-- Name: attendance_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendance_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendance_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendance_records_id_seq OWNED BY public.attendance_records.id;


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
    CONSTRAINT chat_logs_direction_check CHECK (((direction)::text = ANY (ARRAY[('inbound'::character varying)::text, ('outbound'::character varying)::text])))
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
-- Name: competitor_hot_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competitor_hot_products (
    id bigint NOT NULL,
    competitor_id bigint NOT NULL,
    competitor_product_id bigint NOT NULL,
    identified_date date NOT NULL,
    heat_score numeric(5,2),
    evidence json,
    our_product_id bigint,
    recommendation smallint,
    reviewed_by bigint,
    reviewed_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: COLUMN competitor_hot_products.evidence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitor_hot_products.evidence IS '热度证据';


--
-- Name: COLUMN competitor_hot_products.recommendation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitor_hot_products.recommendation IS '1:引进建议 2:加量建议 3:已有无需操作';


--
-- Name: competitor_hot_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competitor_hot_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitor_hot_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competitor_hot_products_id_seq OWNED BY public.competitor_hot_products.id;


--
-- Name: competitor_price_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competitor_price_records (
    id bigint NOT NULL,
    competitor_product_id bigint NOT NULL,
    competitor_id bigint NOT NULL,
    product_id bigint,
    price numeric(12,2) NOT NULL,
    original_price numeric(12,2),
    is_promotion boolean DEFAULT false NOT NULL,
    collect_source smallint DEFAULT '1'::smallint NOT NULL,
    collect_channel character varying(100),
    image_url character varying(500),
    collected_by bigint,
    collected_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: COLUMN competitor_price_records.original_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitor_price_records.original_price IS '划线价';


--
-- Name: COLUMN competitor_price_records.collect_source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitor_price_records.collect_source IS '1:人工录入 2:APP扫码 3:爬虫 4:第三方API';


--
-- Name: COLUMN competitor_price_records.image_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitor_price_records.image_url IS '采集凭证图片';


--
-- Name: competitor_price_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competitor_price_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitor_price_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competitor_price_records_id_seq OWNED BY public.competitor_price_records.id;


--
-- Name: competitor_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competitor_products (
    id bigint NOT NULL,
    competitor_id bigint NOT NULL,
    product_id bigint,
    competitor_product_name character varying(200) NOT NULL,
    competitor_product_code character varying(100),
    spec character varying(200),
    match_confidence numeric(5,4),
    is_manually_confirmed boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN competitor_products.match_confidence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitor_products.match_confidence IS '与自家商品匹配置信度';


--
-- Name: competitor_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competitor_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitor_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competitor_products_id_seq OWNED BY public.competitor_products.id;


--
-- Name: competitors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competitors (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    name character varying(200) NOT NULL,
    brand character varying(100),
    address character varying(300),
    latitude numeric(10,7),
    longitude numeric(10,7),
    distance_to_store numeric(8,2),
    nearest_store_id bigint,
    channels json,
    status smallint DEFAULT '1'::smallint NOT NULL,
    notes text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN competitors.distance_to_store; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitors.distance_to_store IS '距最近自家门店（米）';


--
-- Name: COLUMN competitors.channels; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitors.channels IS '情报采集渠道';


--
-- Name: COLUMN competitors.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.competitors.status IS '0:停止监控 1:正常监控';


--
-- Name: competitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competitors_id_seq OWNED BY public.competitors.id;


--
-- Name: custom_report_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_report_templates (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    created_by bigint NOT NULL,
    name character varying(200) NOT NULL,
    description text,
    data_sources json,
    filters json,
    columns json,
    chart_types json,
    schedule_cron character varying(50),
    is_shared boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN custom_report_templates.data_sources; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.custom_report_templates.data_sources IS '数据源配置';


--
-- Name: COLUMN custom_report_templates.filters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.custom_report_templates.filters IS '筛选条件配置';


--
-- Name: COLUMN custom_report_templates.columns; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.custom_report_templates.columns IS '报表列定义';


--
-- Name: COLUMN custom_report_templates.schedule_cron; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.custom_report_templates.schedule_cron IS '定时生成表达式';


--
-- Name: custom_report_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_report_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_report_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_report_templates_id_seq OWNED BY public.custom_report_templates.id;


--
-- Name: customer_follow_ups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_follow_ups (
    id bigint NOT NULL,
    customer_id bigint NOT NULL,
    store_id bigint NOT NULL,
    type smallint DEFAULT '1'::smallint NOT NULL,
    content text NOT NULL,
    follow_up_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    next_follow_up_at date,
    operator_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN customer_follow_ups.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer_follow_ups.type IS '1:电话 2:微信 3:到店 4:短信 5:其他';


--
-- Name: customer_follow_ups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_follow_ups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_follow_ups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_follow_ups_id_seq OWNED BY public.customer_follow_ups.id;


--
-- Name: customer_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_order_items (
    id bigint NOT NULL,
    customer_order_id bigint NOT NULL,
    product_id bigint,
    product_name character varying(100) NOT NULL,
    qty numeric(10,3) NOT NULL,
    unit character varying(20),
    unit_price numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    subtotal numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: customer_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_order_items_id_seq OWNED BY public.customer_order_items.id;


--
-- Name: customer_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_orders (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    order_no character varying(32) NOT NULL,
    customer_id bigint,
    customer_name character varying(50),
    customer_phone character varying(20),
    type smallint DEFAULT '1'::smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    total_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    discount_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    paid_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    payment_method smallint,
    delivery_address character varying(255),
    delivery_at timestamp(0) without time zone,
    remark text,
    operator_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN customer_orders.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer_orders.type IS '1:预订 2:送货 3:团购 4:自提';


--
-- Name: COLUMN customer_orders.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer_orders.status IS '1:待确认 2:待付款 3:待发货 4:已完成 5:已取消';


--
-- Name: COLUMN customer_orders.payment_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customer_orders.payment_method IS '1:现金 2:微信 3:支付宝 4:银行卡';


--
-- Name: customer_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_orders_id_seq OWNED BY public.customer_orders.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    name character varying(50) NOT NULL,
    phone character varying(20),
    gender smallint DEFAULT '0'::smallint NOT NULL,
    birthday date,
    level smallint DEFAULT '1'::smallint NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    total_spent numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    order_count integer DEFAULT 0 NOT NULL,
    last_order_at timestamp(0) without time zone,
    tags json,
    address character varying(255),
    source smallint DEFAULT '1'::smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    notes text,
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN customers.gender; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customers.gender IS '0:未知 1:男 2:女';


--
-- Name: COLUMN customers.level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customers.level IS '会员等级 1:普通 2:银卡 3:金卡';


--
-- Name: COLUMN customers.total_spent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customers.total_spent IS '累计消费';


--
-- Name: COLUMN customers.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customers.tags IS '分群标签数组';


--
-- Name: COLUMN customers.source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customers.source IS '1:手动 2:AI 3:导入';


--
-- Name: COLUMN customers.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customers.status IS '0:流失 1:正常 2:黑名单';


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: daily_operation_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_operation_logs (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    date date NOT NULL,
    occurred_at timestamp(0) without time zone NOT NULL,
    source smallint NOT NULL,
    content text NOT NULL,
    intent character varying(32) DEFAULT 'note'::character varying NOT NULL,
    is_operational boolean DEFAULT false NOT NULL,
    product_id bigint,
    qty_change numeric(10,3),
    reference_type character varying(64),
    reference_id bigint,
    operator_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_failed boolean DEFAULT false NOT NULL,
    http_status_code smallint,
    error_message character varying(500)
);


--
-- Name: COLUMN daily_operation_logs.source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_operation_logs.source IS '1=AI助手 2=手动API 3=Filament后台';


--
-- Name: COLUMN daily_operation_logs.content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_operation_logs.content IS '操作描述或原始指令文本';


--
-- Name: COLUMN daily_operation_logs.intent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_operation_logs.intent IS 'stock_in|stock_out|sold_out|damage|adjust|supplement|note|other';


--
-- Name: COLUMN daily_operation_logs.is_operational; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_operation_logs.is_operational IS '是否影响库存/销售数据';


--
-- Name: COLUMN daily_operation_logs.qty_change; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_operation_logs.qty_change IS '库存变动量（正入负出）';


--
-- Name: daily_operation_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.daily_operation_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: daily_operation_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.daily_operation_logs_id_seq OWNED BY public.daily_operation_logs.id;


--
-- Name: damage_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.damage_records (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    product_id bigint NOT NULL,
    purchase_order_item_id bigint,
    supplier_id bigint,
    qty numeric(10,3) NOT NULL,
    unit_cost numeric(10,4),
    total_claimed numeric(10,2),
    reason character varying(100) NOT NULL,
    image_paths json,
    status smallint DEFAULT '1'::smallint NOT NULL,
    occurred_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    operator_id bigint,
    notes text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: damage_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.damage_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: damage_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.damage_records_id_seq OWNED BY public.damage_records.id;


--
-- Name: dashboard_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_configs (
    id bigint NOT NULL,
    user_id bigint,
    store_id bigint,
    name character varying(100) NOT NULL,
    scope smallint DEFAULT '3'::smallint NOT NULL,
    widgets json,
    filters json,
    refresh_interval integer DEFAULT 0 NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN dashboard_configs.scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dashboard_configs.scope IS '1:个人 2:门店 3:区域 4:总部';


--
-- Name: COLUMN dashboard_configs.widgets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dashboard_configs.widgets IS '组件配置数组';


--
-- Name: COLUMN dashboard_configs.filters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dashboard_configs.filters IS '默认筛选条件';


--
-- Name: COLUMN dashboard_configs.refresh_interval; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dashboard_configs.refresh_interval IS '自动刷新间隔（秒），0不刷新';


--
-- Name: dashboard_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dashboard_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dashboard_configs_id_seq OWNED BY public.dashboard_configs.id;


--
-- Name: employee_store_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_store_history (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    from_store_id bigint,
    to_store_id bigint NOT NULL,
    effective_date date NOT NULL,
    reason character varying(200),
    approved_by bigint,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: employee_store_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employee_store_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_store_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employee_store_history_id_seq OWNED BY public.employee_store_history.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    user_id bigint,
    current_store_id bigint,
    employee_no character varying(50),
    name character varying(100) NOT NULL,
    phone character varying(20),
    id_card_no character varying(100),
    gender smallint,
    birth_date date,
    education smallint,
    "position" character varying(100),
    position_level smallint DEFAULT '1'::smallint NOT NULL,
    hire_date date,
    contract_expire_date date,
    probation_end_date date,
    status smallint DEFAULT '1'::smallint NOT NULL,
    resign_date date,
    resign_reason text,
    base_salary numeric(10,2),
    emergency_contact character varying(100),
    emergency_phone character varying(20),
    skills json,
    notes text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN employees.id_card_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.employees.id_card_no IS '加密存储';


--
-- Name: COLUMN employees.gender; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.employees.gender IS '1:男 2:女';


--
-- Name: COLUMN employees.education; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.employees.education IS '1:初中及以下 2:高中/中专 3:大专 4:本科 5:研究生';


--
-- Name: COLUMN employees.position_level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.employees.position_level IS '1:店员 2:主管 3:店长 4:区域 5:总部';


--
-- Name: COLUMN employees.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.employees.status IS '1:试用期 2:正式 3:离职 4:暂停';


--
-- Name: COLUMN employees.skills; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.employees.skills IS '技能标签';


--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: expense_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.expense_categories (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    parent_id bigint,
    name character varying(100) NOT NULL,
    code character varying(50),
    is_cogs boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN expense_categories.is_cogs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.expense_categories.is_cogs IS '是否属于销售成本';


--
-- Name: expense_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.expense_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expense_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.expense_categories_id_seq OWNED BY public.expense_categories.id;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.expenses (
    id bigint NOT NULL,
    store_id bigint,
    category_id bigint NOT NULL,
    expense_no character varying(50) NOT NULL,
    amount numeric(12,2) NOT NULL,
    expense_date date NOT NULL,
    description text,
    input_method smallint DEFAULT '1'::smallint NOT NULL,
    ai_session_message_id bigint,
    attachment_urls json,
    vendor_name character varying(200),
    supplier_id bigint,
    payment_method smallint DEFAULT '1'::smallint NOT NULL,
    payment_status smallint DEFAULT '1'::smallint NOT NULL,
    created_by bigint,
    approved_by bigint,
    approved_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN expenses.input_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.expenses.input_method IS '1:手动录入 2:AI录入 3:系统自动';


--
-- Name: COLUMN expenses.attachment_urls; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.expenses.attachment_urls IS '凭证附件URL数组';


--
-- Name: COLUMN expenses.payment_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.expenses.payment_method IS '1:现金 2:转账 3:微信支付 4:支付宝 5:企业网银';


--
-- Name: COLUMN expenses.payment_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.expenses.payment_status IS '1:待支付 2:已支付 3:已报销';


--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.expenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.expenses_id_seq OWNED BY public.expenses.id;


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
-- Name: intelligence_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.intelligence_reports (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    store_id bigint,
    report_period_start date NOT NULL,
    report_period_end date NOT NULL,
    report_type smallint DEFAULT '1'::smallint NOT NULL,
    price_gap_summary json,
    hot_products_summary json,
    ai_insights text,
    action_recommendations json,
    generated_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_auto_generated boolean DEFAULT true NOT NULL
);


--
-- Name: COLUMN intelligence_reports.report_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.intelligence_reports.report_type IS '1:周报 2:月报 3:专项分析';


--
-- Name: intelligence_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.intelligence_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intelligence_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.intelligence_reports_id_seq OWNED BY public.intelligence_reports.id;


--
-- Name: inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    product_id bigint NOT NULL,
    current_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    available_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    locked_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    avg_cost numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    last_in_at timestamp(0) without time zone,
    last_out_at timestamp(0) without time zone,
    last_counted_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_sold_at timestamp(0) without time zone
);


--
-- Name: COLUMN inventory.current_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory.current_qty IS '当前库存量';


--
-- Name: COLUMN inventory.available_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory.available_qty IS '可用库存';


--
-- Name: COLUMN inventory.locked_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory.locked_qty IS '锁定量（已下单未入库）';


--
-- Name: COLUMN inventory.avg_cost; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory.avg_cost IS '移动加权平均成本';


--
-- Name: COLUMN inventory.last_sold_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory.last_sold_at IS '最后一次库存归零的时间，有补货后清空';


--
-- Name: inventory_daily_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_daily_snapshots (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    product_id bigint NOT NULL,
    date date NOT NULL,
    opening_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    received_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    sold_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    damage_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    adjustment_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    closing_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sold_out_at timestamp(0) without time zone
);


--
-- Name: COLUMN inventory_daily_snapshots.opening_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_daily_snapshots.opening_qty IS '往日库存（当天第一笔交易前）';


--
-- Name: COLUMN inventory_daily_snapshots.received_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_daily_snapshots.received_qty IS '今日进货合计';


--
-- Name: COLUMN inventory_daily_snapshots.sold_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_daily_snapshots.sold_qty IS '今日销售出库合计';


--
-- Name: COLUMN inventory_daily_snapshots.damage_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_daily_snapshots.damage_qty IS '今日损耗合计';


--
-- Name: COLUMN inventory_daily_snapshots.adjustment_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_daily_snapshots.adjustment_qty IS '今日盘点调整';


--
-- Name: COLUMN inventory_daily_snapshots.closing_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_daily_snapshots.closing_qty IS '今日结算库存（实时更新）';


--
-- Name: inventory_daily_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_daily_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_daily_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_daily_snapshots_id_seq OWNED BY public.inventory_daily_snapshots.id;


--
-- Name: inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_id_seq OWNED BY public.inventory.id;


--
-- Name: inventory_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_transactions (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    product_id bigint NOT NULL,
    transaction_type smallint NOT NULL,
    qty_change numeric(10,3) NOT NULL,
    qty_before numeric(10,3) NOT NULL,
    qty_after numeric(10,3) NOT NULL,
    unit_cost numeric(12,4),
    total_cost numeric(12,2),
    reference_type character varying(50),
    reference_id bigint,
    batch_no character varying(100),
    expiry_date date,
    operator_id bigint,
    notes character varying(500),
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: COLUMN inventory_transactions.transaction_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_transactions.transaction_type IS '1:采购入库 2:销售出库 3:损耗 4:盘点调整 5:促销出库 6:调拨入 7:调拨出 8:退货入库';


--
-- Name: COLUMN inventory_transactions.qty_change; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_transactions.qty_change IS '变动量（正入负出）';


--
-- Name: COLUMN inventory_transactions.reference_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_transactions.reference_type IS '关联单据类型';


--
-- Name: COLUMN inventory_transactions.reference_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_transactions.reference_id IS '关联单据ID';


--
-- Name: COLUMN inventory_transactions.expiry_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_transactions.expiry_date IS '批次到期日';


--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_transactions_id_seq OWNED BY public.inventory_transactions.id;


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
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leave_requests (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    store_id bigint NOT NULL,
    leave_type smallint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    total_days numeric(4,1) NOT NULL,
    reason text,
    status smallint DEFAULT '1'::smallint NOT NULL,
    approved_by bigint,
    approved_at timestamp(0) without time zone,
    reject_reason text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN leave_requests.leave_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.leave_requests.leave_type IS '1:事假 2:病假 3:年假 4:婚假 5:产假/陪产假 6:其他';


--
-- Name: COLUMN leave_requests.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.leave_requests.status IS '1:待审批 2:已批准 3:已拒绝 4:已撤销';


--
-- Name: leave_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leave_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leave_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leave_requests_id_seq OWNED BY public.leave_requests.id;


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
-- Name: product_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_categories (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    parent_id bigint,
    name character varying(100) NOT NULL,
    code character varying(50),
    sort_order integer DEFAULT 0 NOT NULL,
    icon_url character varying(500),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_categories_id_seq OWNED BY public.product_categories.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    category_id bigint,
    name character varying(200) NOT NULL,
    code character varying(100),
    barcode character varying(100),
    brand character varying(100),
    unit character varying(20) NOT NULL,
    spec character varying(200),
    image_urls json,
    description text,
    shelf_life_days integer,
    storage_condition smallint DEFAULT '1'::smallint NOT NULL,
    is_fresh boolean DEFAULT false NOT NULL,
    min_order_qty numeric(10,3) DEFAULT '1'::numeric NOT NULL,
    purchase_unit character varying(20),
    purchase_unit_qty numeric(10,3),
    status smallint DEFAULT '1'::smallint NOT NULL,
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    supplier_id bigint
);


--
-- Name: COLUMN products.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.code IS 'SKU编码';


--
-- Name: COLUMN products.unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.unit IS '基本单位：斤/个/箱';


--
-- Name: COLUMN products.spec; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.spec IS '规格描述：500g/袋';


--
-- Name: COLUMN products.shelf_life_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.shelf_life_days IS '保质期天数';


--
-- Name: COLUMN products.storage_condition; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.storage_condition IS '1:常温 2:冷藏 3:冷冻';


--
-- Name: COLUMN products.is_fresh; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.is_fresh IS '是否生鲜品';


--
-- Name: COLUMN products.min_order_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.min_order_qty IS '最小采购量';


--
-- Name: COLUMN products.purchase_unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.purchase_unit IS '采购单位：箱';


--
-- Name: COLUMN products.purchase_unit_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.purchase_unit_qty IS '采购单位含基本单位数量';


--
-- Name: COLUMN products.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.status IS '0:下架 1:正常 2:待审核';


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: promotion_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_items (
    id bigint NOT NULL,
    promotion_id bigint NOT NULL,
    product_id bigint NOT NULL,
    original_price numeric(12,2) NOT NULL,
    promotion_price numeric(12,2) NOT NULL,
    discount_rate numeric(5,4),
    ai_suggested_price numeric(12,2),
    cost_price numeric(12,2),
    stock_qty_at_start numeric(10,3),
    target_clear_qty numeric(10,3),
    actual_sold_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN promotion_items.cost_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_items.cost_price IS '成本价（防止亏本）';


--
-- Name: promotion_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promotion_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promotion_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promotion_items_id_seq OWNED BY public.promotion_items.id;


--
-- Name: promotion_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_reviews (
    id bigint NOT NULL,
    promotion_id bigint NOT NULL,
    store_id bigint NOT NULL,
    total_revenue numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    total_cost numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    gross_profit numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    gross_profit_rate numeric(6,4),
    clear_rate numeric(5,4),
    waste_amount_prevented numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    customer_traffic_change numeric(6,4),
    ai_effectiveness_score numeric(5,2),
    lessons_learned text,
    recommendations json,
    generated_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: COLUMN promotion_reviews.clear_rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_reviews.clear_rate IS '清货率';


--
-- Name: COLUMN promotion_reviews.customer_traffic_change; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_reviews.customer_traffic_change IS '客流变化率';


--
-- Name: promotion_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promotion_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promotion_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promotion_reviews_id_seq OWNED BY public.promotion_reviews.id;


--
-- Name: promotion_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_rules (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    name character varying(200) NOT NULL,
    trigger_type smallint NOT NULL,
    trigger_condition json,
    promotion_type smallint NOT NULL,
    pricing_strategy smallint DEFAULT '1'::smallint NOT NULL,
    max_discount_rate numeric(5,4),
    apply_to smallint DEFAULT '1'::smallint NOT NULL,
    apply_target_ids json,
    auto_execute boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN promotion_rules.trigger_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_rules.trigger_type IS '1:库存阈值 2:临期天数 3:滞销天数 4:手动触发 5:节假日';


--
-- Name: COLUMN promotion_rules.trigger_condition; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_rules.trigger_condition IS '触发条件参数';


--
-- Name: COLUMN promotion_rules.promotion_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_rules.promotion_type IS '1:折扣 2:满减 3:买赠 4:捆绑销售 5:限时特价';


--
-- Name: COLUMN promotion_rules.pricing_strategy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_rules.pricing_strategy IS '1:固定折扣 2:AI动态定价 3:清零定价';


--
-- Name: COLUMN promotion_rules.max_discount_rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_rules.max_discount_rate IS '最大折扣率下限';


--
-- Name: COLUMN promotion_rules.apply_to; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_rules.apply_to IS '1:全品类 2:指定分类 3:指定商品';


--
-- Name: COLUMN promotion_rules.auto_execute; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotion_rules.auto_execute IS '是否自动执行';


--
-- Name: promotion_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promotion_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promotion_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promotion_rules_id_seq OWNED BY public.promotion_rules.id;


--
-- Name: promotions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotions (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    rule_id bigint,
    name character varying(200) NOT NULL,
    trigger_source smallint DEFAULT '1'::smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    started_at timestamp(0) without time zone,
    ended_at timestamp(0) without time zone,
    ai_analysis json,
    total_sales_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    total_sales_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    total_saved_waste_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    created_by bigint,
    approved_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN promotions.trigger_source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotions.trigger_source IS '1:AI自动触发 2:店长手动 3:总部下发';


--
-- Name: COLUMN promotions.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotions.status IS '1:待审核 2:进行中 3:已暂停 4:已结束 5:已取消';


--
-- Name: COLUMN promotions.ai_analysis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.promotions.ai_analysis IS 'AI触发时的分析快照';


--
-- Name: promotions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promotions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promotions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promotions_id_seq OWNED BY public.promotions.id;


--
-- Name: purchase_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_order_items (
    id bigint NOT NULL,
    purchase_order_id bigint NOT NULL,
    product_id bigint NOT NULL,
    ordered_qty numeric(10,3) NOT NULL,
    received_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    unit_price numeric(12,4) NOT NULL,
    total_price numeric(12,2) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    supplier_id bigint
);


--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_order_items_id_seq OWNED BY public.purchase_order_items.id;


--
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_orders (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    supplier_id bigint,
    order_no character varying(50) NOT NULL,
    order_type smallint DEFAULT '1'::smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    expected_delivery_date date,
    actual_delivery_date date,
    total_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    notes text,
    created_by bigint,
    approved_by bigint,
    approved_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    image_paths json
);


--
-- Name: COLUMN purchase_orders.order_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.purchase_orders.order_type IS '1:AI建议单 2:手动创建 3:紧急补货';


--
-- Name: COLUMN purchase_orders.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.purchase_orders.status IS '1:草稿 2:待审核 3:已确认 4:配送中 5:已收货 6:已取消';


--
-- Name: COLUMN purchase_orders.image_paths; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.purchase_orders.image_paths IS '上传的进货单据图片 /storage URL 数组';


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_orders_id_seq OWNED BY public.purchase_orders.id;


--
-- Name: quick_action_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quick_action_items (
    id bigint NOT NULL,
    quick_action_id bigint NOT NULL,
    emoji character varying(16),
    label character varying(50) NOT NULL,
    "desc" character varying(100),
    item_type character varying(20) DEFAULT 'prompt'::character varying NOT NULL,
    route character varying(200),
    prompt text,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
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
    menu_template_id bigint
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
    parent_id bigint,
    name character varying(100) NOT NULL,
    code character varying(50),
    manager_user_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
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
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    store_id bigint,
    report_type character varying(50) NOT NULL,
    title character varying(200) NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    content text,
    data_snapshot json,
    ai_analysis text,
    charts_config json,
    status smallint DEFAULT '1'::smallint NOT NULL,
    is_auto_generated boolean DEFAULT true NOT NULL,
    generated_by bigint,
    generated_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN reports.report_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reports.report_type IS 'daily_review, weekly_review, monthly_review, custom';


--
-- Name: COLUMN reports.data_snapshot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reports.data_snapshot IS '核心指标数据快照';


--
-- Name: COLUMN reports.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reports.status IS '1:生成中 2:已完成 3:失败';


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reports_id_seq OWNED BY public.reports.id;


--
-- Name: resumes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resumes (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    name character varying(100),
    phone character varying(20),
    gender smallint DEFAULT '0'::smallint NOT NULL,
    age smallint,
    districts json,
    work_types json,
    positions json,
    experience_years numeric(3,1),
    salary_min integer,
    salary_max integer,
    salary_unit smallint DEFAULT '1'::smallint NOT NULL,
    education smallint,
    availability_date date,
    languages json,
    skills json,
    raw_text text,
    source smallint DEFAULT '1'::smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    notes text,
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN resumes.gender; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.gender IS '0:未知 1:男 2:女';


--
-- Name: COLUMN resumes.districts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.districts IS '意向工作区域，如["筲箕湾","柴湾"]';


--
-- Name: COLUMN resumes.work_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.work_types IS '工作类型，如["全职","小时工"]';


--
-- Name: COLUMN resumes.positions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.positions IS '意向岗位，如["收银员","理货员"]';


--
-- Name: COLUMN resumes.experience_years; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.experience_years IS '工作经验年数';


--
-- Name: COLUMN resumes.salary_min; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.salary_min IS '薪资下限';


--
-- Name: COLUMN resumes.salary_max; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.salary_max IS '薪资上限';


--
-- Name: COLUMN resumes.salary_unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.salary_unit IS '1:月 2:日 3:小时';


--
-- Name: COLUMN resumes.education; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.education IS '1:初中 2:高中 3:大专 4:本科';


--
-- Name: COLUMN resumes.availability_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.availability_date IS '最早到岗日期';


--
-- Name: COLUMN resumes.languages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.languages IS '语言能力，如["粤语","普通话"]';


--
-- Name: COLUMN resumes.skills; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.skills IS '技能标签，如["生鲜处理","收银"]';


--
-- Name: COLUMN resumes.raw_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.raw_text IS '原始输入文本';


--
-- Name: COLUMN resumes.source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.source IS '1:手动录入 2:AI解析 3:文件上传';


--
-- Name: COLUMN resumes.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.resumes.status IS '0:无效 1:求职中 2:已入职 3:暂不求职';


--
-- Name: resumes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resumes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resumes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resumes_id_seq OWNED BY public.resumes.id;


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
-- Name: salary_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.salary_records (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    store_id bigint NOT NULL,
    year integer NOT NULL,
    month smallint NOT NULL,
    work_days numeric(4,1) DEFAULT '0'::numeric NOT NULL,
    actual_work_days numeric(4,1) DEFAULT '0'::numeric NOT NULL,
    base_salary numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    overtime_pay numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    performance_bonus numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    sales_commission numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    deductions numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    social_insurance numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    income_tax numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    gross_salary numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    net_salary numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    payment_status smallint DEFAULT '1'::smallint NOT NULL,
    paid_at timestamp(0) without time zone,
    notes text,
    generated_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN salary_records.payment_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.salary_records.payment_status IS '1:待发放 2:已发放 3:暂停';


--
-- Name: salary_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.salary_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salary_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.salary_records_id_seq OWNED BY public.salary_records.id;


--
-- Name: sales_daily_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_daily_summaries (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    product_id bigint NOT NULL,
    sale_date date NOT NULL,
    sales_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    sales_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    transaction_count integer DEFAULT 0 NOT NULL,
    avg_selling_price numeric(10,4),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    pos_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    pos_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    supplement_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    supplement_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    ai_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    ai_amount numeric(12,2) DEFAULT '0'::numeric NOT NULL
);


--
-- Name: sales_daily_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_daily_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales_daily_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sales_daily_summaries_id_seq OWNED BY public.sales_daily_summaries.id;


--
-- Name: sales_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_order_items (
    id bigint NOT NULL,
    sales_order_id bigint NOT NULL,
    product_id bigint NOT NULL,
    qty numeric(10,3) NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    discount_amount numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    cost_price numeric(10,4),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN sales_order_items.qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_order_items.qty IS '数量';


--
-- Name: COLUMN sales_order_items.unit_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_order_items.unit_price IS '售价';


--
-- Name: COLUMN sales_order_items.discount_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_order_items.discount_amount IS '行级折扣';


--
-- Name: COLUMN sales_order_items.subtotal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_order_items.subtotal IS '小计';


--
-- Name: COLUMN sales_order_items.cost_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_order_items.cost_price IS '成本价（用于毛利计算）';


--
-- Name: sales_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sales_order_items_id_seq OWNED BY public.sales_order_items.id;


--
-- Name: sales_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_orders (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    order_no character varying(50) NOT NULL,
    cashier_id bigint,
    total_amount numeric(10,2) NOT NULL,
    discount_amount numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    paid_amount numeric(10,2) NOT NULL,
    payment_method smallint DEFAULT '1'::smallint NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    sold_at timestamp(0) without time zone NOT NULL,
    notes text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN sales_orders.order_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_orders.order_no IS '流水号';


--
-- Name: COLUMN sales_orders.cashier_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_orders.cashier_id IS '收银员';


--
-- Name: COLUMN sales_orders.total_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_orders.total_amount IS '应收金额';


--
-- Name: COLUMN sales_orders.discount_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_orders.discount_amount IS '整单折扣';


--
-- Name: COLUMN sales_orders.paid_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_orders.paid_amount IS '实收金额';


--
-- Name: COLUMN sales_orders.payment_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_orders.payment_method IS '1:现金 2:微信 3:支付宝 4:银行卡 5:混合';


--
-- Name: COLUMN sales_orders.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_orders.status IS '1:已完成 2:已退款 3:部分退款';


--
-- Name: COLUMN sales_orders.sold_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_orders.sold_at IS '交易时间';


--
-- Name: sales_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sales_orders_id_seq OWNED BY public.sales_orders.id;


--
-- Name: sales_uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_uploads (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    uploaded_by bigint NOT NULL,
    original_filename character varying(255) NOT NULL,
    file_path character varying(500) NOT NULL,
    sale_date date NOT NULL,
    status smallint DEFAULT '0'::smallint NOT NULL,
    total_items integer DEFAULT 0 NOT NULL,
    processed_items integer DEFAULT 0 NOT NULL,
    failed_items integer DEFAULT 0 NOT NULL,
    error_message text,
    raw_rows json,
    ai_result json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN sales_uploads.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_uploads.status IS '0=pending 1=processing 2=completed 3=failed';


--
-- Name: COLUMN sales_uploads.raw_rows; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_uploads.raw_rows IS 'Excel解析出的原始行数据';


--
-- Name: COLUMN sales_uploads.ai_result; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sales_uploads.ai_result IS 'AI分析映射结果';


--
-- Name: sales_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sales_uploads_id_seq OWNED BY public.sales_uploads.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    schedule_date date NOT NULL,
    shift_start time(0) without time zone NOT NULL,
    shift_end time(0) without time zone NOT NULL,
    shift_type smallint DEFAULT '1'::smallint NOT NULL,
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: COLUMN schedules.shift_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.schedules.shift_type IS '1:早班 2:中班 3:晚班 4:全天';


--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schedules_id_seq OWNED BY public.schedules.id;


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
-- Name: supplier_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_products (
    id bigint NOT NULL,
    supplier_id bigint NOT NULL,
    product_id bigint NOT NULL,
    supplier_product_code character varying(100),
    purchase_price numeric(12,2) NOT NULL,
    min_order_qty numeric(10,3) DEFAULT '1'::numeric NOT NULL,
    delivery_lead_days integer,
    is_primary boolean DEFAULT false NOT NULL,
    price_effective_date date,
    price_expired_date date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN supplier_products.supplier_product_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.supplier_products.supplier_product_code IS '供应商侧商品编码';


--
-- Name: COLUMN supplier_products.purchase_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.supplier_products.purchase_price IS '当前采购单价';


--
-- Name: COLUMN supplier_products.is_primary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.supplier_products.is_primary IS '是否为该商品首选供应商';


--
-- Name: supplier_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supplier_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supplier_products_id_seq OWNED BY public.supplier_products.id;


--
-- Name: supplier_refund_claim_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_refund_claim_items (
    id bigint NOT NULL,
    claim_id bigint NOT NULL,
    damage_record_id bigint NOT NULL,
    product_id bigint NOT NULL,
    product_name character varying(100) NOT NULL,
    qty numeric(10,3) NOT NULL,
    unit_cost numeric(10,4),
    claimed_amount numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    purchase_order_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: supplier_refund_claim_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supplier_refund_claim_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_refund_claim_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supplier_refund_claim_items_id_seq OWNED BY public.supplier_refund_claim_items.id;


--
-- Name: supplier_refund_claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier_refund_claims (
    id bigint NOT NULL,
    store_id bigint NOT NULL,
    supplier_id bigint NOT NULL,
    claim_no character varying(30) NOT NULL,
    status smallint DEFAULT '1'::smallint NOT NULL,
    total_items integer DEFAULT 0 NOT NULL,
    total_qty numeric(10,3) DEFAULT '0'::numeric NOT NULL,
    total_amount numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    submitted_at timestamp(0) without time zone,
    resolved_at timestamp(0) without time zone,
    notes text,
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: supplier_refund_claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supplier_refund_claims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_refund_claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supplier_refund_claims_id_seq OWNED BY public.supplier_refund_claims.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    name character varying(200) NOT NULL,
    code character varying(50),
    contact_name character varying(100),
    contact_phone character varying(20),
    contact_wechat character varying(100),
    address character varying(300),
    business_license character varying(200),
    payment_terms smallint DEFAULT '1'::smallint NOT NULL,
    payment_days integer DEFAULT 0 NOT NULL,
    delivery_lead_days integer DEFAULT 1 NOT NULL,
    rating smallint,
    status smallint DEFAULT '1'::smallint NOT NULL,
    notes text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


--
-- Name: COLUMN suppliers.payment_terms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.suppliers.payment_terms IS '1:现款 2:月结 3:季结';


--
-- Name: COLUMN suppliers.payment_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.suppliers.payment_days IS '账期天数';


--
-- Name: COLUMN suppliers.delivery_lead_days; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.suppliers.delivery_lead_days IS '平均交货周期（天）';


--
-- Name: COLUMN suppliers.rating; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.suppliers.rating IS '1-5星评级';


--
-- Name: COLUMN suppliers.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.suppliers.status IS '0:停用 1:正常';


--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suppliers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


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
    username character varying(255)
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
-- Name: attendance_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records ALTER COLUMN id SET DEFAULT nextval('public.attendance_records_id_seq'::regclass);


--
-- Name: chat_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_logs ALTER COLUMN id SET DEFAULT nextval('public.chat_logs_id_seq'::regclass);


--
-- Name: competitor_hot_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_hot_products ALTER COLUMN id SET DEFAULT nextval('public.competitor_hot_products_id_seq'::regclass);


--
-- Name: competitor_price_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_price_records ALTER COLUMN id SET DEFAULT nextval('public.competitor_price_records_id_seq'::regclass);


--
-- Name: competitor_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_products ALTER COLUMN id SET DEFAULT nextval('public.competitor_products_id_seq'::regclass);


--
-- Name: competitors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitors ALTER COLUMN id SET DEFAULT nextval('public.competitors_id_seq'::regclass);


--
-- Name: custom_report_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_report_templates ALTER COLUMN id SET DEFAULT nextval('public.custom_report_templates_id_seq'::regclass);


--
-- Name: customer_follow_ups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_follow_ups ALTER COLUMN id SET DEFAULT nextval('public.customer_follow_ups_id_seq'::regclass);


--
-- Name: customer_order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_items ALTER COLUMN id SET DEFAULT nextval('public.customer_order_items_id_seq'::regclass);


--
-- Name: customer_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders ALTER COLUMN id SET DEFAULT nextval('public.customer_orders_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: daily_operation_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_operation_logs ALTER COLUMN id SET DEFAULT nextval('public.daily_operation_logs_id_seq'::regclass);


--
-- Name: damage_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_records ALTER COLUMN id SET DEFAULT nextval('public.damage_records_id_seq'::regclass);


--
-- Name: dashboard_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_configs ALTER COLUMN id SET DEFAULT nextval('public.dashboard_configs_id_seq'::regclass);


--
-- Name: employee_store_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_store_history ALTER COLUMN id SET DEFAULT nextval('public.employee_store_history_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: expense_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expense_categories ALTER COLUMN id SET DEFAULT nextval('public.expense_categories_id_seq'::regclass);


--
-- Name: expenses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: industries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industries ALTER COLUMN id SET DEFAULT nextval('public.industries_id_seq'::regclass);


--
-- Name: intelligence_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intelligence_reports ALTER COLUMN id SET DEFAULT nextval('public.intelligence_reports_id_seq'::regclass);


--
-- Name: inventory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory ALTER COLUMN id SET DEFAULT nextval('public.inventory_id_seq'::regclass);


--
-- Name: inventory_daily_snapshots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_daily_snapshots ALTER COLUMN id SET DEFAULT nextval('public.inventory_daily_snapshots_id_seq'::regclass);


--
-- Name: inventory_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions ALTER COLUMN id SET DEFAULT nextval('public.inventory_transactions_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: leave_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests ALTER COLUMN id SET DEFAULT nextval('public.leave_requests_id_seq'::regclass);


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
-- Name: product_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories ALTER COLUMN id SET DEFAULT nextval('public.product_categories_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: promotion_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_items ALTER COLUMN id SET DEFAULT nextval('public.promotion_items_id_seq'::regclass);


--
-- Name: promotion_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_reviews ALTER COLUMN id SET DEFAULT nextval('public.promotion_reviews_id_seq'::regclass);


--
-- Name: promotion_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rules ALTER COLUMN id SET DEFAULT nextval('public.promotion_rules_id_seq'::regclass);


--
-- Name: promotions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions ALTER COLUMN id SET DEFAULT nextval('public.promotions_id_seq'::regclass);


--
-- Name: purchase_order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items ALTER COLUMN id SET DEFAULT nextval('public.purchase_order_items_id_seq'::regclass);


--
-- Name: purchase_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders ALTER COLUMN id SET DEFAULT nextval('public.purchase_orders_id_seq'::regclass);


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
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports ALTER COLUMN id SET DEFAULT nextval('public.reports_id_seq'::regclass);


--
-- Name: resumes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resumes ALTER COLUMN id SET DEFAULT nextval('public.resumes_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: saas_integrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saas_integrations ALTER COLUMN id SET DEFAULT nextval('public.saas_integrations_id_seq'::regclass);


--
-- Name: salary_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_records ALTER COLUMN id SET DEFAULT nextval('public.salary_records_id_seq'::regclass);


--
-- Name: sales_daily_summaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_daily_summaries ALTER COLUMN id SET DEFAULT nextval('public.sales_daily_summaries_id_seq'::regclass);


--
-- Name: sales_order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items ALTER COLUMN id SET DEFAULT nextval('public.sales_order_items_id_seq'::regclass);


--
-- Name: sales_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders ALTER COLUMN id SET DEFAULT nextval('public.sales_orders_id_seq'::regclass);


--
-- Name: sales_uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_uploads ALTER COLUMN id SET DEFAULT nextval('public.sales_uploads_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedules_id_seq'::regclass);


--
-- Name: sso_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_users ALTER COLUMN id SET DEFAULT nextval('public.sso_users_id_seq'::regclass);


--
-- Name: stores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores ALTER COLUMN id SET DEFAULT nextval('public.stores_id_seq'::regclass);


--
-- Name: supplier_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_products ALTER COLUMN id SET DEFAULT nextval('public.supplier_products_id_seq'::regclass);


--
-- Name: supplier_refund_claim_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claim_items ALTER COLUMN id SET DEFAULT nextval('public.supplier_refund_claim_items_id_seq'::regclass);


--
-- Name: supplier_refund_claims id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claims ALTER COLUMN id SET DEFAULT nextval('public.supplier_refund_claims_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


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
-- Data for Name: ai_messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_messages (id, session_id, role, input_type, raw_content, voice_url, image_urls, transcribed_text, ocr_text, ai_response, intent, entities, confidence, dispatched_module, dispatched_action_id, processing_time_ms, created_at) FROM stdin;
1	4	1	1	你好，查一下库存	\N	\N	\N	\N	\N	inventory_query	[]	\N	\N	\N	\N	2026-07-27 06:21:46
2	4	2	1	\N	\N	\N	\N	\N	正在为您查询…	\N	\N	\N	inventory	\N	1934	2026-07-27 06:21:46
3	5	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-27 06:22:06
4	5	2	1	\N	\N	\N	\N	\N	您好！请问有什么可以帮您？	\N	\N	\N	inventory	\N	2080	2026-07-27 06:22:06
5	5	1	1	可以做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-27 06:22:15
6	5	2	1	\N	\N	\N	\N	\N	您可以告诉我进货到货、报售出量、报剩余量、盘点、损耗、查询库存/销售/日志/天气/建议等，也可管理客户信息（添加/跟进/查询）。	\N	\N	\N	inventory	\N	2624	2026-07-27 06:22:15
7	6	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-27 06:22:52
8	6	2	1	\N	\N	\N	\N	\N	您好！欢迎使用舌尖香港AI助手，请告知您的需求。	\N	\N	\N	inventory	\N	1662	2026-07-27 06:22:52
9	7	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-27 06:31:47
10	7	2	1	\N	\N	\N	\N	\N	您好，我是舌尖香港AI助手，请问有什么可以帮您的？	\N	\N	\N	inventory	\N	1722	2026-07-27 06:31:47
11	8	1	1	你能帮我做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-27 06:46:25
12	8	2	1	\N	\N	\N	\N	\N	我是舌尖香港AI助手，可以帮您管理进货、销售、库存、损耗记录，查询库存、销售、天气、建议等，还能处理顾客CRM。请问您需要什么帮助？	\N	\N	\N	inventory	\N	1967	2026-07-27 06:46:25
13	9	1	1	你能帮我做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-27 07:30:44
14	9	2	1	\N	\N	\N	\N	\N	我是生鲜门店AI助手，可以帮您记录进货、销售、损耗，查询库存、销售、天气、建议，以及管理客户信息。请问有什么需要帮您的？	\N	\N	\N	inventory	\N	2256	2026-07-27 07:30:44
15	10	1	1	请帮我优化商品的搜索关键词（标题词/属性词/长尾词）。请提供商品名称与类目，我将给出关键词建议。	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-27 07:31:02
16	10	2	1	\N	\N	\N	\N	\N	很抱歉，我目前只能处理生鲜门店的进销存、客户管理和查询类任务，无法进行关键词优化建议。您可以让我查询库存或记录进货等。	\N	\N	\N	inventory	\N	3716	2026-07-27 07:31:02
17	11	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 05:43:07
18	11	2	1	\N	\N	\N	\N	\N	您好！我是舌尖香港AI助手，有什么可以帮您的？	\N	\N	\N	inventory	\N	1932	2026-07-28 05:43:07
19	12	1	1	你能帮我做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 07:26:24
20	12	2	1	\N	\N	\N	\N	\N	我是您的生鲜门店AI助手，可以帮您记录进货、销售、损耗、盘点，查询库存、销售数据、天气等，还能管理客户信息。请问有什么可以帮您？	\N	\N	\N	inventory	\N	2011	2026-07-28 07:26:24
21	13	1	1	请帮我写一篇小红书种草笔记（标题+正文+话题标签）。请提供商品与使用场景：	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 07:36:08
22	13	2	1	\N	\N	\N	\N	\N	抱歉，我无法处理这个请求。我是生鲜门店AI助手，专注于进货、销售、库存、客户管理等生鲜业务。您可以告诉我具体需要查询或记录什么信息。	\N	\N	\N	inventory	\N	3633	2026-07-28 07:36:08
23	14	1	1	请帮我分析以下品牌名称/商标/专利词是否可能存在侵权风险，并给出规避建议（仅供参考，不构成法律意见）。请输入要检测的内容：	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 07:38:42
24	14	2	1	\N	\N	\N	\N	\N	抱歉，我是生鲜门店AI助手，无法分析品牌侵权风险。请转至专业商标检测平台或咨询法律顾问。	\N	\N	\N	inventory	\N	1883	2026-07-28 07:38:42
25	15	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 07:39:05
26	15	2	1	\N	\N	\N	\N	\N	你好！有什么可以帮您的吗？	\N	\N	\N	inventory	\N	1712	2026-07-28 07:39:05
27	15	1	1	你在哪里	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 07:39:13
28	15	2	1	\N	\N	\N	\N	\N	我在您的手机里，随时为您服务！	\N	\N	\N	inventory	\N	1883	2026-07-28 07:39:13
29	15	1	1	请帮我做行业竞品分析。请提供：目标公司与主要竞争对手，我将从市场份额、产品、财务、护城河等维度对比。	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 07:39:29
30	15	2	1	\N	\N	\N	\N	\N	抱歉，我是生鲜门店AI助手，无法进行行业竞品分析。您可以咨询库存、销售、进货等门店相关事务。	\N	\N	\N	inventory	\N	2397	2026-07-28 07:39:29
31	16	1	1	12	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 07:44:46
32	16	2	1	\N	\N	\N	\N	\N	您好，您输入的“12”我没有理解，请告诉我具体需要什么帮助？	\N	\N	\N	inventory	\N	1877	2026-07-28 07:44:46
33	17	1	1	请帮我为客户设计保险方案。请提供客户基本信息（年龄/家庭/收入/已有保障），我将按需求优先级推荐险种组合和配置建议。	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 07:45:09
34	17	2	1	\N	\N	\N	\N	\N	抱歉，我是生鲜门店AI助手，专注于库存、销售、进货等门店管理。您咨询的保险方案设计超出了我的能力范围，请咨询专业保险顾问。	\N	\N	\N	inventory	\N	2886	2026-07-28 07:45:09
35	18	1	1	你能帮我做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 08:25:22
36	18	2	1	\N	\N	\N	\N	\N	我是舌尖香港AI助手，可以帮您管理进货、报售、盘点、查库存、查销售、记损耗、管客户等。您可以直接告诉我需求，比如“收到50斤番茄”或“查今天库存”。	\N	\N	\N	inventory	\N	2278	2026-07-28 08:25:22
37	18	1	1	你能帮我做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 08:25:35
38	18	2	1	\N	\N	\N	\N	\N	我是你的生鲜门店AI助手，可以帮你：记录进货、销售、损耗、库存盘点；查询库存、销售、天气、建议等信息；管理顾客档案和跟进。你可以对我说‘进了50斤白菜’、‘查库存’、‘今天天气’、‘添加会员张三’等。	\N	\N	\N	inventory	\N	2413	2026-07-28 08:25:35
39	18	1	1	你能帮我做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 08:25:43
40	18	2	1	\N	\N	\N	\N	\N	我是生鲜门店AI助手，可以帮您管理进货、销售、库存、损耗，查询库存、销售、每日概览、天气、建议等，还可以管理客户信息。请直接告诉我您的需求！	\N	\N	\N	inventory	\N	2124	2026-07-28 08:25:43
41	18	1	1	你能帮我做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 08:25:48
42	18	2	1	\N	\N	\N	\N	\N	我是舌尖香港AI助手，可以帮您记录进货、销售、损耗，查询库存、每日概览、操作记录，管理客户信息等。请问您需要什么帮助？	\N	\N	\N	inventory	\N	2050	2026-07-28 08:25:48
43	18	1	1	你能帮我做什么	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 08:25:51
44	18	2	1	\N	\N	\N	\N	\N	我是生鲜门店AI助手，可以帮您记录进货、销售、损耗、库存，查询库存、销售、进货记录、每日总览、天气、顾客信息等，还支持识别图片单据。请问有什么需要帮助？	\N	\N	\N	inventory	\N	2012	2026-07-28 08:25:51
45	19	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 14:16:15
46	19	2	1	\N	\N	\N	\N	\N	您好！有什么可以帮您的？我可以帮您记录进货、销售、损耗，查询库存、销售情况，管理客户信息等。	\N	\N	\N	inventory	\N	2325	2026-07-28 14:16:15
47	20	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 14:54:41
48	20	2	1	\N	\N	\N	\N	\N	您好！有什么可以帮您的吗？	\N	\N	\N	inventory	\N	1618	2026-07-28 14:54:41
49	20	1	1	你是deepseek	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 14:54:49
50	20	2	1	\N	\N	\N	\N	\N	您好，我是舌尖香港AI助手，请问有什么可以帮您？	\N	\N	\N	inventory	\N	1889	2026-07-28 14:54:49
51	20	1	1	今天销量如何	\N	\N	\N	\N	\N	sales_today_query	[]	\N	\N	\N	\N	2026-07-28 14:55:00
52	20	2	1	\N	\N	\N	\N	\N	正在为您查询今日销售数据，请稍候…	\N	\N	\N	inventory	\N	1328	2026-07-28 14:55:00
53	21	1	1	nh	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 15:47:30
54	21	2	1	\N	\N	\N	\N	\N	您好，请告诉我需要什么帮助？	\N	\N	\N	inventory	\N	1754	2026-07-28 15:47:30
55	22	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 15:59:03
56	22	2	1	\N	\N	\N	\N	\N	您好！我是舌尖香港AI助手，请问有什么可以帮您？	\N	\N	\N	inventory	\N	2149	2026-07-28 15:59:03
57	23	1	1	你好】	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 16:06:21
58	23	2	1	\N	\N	\N	\N	\N	您好！我是生鲜门店小助手，有什么可以帮您？	\N	\N	\N	inventory	\N	1444	2026-07-28 16:06:21
59	24	1	1	hi	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 16:26:53
60	24	2	1	\N	\N	\N	\N	\N	您好！我是您的生鲜门店AI助手，可以帮您处理进货、销售、库存查询等事宜，请告诉我需要什么帮助？	\N	\N	\N	inventory	\N	1822	2026-07-28 16:26:53
61	25	1	1	hi	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 16:43:06
62	25	2	1	\N	\N	\N	\N	\N	您好！请问有什么可以帮您？	\N	\N	\N	inventory	\N	1870	2026-07-28 16:43:06
63	26	1	1	hi	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 17:01:58
64	26	2	1	\N	\N	\N	\N	\N	您好！我是舌尖香港AI助手。请问有什么可以帮您的？比如查询库存、添加进货、记录销售或查询客户信息。	\N	\N	\N	inventory	\N	1857	2026-07-28 17:01:58
65	27	1	1	你好	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 17:04:03
66	27	2	1	\N	\N	\N	\N	\N	您好！请问有什么可以帮助您的？	\N	\N	\N	inventory	\N	1335	2026-07-28 17:04:03
67	28	1	1	hi	\N	\N	\N	\N	\N	other	[]	\N	\N	\N	\N	2026-07-28 17:15:53
68	28	2	1	\N	\N	\N	\N	\N	您好，我是生鲜门店AI助手，请问有什么可以帮您？	\N	\N	\N	inventory	\N	1367	2026-07-28 17:15:53
\.


--
-- Data for Name: ai_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_sessions (id, store_id, user_id, session_uuid, channel, status, started_at, ended_at, context, created_at, updated_at) FROM stdin;
1	1	9	c15922cf-ab7b-40fd-af03-c0fa49ab4899	2	1	2026-07-27 06:17:42	\N	\N	2026-07-27 06:17:42	2026-07-27 06:17:42
2	1	9	d9491e2b-8d09-4fd4-97f6-90aad39f2f73	2	1	2026-07-27 06:17:57	\N	\N	2026-07-27 06:17:57	2026-07-27 06:17:57
3	1	8	8bffbc40-fec8-4b62-8898-a80b16769011	2	1	2026-07-27 06:18:54	\N	\N	2026-07-27 06:18:54	2026-07-27 06:18:54
4	1	8	18a528ea-3b38-4ab7-93b6-519a9e949845	2	1	2026-07-27 06:21:44	\N	\N	2026-07-27 06:21:44	2026-07-27 06:21:44
5	1	9	92cfd582-c9ae-4498-b1fd-d9172f0d4e6f	2	1	2026-07-27 06:22:04	\N	\N	2026-07-27 06:22:04	2026-07-27 06:22:04
6	1	9	09800d85-2742-489b-a244-b36a5e1e94a2	2	1	2026-07-27 06:22:50	\N	\N	2026-07-27 06:22:50	2026-07-27 06:22:50
7	1	9	0e65ddc8-3a34-4ed6-b73d-3b1727cc251f	2	1	2026-07-27 06:31:45	\N	\N	2026-07-27 06:31:45	2026-07-27 06:31:45
8	1	9	d40e1c23-91ed-4aee-a416-78c3fc4659d1	2	1	2026-07-27 06:46:23	\N	\N	2026-07-27 06:46:23	2026-07-27 06:46:23
9	1	11	f207a19e-ea55-4c0b-b99b-88e6e9e6e237	2	1	2026-07-27 07:30:42	\N	\N	2026-07-27 07:30:42	2026-07-27 07:30:42
10	1	11	9e215357-9f7f-4413-867d-b4b3f16f3630	2	1	2026-07-27 07:30:58	\N	\N	2026-07-27 07:30:58	2026-07-27 07:30:58
11	1	11	43c40195-619b-4914-9ab5-d721da2d1e33	2	1	2026-07-28 05:43:05	\N	\N	2026-07-28 05:43:05	2026-07-28 05:43:05
12	1	11	36b228a9-7433-4e70-94b7-c5facb6ca3b1	2	1	2026-07-28 07:26:22	\N	\N	2026-07-28 07:26:22	2026-07-28 07:26:22
13	1	11	e9ab952a-c080-475c-a8e4-9179cbd38ceb	2	1	2026-07-28 07:36:04	\N	\N	2026-07-28 07:36:04	2026-07-28 07:36:04
14	1	11	cc562aa4-8a46-4ce5-b0f3-96e1bcdbdf36	2	1	2026-07-28 07:38:40	\N	\N	2026-07-28 07:38:40	2026-07-28 07:38:40
15	1	11	f829055e-dc8f-4e98-81e6-e56f3b5bd6ec	2	1	2026-07-28 07:39:03	\N	\N	2026-07-28 07:39:03	2026-07-28 07:39:03
16	1	11	96d1d449-cb63-42bf-aa5c-34a064c2ca17	2	1	2026-07-28 07:44:44	\N	\N	2026-07-28 07:44:44	2026-07-28 07:44:44
17	1	11	39deb9fe-5087-47e7-8f4c-f59aa175ab95	2	1	2026-07-28 07:45:06	\N	\N	2026-07-28 07:45:06	2026-07-28 07:45:06
18	1	11	d91189cf-27d2-471c-8e52-d336cf7ace2a	2	1	2026-07-28 08:25:20	\N	\N	2026-07-28 08:25:20	2026-07-28 08:25:20
19	1	11	cd7e6acb-3bde-4df9-a541-0fe234e26196	2	1	2026-07-28 14:16:13	\N	\N	2026-07-28 14:16:13	2026-07-28 14:16:13
20	1	11	b26a9183-c607-49cc-b23a-53e9fa0df935	2	1	2026-07-28 14:54:39	\N	\N	2026-07-28 14:54:39	2026-07-28 14:54:39
21	1	11	2a3949f2-1b4a-4b49-8285-125a215ae7a5	2	1	2026-07-28 15:47:28	\N	\N	2026-07-28 15:47:28	2026-07-28 15:47:28
22	1	11	368c7b41-6b26-4c76-ba1a-d00d0a55edd0	2	1	2026-07-28 15:59:00	\N	\N	2026-07-28 15:59:00	2026-07-28 15:59:00
23	1	11	05d6ad4f-3a90-4b5d-afad-f7d1b8e80a01	2	1	2026-07-28 16:06:19	\N	\N	2026-07-28 16:06:19	2026-07-28 16:06:19
24	1	11	066a3a6b-9a56-401a-a3c7-183140bb3cf0	2	1	2026-07-28 16:26:51	\N	\N	2026-07-28 16:26:51	2026-07-28 16:26:51
25	1	11	dee6be20-dcf6-48cf-ac57-7034607027b9	2	1	2026-07-28 16:43:04	\N	\N	2026-07-28 16:43:04	2026-07-28 16:43:04
26	1	11	dbc57252-dfc7-4dec-8b33-2ebd3003e230	2	1	2026-07-28 17:01:56	\N	\N	2026-07-28 17:01:56	2026-07-28 17:01:56
27	1	11	15ac13c0-97f2-4900-8af2-41d9f17bac94	2	1	2026-07-28 17:04:02	\N	\N	2026-07-28 17:04:02	2026-07-28 17:04:02
28	1	11	390f0eae-72bc-4735-9caf-e1341847f5a8	2	1	2026-07-28 17:15:52	\N	\N	2026-07-28 17:15:52	2026-07-28 17:15:52
\.


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_settings (id, key, value, label, sort_order, created_at, updated_at) FROM stdin;
1	miniprogram_title	舌尖生鲜	小程序顶部标题	10	2026-07-27 05:31:36	2026-07-27 05:31:36
2	industry_page_title	企业AI落地行业应用案例	行业选择页大标题	20	2026-07-27 05:31:36	2026-07-27 05:31:36
3	industry_page_subtitle	请选择你的行业	行业选择页小标题	30	2026-07-27 05:31:36	2026-07-27 05:31:36
\.


--
-- Data for Name: attendance_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attendance_records (id, employee_id, store_id, work_date, scheduled_start, scheduled_end, clock_in_at, clock_out_at, clock_in_source, work_hours, overtime_hours, status, exception_reason, approved_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cache (key, value, expiration) FROM stdin;
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: chat_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chat_logs (id, agent_id, direction, channel, account_id, conversation_id, message_id, sender, content, success, error_msg, session_key, occurred_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: competitor_hot_products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.competitor_hot_products (id, competitor_id, competitor_product_id, identified_date, heat_score, evidence, our_product_id, recommendation, reviewed_by, reviewed_at, created_at) FROM stdin;
\.


--
-- Data for Name: competitor_price_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.competitor_price_records (id, competitor_product_id, competitor_id, product_id, price, original_price, is_promotion, collect_source, collect_channel, image_url, collected_by, collected_at, created_at) FROM stdin;
\.


--
-- Data for Name: competitor_products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.competitor_products (id, competitor_id, product_id, competitor_product_name, competitor_product_code, spec, match_confidence, is_manually_confirmed, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: competitors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.competitors (id, organization_id, name, brand, address, latitude, longitude, distance_to_store, nearest_store_id, channels, status, notes, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: custom_report_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.custom_report_templates (id, organization_id, created_by, name, description, data_sources, filters, columns, chart_types, schedule_cron, is_shared, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_follow_ups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_follow_ups (id, customer_id, store_id, type, content, follow_up_at, next_follow_up_at, operator_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: customer_order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_order_items (id, customer_order_id, product_id, product_name, qty, unit, unit_price, subtotal, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: customer_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_orders (id, store_id, order_no, customer_id, customer_name, customer_phone, type, status, total_amount, discount_amount, paid_amount, payment_method, delivery_address, delivery_at, remark, operator_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (id, store_id, name, phone, gender, birthday, level, points, total_spent, order_count, last_order_at, tags, address, source, status, notes, created_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: daily_operation_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.daily_operation_logs (id, store_id, date, occurred_at, source, content, intent, is_operational, product_id, qty_change, reference_type, reference_id, operator_id, created_at, updated_at, is_failed, http_status_code, error_message) FROM stdin;
1	1	2026-07-27	2026-07-27 06:17:42	2	[失败 500] POST /api/ai/message	error	f	\N	\N	\N	\N	9	2026-07-27 06:17:42	2026-07-27 06:17:42	t	500	Server Error
2	1	2026-07-27	2026-07-27 06:17:57	2	[失败 500] POST /api/ai/message	error	f	\N	\N	\N	\N	9	2026-07-27 06:17:57	2026-07-27 06:17:57	t	500	Server Error
3	1	2026-07-27	2026-07-27 06:18:54	2	[失败 500] POST /api/ai/message	error	f	\N	\N	\N	\N	8	2026-07-27 06:18:54	2026-07-27 06:18:54	t	500	Server Error
4	1	2026-07-27	2026-07-27 06:21:46	1	AI助手: 你好，查一下库存	inventory_query	f	\N	\N	ai_message	1	8	2026-07-27 06:21:46	2026-07-27 06:21:46	f	\N	\N
5	1	2026-07-27	2026-07-27 06:22:06	1	AI助手: 你好	other	f	\N	\N	ai_message	3	9	2026-07-27 06:22:06	2026-07-27 06:22:06	f	\N	\N
6	1	2026-07-27	2026-07-27 06:22:15	1	AI助手: 可以做什么	other	f	\N	\N	ai_message	5	9	2026-07-27 06:22:15	2026-07-27 06:22:15	f	\N	\N
7	1	2026-07-27	2026-07-27 06:22:52	1	AI助手: 你好	other	f	\N	\N	ai_message	7	9	2026-07-27 06:22:52	2026-07-27 06:22:52	f	\N	\N
8	1	2026-07-27	2026-07-27 06:31:47	1	AI助手: 你好	other	f	\N	\N	ai_message	9	9	2026-07-27 06:31:47	2026-07-27 06:31:47	f	\N	\N
9	1	2026-07-27	2026-07-27 06:46:25	1	AI助手: 你能帮我做什么	other	f	\N	\N	ai_message	11	9	2026-07-27 06:46:25	2026-07-27 06:46:25	f	\N	\N
10	1	2026-07-27	2026-07-27 07:30:44	1	AI助手: 你能帮我做什么	other	f	\N	\N	ai_message	13	11	2026-07-27 07:30:44	2026-07-27 07:30:44	f	\N	\N
11	1	2026-07-27	2026-07-27 07:31:02	1	AI助手: 请帮我优化商品的搜索关键词（标题词/属性词/长尾词）。请提供商品名称与类目，我将给出关键词建议。	other	f	\N	\N	ai_message	15	11	2026-07-27 07:31:02	2026-07-27 07:31:02	f	\N	\N
12	1	2026-07-28	2026-07-28 05:43:07	1	AI助手: 你好	other	f	\N	\N	ai_message	17	11	2026-07-28 05:43:07	2026-07-28 05:43:07	f	\N	\N
13	1	2026-07-28	2026-07-28 07:26:24	1	AI助手: 你能帮我做什么	other	f	\N	\N	ai_message	19	11	2026-07-28 07:26:24	2026-07-28 07:26:24	f	\N	\N
14	1	2026-07-28	2026-07-28 07:36:08	1	AI助手: 请帮我写一篇小红书种草笔记（标题+正文+话题标签）。请提供商品与使用场景：	other	f	\N	\N	ai_message	21	11	2026-07-28 07:36:08	2026-07-28 07:36:08	f	\N	\N
15	1	2026-07-28	2026-07-28 07:38:42	1	AI助手: 请帮我分析以下品牌名称/商标/专利词是否可能存在侵权风险，并给出规避建议（仅供参考，不构成法律意见）。请输入要检测的内容：	other	f	\N	\N	ai_message	23	11	2026-07-28 07:38:42	2026-07-28 07:38:42	f	\N	\N
16	1	2026-07-28	2026-07-28 07:39:05	1	AI助手: 你好	other	f	\N	\N	ai_message	25	11	2026-07-28 07:39:05	2026-07-28 07:39:05	f	\N	\N
17	1	2026-07-28	2026-07-28 07:39:13	1	AI助手: 你在哪里	other	f	\N	\N	ai_message	27	11	2026-07-28 07:39:13	2026-07-28 07:39:13	f	\N	\N
18	1	2026-07-28	2026-07-28 07:39:29	1	AI助手: 请帮我做行业竞品分析。请提供：目标公司与主要竞争对手，我将从市场份额、产品、财务、护城河等维度对比。	other	f	\N	\N	ai_message	29	11	2026-07-28 07:39:29	2026-07-28 07:39:29	f	\N	\N
19	1	2026-07-28	2026-07-28 07:44:46	1	AI助手: 12	other	f	\N	\N	ai_message	31	11	2026-07-28 07:44:46	2026-07-28 07:44:46	f	\N	\N
20	1	2026-07-28	2026-07-28 07:45:09	1	AI助手: 请帮我为客户设计保险方案。请提供客户基本信息（年龄/家庭/收入/已有保障），我将按需求优先级推荐险种组合和配置建议。	other	f	\N	\N	ai_message	33	11	2026-07-28 07:45:09	2026-07-28 07:45:09	f	\N	\N
21	1	2026-07-28	2026-07-28 08:25:22	1	AI助手: 你能帮我做什么	other	f	\N	\N	ai_message	35	11	2026-07-28 08:25:22	2026-07-28 08:25:22	f	\N	\N
22	1	2026-07-28	2026-07-28 08:25:35	1	AI助手: 你能帮我做什么	other	f	\N	\N	ai_message	37	11	2026-07-28 08:25:35	2026-07-28 08:25:35	f	\N	\N
23	1	2026-07-28	2026-07-28 08:25:43	1	AI助手: 你能帮我做什么	other	f	\N	\N	ai_message	39	11	2026-07-28 08:25:43	2026-07-28 08:25:43	f	\N	\N
24	1	2026-07-28	2026-07-28 08:25:44	2	[失败 500] POST /api/ai/voice	error	f	\N	\N	\N	\N	11	2026-07-28 08:25:44	2026-07-28 08:25:44	t	500	Server Error
25	1	2026-07-28	2026-07-28 08:25:48	1	AI助手: 你能帮我做什么	other	f	\N	\N	ai_message	41	11	2026-07-28 08:25:48	2026-07-28 08:25:48	f	\N	\N
26	1	2026-07-28	2026-07-28 08:25:51	1	AI助手: 你能帮我做什么	other	f	\N	\N	ai_message	43	11	2026-07-28 08:25:51	2026-07-28 08:25:51	f	\N	\N
27	1	2026-07-28	2026-07-28 14:16:15	1	AI助手: 你好	other	f	\N	\N	ai_message	45	11	2026-07-28 14:16:15	2026-07-28 14:16:15	f	\N	\N
28	1	2026-07-28	2026-07-28 14:54:41	1	AI助手: 你好	other	f	\N	\N	ai_message	47	11	2026-07-28 14:54:41	2026-07-28 14:54:41	f	\N	\N
29	1	2026-07-28	2026-07-28 14:54:49	1	AI助手: 你是deepseek	other	f	\N	\N	ai_message	49	11	2026-07-28 14:54:49	2026-07-28 14:54:49	f	\N	\N
30	1	2026-07-28	2026-07-28 14:55:00	1	AI助手: 今天销量如何	sales_today_query	f	\N	\N	ai_message	51	11	2026-07-28 14:55:00	2026-07-28 14:55:00	f	\N	\N
31	1	2026-07-28	2026-07-28 15:47:30	1	AI助手: nh	other	f	\N	\N	ai_message	53	11	2026-07-28 15:47:30	2026-07-28 15:47:30	f	\N	\N
32	1	2026-07-28	2026-07-28 15:59:03	1	AI助手: 你好	other	f	\N	\N	ai_message	55	11	2026-07-28 15:59:03	2026-07-28 15:59:03	f	\N	\N
33	1	2026-07-28	2026-07-28 16:06:21	1	AI助手: 你好】	other	f	\N	\N	ai_message	57	11	2026-07-28 16:06:21	2026-07-28 16:06:21	f	\N	\N
34	1	2026-07-28	2026-07-28 16:26:53	1	AI助手: hi	other	f	\N	\N	ai_message	59	11	2026-07-28 16:26:53	2026-07-28 16:26:53	f	\N	\N
35	1	2026-07-28	2026-07-28 16:43:06	1	AI助手: hi	other	f	\N	\N	ai_message	61	11	2026-07-28 16:43:06	2026-07-28 16:43:06	f	\N	\N
36	1	2026-07-28	2026-07-28 17:01:58	1	AI助手: hi	other	f	\N	\N	ai_message	63	11	2026-07-28 17:01:58	2026-07-28 17:01:58	f	\N	\N
37	1	2026-07-28	2026-07-28 17:04:03	1	AI助手: 你好	other	f	\N	\N	ai_message	65	11	2026-07-28 17:04:03	2026-07-28 17:04:03	f	\N	\N
38	1	2026-07-28	2026-07-28 17:15:53	1	AI助手: hi	other	f	\N	\N	ai_message	67	11	2026-07-28 17:15:53	2026-07-28 17:15:53	f	\N	\N
\.


--
-- Data for Name: damage_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.damage_records (id, store_id, product_id, purchase_order_item_id, supplier_id, qty, unit_cost, total_claimed, reason, image_paths, status, occurred_at, operator_id, notes, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: dashboard_configs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dashboard_configs (id, user_id, store_id, name, scope, widgets, filters, refresh_interval, is_default, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: employee_store_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employee_store_history (id, employee_id, from_store_id, to_store_id, effective_date, reason, approved_by, created_at) FROM stdin;
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employees (id, organization_id, user_id, current_store_id, employee_no, name, phone, id_card_no, gender, birth_date, education, "position", position_level, hire_date, contract_expire_date, probation_end_date, status, resign_date, resign_reason, base_salary, emergency_contact, emergency_phone, skills, notes, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: expense_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.expense_categories (id, organization_id, parent_id, name, code, is_cogs, sort_order, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.expenses (id, store_id, category_id, expense_no, amount, expense_date, description, input_method, ai_session_message_id, attachment_urls, vendor_name, supplier_id, payment_method, payment_status, created_by, approved_by, approved_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: industries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.industries (id, slug, name, emoji, title, description, sort_order, enabled, created_at, updated_at, api_base, api_token, ai_path, ai_media, greeting) FROM stdin;
1	fresh	生鲜门店	🥬	舌尖生鲜	果蔬肉禽 · 进货/库存/损耗/销售	20	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	t	我是舌尖生鲜 · AI 店长助手 🥬\n\n直接在下面输入框跟我说，我能帮你：\n📦 查库存 / 报剩余\n💰 录销售 / 查今日销售\n🚚 记进货\n🗑️ 记损耗
3	restaurant	餐饮快餐	🍜	AI 餐饮店长	点餐/营业额/备料/损耗	16	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 餐饮店长 🍜\n\n点下面菜单或直接跟我说，我能帮你：\n📈 营业概况 / 热销菜品\n🥬 备料建议 / 库存\n🗑️ 损耗登记\n👥 会员储值
4	apparel	服装零售	👕	AI 服装店长	上新/库存/销售/会员	30	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 服装店长 👕\n\n点下面菜单或直接跟我说，我能帮你：\n🆕 上新登记 / 款式管理\n📦 库存 / 尺码缺货\n💰 销售统计\n👥 会员管理
5	convenience	便利超市	🏪	AI 便利店长	进货/库存/销售/促销	40	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 便利店长 🏪\n\n点下面菜单或直接跟我说，我能帮你：\n🚚 进货登记 / 补货建议\n📦 库存 / 临期预警\n💰 销售统计\n🎁 促销活动
6	beauty	美业服务	💇	AI 美业管家	预约/会员/消费/员工	50	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 美业管家 💇\n\n点下面菜单或直接跟我说，我能帮你：\n📅 预约管理 / 客户回访\n👥 会员 / 办卡储值\n🧾 消费记录\n🏆 员工业绩
7	manufacturing	制造业	🏭	AI 生产助手	订单/产能/物料/排程	60	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 生产助手 🏭\n\n点下面菜单或直接跟我说，我能帮你：\n📐 工艺文档 · SOP / 参数 / 报价\n🔧 设备运维 · 故障诊断 / 保养\n🔍 质量管理 · 质检 / 8D / 根因\n🛡️ 安全精益 · 隐患排查 / 5S
8	auto_repair	汽修门店	🚗	AI 汽修助手	故障诊断/维修保养/报价工单	65	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 汽修助手 🚗\n\n点下面菜单或直接跟我说，我能帮你：\n🩺 故障诊断 · 故障码 / 异响\n🔧 维修保养 · 方案 / 工时 / 配件\n💵 报价开单 · 报价单 / 工单\n🛎️ 客户服务 · 沟通 / 回访话术
10	finance	金融	💰	AI 金融助手	账户/对账/客户/风控	5	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 金融助手 💰\n\n点下面菜单或直接跟我说，我能帮你：\n📈 投研分析 · 财报 / 估值 / DCF\n🏦 投行交易 · 建模 / 路演 PPT\n💰 基金行政 · 对账 / NAV / 月末结账\n🌱 私募财富 · 寻源 / 组合分析
11	ecommerce	电商	🛒	AI 电商助手	订单/库存/退款/客服	12	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 电商助手 🛒\n\n点下面菜单或直接跟我说，我能帮你：\n✍️ 写标题 / 详情 / 种草文案\n🎬 短视频 / 直播话术\n📈 关键词 / 竞品 / 活动策划\n🛎️ 客服 / 差评 / 售后话术
12	cross_border	跨境电商	🌐	AI 跨境助手	文案/翻译/五点/侵权检测	92	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	f	我是 AI 跨境助手 🌐\n\n点下面菜单或直接跟我说，我能帮你：\n🤖 AI 工具 · 翻译 / 文案 / 五点描述\n🔍 侵权检测 · 单词 / 品牌专利\n📊 经营查询 / 日常管理
2	erp_crm	进销存及CRM	📊	进销存及CRM	商品/采购/销售/客户/线索/商机	8	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	t	我是 AI 进销存 & CRM 助手 📊\n\n点下面菜单或直接跟我说，我能帮你：\n📦 商品 / 采购 / 销售\n👥 客户 / 线索 / 商机\n📊 经营数据查询
9	insurance	保险	🛡️	AI 保险助手	保单/客户/续保/业绩	70	t	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N	\N	t	我是 AI 保险助手 🛡️\n\n点下面菜单或直接跟我说，我能帮你：\n📋 产品对比 / 条款解读 / 方案设计\n🚀 展业话术 / 拒绝处理 / 拓客文案\n🛎️ AI客服 / 理赔指引 / 续保提醒\n🎓 新人培训 / 话术演练 / 合规\n📊 业绩查询 / 客户跟进
\.


--
-- Data for Name: intelligence_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.intelligence_reports (id, organization_id, store_id, report_period_start, report_period_end, report_type, price_gap_summary, hot_products_summary, ai_insights, action_recommendations, generated_at, is_auto_generated) FROM stdin;
\.


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory (id, store_id, product_id, current_qty, available_qty, locked_qty, avg_cost, last_in_at, last_out_at, last_counted_at, updated_at, last_sold_at) FROM stdin;
\.


--
-- Data for Name: inventory_daily_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_daily_snapshots (id, store_id, product_id, date, opening_qty, received_qty, sold_qty, damage_qty, adjustment_qty, closing_qty, created_at, updated_at, sold_out_at) FROM stdin;
\.


--
-- Data for Name: inventory_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_transactions (id, store_id, product_id, transaction_type, qty_change, qty_before, qty_after, unit_cost, total_cost, reference_type, reference_id, batch_no, expiry_date, operator_id, notes, created_at) FROM stdin;
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leave_requests (id, employee_id, store_id, leave_type, start_date, end_date, total_days, reason, status, approved_by, approved_at, reject_reason, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: menu_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.menu_templates (id, industry, name, is_active, sort_order, created_at, updated_at) FROM stdin;
1	insurance	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
2	ecommerce	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
3	auto_repair	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
4	finance	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
5	cross_border	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
6	manufacturing	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
7	beauty	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
8	restaurant	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
9	fresh	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
10	convenience	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
11	apparel	默认模版	t	0	2026-07-27 05:31:36	2026-07-27 05:31:36
\.


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
11	2026_03_16_000006_create_product_categories_table	1
12	2026_03_16_000007_create_products_tables	1
13	2026_03_16_000008_create_suppliers_tables	1
14	2026_03_16_000009_create_inventory_tables	1
15	2026_03_16_000010_create_ai_assistant_tables	1
16	2026_03_16_000011_create_ai_forecast_tables	1
17	2026_03_16_000012_create_promotion_tables	1
18	2026_03_16_000013_create_competitor_tables	1
19	2026_03_16_000014_create_finance_tables	1
20	2026_03_16_000015_create_hr_tables	1
21	2026_03_16_000016_create_dashboard_report_tables	1
22	2026_03_22_070800_add_is_admin_to_users_table	1
23	2026_03_22_082441_add_supplier_id_to_products_table	1
24	2026_03_22_100000_create_resumes_table	1
25	2026_03_22_111908_alter_purchase_orders_move_supplier_to_items	1
26	2026_03_30_224524_create_sales_orders_tables	1
27	2026_03_30_225348_add_last_sold_out_at_to_inventory_table	1
28	2026_03_30_225639_create_product_sellout_logs_table	1
29	2026_03_30_230102_rename_last_sold_out_at_and_drop_sellout_logs	1
30	2026_03_31_000816_create_inventory_daily_snapshots_table	1
31	2026_03_31_004600_create_daily_operation_logs_table	1
32	2026_03_31_012733_create_sales_daily_summaries_table	1
33	2026_03_31_013104_drop_unused_inventory_sales_tables	1
34	2026_03_31_022259_drop_store_products_table	1
35	2026_03_31_022902_add_sold_out_at_to_inventory_daily_snapshots	1
36	2026_03_31_022902_drop_unused_supplier_finance_tables	1
37	2026_03_31_215717_create_sales_uploads_table	1
38	2026_04_04_022128_add_username_to_users_table	1
39	2026_04_04_025507_add_source_columns_to_sales_daily_summaries	1
40	2026_04_07_000001_create_chat_logs_table	1
41	2026_04_15_214504_add_failure_fields_to_daily_operation_logs	1
42	2026_04_17_000309_create_weather_logs_table	1
43	2026_04_29_070457_create_damage_records_table	1
44	2026_04_29_070458_create_supplier_refund_claims_tables	1
45	2026_05_30_120000_create_quick_actions_tables	1
46	2026_05_30_130000_create_app_settings_table	1
47	2026_05_31_070311_add_image_paths_to_purchase_orders_table	1
48	2026_05_31_093318_create_customers_table	2
49	2026_05_31_093319_create_customer_follow_ups_table	2
50	2026_05_31_093319_create_customer_orders_table	3
51	2026_05_31_093320_create_customer_order_items_table	3
52	2026_06_11_120000_create_industries_table	4
53	2026_06_11_120100_add_industry_to_quick_actions	4
54	2026_06_12_120000_create_menu_templates_table	4
55	2026_06_12_120100_add_menu_template_to_quick_actions	4
56	2026_06_12_130000_add_api_base_to_industries	4
57	2026_06_13_100000_add_api_token_to_industries	4
58	2026_06_13_110000_add_ai_path_to_industries	4
59	2026_06_13_120000_add_ai_media_to_industries	4
60	2026_06_14_130000_add_greeting_to_industries	4
61	2026_06_15_053246_create_sso_users_table	4
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organizations (id, name, code, logo_url, contact_phone, settings, created_at, updated_at, deleted_at) FROM stdin;
1	舌尖香港	SJTXG	\N	\N	\N	2026-07-27 05:31:36	2026-07-27 05:31:36	\N
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permissions (id, module, code, name, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
1	App\\Models\\User	7	auth_token	bc58b9bc2d285b30eb5aa4717ef901c35be518b8e606b404d28005fa29053980	["store:1"]	\N	2026-08-26 05:33:43	2026-07-27 05:33:43	2026-07-27 05:33:43
2	App\\Models\\User	9	auth_token	93289123d40d983d35190055998c3b68c2d84569c213822d71f0713e71cad64e	["store:1"]	\N	2026-08-26 06:15:18	2026-07-27 06:15:18	2026-07-27 06:15:18
3	App\\Models\\User	10	auth_token	4c29abdac75cf9dfe8c0c816dbb054bb8848490a4ef5b6e258f895f70dd7b48b	["store:1"]	\N	2026-08-26 06:16:57	2026-07-27 06:16:57	2026-07-27 06:16:57
4	App\\Models\\User	9	auth_token	8352a290eacb94b911bb307d186cec4b9ff21ce81b35024b3a9e407c04f286ae	["store:1"]	\N	2026-08-26 06:17:27	2026-07-27 06:17:27	2026-07-27 06:17:27
5	App\\Models\\User	9	auth_token	391811d99d39ee0e052441bd0bc920cd0d5901778d3d1b71ffad48717bb1f338	["store:1"]	\N	2026-08-26 06:22:50	2026-07-27 06:22:50	2026-07-27 06:22:50
6	App\\Models\\User	9	auth_token	06505f5eacc5d3ea7043502c1d67c611fa633d13e8a41a9a547b06747b6e1a4c	["store:1"]	\N	2026-08-26 06:31:41	2026-07-27 06:31:41	2026-07-27 06:31:41
7	App\\Models\\User	9	auth_token	d172e68c9358449e597d8e1d70cb9beaa5d2190299f30d52f23d255f61258834	["store:1"]	\N	2026-08-26 06:36:27	2026-07-27 06:36:27	2026-07-27 06:36:27
8	App\\Models\\User	9	auth_token	364c01939e9d3f5d9c8aff9bd5d7f951279f95fb4433f14a6f2cdb4f7a121fa7	["store:1"]	\N	2026-08-26 06:45:28	2026-07-27 06:45:28	2026-07-27 06:45:28
9	App\\Models\\User	11	auth_token	e494e2882b9604a6d863fca23afbf44e18121af32f28cead9c4cd7cbde3fb536	["store:1"]	\N	2026-08-26 06:58:24	2026-07-27 06:58:24	2026-07-27 06:58:24
10	App\\Models\\User	9	auth_token	747d49827448f9431513e33d989db38c63aa9f3f48286d46cece3e2651444174	["store:1"]	\N	2026-08-26 07:03:52	2026-07-27 07:03:52	2026-07-27 07:03:52
11	App\\Models\\User	9	auth_token	fd282d6635002a042fd7e73c7cb278f1474fb207370cf517a0477bacfca82623	["store:1"]	\N	2026-08-26 07:06:00	2026-07-27 07:06:00	2026-07-27 07:06:00
12	App\\Models\\User	11	auth_token	f73ea76f25f6b4f11eaac595f380f884edf0ea693845c3441e3579a47f947a7e	["store:1"]	\N	2026-08-26 07:06:16	2026-07-27 07:06:16	2026-07-27 07:06:16
13	App\\Models\\User	9	auth_token	426e26bda8208313eeb21a21341b3d18e66bb6e0f0be91146c310a30bdde1f34	["store:1"]	\N	2026-08-26 07:06:36	2026-07-27 07:06:36	2026-07-27 07:06:36
14	App\\Models\\User	9	auth_token	21f19b14167ff7131553e738338b3c21632c4f1edb1c9847aa7d8273a047fb37	["store:1"]	\N	2026-08-26 07:08:04	2026-07-27 07:08:04	2026-07-27 07:08:04
15	App\\Models\\User	11	auth_token	9795c08c39e89c6cc1df5905e1a44442b6c3bed1d4d0d3df8ee10749afaf3944	["store:1"]	\N	2026-08-26 07:24:39	2026-07-27 07:24:39	2026-07-27 07:24:39
16	App\\Models\\User	11	auth_token	9648f84f859ec8f4bd738cd0672c9e900b9d83c7abd2eb719d2f21e07dafa963	["store:1"]	\N	2026-08-26 07:28:02	2026-07-27 07:28:02	2026-07-27 07:28:02
17	App\\Models\\User	13	auth_token	0f5a8ca83c52f3ab385ba9b72e1c5ba4801e2722b05ceb83a73a44f8c1d3b673	["store:1"]	\N	2026-08-26 07:36:13	2026-07-27 07:36:13	2026-07-27 07:36:13
18	App\\Models\\User	11	auth_token	2792ffdb0226b8172c7aea7f89bd2c3646b50a5291ee3af2432576463f82f8c3	["store:1"]	\N	2026-08-26 07:50:14	2026-07-27 07:50:14	2026-07-27 07:50:14
19	App\\Models\\User	11	auth_token	019775580f6108e0849853ac5fc4a3730736350d79e3a5b1497c334e0d68d5db	["store:1"]	\N	2026-08-27 07:12:10	2026-07-28 07:12:10	2026-07-28 07:12:10
20	App\\Models\\User	11	auth_token	4126d7a7f6c703da1d9a08ea5612a2bafa01f8ce5fe95c94de95782a8ce2fb82	["store:1"]	\N	2026-08-27 07:24:36	2026-07-28 07:24:36	2026-07-28 07:24:36
21	App\\Models\\User	11	auth_token	c604f7188e89862165d7bc51589ae3c829890b96cac4a5d7ddff199e53a155e9	["store:1"]	\N	2026-08-27 08:17:45	2026-07-28 08:17:45	2026-07-28 08:17:45
22	App\\Models\\User	11	auth_token	2b7306db71ef9221d5e8b3ad3ad68e7a6dcff395efb55b6a98eec653aa7946a5	["store:1"]	\N	2026-08-27 08:18:25	2026-07-28 08:18:25	2026-07-28 08:18:25
23	App\\Models\\User	11	auth_token	c637146a44b207086a1b80c1ead3d34ca63a19783f05fc2fa14f99847c70456a	["store:1"]	\N	2026-08-27 08:19:50	2026-07-28 08:19:50	2026-07-28 08:19:50
24	App\\Models\\User	11	auth_token	f11be2ba42dd9a1dd9e67faff1898d2759ee9adffe571128b3a87ace3c1514db	["store:1"]	\N	2026-08-27 11:10:46	2026-07-28 11:10:46	2026-07-28 11:10:46
25	App\\Models\\User	11	auth_token	e7fce2e597c54f1a9969e9161fc278433e79a647fb0be19cdef8bc631d30831d	["store:1"]	\N	2026-08-27 14:16:07	2026-07-28 14:16:07	2026-07-28 14:16:07
26	App\\Models\\User	11	auth_token	262e945c097b9e44c388e0fe0611c3eb1863284f99711e8297d98181cbd6959b	["store:1"]	\N	2026-08-27 14:54:35	2026-07-28 14:54:35	2026-07-28 14:54:35
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.posts (id, user_id, title, content, published, created_at, updated_at) FROM stdin;
1	1	Sed quae quia dolor neque unde.	Quisquam voluptates molestias hic. A ut qui recusandae molestiae ab cupiditate. Voluptas consequatur iusto optio ut dolores.\n\nVoluptatem labore adipisci ut officiis. Explicabo nisi omnis nesciunt iusto totam voluptas. Quam officia aliquid vel quo.\n\nMagnam et dolorem saepe sapiente. Debitis facilis blanditiis quis soluta cumque blanditiis sed odio. Accusamus velit repellendus harum aliquam laudantium iste molestias. Omnis nihil doloremque cum.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
2	1	Eos ab et omnis aspernatur eos nihil.	Temporibus voluptas ea porro ratione. Dolorem ullam aliquid aut aut distinctio voluptatum incidunt. Distinctio qui excepturi magni eaque dolorem voluptas beatae. Repudiandae sit eveniet expedita omnis.\n\nAsperiores quam eos repellendus est fuga. Ut soluta quibusdam expedita laudantium et. Dolor error voluptas earum voluptatem. Cupiditate consequatur a necessitatibus hic mollitia qui sunt sint. Omnis impedit doloribus sed dignissimos.\n\nSimilique quia omnis minus. Distinctio veniam temporibus quia eos voluptatibus officiis voluptatibus. Velit aspernatur possimus rerum quo accusamus.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
3	1	Architecto et voluptatem magni tempora.	Dolores et quia cum. Molestiae ut molestiae reiciendis. Consequatur hic vel architecto perferendis. Nam quo est omnis et exercitationem nihil et.\n\nVoluptatem pariatur voluptatibus repudiandae incidunt. Ut doloribus a veniam. Quaerat consequuntur reiciendis aperiam atque voluptatem tempore commodi.\n\nEsse nesciunt est aut eaque fuga quae. Et neque enim culpa molestias rerum ut. Ut autem dolor sequi alias reiciendis esse totam.	f	2026-07-27 05:31:36	2026-07-27 05:31:36
4	1	Aliquid eius placeat vero pariatur facere corrupti.	Fugiat nemo harum delectus perspiciatis necessitatibus sit voluptatum itaque. Nihil omnis et a non dignissimos. Culpa libero qui perspiciatis quia voluptatibus. Accusamus dicta vero eius voluptatibus porro error laborum.\n\nEos ipsa eum explicabo quibusdam. Minima repudiandae blanditiis non nostrum voluptatem voluptas. Quaerat unde quod voluptate. Itaque voluptatem dolorum incidunt magnam aut.\n\nAccusantium delectus placeat similique unde dignissimos pariatur. Qui totam assumenda minus ipsam et et. Culpa non accusantium nihil praesentium incidunt placeat. Et rerum ad quaerat fugiat est incidunt. Veniam sapiente explicabo quo pariatur.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
5	1	Vel sequi quibusdam maiores quo id dicta error.	Et commodi repellat labore. Quis modi ipsa delectus vel quo voluptatibus. Est ut cumque consequatur inventore quis enim. Non accusamus quibusdam dolorem sit impedit.\n\nPerferendis quia incidunt et voluptates alias. Ex repellat at quam quam quibusdam mollitia voluptatibus. Reprehenderit harum dolores quia dolore. Consequatur natus accusantium non id.\n\nSed ducimus laboriosam ex. Voluptas vero dignissimos deleniti minus voluptatem. Libero fugiat officiis placeat et. Corrupti molestiae ut occaecati et eligendi hic.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
6	2	Quibusdam velit dolorem natus in vel quia ut corporis.	Eaque facere non corrupti in. Voluptas blanditiis exercitationem voluptates unde veritatis non accusamus. Sed necessitatibus quo rem quaerat. Veritatis illum vel consequatur repudiandae.\n\nReiciendis quasi sit qui autem. Voluptas deserunt aut sapiente vitae labore enim rerum. Non ipsa blanditiis est ipsum quaerat. Ea perspiciatis nostrum dolore.\n\nVoluptatem qui voluptatibus alias. Nulla et dolores tempore quibusdam. Sint cumque illo eius minus qui dolore modi. Id perferendis nam error autem quod repellat a.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
7	2	Et delectus qui voluptas natus natus at distinctio quaerat.	Magni eum ratione optio aperiam repellendus enim. Aspernatur ducimus rerum reprehenderit optio. Delectus similique consequatur et qui.\n\nPerspiciatis repudiandae voluptatem eius omnis. Inventore distinctio consequatur omnis. Cum libero et qui. Corporis a ut rem. Tempore voluptatem impedit possimus consequatur iusto accusantium mollitia.\n\nRepudiandae molestias laboriosam cumque et modi impedit. Similique delectus illum mollitia quas. Omnis dolor voluptatem placeat autem.	f	2026-07-27 05:31:36	2026-07-27 05:31:36
8	2	Nulla labore minus provident corrupti est.	Placeat amet occaecati dolores illum. Quam consequatur ad voluptatibus earum assumenda consequatur ipsum. Voluptas voluptatem quia occaecati delectus distinctio doloremque. Doloremque consequatur sed quas facere repellendus eos.\n\nSaepe autem quis occaecati veniam sed. Similique ea quas impedit. Laudantium eaque qui maxime fuga molestiae aut.\n\nAut assumenda tenetur laborum. Sed facere officia ipsam ex tenetur quia excepturi. Sed est facere et accusamus corrupti. Aut quae molestias dolorem nisi officia maiores est.	f	2026-07-27 05:31:36	2026-07-27 05:31:36
9	2	Sed eveniet deserunt est nemo illum sed.	Assumenda veniam libero saepe necessitatibus nam aliquam. Eum quibusdam et molestias molestiae et nostrum. Blanditiis et eligendi ut sequi. Iure doloremque ea nobis perspiciatis atque.\n\nTemporibus necessitatibus nulla sunt voluptate. Est sapiente assumenda error nam sunt.\n\nQuas numquam tenetur fugiat voluptatem. Autem numquam inventore sed nisi. Dignissimos rerum ut vitae molestiae. Quod sit consequatur vitae placeat aspernatur maiores.	f	2026-07-27 05:31:36	2026-07-27 05:31:36
10	2	Magnam officia ratione magnam quod ut vitae aut.	Veritatis dolor veritatis et eligendi asperiores est eius. Ea aliquid natus sapiente ipsam. Commodi velit et maxime omnis id. Nihil error nemo nulla nostrum cum magnam.\n\nAccusantium porro accusamus adipisci nobis perferendis. Sed id molestiae blanditiis. Praesentium ipsam et dolores alias corporis voluptates et. Non earum voluptatem enim veritatis quis.\n\nQuo in sint molestiae culpa asperiores porro. Vel maxime qui quasi quia. Corrupti consequatur quibusdam qui nam.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
11	3	Est voluptatem aliquid quos occaecati inventore voluptatem ut.	Culpa quasi dignissimos rerum in. Architecto autem sint corporis quo consequatur rerum libero. Totam aliquid perferendis et voluptas quis. Voluptatem eligendi quasi facilis numquam nesciunt minus vitae.\n\nAt minus minima est. Voluptas deserunt modi necessitatibus tempora magnam laborum molestias perspiciatis.\n\nDignissimos similique distinctio in nisi iure deserunt tempore est. Aut eius delectus non laudantium voluptatem. Minima amet non quisquam possimus.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
12	3	Alias nemo sit ut consequatur tenetur saepe.	Temporibus iure aliquid quia est nulla reprehenderit. Velit at et a et. Aperiam corporis sit dolorum et nihil quidem. Voluptas nihil earum perferendis consequatur nihil voluptatem.\n\nExplicabo sequi doloribus dolorum sed veniam optio voluptatem. Fugiat modi voluptas tempora alias nam ea quia. Totam qui tempora labore est et qui ipsum. Accusantium ipsum rerum eos expedita eaque perferendis veniam in.\n\nDignissimos voluptas id sequi vel odio aliquid culpa. Impedit ut eligendi recusandae molestias dicta accusantium itaque.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
13	4	Illo laboriosam odio maiores nihil nisi tenetur fugit.	Voluptas placeat incidunt omnis. Sit in nam laborum. Officiis earum rerum sit saepe voluptatem omnis omnis. Numquam voluptas voluptatem enim accusamus fugiat ullam.\n\nSint eos consequatur debitis itaque delectus voluptatibus necessitatibus. Optio et beatae voluptates molestiae eaque cupiditate. Voluptatem et vitae consequuntur asperiores ipsum nostrum iure. Repudiandae deleniti veniam aliquam totam ex.\n\nIusto qui quia sint quo qui delectus tempora. Maxime beatae et dolores vero. Eum quia in maiores rerum quia.	f	2026-07-27 05:31:36	2026-07-27 05:31:36
14	4	Nobis rerum perferendis alias ea aut laborum autem nesciunt.	Temporibus et voluptatem vitae laboriosam aut. Iure et blanditiis omnis quibusdam aliquam eum delectus. Quae et provident quia veritatis quibusdam magni.\n\nAliquam cupiditate ducimus itaque dolor. Consequatur voluptas eligendi enim odio. Labore debitis reprehenderit vel est ullam doloremque.\n\nTempora et repellendus assumenda quam minima. Et sed deleniti veniam voluptas nulla aut. Similique amet vel hic aut adipisci velit.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
15	4	Perspiciatis voluptas quia eum voluptas excepturi voluptas qui.	Aut placeat tenetur omnis omnis accusantium. Voluptates molestiae odio et pariatur et unde. Qui ipsum vel ut.\n\nNobis voluptatem autem aut sunt. Velit tenetur quo est excepturi. In libero explicabo aperiam. At velit at voluptatem pariatur. Deleniti occaecati cum autem incidunt nostrum labore.\n\nArchitecto vitae molestias ad perspiciatis. Minus cupiditate sit et. Aliquid est eos ut ea reprehenderit blanditiis.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
16	4	Ipsa et maxime id dolor modi corrupti minima.	Aut fugit sit et est minima rerum nisi. Quaerat doloribus reprehenderit qui error magnam. Dolorem officiis quis sint consequatur est. Harum et nostrum occaecati autem quidem.\n\nVoluptatibus possimus quasi voluptatem atque pariatur tempore. Recusandae asperiores expedita distinctio est. Quae soluta eos aut illum id. Quas veniam officia nulla sed sapiente.\n\nMolestias deserunt hic adipisci excepturi voluptatem molestiae voluptates nam. Veritatis vel nihil velit doloribus sint nisi et. Et alias expedita enim earum. Assumenda quaerat velit a est.	f	2026-07-27 05:31:36	2026-07-27 05:31:36
17	5	Eligendi et rerum ut repellat voluptatem aut aut sed.	Nostrum ipsa esse in ut et consectetur. Voluptas illo eum cum quibusdam vero id blanditiis. Non ab cupiditate itaque omnis.\n\nAut libero illo quidem sit. Vitae reiciendis eligendi hic suscipit autem distinctio distinctio eaque. Quia eaque qui enim et cum quas. Qui officia sequi perferendis et. Nihil soluta voluptatem debitis enim.\n\nEt voluptas qui quo soluta. Rerum eaque beatae adipisci animi esse quia laborum. Quis nihil et minus. Tempora quos sint est laudantium.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
18	5	Ullam sint dignissimos totam molestiae molestias.	Consectetur fugiat ipsam enim cum. Voluptatem exercitationem sed non dolorem. Corrupti ad autem numquam aut earum. Voluptatum animi sed quia qui adipisci explicabo.\n\nEaque eaque suscipit quisquam temporibus earum. Provident incidunt sapiente facere doloribus. Sint ut similique quo sequi reprehenderit voluptatem. Et aliquam voluptatem nobis et aspernatur.\n\nQuidem voluptas eligendi illo facere incidunt perferendis ea. Porro cum optio sunt suscipit maiores aliquid. Voluptatem sed magni excepturi ut totam. Dolores delectus maiores ut est id.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
19	5	Inventore quos voluptates necessitatibus.	Officia ducimus ut molestiae ratione. Porro aliquam fugiat non aut sint blanditiis ut incidunt. Aut quae sed est aliquam ex. Iste unde ducimus voluptates. Sequi officiis sit quia voluptatem officia culpa quo.\n\nAliquam eius incidunt illum vitae ut velit ut voluptate. Fuga eum autem culpa dolorum non. Quisquam sit assumenda voluptatem beatae.\n\nEt molestias rerum iste sed numquam suscipit. Debitis commodi nihil eos quia. Neque aspernatur debitis dolores tenetur enim vel sequi.	f	2026-07-27 05:31:36	2026-07-27 05:31:36
20	5	Magnam sit ducimus ipsum quia inventore dolor aperiam.	Veritatis asperiores delectus ut et cum. Laborum et dolor voluptatem amet consequatur. Omnis velit autem non cumque voluptatibus laborum.\n\nSaepe pariatur non reiciendis aut. Illum neque nostrum et sunt earum officiis ipsam. Quibusdam qui exercitationem nobis quis nihil voluptatum rerum. Quod nihil voluptatem quos unde sed voluptatum.\n\nExplicabo similique sint ut quidem iusto quae placeat nihil. Earum porro sed nisi. Et voluptas similique eligendi sunt. Est est nesciunt unde harum.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
21	6	Laboriosam et sit autem dolor illo veritatis incidunt.	Alias distinctio est dolor libero impedit delectus ut. Suscipit officiis ab sunt.\n\nEt quod at quasi magni. Nostrum expedita hic natus beatae.\n\nOccaecati praesentium quos ut. Recusandae sed laudantium eos consectetur. Quidem quidem voluptas dicta temporibus doloribus voluptatem. Expedita dolores architecto quia officia ut.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
22	6	Et cupiditate repudiandae neque accusantium velit.	Ut cumque illum maxime iusto rerum sit. Rerum nulla facere consequatur at. Incidunt accusantium ut sed neque nemo dolore. Sapiente maxime similique itaque earum.\n\nMollitia laudantium aspernatur animi quia libero vel est. Et voluptatem debitis nisi unde quo vitae. Error eum magnam placeat eum minima rerum.\n\nVelit et voluptatem dolores quas. Dolores quia culpa illum aut dignissimos quasi praesentium id.	t	2026-07-27 05:31:36	2026-07-27 05:31:36
\.


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_categories (id, organization_id, parent_id, name, code, sort_order, icon_url, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, organization_id, category_id, name, code, barcode, brand, unit, spec, image_urls, description, shelf_life_days, storage_condition, is_fresh, min_order_qty, purchase_unit, purchase_unit_qty, status, created_by, created_at, updated_at, deleted_at, supplier_id) FROM stdin;
\.


--
-- Data for Name: promotion_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_items (id, promotion_id, product_id, original_price, promotion_price, discount_rate, ai_suggested_price, cost_price, stock_qty_at_start, target_clear_qty, actual_sold_qty, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: promotion_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_reviews (id, promotion_id, store_id, total_revenue, total_cost, gross_profit, gross_profit_rate, clear_rate, waste_amount_prevented, customer_traffic_change, ai_effectiveness_score, lessons_learned, recommendations, generated_at) FROM stdin;
\.


--
-- Data for Name: promotion_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_rules (id, organization_id, name, trigger_type, trigger_condition, promotion_type, pricing_strategy, max_discount_rate, apply_to, apply_target_ids, auto_execute, is_active, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotions (id, store_id, rule_id, name, trigger_source, status, started_at, ended_at, ai_analysis, total_sales_qty, total_sales_amount, total_saved_waste_amount, created_by, approved_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: purchase_order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_order_items (id, purchase_order_id, product_id, ordered_qty, received_qty, unit_price, total_price, created_at, updated_at, supplier_id) FROM stdin;
\.


--
-- Data for Name: purchase_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_orders (id, store_id, supplier_id, order_no, order_type, status, expected_delivery_date, actual_delivery_date, total_amount, notes, created_by, approved_by, approved_at, created_at, updated_at, deleted_at, image_paths) FROM stdin;
\.


--
-- Data for Name: quick_action_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quick_action_items (id, quick_action_id, emoji, label, "desc", item_type, route, prompt, sort_order, created_at, updated_at) FROM stdin;
3	5	📋	历史进货单记录	看历史上传的单据	route	/pages/purchase-orders/purchase-orders	\N	10	2026-07-27 05:31:36	2026-07-27 05:31:36
4	5	📤	上传进货单	拍照/相册/文件 AI 识别入库	route	/pages/purchase-upload/purchase-upload	\N	20	2026-07-27 05:31:36	2026-07-27 05:31:36
5	6	📊	每日营运概况	往日库存/进货/已售/售罄	route	/pages/report/report	\N	10	2026-07-27 05:31:36	2026-07-27 05:31:36
6	6	🚚	最近进货	进货单明细	prompt	\N	查一下最近的进货单	20	2026-07-27 05:31:36	2026-07-27 05:31:36
7	6	💡	进货建议	补货优先级	prompt	\N	给我一些进货和促销建议	30	2026-07-27 05:31:36	2026-07-27 05:31:36
8	6	📝	操作日志	今日远程指令留档	prompt	\N	看一下今天的操作日志	40	2026-07-27 05:31:36	2026-07-27 05:31:36
9	9	📈	营业概况	今日营收与客单	prompt	\N	今天的营业概况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
10	9	🔥	热销菜品	卖得最好的菜	prompt	\N	最近哪些菜品最热销	20	2026-07-27 05:31:36	2026-07-27 05:31:36
11	9	🥬	备料建议	明天备多少料	prompt	\N	明天需要备多少料	30	2026-07-27 05:31:36	2026-07-27 05:31:36
12	9	🪑	客流翻台	客流与翻台率	prompt	\N	今天客流和翻台情况	40	2026-07-27 05:31:36	2026-07-27 05:31:36
13	10	💵	今日营业额	当日营收	prompt	\N	今天营业额多少	10	2026-07-27 05:31:36	2026-07-27 05:31:36
14	10	🍽️	菜品销量	各菜销量	prompt	\N	今天各菜品卖了多少	20	2026-07-27 05:31:36	2026-07-27 05:31:36
15	10	🥬	库存备料	备料余量	prompt	\N	现在还剩多少备料	30	2026-07-27 05:31:36	2026-07-27 05:31:36
16	10	🗑️	损耗记录	报废登记	prompt	\N	记录一笔损耗	40	2026-07-27 05:31:36	2026-07-27 05:31:36
17	10	👥	会员储值	会员余额	prompt	\N	查一下会员储值情况	50	2026-07-27 05:31:36	2026-07-27 05:31:36
18	11	📈	销售概况	今日销售与件数	prompt	\N	今天的销售概况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
19	11	🔥	热销款式	卖得好的款	prompt	\N	最近哪些款式卖得好	20	2026-07-27 05:31:36	2026-07-27 05:31:36
20	11	⚠️	库存预警	缺货款式	prompt	\N	哪些商品库存不足	30	2026-07-27 05:31:36	2026-07-27 05:31:36
21	11	👥	会员消费	会员消费情况	prompt	\N	会员消费情况怎么样	40	2026-07-27 05:31:36	2026-07-27 05:31:36
22	12	🆕	上新管理	登记新款	prompt	\N	帮我登记今天的上新款	10	2026-07-27 05:31:36	2026-07-27 05:31:36
23	12	📦	库存查询	当前库存	prompt	\N	查一下当前库存	20	2026-07-27 05:31:36	2026-07-27 05:31:36
24	12	💰	销售统计	今日件数	prompt	\N	今天卖了多少件	30	2026-07-27 05:31:36	2026-07-27 05:31:36
25	12	👥	会员管理	会员信息	prompt	\N	查一下会员信息	40	2026-07-27 05:31:36	2026-07-27 05:31:36
26	12	📏	尺码缺货	缺码提醒	prompt	\N	哪些尺码缺货了	50	2026-07-27 05:31:36	2026-07-27 05:31:36
27	13	📈	销售概况	今日销售额	prompt	\N	今天的销售概况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
28	13	🔥	畅销商品	卖得最快的货	prompt	\N	最近哪些商品最畅销	20	2026-07-27 05:31:36	2026-07-27 05:31:36
29	13	🚚	补货建议	该补哪些货	prompt	\N	需要补哪些货	30	2026-07-27 05:31:36	2026-07-27 05:31:36
30	13	⏰	临期预警	快到期商品	prompt	\N	哪些商品临期了	40	2026-07-27 05:31:36	2026-07-27 05:31:36
31	14	🚚	进货登记	登记进货	prompt	\N	登记今天的进货	10	2026-07-27 05:31:36	2026-07-27 05:31:36
32	14	📦	库存查询	当前库存	prompt	\N	查一下当前库存	20	2026-07-27 05:31:36	2026-07-27 05:31:36
33	14	💰	销售统计	今日销售	prompt	\N	今天销售额多少	30	2026-07-27 05:31:36	2026-07-27 05:31:36
34	14	⏰	临期商品	临期提醒	prompt	\N	哪些商品快到期了	40	2026-07-27 05:31:36	2026-07-27 05:31:36
35	14	🎁	促销活动	当前促销	prompt	\N	现在有哪些促销	50	2026-07-27 05:31:36	2026-07-27 05:31:36
36	15	📈	营业概况	今日营收	prompt	\N	今天的营业概况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
37	15	💆	项目排行	受欢迎的项目	prompt	\N	最近哪些项目最受欢迎	20	2026-07-27 05:31:36	2026-07-27 05:31:36
38	15	📞	客户回访	待回访客户	prompt	\N	有哪些客户需要回访	30	2026-07-27 05:31:36	2026-07-27 05:31:36
39	15	🏆	员工业绩	员工业绩排行	prompt	\N	员工业绩排行怎么样	40	2026-07-27 05:31:36	2026-07-27 05:31:36
40	16	📅	预约管理	今日预约	prompt	\N	今天有哪些预约	10	2026-07-27 05:31:36	2026-07-27 05:31:36
41	16	👥	会员管理	会员信息	prompt	\N	查一下会员信息	20	2026-07-27 05:31:36	2026-07-27 05:31:36
42	16	🧾	消费记录	今日消费	prompt	\N	今天的消费记录	30	2026-07-27 05:31:36	2026-07-27 05:31:36
43	16	🏆	员工业绩	今日业绩	prompt	\N	员工今天的业绩	40	2026-07-27 05:31:36	2026-07-27 05:31:36
44	16	💳	办卡储值	新办会员	prompt	\N	帮客户办一张会员卡	50	2026-07-27 05:31:36	2026-07-27 05:31:36
45	17	📈	销售概况	今日销售	prompt	\N	今天的销售概况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
46	17	🔥	爆款商品	卖爆的商品	prompt	\N	最近哪些商品最热销	20	2026-07-27 05:31:36	2026-07-27 05:31:36
47	17	⚠️	库存预警	需补货商品	prompt	\N	哪些商品库存不足需要补货	30	2026-07-27 05:31:36	2026-07-27 05:31:36
48	17	↩️	售后情况	退款售后	prompt	\N	最近的退款和售后情况	40	2026-07-27 05:31:36	2026-07-27 05:31:36
49	18	🧾	订单管理	今日订单	prompt	\N	查一下今天的订单情况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
50	18	📦	库存查询	当前库存	prompt	\N	当前各商品库存还有多少	20	2026-07-27 05:31:36	2026-07-27 05:31:36
51	18	↩️	退款处理	待处理退款	prompt	\N	有哪些退款待处理	30	2026-07-27 05:31:36	2026-07-27 05:31:36
52	18	💬	客服消息	待回复消息	prompt	\N	有哪些客服消息需要回复	40	2026-07-27 05:31:36	2026-07-27 05:31:36
53	18	📊	数据报表	经营数据	prompt	\N	最近的经营数据报表	50	2026-07-27 05:31:36	2026-07-27 05:31:36
54	19	🎙️	语音翻译	语音转文字并翻译	prompt	\N	我想翻译一段内容，请先告诉我需要翻译成哪种语言（中文/英文/日文等），然后我来提供内容。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
1	2	📊	销售统计	每日销售报表	route	/pages/report/report?path=%2Fsales-report&title=%E9%94%80%E5%94%AE%E7%BB%9F%E8%AE%A1	\N	10	2026-07-27 05:31:36	2026-07-28 15:36:23
55	19	✍️	写文案写标题	产品文案与标题	prompt	\N	请帮我写电商产品文案和标题。请告诉我：1. 产品名称；2. 主要功能特点；3. 目标受众。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
56	19	📋	写五点描述	Amazon Bullet Points	prompt	\N	请帮我写Amazon产品五点描述（Five Bullet Points），要突出核心卖点。请提供产品名称和主要特点：	30	2026-07-27 05:31:36	2026-07-27 05:31:36
57	19	🎨	图片设计	产品图设计方案	prompt	\N	请帮我规划一套电商产品主图和详情图的设计方案，包括构图建议、文案布局、色彩搭配。请描述你的产品：	40	2026-07-27 05:31:36	2026-07-27 05:31:36
58	19	✅	文案纠错	拼写/语法检查	prompt	\N	请帮我检查以下文案的拼写错误和语法问题，并给出修改建议。请粘贴需要检查的内容：	50	2026-07-27 05:31:36	2026-07-27 05:31:36
59	19	🔍	单词侵权检测	词汇侵权风险分析	prompt	\N	请帮我分析以下词语/短语是否存在商标侵权风险（仅供参考，不构成法律意见）。请输入要检测的词语：	60	2026-07-27 05:31:36	2026-07-27 05:31:36
60	19	⚖️	品牌专利检测	商标品牌专利侵权	prompt	\N	请帮我分析以下品牌名称/商标/专利词是否可能存在侵权风险，并给出规避建议（仅供参考，不构成法律意见）。请输入要检测的内容：	70	2026-07-27 05:31:36	2026-07-27 05:31:36
61	20	📊	财报分析	解读上市公司财报	prompt	\N	请帮我做上市公司财报分析。请提供：公司名称或股票代码、报告期（如 2025 年报），我将从盈利能力、成长性、现金流、负债结构等维度解读。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
62	20	🆕	首次覆盖报告	生成首次覆盖研报	prompt	\N	请帮我撰写一份股票首次覆盖报告（Initiation Report）。请提供：标的公司、所属行业、关注要点，我将给出投资逻辑、估值与评级建议。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
63	20	🧮	DCF 估值	现金流折现建模	prompt	\N	请帮我搭建 DCF 估值模型。请提供：公司名称、近年营收/利润、增长假设、WACC（不确定可让我帮你估算）。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
64	20	⚖️	可比公司分析	可比公司估值	prompt	\N	请帮我做可比公司估值分析（Comparable Companies）。请提供：标的公司与 3-5 家可比公司，我将用 P/E、EV/EBITDA 等倍数对比。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
65	20	🏢	竞品分析	行业竞品对比	prompt	\N	请帮我做行业竞品分析。请提供：目标公司与主要竞争对手，我将从市场份额、产品、财务、护城河等维度对比。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
66	21	📑	三表建模	三大财务报表模型	prompt	\N	请帮我搭建三大财务报表联动模型（利润表/资产负债表/现金流量表）。请提供公司近 3 年财务数据与关键假设。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
67	21	💼	LBO 模型	杠杆收购建模	prompt	\N	请帮我搭建 LBO 杠杆收购模型。请提供：标的 EBITDA、收购价/估值倍数、债务结构与退出假设。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
68	21	🎤	路演 PPT	估值结论转路演材料	prompt	\N	请帮我把估值分析（可比/先例交易/LBO）整理成品牌化路演 PPT 大纲。请提供：交易标的、目标受众（买方/卖方）、核心卖点。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
69	21	🔍	市场洞察	客户与市场洞察	prompt	\N	请帮我做市场与客户洞察简报。请提供：目标行业或客户、关注议题（融资/并购/趋势），我将汇总要点。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
70	21	🤝	交易管理	交易流程跟踪	prompt	\N	请帮我梳理一笔交易的执行流程与待办清单（尽调/估值/文件/审批）。请描述交易类型与当前阶段。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
71	22	🧾	对账	基金账目对账	prompt	\N	请帮我做基金账目对账。请提供或上传两侧台账（如基金账 vs 托管账），我将逐笔比对并列出差异。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
72	22	🔎	差异追踪	追踪对账差异	prompt	\N	请帮我追踪并解释对账差异。请提供差异明细，我将分类原因（时点差/金额差/漏记）并给出处理建议。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
73	22	📐	NAV 核对	基金净值核对	prompt	\N	请帮我核对基金 NAV 净值。请提供：估值日、持仓估值、负债与份额，我将复核单位净值。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
74	22	📅	月末结账	计提与滚动结转	prompt	\N	请帮我做月末结账。请提供本期数据，我将处理费用计提、滚动结转，并生成差异说明。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
75	22	✅	LP 报表审计	分发前报表审计	prompt	\N	请帮我在分发给 LP 前审计基金报表。请上传/提供报表，我将检查勾稽关系、口径一致性与异常项。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
76	22	🔬	估值复核	GP 资料包估值复核	prompt	\N	请帮我复核投资组合估值。请提供 GP 资料包/估值底稿，我将按估值模板复核并准备 LP 报告要点。	60	2026-07-27 05:31:36	2026-07-27 05:31:36
77	23	🔭	项目寻源	标的公司发现	prompt	\N	请帮我做 PE 项目寻源。请提供：目标赛道、地域、规模/阶段标准，我将筛选并描述潜在标的画像。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
78	23	📇	创始人触达	触达话术与CRM	prompt	\N	请帮我准备创始人触达（Outreach）。请提供：目标公司/创始人与触达目的，我将拟定个性化触达话术。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
79	23	👤	客户回顾	财富客户回顾	prompt	\N	请帮我准备一次财富管理客户回顾。请提供：客户基本情况与持仓，我将梳理回顾要点与沟通建议。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
80	23	🗺️	理财规划	客户理财方案	prompt	\N	请帮我做客户理财规划。请提供：客户年龄、风险偏好、目标与可投资金额，我将给出资产配置建议。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
81	23	📊	组合分析	投资组合分析	prompt	\N	请帮我分析投资组合。请提供持仓明细，我将分析配置、风险敞口与收益归因。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
82	23	📝	客户报告	生成客户报告	prompt	\N	请帮我生成一份客户投资报告。请提供：报告期、组合表现与关注点，我将整理成可分发的客户报告。	60	2026-07-27 05:31:36	2026-07-27 05:31:36
83	24	🪪	KYC 解析	KYC 文件解析	prompt	\N	请帮我解析 KYC 文件并提取关键信息（主体、受益人、证件、风险标识）。请上传或粘贴文件内容。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
84	24	🧰	规则评估	规则网格评估	prompt	\N	请帮我按规则网格（Rules Grid）评估一笔业务的合规性。请提供业务要素与适用规则，我将逐条评估并标出风险。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
85	25	🏷️	商品标题	生成爆款标题	prompt	\N	请帮我写电商商品标题（适配淘宝/拼多多/抖音/京东）。请提供：商品名称、核心卖点、目标平台，我将给出多个高搜索权重的标题供选择。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
86	25	📝	详情文案	商品详情页文案	prompt	\N	请帮我写商品详情页文案。请提供：商品名称、主要功能/材质、适用人群，我将输出卖点排布与段落文案。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
87	25	💎	卖点提炼	提炼核心卖点	prompt	\N	请帮我提炼商品核心卖点。请提供商品信息，我将总结 3-5 个最能打动买家的卖点。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
88	25	🎨	主图设计	主图/详情图方案	prompt	\N	请帮我规划商品主图与详情图设计方案（构图、文案、配色、卖点排版）。请描述你的商品：	40	2026-07-27 05:31:36	2026-07-27 05:31:36
89	25	🎬	短视频脚本	带货短视频脚本	prompt	\N	请帮我写一条带货短视频脚本（15-60 秒，含分镜与口播）。请提供商品与卖点：	50	2026-07-27 05:31:36	2026-07-27 05:31:36
90	25	📡	直播话术	直播带货话术	prompt	\N	请帮我写直播带货话术（含引入、卖点讲解、逼单促单）。请提供商品与优惠：	60	2026-07-27 05:31:36	2026-07-27 05:31:36
91	25	📕	种草笔记	小红书种草文案	prompt	\N	请帮我写一篇小红书种草笔记（标题+正文+话题标签）。请提供商品与使用场景：	70	2026-07-27 05:31:36	2026-07-27 05:31:36
92	25	✅	文案纠错	错别字/违禁词检查	prompt	\N	请帮我检查以下电商文案的错别字、语法和违禁词，并给出修改建议。请粘贴文案：	80	2026-07-27 05:31:36	2026-07-27 05:31:36
93	26	🔑	关键词优化	搜索 SEO 关键词	prompt	\N	请帮我优化商品的搜索关键词（标题词/属性词/长尾词）。请提供商品名称与类目，我将给出关键词建议。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
94	26	🏢	竞品分析	竞品对比分析	prompt	\N	请帮我做电商竞品分析。请提供我的商品与 2-3 个竞品名称或链接，我将从价格、卖点、评价、视觉等维度对比。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
95	26	🛒	选品建议	上新选品方向	prompt	\N	请帮我做选品/上新建议。请提供：经营类目、目标人群、预算，我将给出选品方向与理由。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
96	26	💰	定价建议	商品定价策略	prompt	\N	请帮我制定商品定价策略。请提供：成本、竞品价格、目标利润，我将给出定价与促销价建议。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
97	26	🎁	活动策划	满减/优惠券方案	prompt	\N	请帮我策划一场促销活动（满减/优惠券/限时折扣）。请提供：活动目标、商品、预算，我将给出玩法与节奏。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
98	26	📣	营销文案	短信/Push/朋友圈	prompt	\N	请帮我写营销推广文案（短信/push/朋友圈）。请提供：商品、活动卖点、目标人群，我将给出多版短文案。	60	2026-07-27 05:31:36	2026-07-27 05:31:36
99	27	💬	客服回复	常见问题话术	prompt	\N	请帮我写电商客服回复话术。请描述买家的问题或场景，我将给出专业、亲和的回复模板。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
100	27	😡	差评处理	中差评回复	prompt	\N	请帮我回复一条中差评并给出挽回方案。请粘贴差评内容：	20	2026-07-27 05:31:36	2026-07-27 05:31:36
101	27	⏰	催付话术	催下单/催付款	prompt	\N	请帮我写催付/催下单话术（含优惠提醒、不让人反感）。请描述商品与当前优惠：	30	2026-07-27 05:31:36	2026-07-27 05:31:36
102	27	🔁	退换货话术	退换货沟通	prompt	\N	请帮我写退换货沟通话术，既守规则又安抚情绪。请描述退换货场景：	40	2026-07-27 05:31:36	2026-07-27 05:31:36
103	27	🙏	售后安抚	安抚情绪话术	prompt	\N	请帮我写售后安抚话术（物流慢/破损/不满意等）。请描述具体情况：	50	2026-07-27 05:31:36	2026-07-27 05:31:36
104	28	📈	销售概况	今日销售	prompt	\N	今天的销售概况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
105	28	🔥	爆款商品	卖爆的商品	prompt	\N	最近的爆款商品	20	2026-07-27 05:31:36	2026-07-27 05:31:36
106	28	⚠️	库存预警	需补货商品	prompt	\N	哪些商品需要补货	30	2026-07-27 05:31:36	2026-07-27 05:31:36
107	28	🧾	订单情况	今日订单	prompt	\N	查一下今天的订单情况	40	2026-07-27 05:31:36	2026-07-27 05:31:36
108	28	↩️	退款售后	退款情况	prompt	\N	最近的退款和售后情况	50	2026-07-27 05:31:36	2026-07-27 05:31:36
109	29	📋	作业指导书	SOP 生成	prompt	\N	请帮我编写标准作业指导书（SOP）。请提供：工序名称、操作步骤、设备与注意事项，我将整理成规范的作业指导文件。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
110	29	⚙️	工艺参数	加工参数建议	prompt	\N	请帮我推荐加工工艺参数。请提供：材料、设备/刀具、加工类型（切削/注塑/焊接等），我将给出参数建议与注意点。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
111	29	💵	报价/BOM	成本估算	prompt	\N	请帮我估算产品报价与 BOM 成本。请提供：产品规格或图纸要点、材料、批量，我将拆解材料/工时/成本。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
112	29	📖	技术问答	手册规范查询	prompt	\N	请帮我解答技术/工艺问题。请描述你的问题或粘贴相关手册/规范内容：	40	2026-07-27 05:31:36	2026-07-27 05:31:36
113	29	📏	图纸解读	图纸/规格解读	prompt	\N	请帮我解读机械图纸或技术规格。请上传图纸或描述关键尺寸/公差/材料要求：	50	2026-07-27 05:31:36	2026-07-27 05:31:36
114	30	🩺	故障诊断	设备故障排查	prompt	\N	请帮我诊断设备故障。请描述：设备类型、故障现象（报警/异响/停机等）、发生场景，我将给出可能原因与排查步骤。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
115	30	🗓️	保养计划	点检保养周期	prompt	\N	请帮我制定设备保养计划。请提供设备清单与运行情况，我将给出点检/保养项目与周期。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
116	30	📝	点检表	日常点检表生成	prompt	\N	请帮我生成设备日常点检表。请提供设备名称与关键部位，我将输出可打印的点检清单。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
117	30	🔩	备件清单	易损备件梳理	prompt	\N	请帮我梳理设备的易损件与备件清单及建议库存。请提供设备型号或类型：	40	2026-07-27 05:31:36	2026-07-27 05:31:36
118	31	📄	质检报告	检验报告生成	prompt	\N	请帮我生成质检报告。请提供：产品、检验项目与实测数据，我将整理成规范的检验报告。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
119	31	🛠️	8D 报告	质量问题 8D	prompt	\N	请帮我编写 8D 报告。请描述质量问题（现象、批次、影响），我将按 8D 步骤给出分析与纠正措施。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
120	31	🐟	根因分析	5Why/鱼骨分析	prompt	\N	请帮我做质量问题根因分析（5Why / 鱼骨图）。请描述问题现象，我将逐层追因并给出对策。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
121	31	📉	SPC 解读	过程数据分析	prompt	\N	请帮我解读 SPC 过程控制数据。请提供测量数据或控制图描述，我将判断过程是否受控并给建议。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
122	31	📞	客诉处理	客户投诉回复	prompt	\N	请帮我处理客户质量投诉。请描述客诉内容，我将给出回复话术与内部改善建议。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
123	32	🦺	隐患排查	安全隐患清单	prompt	\N	请帮我做车间安全隐患排查。请描述作业区域/设备/工序，我将列出 EHS 隐患点与整改建议。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
124	32	🧹	5S 改善	5S 现场改善	prompt	\N	请帮我做 5S 现场改善方案。请描述现场现状，我将给出整理/整顿/清扫/清洁/素养建议。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
125	32	💡	精益改善	降本增效建议	prompt	\N	请帮我做精益改善（消除浪费）。请描述工序或现状，我将识别七大浪费并给出改善方向。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
126	32	🎓	培训材料	培训/考题生成	prompt	\N	请帮我编写岗位培训材料或考试题。请提供：岗位/主题与要点，我将输出培训提纲或试题。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
127	32	🚨	应急预案	应急处置预案	prompt	\N	请帮我编写应急预案（火灾/工伤/设备事故等）。请说明场景，我将给出处置流程与责任分工。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
128	33	📈	生产概况	今日产量	prompt	\N	今天的生产概况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
129	33	📋	订单进度	订单完成度	prompt	\N	订单完成进度如何	20	2026-07-27 05:31:36	2026-07-27 05:31:36
130	33	🧱	物料库存	物料余量	prompt	\N	物料还剩多少	30	2026-07-27 05:31:36	2026-07-27 05:31:36
131	33	⚙️	设备状态	设备运行	prompt	\N	设备运行状态怎么样	40	2026-07-27 05:31:36	2026-07-27 05:31:36
132	33	🗓️	排程计划	今日排程	prompt	\N	今天的排程计划	50	2026-07-27 05:31:36	2026-07-27 05:31:36
133	34	🔎	故障诊断	症状→原因排查	prompt	\N	请帮我诊断车辆故障。请提供：车型、故障现象（异响/抖动/无法启动/仪表报警等）、出现场景，我将给出可能原因与排查步骤。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
134	34	🔢	故障码解读	OBD 故障码	prompt	\N	请帮我解读 OBD 故障码。请提供故障码（如 P0301）和车型，我将说明含义、可能原因与处理建议。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
135	34	🚨	仪表灯解读	报警灯含义	prompt	\N	请帮我解读仪表盘报警灯。请描述亮起的指示灯（颜色/图标）和车型，我将说明含义与是否可继续行驶。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
136	34	🔊	异响判断	异响部位定位	prompt	\N	请帮我判断车辆异响来源。请描述：异响类型（咔哒/嗡嗡/金属摩擦）、出现时机（刹车/转弯/过坎/加速），我将推断可能部位。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
137	35	🛠️	维修方案	维修步骤建议	prompt	\N	请帮我制定维修方案。请提供：车型、故障部位/项目，我将给出维修步骤、需更换配件与注意事项。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
138	35	🧰	保养建议	按里程保养	prompt	\N	请帮我制定保养建议。请提供：车型与当前里程，我将列出该做的保养项目（机油/三滤/刹车/正时等）。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
139	35	⏱️	工时估算	维修工时难度	prompt	\N	请帮我估算维修工时。请提供维修项目与车型，我将给出参考工时与难度等级。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
140	35	🔩	配件查询	配件型号规格	prompt	\N	请帮我查配件型号/规格。请提供：车型、年款、需要的部位（如刹车片/火花塞），我将给出常见规格与选购建议。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
141	36	📋	维修报价	工时+配件报价	prompt	\N	请帮我做维修报价单。请提供：车型、维修项目，我将拆解工时费与配件费给出报价。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
142	36	🧾	工单生成	规范维修工单	prompt	\N	请帮我生成维修工单。请提供：车牌/车型、故障描述、维修项目，我将整理成规范工单。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
143	36	🎁	保养套餐	套餐方案设计	prompt	\N	请帮我设计保养/维修套餐。请提供：目标客户与车型范围、预算，我将给出套餐内容与定价建议。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
144	37	💬	沟通话术	维修必要性解释	prompt	\N	请帮我写向客户解释维修必要性的话术。请描述维修项目与客户顾虑，我将给出通俗易懂、可信的解释。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
145	37	💰	报价解释	解释报价构成	prompt	\N	请帮我向客户解释报价为什么是这个价。请提供报价项目，我将拆解工时/配件/原因，让客户理解。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
146	37	📞	完工回访	提车/回访话术	prompt	\N	请帮我写完工提车通知与回访话术。请描述维修内容，我将给出提车通知和售后回访模板。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
147	37	😡	投诉处理	客诉回复	prompt	\N	请帮我处理客户投诉（维修后仍有问题/费用争议等）。请描述投诉内容，我将给出回复话术与处理建议。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
148	38	📈	今日营业	今日营收	prompt	\N	今天的营业概况	10	2026-07-27 05:31:36	2026-07-27 05:31:36
149	38	🧾	在修工单	进行中的工单	prompt	\N	查一下在修的工单	20	2026-07-27 05:31:36	2026-07-27 05:31:36
150	38	🚗	在修车辆	厂内车辆	prompt	\N	现在厂里有哪些在修车辆	30	2026-07-27 05:31:36	2026-07-27 05:31:36
151	38	🔩	配件库存	配件余量	prompt	\N	配件库存还有多少	40	2026-07-27 05:31:36	2026-07-27 05:31:36
152	38	💳	挂账记录	客户挂账	prompt	\N	查一下客户挂账情况	50	2026-07-27 05:31:36	2026-07-27 05:31:36
153	39	⚖️	产品对比	多款保险横向对比	prompt	\N	请帮我做保险产品对比。请提供需要对比的险种名称（如：重疾险 A vs 重疾险 B），我将从保障责任、保费、除外条款、赔付条件等维度横向对比，给出适合不同客户的建议。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
154	39	📖	条款解读	保险条款通俗解读	prompt	\N	请帮我通俗解读保险条款。请提供条款原文或险种名称，我将把晦涩的保险术语转化为客户易懂的语言，并标注关键除外责任。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
155	39	🧮	保费计算	保费/保额估算	prompt	\N	请帮我估算保费或保额。请提供：险种、被保险人年龄/性别、期望保额/保费，我将给出估算结果和性价比分析。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
156	39	📝	核保指南	核保要点提示	prompt	\N	请帮我梳理核保注意事项。请提供客户基本情况（年龄、职业、健康状况要点），我将提示可能影响核保的风险点和应对建议。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
157	39	🎯	方案设计	定制保险方案	prompt	\N	请帮我为客户设计保险方案。请提供客户基本信息（年龄/家庭/收入/已有保障），我将按需求优先级推荐险种组合和配置建议。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
158	40	💬	话术设计	开口/促成话术	prompt	\N	请帮我设计保险销售话术。请提供：场景（陌拜/转介绍/电话/微信），我将给出开场白、需求激发、产品切入和促成成交的完整话术框架。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
159	40	🙅	拒绝处理	异议处理话术	prompt	\N	请帮我处理客户拒绝。请描述客户的具体拒绝理由（如：太贵了/不需要/再考虑考虑），我将给出针对性的化解话术和跟进策略。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
160	40	👤	客户画像	潜在客户分析	prompt	\N	请帮我分析潜在保险客户画像。请提供客户基本信息（职业/年龄/家庭/收入/消费习惯），我将识别主要保障缺口并推荐切入角度。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
161	40	🔗	转介绍脚本	老客户转介绍	prompt	\N	请帮我设计转介绍话术。请描述当前客户类型与关系，我将给出自然引出、降低抵触的转介绍邀约脚本。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
162	40	📱	朋友圈文案	保险营销内容	prompt	\N	请帮我写保险营销朋友圈文案。请提供主题（如：重疾险/意外险/年金险），我将写出有共鸣感、不硬销售的推文，可直接发圈。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
163	40	🏘️	社群运营	微信群/社区运营	prompt	\N	请帮我策划保险社群运营内容。请提供：群定位（宝妈/车主/企业主），我将给出活动策划、干货话题和成交转化节奏。	60	2026-07-27 05:31:36	2026-07-27 05:31:36
164	41	🤖	AI智能客服	常见问题自动回复	prompt	\N	请帮我处理客户的保险咨询。请描述客户问题，我将给出准确、专业的解答，必要时提示需转人工的情况。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
165	41	📄	保单查询	保单信息说明	prompt	\N	请帮我解读保单内容。请提供保单关键信息，我将说明保障范围、受益人设置、生效条件等要点。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
166	41	⚕️	理赔指引	理赔材料/流程	prompt	\N	请帮我指引客户理赔。请提供险种和出险情况，我将列出所需材料清单、提交步骤和注意事项，帮客户顺利完成理赔。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
167	41	🔔	续保提醒	到期/续保话术	prompt	\N	请帮我写续保提醒内容。请提供客户类型和保单到期情况，我将给出短信/微信提醒文案和电话沟通脚本。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
168	41	💌	回访话术	服务回访脚本	prompt	\N	请帮我写保险服务回访话术。请提供：回访目的（生日关怀/理赔后/续保前），我将给出温情得体的回访脚本。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
169	42	📚	产品知识	险种知识速成	prompt	\N	请帮我讲解保险产品知识。请提供险种名称（如：终身寿险/定期寿险/医疗险），我将从产品定义、保障内容、适合人群、常见问题等角度给出系统讲解。	10	2026-07-27 05:31:36	2026-07-27 05:31:36
170	42	🎙️	话术练习	模拟销售演练	prompt	\N	请帮我做销售话术演练。请描述客户类型和场景，我扮演客户提问和质疑，帮你练习应对技巧，演练结束后给出反馈建议。	20	2026-07-27 05:31:36	2026-07-27 05:31:36
171	42	⚖️	合规培训	销售合规要点	prompt	\N	请帮我梳理保险销售合规要点。请提供关注方向（如：回访录音/条款说明/双录要求），我将给出合规操作指引和常见违规案例提示。	30	2026-07-27 05:31:36	2026-07-27 05:31:36
172	42	🗺️	职涯规划	晋升路径建议	prompt	\N	请帮我规划保险职业发展路径。请提供：当前职级/入行时间/目标，我将给出阶段目标、技能要求和晋升关键行动建议。	40	2026-07-27 05:31:36	2026-07-27 05:31:36
173	42	❓	考试题库	从业资格备考	prompt	\N	请帮我出保险从业资格考试练习题。请提供科目（如：保险原理/法律法规/险种知识），我将出题并给出详细解析。	50	2026-07-27 05:31:36	2026-07-27 05:31:36
174	43	🏆	业绩概况	我的业绩数据	prompt	\N	我的业绩概况怎么样	10	2026-07-27 05:31:36	2026-07-27 05:31:36
175	43	🎯	目标追踪	目标完成进度	prompt	\N	本月目标完成进度如何	20	2026-07-27 05:31:36	2026-07-27 05:31:36
176	43	🤝	客户跟进	待跟进名单	prompt	\N	有哪些客户需要跟进	30	2026-07-27 05:31:36	2026-07-27 05:31:36
177	43	🔔	续保到期	近期续保保单	prompt	\N	近期哪些保单要续保	40	2026-07-27 05:31:36	2026-07-27 05:31:36
178	43	💼	理赔进度	理赔情况汇总	prompt	\N	理赔进度汇总查询	50	2026-07-27 05:31:36	2026-07-27 05:31:36
181	2	📦	今日库存	实时库存总览	route	/pages/report/report?path=%2Finventory&title=%E4%BB%8A%E6%97%A5%E5%BA%93%E5%AD%98	\N	5	2026-07-28 15:36:23	2026-07-28 15:36:23
2	2	📤	上传销售报表	拍照/相册/文件 AI 识别入库	route	/pages/sales-upload/sales-upload	\N	20	2026-07-27 05:31:36	2026-07-28 15:36:23
182	5	🗑️	损耗记录	录入/查看损耗	route	/pages/damage/damage	\N	30	2026-07-28 15:36:23	2026-07-28 15:36:23
183	6	✍️	公众号写作	AI 辅助内容创作	external	https://ai.xingke888.com/gzh-rewrite	\N	50	2026-07-28 15:38:27	2026-07-28 15:38:27
184	6	💡	使用说明	了解 AI 店长能做什么	prompt	\N	你能帮我做什么	60	2026-07-28 15:38:27	2026-07-28 15:38:27
185	1	📦	今日库存	\N	route	/pages/report/report?path=%2Finventory&title=%E4%BB%8A%E6%97%A5%E5%BA%93%E5%AD%98	\N	10	2026-07-28 15:43:06	2026-07-28 15:43:06
186	1	💰	今日销售	\N	route	/pages/report/report?path=%2Fsales-report&title=%E4%BB%8A%E6%97%A5%E9%94%80%E5%94%AE	\N	20	2026-07-28 15:43:06	2026-07-28 15:43:06
187	1	🚚	进货管理	\N	route	/pages/purchase-orders/purchase-orders	\N	30	2026-07-28 15:43:06	2026-07-28 15:43:06
188	1	🗑️	损耗记录	\N	route	/pages/damage/damage	\N	40	2026-07-28 15:43:06	2026-07-28 15:43:06
189	1	📊	营运概况	\N	route	/pages/report/report?path=%2F&title=%E8%90%A5%E8%BF%90%E6%A6%82%E5%86%B5	\N	50	2026-07-28 15:43:06	2026-07-28 15:43:06
\.


--
-- Data for Name: quick_actions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quick_actions (id, key, emoji, label, badge, action_type, prompt, target_path, target_title, web_label, admin_only, store_id, enabled, sort_order, created_at, updated_at, industry, menu_template_id) FROM stdin;
8	admin	🛠️	后台管理	\N	open	\N	/admin/sso	后台管理	\N	t	\N	t	920	2026-07-27 05:31:36	2026-07-27 05:31:36	\N	\N
39	insurance-product	📋	产品工具	\N	menu	\N	\N	\N	\N	f	\N	t	45	2026-07-27 05:31:36	2026-07-27 05:31:36	insurance	1
40	insurance-sales	🚀	展业拓客	\N	menu	\N	\N	\N	\N	f	\N	t	55	2026-07-27 05:31:36	2026-07-27 05:31:36	insurance	1
41	insurance-service	🛎️	客户服务	\N	menu	\N	\N	\N	\N	f	\N	t	65	2026-07-27 05:31:36	2026-07-27 05:31:36	insurance	1
42	insurance-training	🎓	新人培训	\N	menu	\N	\N	\N	\N	f	\N	t	75	2026-07-27 05:31:36	2026-07-27 05:31:36	insurance	1
43	insurance-performance	📊	业绩管理	\N	menu	\N	\N	\N	\N	f	\N	t	85	2026-07-27 05:31:36	2026-07-27 05:31:36	insurance	1
25	ecommerce-content	✍️	内容创作	\N	menu	\N	\N	\N	\N	f	\N	t	45	2026-07-27 05:31:36	2026-07-27 05:31:36	ecommerce	2
26	ecommerce-ops	📈	运营推广	\N	menu	\N	\N	\N	\N	f	\N	t	55	2026-07-27 05:31:36	2026-07-27 05:31:36	ecommerce	2
27	ecommerce-service	🛎️	客服话术	\N	menu	\N	\N	\N	\N	f	\N	t	65	2026-07-27 05:31:36	2026-07-27 05:31:36	ecommerce	2
28	ecommerce-query	📊	经营查询	\N	menu	\N	\N	\N	\N	f	\N	t	75	2026-07-27 05:31:36	2026-07-27 05:31:36	ecommerce	2
34	auto_repair-diagnosis	🩺	故障诊断	\N	menu	\N	\N	\N	\N	f	\N	t	45	2026-07-27 05:31:36	2026-07-27 05:31:36	auto_repair	3
35	auto_repair-service	🔧	维修保养	\N	menu	\N	\N	\N	\N	f	\N	t	55	2026-07-27 05:31:36	2026-07-27 05:31:36	auto_repair	3
36	auto_repair-quote	💵	报价开单	\N	menu	\N	\N	\N	\N	f	\N	t	65	2026-07-27 05:31:36	2026-07-27 05:31:36	auto_repair	3
37	auto_repair-customer	🛎️	客户服务	\N	menu	\N	\N	\N	\N	f	\N	t	75	2026-07-27 05:31:36	2026-07-27 05:31:36	auto_repair	3
38	auto_repair-query	📊	经营查询	\N	menu	\N	\N	\N	\N	f	\N	t	85	2026-07-27 05:31:36	2026-07-27 05:31:36	auto_repair	3
20	finance-research	📈	投研分析	\N	menu	\N	\N	\N	\N	f	\N	t	50	2026-07-27 05:31:36	2026-07-27 05:31:36	finance	4
21	finance-ib	🏦	投行交易	\N	menu	\N	\N	\N	\N	f	\N	t	60	2026-07-27 05:31:36	2026-07-27 05:31:36	finance	4
22	finance-fundadmin	💰	基金行政	\N	menu	\N	\N	\N	\N	f	\N	t	70	2026-07-27 05:31:36	2026-07-27 05:31:36	finance	4
23	finance-pewm	🌱	私募与财富	\N	menu	\N	\N	\N	\N	f	\N	t	80	2026-07-27 05:31:36	2026-07-27 05:31:36	finance	4
24	finance-ops	🛡️	运营合规	\N	menu	\N	\N	\N	\N	f	\N	t	90	2026-07-27 05:31:36	2026-07-27 05:31:36	finance	4
17	cross_border-query	📊	经营查询	\N	menu	\N	\N	\N	\N	f	\N	t	50	2026-07-27 05:31:36	2026-07-27 05:31:36	cross_border	5
18	cross_border-manage	🛠️	日常管理	\N	menu	\N	\N	\N	\N	f	\N	t	60	2026-07-27 05:31:36	2026-07-27 05:31:36	cross_border	5
19	cross_border-aitools	🤖	AI工具	\N	menu	\N	\N	\N	\N	f	\N	t	40	2026-07-27 05:31:36	2026-07-27 05:31:36	cross_border	5
29	manufacturing-process	📐	工艺文档	\N	menu	\N	\N	\N	\N	f	\N	t	45	2026-07-27 05:31:36	2026-07-27 05:31:36	manufacturing	6
30	manufacturing-equipment	🔧	设备运维	\N	menu	\N	\N	\N	\N	f	\N	t	55	2026-07-27 05:31:36	2026-07-27 05:31:36	manufacturing	6
31	manufacturing-quality	🔍	质量管理	\N	menu	\N	\N	\N	\N	f	\N	t	65	2026-07-27 05:31:36	2026-07-27 05:31:36	manufacturing	6
32	manufacturing-safety	🛡️	安全精益	\N	menu	\N	\N	\N	\N	f	\N	t	75	2026-07-27 05:31:36	2026-07-27 05:31:36	manufacturing	6
33	manufacturing-query	📊	生产查询	\N	menu	\N	\N	\N	\N	f	\N	t	85	2026-07-27 05:31:36	2026-07-27 05:31:36	manufacturing	6
15	beauty-query	📊	经营查询	\N	menu	\N	\N	\N	\N	f	\N	t	50	2026-07-27 05:31:36	2026-07-27 05:31:36	beauty	7
16	beauty-manage	🛠️	日常管理	\N	menu	\N	\N	\N	\N	f	\N	t	60	2026-07-27 05:31:36	2026-07-27 05:31:36	beauty	7
9	restaurant-query	📊	经营查询	\N	menu	\N	\N	\N	\N	f	\N	t	50	2026-07-27 05:31:36	2026-07-27 05:31:36	restaurant	8
10	restaurant-manage	🛠️	日常管理	\N	menu	\N	\N	\N	\N	f	\N	t	60	2026-07-27 05:31:36	2026-07-27 05:31:36	restaurant	8
1	home	🏠	主页	\N	shortcuts	\N		\N	\N	f	\N	t	1	2026-07-27 05:31:36	2026-07-28 15:43:06	\N	\N
6	report	📊	经营查询	\N	menu	\N	\N	\N	\N	f	\N	t	30	2026-07-27 05:31:36	2026-07-27 05:31:36	fresh	9
13	convenience-query	📊	经营查询	\N	menu	\N	\N	\N	\N	f	\N	t	50	2026-07-27 05:31:36	2026-07-27 05:31:36	convenience	10
14	convenience-manage	🛠️	日常管理	\N	menu	\N	\N	\N	\N	f	\N	t	60	2026-07-27 05:31:36	2026-07-27 05:31:36	convenience	10
11	apparel-query	📊	经营查询	\N	menu	\N	\N	\N	\N	f	\N	t	50	2026-07-27 05:31:36	2026-07-27 05:31:36	apparel	11
12	apparel-manage	🛠️	日常管理	\N	menu	\N	\N	\N	\N	f	\N	t	60	2026-07-27 05:31:36	2026-07-27 05:31:36	apparel	11
2	inventory	📦	今日汇总	\N	menu	\N			\N	f	\N	t	10	2026-07-27 05:31:36	2026-07-28 15:36:23	fresh	9
5	purchase	🚚	进货损耗	\N	menu	\N	\N	\N	\N	f	\N	t	28	2026-07-27 05:31:36	2026-07-28 15:36:23	fresh	9
3	sales	💰	今日销售	\N	menu	\N	\N	\N	\N	f	\N	f	20	2026-07-27 05:31:36	2026-07-28 15:36:23	fresh	9
4	damage	🗑️	损耗记录	\N	route	\N	/pages/damage/damage	\N	\N	f	\N	f	25	2026-07-27 05:31:36	2026-07-28 15:36:23	fresh	9
7	help	💡	使用说明	\N	prompt	你能帮我做什么	\N	\N	\N	f	\N	f	910	2026-07-27 05:31:36	2026-07-28 15:38:27	\N	\N
44	gzh_rewrite	✍️	公众号写作	\N	external_open	\N	https://ai.xingke888.com/gzh-rewrite	公众号写作	\N	f	\N	f	100	2026-07-27 06:45:23	2026-07-28 15:38:27	\N	\N
\.


--
-- Data for Name: regions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.regions (id, organization_id, parent_id, name, code, manager_user_id, created_at, updated_at, deleted_at) FROM stdin;
1	1	\N	香港	HK	\N	2026-07-27 05:31:36	2026-07-27 05:31:36	\N
\.


--
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reports (id, organization_id, store_id, report_type, title, period_start, period_end, content, data_snapshot, ai_analysis, charts_config, status, is_auto_generated, generated_by, generated_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: resumes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.resumes (id, organization_id, name, phone, gender, age, districts, work_types, positions, experience_years, salary_min, salary_max, salary_unit, education, availability_date, languages, skills, raw_text, source, status, notes, created_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (role_id, permission_id, created_at) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, organization_id, name, code, description, scope, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: saas_integrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.saas_integrations (id, organization_id, store_id, platform, app_id, app_secret, access_token, token_expires_at, webhook_url, config, status, last_sync_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: salary_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.salary_records (id, employee_id, store_id, year, month, work_days, actual_work_days, base_salary, overtime_pay, performance_bonus, sales_commission, deductions, social_insurance, income_tax, gross_salary, net_salary, payment_status, paid_at, notes, generated_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sales_daily_summaries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_daily_summaries (id, store_id, product_id, sale_date, sales_qty, sales_amount, transaction_count, avg_selling_price, created_at, updated_at, pos_qty, pos_amount, supplement_qty, supplement_amount, ai_qty, ai_amount) FROM stdin;
\.


--
-- Data for Name: sales_order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_order_items (id, sales_order_id, product_id, qty, unit_price, discount_amount, subtotal, cost_price, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sales_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_orders (id, store_id, order_no, cashier_id, total_amount, discount_amount, paid_amount, payment_method, status, sold_at, notes, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sales_uploads; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_uploads (id, store_id, uploaded_by, original_filename, file_path, sale_date, status, total_items, processed_items, failed_items, error_message, raw_rows, ai_result, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schedules (id, store_id, employee_id, schedule_date, shift_start, shift_end, shift_type, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
NRsT8rzNfATPDQnL4iqMA4wTF4I3eQqjvR5b4HNT	\N	162.158.167.120	curl/8.18.0	YTozOntzOjY6Il90b2tlbiI7czo0MDoicDRMbklwam01YmxkSTZyU3ZRT285cWNRWExTNURSc3k1T0lkenJYTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzk6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hZG1pbi9sb2dpbiI7czo1OiJyb3V0ZSI7czoyNToiZmlsYW1lbnQuYWRtaW4uYXV0aC5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1785101613
uV1tnjbhvQCVvIJhHah730ZxGkY0TxUowpxKxGmY	\N	162.158.210.64	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36	YTo0OntzOjY6Il90b2tlbiI7czo0MDoiVm1oNzJmQ2NFNFU3UXZzb2duWXZQeTk3Ym5SR3ZkQ2FWVlY3a3hRYiI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozMzoiaHR0cHM6Ly9hcHA2MS54aW5na2U4ODguY29tL2FkbWluIjt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hZG1pbiI7czo1OiJyb3V0ZSI7czozMDoiZmlsYW1lbnQuYWRtaW4ucGFnZXMuZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785101796
3jaN953a1r319LdjyrF3bynkNMFpmJJUmJdA5aR7	\N	162.158.210.64	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	YTo0OntzOjY6Il90b2tlbiI7czo0MDoieGN5ZEQyYU5tQ1lWUlZTanpyenRkYjJlZWg4MzhvS1RZaWxQM0cxMSI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozMzoiaHR0cHM6Ly9hcHA2MS54aW5na2U4ODguY29tL2FkbWluIjt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hZG1pbiI7czo1OiJyb3V0ZSI7czozMDoiZmlsYW1lbnQuYWRtaW4ucGFnZXMuZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785101796
WK8ZRCksCFH60hLGMZ5BIKENSCqkaqHlpCgAKqQh	\N	162.158.210.64	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0	YTo0OntzOjY6Il90b2tlbiI7czo0MDoiQjRERTBHTUpZY3NQM1QyRDJ2SzZxR3J3VElNNkxJYnEzMWpnMVFBWCI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozMzoiaHR0cHM6Ly9hcHA2MS54aW5na2U4ODguY29tL2FkbWluIjt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hZG1pbiI7czo1OiJyb3V0ZSI7czozMDoiZmlsYW1lbnQuYWRtaW4ucGFnZXMuZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785101797
W1tceljfZVnLGbYiEbhBndLXq7dYZzuMFjcEjLNB	\N	162.158.210.64	Go-http-client/2.0	YTo0OntzOjY6Il90b2tlbiI7czo0MDoieFBQdDZEY2J1aXhNWDFZZnMyejlEUTNZTktMRlBXb0EzMnI4cVE1ZSI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozMzoiaHR0cHM6Ly9hcHA2MS54aW5na2U4ODguY29tL2FkbWluIjt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hZG1pbiI7czo1OiJyb3V0ZSI7czozMDoiZmlsYW1lbnQuYWRtaW4ucGFnZXMuZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785101798
75V7LMiw9VJijsCW6nbrICmv8Wtg7RPGAVxri0SH	9	172.71.159.64	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	YToyOntzOjY6Il90b2tlbiI7czo0MDoiVkpPOVdFRmUweTc0b0h0YlFYczBXU0FjMHVIQjFTbUdicG9ibVRwbiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785104535
aKvQOf6D3kufo7NUZC0JcnV1BcNriWjmx5WBxUNe	11	172.71.154.167	Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1 wechatdevtools/2.01.2510290 MicroMessenger/8.0.5 Language/zh_CN webview/5065_4 webdebugger  miniprogramhtmlwebview miniProgram port/44238 messageProjectId/0	YTozOntzOjY6Il90b2tlbiI7czo0MDoiUmd1M0lKZ0RzeVY5MHowSEdHSVB1MExqSjhBU0hFd2VGSDJvOEZwYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NzA6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hcGkvaW52ZW50b3J5L3RyYW5zYWN0aW9ucz9kYXRlPTIwMjYtMDctMjciO3M6NToicm91dGUiO3M6Mjc6ImdlbmVyYXRlZDo6amZGUk9zUTVSTnc2ODhWSCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1785109824
vYVgG2S1339TXMXSabgB0a6nlkQBX2ir3yefJvm4	9	104.22.20.58	Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1 wechatdevtools/2.01.2510290 MicroMessenger/8.0.5 Language/zh_CN webview/23444_9 webdebugger  miniprogramhtmlwebview miniProgram port/44238 messageProjectId/0	YTozOntzOjY6Il90b2tlbiI7czo0MDoiSkh6ck4xblMzbWZ4NFZvd3loMHNNbEVkZVRmZUVZdWFTTWlreE1iNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NjA6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hcGkvc2FsZXMvcmVwb3J0P2RhdGU9MjAyNi0wNy0yNyI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpxOGJscXFwaE9lNzNWVlE3Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785105167
CDCWmzzjPWhmwKlLl3pQUm5ITK1oAsnH8wfX3FT9	\N	162.158.166.220	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	YTo0OntzOjY6Il90b2tlbiI7czo0MDoiMWlXYW5YMklobzFVVFNHOE14Q2NFRUx2VjBBbmc4eEJPN0N3cTIwNyI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozMzoiaHR0cHM6Ly9hcHA2MS54aW5na2U4ODguY29tL2FkbWluIjt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzk6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hZG1pbi9sb2dpbiI7czo1OiJyb3V0ZSI7czoyNToiZmlsYW1lbnQuYWRtaW4uYXV0aC5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1785141127
lSex9o1DAr71s5TRjOWyIbNex1AAY6GTe7wMSCk7	11	172.70.207.128	Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1 wechatdevtools/2.02.2607271 MicroMessenger/8.0.5 Language/zh_CN webview/13729_47 webdebugger  miniprogramhtmlwebview miniProgram proxyPort/49711	YTozOntzOjY6Il90b2tlbiI7czo0MDoiVGluc05SYUdqUG1hNGdUNGRFb0FjVG5RVXk2UTFyTGNnMmxERDYyNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NzA6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hcGkvaW52ZW50b3J5L3RyYW5zYWN0aW9ucz9kYXRlPTIwMjYtMDctMjgiO3M6NToicm91dGUiO3M6Mjc6ImdlbmVyYXRlZDo6amZGUk9zUTVSTnc2ODhWSCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1785196071
X7EhPAfXtmY1OpfwApNj7ugd6jAmgcO9aWsIQSrR	11	162.158.186.169	Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1 wechatdevtools/2.02.2607271 MicroMessenger/8.0.5 Language/zh_CN webview/10319_41 webdebugger  miniprogramhtmlwebview miniProgram proxyPort/64939	YTozOntzOjY6Il90b2tlbiI7czo0MDoicU9CbnVnS1l0NFhNNElBUEJSY3ZJYk1XZ0tmd0JHaTVmZ1Y2T1JLNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NjA6Imh0dHBzOi8vYXBwNjEueGluZ2tlODg4LmNvbS9hcGkvc2FsZXMvcmVwb3J0P2RhdGU9MjAyNi0wNy0yOCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785198228
XG4vU5HpLlfkQAOXHOJtoY6lFqoHs1bEsfBZBTS2	\N	127.0.0.1	curl/8.18.0	YTozOntzOjY6Il90b2tlbiI7czo0MDoiSUx4YXo5OHdBYmgzMFNPekZrZFpwQ1VYQ2FiUXJKWWVveDN3VWxsMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODMwMyI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785206964
qo2roFcGlLcILsJN3T8vYofoU76NqHlq1doGX9MC	11	104.23.166.83	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	YTozOntzOjY6Il90b2tlbiI7czo0MDoiczBudTllVFRUN2hHemlrbGg0a1VCS1VUZWZTV1VHRXdIZ2xaTGZMQSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDM6Imh0dHBzOi8vYXBwNTEueGluZ2tlODg4LmNvbS9hcGkvc3VnZ2VzdGlvbnMiO3M6NToicm91dGUiO047fX0=	1785221759
n0gFXSpxvHg8vPA4lbFpNVTL07OOkk7XgkdulAW9	11	162.158.178.181	Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1 wechatdevtools/2.02.2607271 MicroMessenger/8.0.5 Language/zh_CN webview/20355_223 webdebugger  miniprogramhtmlwebview miniProgram proxyPort/64939	YTozOntzOjY6Il90b2tlbiI7czo0MDoiUnhqcHF5UFhrTjV1bnA3VThWQmFqNjNHS2d5YUdGbXgzbks2dVdKRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NjA6Imh0dHBzOi8vYXBwNTEueGluZ2tlODg4LmNvbS9hcGkvc2FsZXMvcmVwb3J0P2RhdGU9MjAyNi0wNy0yOCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1785229425
\.


--
-- Data for Name: sso_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sso_users (id, sso_user_id, user_id, created_at, updated_at) FROM stdin;
1	32	9	2026-07-27 06:15:18	2026-07-27 06:15:18
2	33	10	2026-07-27 06:16:57	2026-07-27 06:16:57
3	21	11	2026-07-27 06:58:24	2026-07-27 06:58:24
4	34	13	2026-07-27 07:36:13	2026-07-27 07:36:13
\.


--
-- Data for Name: stores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stores (id, organization_id, region_id, name, code, address, province, city, district, latitude, longitude, manager_user_id, business_hours, status, settings, opened_at, created_at, updated_at, deleted_at) FROM stdin;
1	1	1	西湾河店	XWH	西湾河筲箕湾道 18 号地铺	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	2026-07-27 05:31:36	2026-07-27 05:31:36	\N
\.


--
-- Data for Name: supplier_products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.supplier_products (id, supplier_id, product_id, supplier_product_code, purchase_price, min_order_qty, delivery_lead_days, is_primary, price_effective_date, price_expired_date, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: supplier_refund_claim_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.supplier_refund_claim_items (id, claim_id, damage_record_id, product_id, product_name, qty, unit_cost, claimed_amount, purchase_order_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: supplier_refund_claims; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.supplier_refund_claims (id, store_id, supplier_id, claim_no, status, total_items, total_qty, total_amount, submitted_at, resolved_at, notes, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.suppliers (id, organization_id, name, code, contact_name, contact_phone, contact_wechat, address, business_license, payment_terms, payment_days, delivery_lead_days, rating, status, notes, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: user_store_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_store_roles (id, user_id, store_id, region_id, role_id, granted_by, granted_at, expired_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, is_admin, username) FROM stdin;
1	Demo User	demo@example.com	2026-07-27 05:31:35	$2y$12$N61lsrmspyt77MLhUl62lOXQL8ulTNMfREQTY8oLwFtXctRc2gACG	qJ5mgdIwGn	2026-07-27 05:31:36	2026-07-27 05:31:36	f	\N
2	Evans Nitzsche	dschulist@example.net	2026-07-27 05:31:36	$2y$12$N61lsrmspyt77MLhUl62lOXQL8ulTNMfREQTY8oLwFtXctRc2gACG	6d9ELaUBJ6	2026-07-27 05:31:36	2026-07-27 05:31:36	f	\N
3	Hortense Hill	travon13@example.org	2026-07-27 05:31:36	$2y$12$N61lsrmspyt77MLhUl62lOXQL8ulTNMfREQTY8oLwFtXctRc2gACG	02D4WA36f5	2026-07-27 05:31:36	2026-07-27 05:31:36	f	\N
4	Alexandria McClure	helga.leuschke@example.net	2026-07-27 05:31:36	$2y$12$N61lsrmspyt77MLhUl62lOXQL8ulTNMfREQTY8oLwFtXctRc2gACG	v3iXtsQzff	2026-07-27 05:31:36	2026-07-27 05:31:36	f	\N
5	General Mann	schmeler.gabrielle@example.net	2026-07-27 05:31:36	$2y$12$N61lsrmspyt77MLhUl62lOXQL8ulTNMfREQTY8oLwFtXctRc2gACG	N6Yvg4G4aT	2026-07-27 05:31:36	2026-07-27 05:31:36	f	\N
6	Prof. Judson Ward	jhane@example.org	2026-07-27 05:31:36	$2y$12$N61lsrmspyt77MLhUl62lOXQL8ulTNMfREQTY8oLwFtXctRc2gACG	6uY19wJ8wE	2026-07-27 05:31:36	2026-07-27 05:31:36	f	\N
7	Admin	admin@app61.xingke888.com	\N	$2y$12$THmFtuSbDMakAKFYXGjAmeOuVSo2K74LkxuDjeO4RANLn5QCjUFEi	\N	2026-07-27 05:31:52	2026-07-27 05:31:52	t	admin
8	Test User	test@app61.xingke888.com	\N	$2y$12$3YoaUcWu0b.HI0ZOL3PhzOsbuHnoRuSES8xYVlu6AAHn5U1jRee5y	\N	2026-07-27 06:10:25	2026-07-27 06:10:25	f	testuser
9	david	32@sso.local	\N	$2y$12$JqaaT7B21QETCDOgM.G5J.6bd6GVAHbsVeMm/e27rl4VFa1I62fr.	\N	2026-07-27 06:15:18	2026-07-27 06:15:18	f	david
10	regtest1	33@sso.local	\N	$2y$12$dAWkfydA9Q0a.feqN8ZMTeGz2QJhqqOU4d21J4FWUAJ2UXlj0jazu	\N	2026-07-27 06:16:57	2026-07-27 06:16:57	f	regtest1
11	aaa1	21@sso.local	\N	$2y$12$XxB4mPT.0IBesDZLPKpjFeJoh7f69Q36dU1z4e6EbcDCeQTArXu1q	\N	2026-07-27 06:58:24	2026-07-27 06:58:24	f	aaa1
12	probe	probe_reg_test@example.com	\N	$2y$12$ZnWV85Kzotm37BKoRDVMxuC4JZVXJDhYsRoBRhjEuXTdiotHdmZNa	\N	2026-07-27 07:34:14	2026-07-27 07:34:14	f	probe_reg_test
13	regtest2	34@sso.local	\N	$2y$12$cCFp9V1C4qbOmSNSGG2UVut81eGb1.8dHnGjtJe0yA7lL.OqnY2ju	\N	2026-07-27 07:36:13	2026-07-27 07:36:13	f	regtest2
\.


--
-- Data for Name: weather_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.weather_logs (id, store_id, date, city, weather, temperature_high, temperature_low, humidity, rain_probability, uv_index, description, created_at, updated_at) FROM stdin;
1	1	2026-07-28	香港	多云转阵雨	32	27	80	60	8	炎热潮湿，午后可能有阵雨，注意防晒，生鲜商品需防潮保鲜	2026-07-28 14:55:50	2026-07-28 14:55:50
\.


--
-- Data for Name: wework_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wework_users (id, user_id, wework_userid, wework_openid, department_ids, bound_at) FROM stdin;
\.


--
-- Name: ai_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ai_messages_id_seq', 68, true);


--
-- Name: ai_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ai_sessions_id_seq', 28, true);


--
-- Name: app_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.app_settings_id_seq', 3, true);


--
-- Name: attendance_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attendance_records_id_seq', 1, false);


--
-- Name: chat_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.chat_logs_id_seq', 1, false);


--
-- Name: competitor_hot_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.competitor_hot_products_id_seq', 1, false);


--
-- Name: competitor_price_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.competitor_price_records_id_seq', 1, false);


--
-- Name: competitor_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.competitor_products_id_seq', 1, false);


--
-- Name: competitors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.competitors_id_seq', 1, false);


--
-- Name: custom_report_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.custom_report_templates_id_seq', 1, false);


--
-- Name: customer_follow_ups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_follow_ups_id_seq', 1, false);


--
-- Name: customer_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_order_items_id_seq', 1, false);


--
-- Name: customer_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_orders_id_seq', 1, false);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_id_seq', 1, false);


--
-- Name: daily_operation_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.daily_operation_logs_id_seq', 38, true);


--
-- Name: damage_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.damage_records_id_seq', 1, false);


--
-- Name: dashboard_configs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dashboard_configs_id_seq', 1, false);


--
-- Name: employee_store_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employee_store_history_id_seq', 1, false);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employees_id_seq', 1, false);


--
-- Name: expense_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.expense_categories_id_seq', 1, false);


--
-- Name: expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.expenses_id_seq', 1, false);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: industries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.industries_id_seq', 12, true);


--
-- Name: intelligence_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.intelligence_reports_id_seq', 1, false);


--
-- Name: inventory_daily_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_daily_snapshots_id_seq', 1, false);


--
-- Name: inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_id_seq', 1, false);


--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_transactions_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: leave_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.leave_requests_id_seq', 1, false);


--
-- Name: menu_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.menu_templates_id_seq', 11, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 61, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organizations_id_seq', 1, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permissions_id_seq', 1, false);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 26, true);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.posts_id_seq', 22, true);


--
-- Name: product_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_categories_id_seq', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 1, false);


--
-- Name: promotion_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promotion_items_id_seq', 1, false);


--
-- Name: promotion_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promotion_reviews_id_seq', 1, false);


--
-- Name: promotion_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promotion_rules_id_seq', 1, false);


--
-- Name: promotions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promotions_id_seq', 1, false);


--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_order_items_id_seq', 1, false);


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_orders_id_seq', 1, false);


--
-- Name: quick_action_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quick_action_items_id_seq', 189, true);


--
-- Name: quick_actions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quick_actions_id_seq', 44, true);


--
-- Name: regions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.regions_id_seq', 1, true);


--
-- Name: reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reports_id_seq', 1, false);


--
-- Name: resumes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.resumes_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 1, false);


--
-- Name: saas_integrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.saas_integrations_id_seq', 1, false);


--
-- Name: salary_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.salary_records_id_seq', 1, false);


--
-- Name: sales_daily_summaries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_daily_summaries_id_seq', 1, false);


--
-- Name: sales_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_order_items_id_seq', 1, false);


--
-- Name: sales_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_orders_id_seq', 1, false);


--
-- Name: sales_uploads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_uploads_id_seq', 1, false);


--
-- Name: schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.schedules_id_seq', 1, false);


--
-- Name: sso_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sso_users_id_seq', 4, true);


--
-- Name: stores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stores_id_seq', 1, true);


--
-- Name: supplier_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.supplier_products_id_seq', 1, false);


--
-- Name: supplier_refund_claim_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.supplier_refund_claim_items_id_seq', 1, false);


--
-- Name: supplier_refund_claims_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.supplier_refund_claims_id_seq', 1, false);


--
-- Name: suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.suppliers_id_seq', 1, false);


--
-- Name: user_store_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_store_roles_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- Name: weather_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.weather_logs_id_seq', 1, true);


--
-- Name: wework_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wework_users_id_seq', 1, false);


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
-- Name: attendance_records attendance_records_employee_id_work_date_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_employee_id_work_date_unique UNIQUE (employee_id, work_date);


--
-- Name: attendance_records attendance_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_pkey PRIMARY KEY (id);


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
-- Name: competitor_hot_products competitor_hot_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_hot_products
    ADD CONSTRAINT competitor_hot_products_pkey PRIMARY KEY (id);


--
-- Name: competitor_price_records competitor_price_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_price_records
    ADD CONSTRAINT competitor_price_records_pkey PRIMARY KEY (id);


--
-- Name: competitor_products competitor_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_products
    ADD CONSTRAINT competitor_products_pkey PRIMARY KEY (id);


--
-- Name: competitors competitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitors
    ADD CONSTRAINT competitors_pkey PRIMARY KEY (id);


--
-- Name: custom_report_templates custom_report_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_report_templates
    ADD CONSTRAINT custom_report_templates_pkey PRIMARY KEY (id);


--
-- Name: customer_follow_ups customer_follow_ups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_follow_ups
    ADD CONSTRAINT customer_follow_ups_pkey PRIMARY KEY (id);


--
-- Name: customer_order_items customer_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_items
    ADD CONSTRAINT customer_order_items_pkey PRIMARY KEY (id);


--
-- Name: customer_orders customer_orders_order_no_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders
    ADD CONSTRAINT customer_orders_order_no_unique UNIQUE (order_no);


--
-- Name: customer_orders customer_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders
    ADD CONSTRAINT customer_orders_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: daily_operation_logs daily_operation_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_operation_logs
    ADD CONSTRAINT daily_operation_logs_pkey PRIMARY KEY (id);


--
-- Name: damage_records damage_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_records
    ADD CONSTRAINT damage_records_pkey PRIMARY KEY (id);


--
-- Name: dashboard_configs dashboard_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_configs
    ADD CONSTRAINT dashboard_configs_pkey PRIMARY KEY (id);


--
-- Name: employee_store_history employee_store_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_store_history
    ADD CONSTRAINT employee_store_history_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: expense_categories expense_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_pkey PRIMARY KEY (id);


--
-- Name: expenses expenses_expense_no_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_expense_no_unique UNIQUE (expense_no);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


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
-- Name: intelligence_reports intelligence_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intelligence_reports
    ADD CONSTRAINT intelligence_reports_pkey PRIMARY KEY (id);


--
-- Name: inventory_daily_snapshots inventory_daily_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_daily_snapshots
    ADD CONSTRAINT inventory_daily_snapshots_pkey PRIMARY KEY (id);


--
-- Name: inventory_daily_snapshots inventory_daily_snapshots_store_id_product_id_date_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_daily_snapshots
    ADD CONSTRAINT inventory_daily_snapshots_store_id_product_id_date_unique UNIQUE (store_id, product_id, date);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (id);


--
-- Name: inventory inventory_store_id_product_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_store_id_product_id_unique UNIQUE (store_id, product_id);


--
-- Name: inventory_transactions inventory_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (id);


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
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


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
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: promotion_items promotion_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_items
    ADD CONSTRAINT promotion_items_pkey PRIMARY KEY (id);


--
-- Name: promotion_reviews promotion_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_reviews
    ADD CONSTRAINT promotion_reviews_pkey PRIMARY KEY (id);


--
-- Name: promotion_rules promotion_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rules
    ADD CONSTRAINT promotion_rules_pkey PRIMARY KEY (id);


--
-- Name: promotions promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);


--
-- Name: purchase_order_items purchase_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_order_no_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_order_no_unique UNIQUE (order_no);


--
-- Name: purchase_orders purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


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
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: resumes resumes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resumes
    ADD CONSTRAINT resumes_pkey PRIMARY KEY (id);


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
-- Name: salary_records salary_records_employee_id_year_month_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_records
    ADD CONSTRAINT salary_records_employee_id_year_month_unique UNIQUE (employee_id, year, month);


--
-- Name: salary_records salary_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_records
    ADD CONSTRAINT salary_records_pkey PRIMARY KEY (id);


--
-- Name: sales_daily_summaries sales_daily_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_daily_summaries
    ADD CONSTRAINT sales_daily_summaries_pkey PRIMARY KEY (id);


--
-- Name: sales_daily_summaries sales_daily_summaries_store_id_product_id_sale_date_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_daily_summaries
    ADD CONSTRAINT sales_daily_summaries_store_id_product_id_sale_date_unique UNIQUE (store_id, product_id, sale_date);


--
-- Name: sales_order_items sales_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_pkey PRIMARY KEY (id);


--
-- Name: sales_orders sales_orders_order_no_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_order_no_unique UNIQUE (order_no);


--
-- Name: sales_orders sales_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_pkey PRIMARY KEY (id);


--
-- Name: sales_uploads sales_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_uploads
    ADD CONSTRAINT sales_uploads_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_store_id_employee_id_schedule_date_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_store_id_employee_id_schedule_date_unique UNIQUE (store_id, employee_id, schedule_date);


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
-- Name: supplier_products supplier_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_products
    ADD CONSTRAINT supplier_products_pkey PRIMARY KEY (id);


--
-- Name: supplier_refund_claim_items supplier_refund_claim_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claim_items
    ADD CONSTRAINT supplier_refund_claim_items_pkey PRIMARY KEY (id);


--
-- Name: supplier_refund_claims supplier_refund_claims_claim_no_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claims
    ADD CONSTRAINT supplier_refund_claims_claim_no_unique UNIQUE (claim_no);


--
-- Name: supplier_refund_claims supplier_refund_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claims
    ADD CONSTRAINT supplier_refund_claims_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


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
-- Name: attendance_records_store_id_work_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attendance_records_store_id_work_date_index ON public.attendance_records USING btree (store_id, work_date);


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
-- Name: competitor_hot_products_competitor_id_identified_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitor_hot_products_competitor_id_identified_date_index ON public.competitor_hot_products USING btree (competitor_id, identified_date);


--
-- Name: competitor_price_records_collected_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitor_price_records_collected_at_index ON public.competitor_price_records USING btree (collected_at);


--
-- Name: competitor_products_competitor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitor_products_competitor_id_index ON public.competitor_products USING btree (competitor_id);


--
-- Name: competitor_products_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitor_products_product_id_index ON public.competitor_products USING btree (product_id);


--
-- Name: competitors_organization_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitors_organization_id_status_index ON public.competitors USING btree (organization_id, status);


--
-- Name: cpr_competitor_product_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cpr_competitor_product_date ON public.competitor_price_records USING btree (competitor_id, product_id, collected_at);


--
-- Name: cpr_product_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cpr_product_date ON public.competitor_price_records USING btree (product_id, collected_at);


--
-- Name: custom_report_templates_organization_id_is_shared_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX custom_report_templates_organization_id_is_shared_index ON public.custom_report_templates USING btree (organization_id, is_shared);


--
-- Name: customer_follow_ups_store_id_follow_up_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_follow_ups_store_id_follow_up_at_index ON public.customer_follow_ups USING btree (store_id, follow_up_at);


--
-- Name: customer_follow_ups_store_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_follow_ups_store_id_index ON public.customer_follow_ups USING btree (store_id);


--
-- Name: customer_order_items_customer_order_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_order_items_customer_order_id_index ON public.customer_order_items USING btree (customer_order_id);


--
-- Name: customer_orders_customer_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_orders_customer_id_index ON public.customer_orders USING btree (customer_id);


--
-- Name: customer_orders_store_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_orders_store_id_index ON public.customer_orders USING btree (store_id);


--
-- Name: customer_orders_store_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_orders_store_id_status_index ON public.customer_orders USING btree (store_id, status);


--
-- Name: customers_phone_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_phone_index ON public.customers USING btree (phone);


--
-- Name: customers_store_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_store_id_index ON public.customers USING btree (store_id);


--
-- Name: customers_store_id_phone_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_store_id_phone_index ON public.customers USING btree (store_id, phone);


--
-- Name: customers_store_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_store_id_status_index ON public.customers USING btree (store_id, status);


--
-- Name: daily_operation_logs_store_id_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX daily_operation_logs_store_id_date_index ON public.daily_operation_logs USING btree (store_id, date);


--
-- Name: damage_records_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX damage_records_product_id_index ON public.damage_records USING btree (product_id);


--
-- Name: damage_records_purchase_order_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX damage_records_purchase_order_item_id_index ON public.damage_records USING btree (purchase_order_item_id);


--
-- Name: damage_records_store_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX damage_records_store_id_index ON public.damage_records USING btree (store_id);


--
-- Name: damage_records_supplier_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX damage_records_supplier_id_index ON public.damage_records USING btree (supplier_id);


--
-- Name: dashboard_configs_store_id_scope_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dashboard_configs_store_id_scope_index ON public.dashboard_configs USING btree (store_id, scope);


--
-- Name: dashboard_configs_user_id_is_default_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dashboard_configs_user_id_is_default_index ON public.dashboard_configs USING btree (user_id, is_default);


--
-- Name: employee_store_history_employee_id_effective_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employee_store_history_employee_id_effective_date_index ON public.employee_store_history USING btree (employee_id, effective_date);


--
-- Name: employees_current_store_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employees_current_store_id_status_index ON public.employees USING btree (current_store_id, status);


--
-- Name: employees_employee_no_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employees_employee_no_index ON public.employees USING btree (employee_no);


--
-- Name: employees_organization_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employees_organization_id_status_index ON public.employees USING btree (organization_id, status);


--
-- Name: employees_phone_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employees_phone_index ON public.employees USING btree (phone);


--
-- Name: expense_categories_organization_id_parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX expense_categories_organization_id_parent_id_index ON public.expense_categories USING btree (organization_id, parent_id);


--
-- Name: expenses_category_id_expense_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX expenses_category_id_expense_date_index ON public.expenses USING btree (category_id, expense_date);


--
-- Name: expenses_payment_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX expenses_payment_status_index ON public.expenses USING btree (payment_status);


--
-- Name: expenses_store_id_expense_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX expenses_store_id_expense_date_index ON public.expenses USING btree (store_id, expense_date);


--
-- Name: expenses_supplier_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX expenses_supplier_id_index ON public.expenses USING btree (supplier_id);


--
-- Name: industries_enabled_sort_order_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX industries_enabled_sort_order_index ON public.industries USING btree (enabled, sort_order);


--
-- Name: inv_tx_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inv_tx_reference ON public.inventory_transactions USING btree (reference_type, reference_id);


--
-- Name: inv_tx_store_product_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inv_tx_store_product_date ON public.inventory_transactions USING btree (store_id, product_id, created_at);


--
-- Name: inv_tx_store_type_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inv_tx_store_type_date ON public.inventory_transactions USING btree (store_id, transaction_type, created_at);


--
-- Name: inventory_daily_snapshots_store_id_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_daily_snapshots_store_id_date_index ON public.inventory_daily_snapshots USING btree (store_id, date);


--
-- Name: inventory_store_id_current_qty_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_store_id_current_qty_index ON public.inventory USING btree (store_id, current_qty);


--
-- Name: inventory_transactions_expiry_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_transactions_expiry_date_index ON public.inventory_transactions USING btree (expiry_date);


--
-- Name: ir_org_type_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_org_type_period ON public.intelligence_reports USING btree (organization_id, report_type, report_period_start);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: leave_requests_employee_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX leave_requests_employee_id_status_index ON public.leave_requests USING btree (employee_id, status);


--
-- Name: leave_requests_store_id_start_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX leave_requests_store_id_start_date_index ON public.leave_requests USING btree (store_id, start_date);


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
-- Name: product_categories_organization_id_parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_categories_organization_id_parent_id_index ON public.product_categories USING btree (organization_id, parent_id);


--
-- Name: products_barcode_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_barcode_index ON public.products USING btree (barcode);


--
-- Name: products_category_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_category_id_index ON public.products USING btree (category_id);


--
-- Name: products_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_code_index ON public.products USING btree (code);


--
-- Name: products_organization_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_organization_id_status_index ON public.products USING btree (organization_id, status);


--
-- Name: promotion_items_promotion_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX promotion_items_promotion_id_index ON public.promotion_items USING btree (promotion_id);


--
-- Name: promotion_reviews_store_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX promotion_reviews_store_id_index ON public.promotion_reviews USING btree (store_id);


--
-- Name: promotion_rules_organization_id_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX promotion_rules_organization_id_is_active_index ON public.promotion_rules USING btree (organization_id, is_active);


--
-- Name: promotions_store_id_started_at_ended_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX promotions_store_id_started_at_ended_at_index ON public.promotions USING btree (store_id, started_at, ended_at);


--
-- Name: promotions_store_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX promotions_store_id_status_index ON public.promotions USING btree (store_id, status);


--
-- Name: purchase_order_items_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX purchase_order_items_product_id_index ON public.purchase_order_items USING btree (product_id);


--
-- Name: purchase_order_items_purchase_order_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX purchase_order_items_purchase_order_id_index ON public.purchase_order_items USING btree (purchase_order_id);


--
-- Name: purchase_orders_expected_delivery_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX purchase_orders_expected_delivery_date_index ON public.purchase_orders USING btree (expected_delivery_date);


--
-- Name: purchase_orders_store_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX purchase_orders_store_id_status_index ON public.purchase_orders USING btree (store_id, status);


--
-- Name: purchase_orders_supplier_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX purchase_orders_supplier_id_status_index ON public.purchase_orders USING btree (supplier_id, status);


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
-- Name: regions_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX regions_organization_id_index ON public.regions USING btree (organization_id);


--
-- Name: reports_organization_id_report_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reports_organization_id_report_type_index ON public.reports USING btree (organization_id, report_type);


--
-- Name: reports_store_type_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reports_store_type_period ON public.reports USING btree (store_id, report_type, period_start);


--
-- Name: resumes_organization_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX resumes_organization_id_status_index ON public.resumes USING btree (organization_id, status);


--
-- Name: saas_integrations_organization_id_platform_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX saas_integrations_organization_id_platform_index ON public.saas_integrations USING btree (organization_id, platform);


--
-- Name: saas_integrations_store_id_platform_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX saas_integrations_store_id_platform_index ON public.saas_integrations USING btree (store_id, platform);


--
-- Name: salary_records_store_id_year_month_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX salary_records_store_id_year_month_index ON public.salary_records USING btree (store_id, year, month);


--
-- Name: sales_daily_summaries_store_id_sale_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sales_daily_summaries_store_id_sale_date_index ON public.sales_daily_summaries USING btree (store_id, sale_date);


--
-- Name: sales_order_items_product_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sales_order_items_product_id_index ON public.sales_order_items USING btree (product_id);


--
-- Name: sales_order_items_sales_order_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sales_order_items_sales_order_id_index ON public.sales_order_items USING btree (sales_order_id);


--
-- Name: sales_orders_cashier_id_sold_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sales_orders_cashier_id_sold_at_index ON public.sales_orders USING btree (cashier_id, sold_at);


--
-- Name: sales_orders_sold_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sales_orders_sold_at_index ON public.sales_orders USING btree (sold_at);


--
-- Name: sales_orders_store_id_sold_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sales_orders_store_id_sold_at_index ON public.sales_orders USING btree (store_id, sold_at);


--
-- Name: sales_uploads_store_id_sale_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sales_uploads_store_id_sale_date_index ON public.sales_uploads USING btree (store_id, sale_date);


--
-- Name: sales_uploads_store_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sales_uploads_store_id_status_index ON public.sales_uploads USING btree (store_id, status);


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
-- Name: supplier_products_product_id_is_primary_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_products_product_id_is_primary_index ON public.supplier_products USING btree (product_id, is_primary);


--
-- Name: supplier_products_supplier_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_products_supplier_id_index ON public.supplier_products USING btree (supplier_id);


--
-- Name: supplier_refund_claim_items_claim_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_refund_claim_items_claim_id_index ON public.supplier_refund_claim_items USING btree (claim_id);


--
-- Name: supplier_refund_claim_items_damage_record_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_refund_claim_items_damage_record_id_index ON public.supplier_refund_claim_items USING btree (damage_record_id);


--
-- Name: supplier_refund_claims_store_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_refund_claims_store_id_index ON public.supplier_refund_claims USING btree (store_id);


--
-- Name: supplier_refund_claims_supplier_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_refund_claims_supplier_id_index ON public.supplier_refund_claims USING btree (supplier_id);


--
-- Name: suppliers_organization_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX suppliers_organization_id_status_index ON public.suppliers USING btree (organization_id, status);


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
-- Name: ai_messages ai_messages_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_messages
    ADD CONSTRAINT ai_messages_session_id_foreign FOREIGN KEY (session_id) REFERENCES public.ai_sessions(id) ON DELETE CASCADE;


--
-- Name: ai_sessions ai_sessions_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_sessions
    ADD CONSTRAINT ai_sessions_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: ai_sessions ai_sessions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_sessions
    ADD CONSTRAINT ai_sessions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: attendance_records attendance_records_approved_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_approved_by_foreign FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: attendance_records attendance_records_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: attendance_records attendance_records_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: competitor_hot_products competitor_hot_products_competitor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_hot_products
    ADD CONSTRAINT competitor_hot_products_competitor_id_foreign FOREIGN KEY (competitor_id) REFERENCES public.competitors(id) ON DELETE CASCADE;


--
-- Name: competitor_hot_products competitor_hot_products_competitor_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_hot_products
    ADD CONSTRAINT competitor_hot_products_competitor_product_id_foreign FOREIGN KEY (competitor_product_id) REFERENCES public.competitor_products(id) ON DELETE CASCADE;


--
-- Name: competitor_hot_products competitor_hot_products_our_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_hot_products
    ADD CONSTRAINT competitor_hot_products_our_product_id_foreign FOREIGN KEY (our_product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: competitor_hot_products competitor_hot_products_reviewed_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_hot_products
    ADD CONSTRAINT competitor_hot_products_reviewed_by_foreign FOREIGN KEY (reviewed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: competitor_price_records competitor_price_records_collected_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_price_records
    ADD CONSTRAINT competitor_price_records_collected_by_foreign FOREIGN KEY (collected_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: competitor_price_records competitor_price_records_competitor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_price_records
    ADD CONSTRAINT competitor_price_records_competitor_id_foreign FOREIGN KEY (competitor_id) REFERENCES public.competitors(id) ON DELETE CASCADE;


--
-- Name: competitor_price_records competitor_price_records_competitor_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_price_records
    ADD CONSTRAINT competitor_price_records_competitor_product_id_foreign FOREIGN KEY (competitor_product_id) REFERENCES public.competitor_products(id) ON DELETE CASCADE;


--
-- Name: competitor_price_records competitor_price_records_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_price_records
    ADD CONSTRAINT competitor_price_records_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: competitor_products competitor_products_competitor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_products
    ADD CONSTRAINT competitor_products_competitor_id_foreign FOREIGN KEY (competitor_id) REFERENCES public.competitors(id) ON DELETE CASCADE;


--
-- Name: competitor_products competitor_products_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitor_products
    ADD CONSTRAINT competitor_products_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: competitors competitors_nearest_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitors
    ADD CONSTRAINT competitors_nearest_store_id_foreign FOREIGN KEY (nearest_store_id) REFERENCES public.stores(id) ON DELETE SET NULL;


--
-- Name: competitors competitors_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitors
    ADD CONSTRAINT competitors_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: custom_report_templates custom_report_templates_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_report_templates
    ADD CONSTRAINT custom_report_templates_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: custom_report_templates custom_report_templates_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_report_templates
    ADD CONSTRAINT custom_report_templates_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: customer_follow_ups customer_follow_ups_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_follow_ups
    ADD CONSTRAINT customer_follow_ups_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: customer_follow_ups customer_follow_ups_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_follow_ups
    ADD CONSTRAINT customer_follow_ups_operator_id_foreign FOREIGN KEY (operator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: customer_order_items customer_order_items_customer_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_items
    ADD CONSTRAINT customer_order_items_customer_order_id_foreign FOREIGN KEY (customer_order_id) REFERENCES public.customer_orders(id) ON DELETE CASCADE;


--
-- Name: customer_order_items customer_order_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_items
    ADD CONSTRAINT customer_order_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: customer_orders customer_orders_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders
    ADD CONSTRAINT customer_orders_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: customer_orders customer_orders_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders
    ADD CONSTRAINT customer_orders_operator_id_foreign FOREIGN KEY (operator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: customer_orders customer_orders_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders
    ADD CONSTRAINT customer_orders_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id);


--
-- Name: customers customers_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: customers customers_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id);


--
-- Name: daily_operation_logs daily_operation_logs_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_operation_logs
    ADD CONSTRAINT daily_operation_logs_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: damage_records damage_records_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_records
    ADD CONSTRAINT damage_records_operator_id_foreign FOREIGN KEY (operator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: damage_records damage_records_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_records
    ADD CONSTRAINT damage_records_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: damage_records damage_records_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.damage_records
    ADD CONSTRAINT damage_records_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id);


--
-- Name: dashboard_configs dashboard_configs_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_configs
    ADD CONSTRAINT dashboard_configs_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE SET NULL;


--
-- Name: dashboard_configs dashboard_configs_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_configs
    ADD CONSTRAINT dashboard_configs_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: employee_store_history employee_store_history_approved_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_store_history
    ADD CONSTRAINT employee_store_history_approved_by_foreign FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: employee_store_history employee_store_history_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_store_history
    ADD CONSTRAINT employee_store_history_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: employee_store_history employee_store_history_from_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_store_history
    ADD CONSTRAINT employee_store_history_from_store_id_foreign FOREIGN KEY (from_store_id) REFERENCES public.stores(id) ON DELETE SET NULL;


--
-- Name: employee_store_history employee_store_history_to_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_store_history
    ADD CONSTRAINT employee_store_history_to_store_id_foreign FOREIGN KEY (to_store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: employees employees_current_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_current_store_id_foreign FOREIGN KEY (current_store_id) REFERENCES public.stores(id) ON DELETE SET NULL;


--
-- Name: employees employees_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: employees employees_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: expense_categories expense_categories_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: expense_categories expense_categories_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.expense_categories(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_ai_session_message_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_ai_session_message_id_foreign FOREIGN KEY (ai_session_message_id) REFERENCES public.ai_messages(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_approved_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_approved_by_foreign FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.expense_categories(id) ON DELETE CASCADE;


--
-- Name: expenses expenses_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_supplier_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_supplier_id_foreign FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: intelligence_reports intelligence_reports_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intelligence_reports
    ADD CONSTRAINT intelligence_reports_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: intelligence_reports intelligence_reports_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intelligence_reports
    ADD CONSTRAINT intelligence_reports_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE SET NULL;


--
-- Name: inventory_daily_snapshots inventory_daily_snapshots_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_daily_snapshots
    ADD CONSTRAINT inventory_daily_snapshots_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: inventory_daily_snapshots inventory_daily_snapshots_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_daily_snapshots
    ADD CONSTRAINT inventory_daily_snapshots_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: inventory inventory_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: inventory inventory_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: inventory_transactions inventory_transactions_operator_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_operator_id_foreign FOREIGN KEY (operator_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: inventory_transactions inventory_transactions_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: inventory_transactions inventory_transactions_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_approved_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_approved_by_foreign FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: leave_requests leave_requests_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: posts posts_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: product_categories product_categories_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: product_categories product_categories_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.product_categories(id) ON DELETE SET NULL;


--
-- Name: products products_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.product_categories(id) ON DELETE SET NULL;


--
-- Name: products products_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: products products_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: products products_supplier_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_supplier_id_foreign FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: promotion_items promotion_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_items
    ADD CONSTRAINT promotion_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: promotion_items promotion_items_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_items
    ADD CONSTRAINT promotion_items_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotions(id) ON DELETE CASCADE;


--
-- Name: promotion_reviews promotion_reviews_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_reviews
    ADD CONSTRAINT promotion_reviews_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotions(id) ON DELETE CASCADE;


--
-- Name: promotion_reviews promotion_reviews_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_reviews
    ADD CONSTRAINT promotion_reviews_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: promotion_rules promotion_rules_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rules
    ADD CONSTRAINT promotion_rules_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: promotions promotions_approved_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_approved_by_foreign FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: promotions promotions_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: promotions promotions_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_rule_id_foreign FOREIGN KEY (rule_id) REFERENCES public.promotion_rules(id) ON DELETE SET NULL;


--
-- Name: promotions promotions_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: purchase_order_items purchase_order_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: purchase_order_items purchase_order_items_purchase_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_purchase_order_id_foreign FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id) ON DELETE CASCADE;


--
-- Name: purchase_order_items purchase_order_items_supplier_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_supplier_id_foreign FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: purchase_orders purchase_orders_approved_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_approved_by_foreign FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: purchase_orders purchase_orders_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: purchase_orders purchase_orders_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: purchase_orders purchase_orders_supplier_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_supplier_id_foreign FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


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
-- Name: regions regions_manager_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_manager_user_id_foreign FOREIGN KEY (manager_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: regions regions_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: regions regions_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.regions(id) ON DELETE SET NULL;


--
-- Name: reports reports_generated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_generated_by_foreign FOREIGN KEY (generated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: reports reports_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: reports reports_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE SET NULL;


--
-- Name: resumes resumes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resumes
    ADD CONSTRAINT resumes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: resumes resumes_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resumes
    ADD CONSTRAINT resumes_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


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
-- Name: salary_records salary_records_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_records
    ADD CONSTRAINT salary_records_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: salary_records salary_records_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_records
    ADD CONSTRAINT salary_records_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: sales_daily_summaries sales_daily_summaries_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_daily_summaries
    ADD CONSTRAINT sales_daily_summaries_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: sales_daily_summaries sales_daily_summaries_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_daily_summaries
    ADD CONSTRAINT sales_daily_summaries_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id);


--
-- Name: sales_order_items sales_order_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: sales_order_items sales_order_items_sales_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_sales_order_id_foreign FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE CASCADE;


--
-- Name: sales_orders sales_orders_cashier_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_cashier_id_foreign FOREIGN KEY (cashier_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: sales_orders sales_orders_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: sales_uploads sales_uploads_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_uploads
    ADD CONSTRAINT sales_uploads_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: sales_uploads sales_uploads_uploaded_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_uploads
    ADD CONSTRAINT sales_uploads_uploaded_by_foreign FOREIGN KEY (uploaded_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: schedules schedules_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: schedules schedules_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: schedules schedules_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


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
-- Name: supplier_products supplier_products_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_products
    ADD CONSTRAINT supplier_products_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: supplier_products supplier_products_supplier_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_products
    ADD CONSTRAINT supplier_products_supplier_id_foreign FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: supplier_refund_claim_items supplier_refund_claim_items_claim_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claim_items
    ADD CONSTRAINT supplier_refund_claim_items_claim_id_foreign FOREIGN KEY (claim_id) REFERENCES public.supplier_refund_claims(id) ON DELETE CASCADE;


--
-- Name: supplier_refund_claim_items supplier_refund_claim_items_damage_record_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claim_items
    ADD CONSTRAINT supplier_refund_claim_items_damage_record_id_foreign FOREIGN KEY (damage_record_id) REFERENCES public.damage_records(id);


--
-- Name: supplier_refund_claims supplier_refund_claims_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claims
    ADD CONSTRAINT supplier_refund_claims_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(id);


--
-- Name: supplier_refund_claims supplier_refund_claims_supplier_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier_refund_claims
    ADD CONSTRAINT supplier_refund_claims_supplier_id_foreign FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: suppliers suppliers_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


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
-- Name: wework_users wework_users_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wework_users
    ADD CONSTRAINT wework_users_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict UeTpp3XWd6IaZg4tdBHngN4lmuZp4gl92IOvHE0xuoNVGgqb4stfdYiR3yaOfF3


--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 9.6.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: announcement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement (
    id integer NOT NULL,
    created text,
    user_id integer,
    updated text,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    info json,
    media_url text,
    published boolean NOT NULL
);


ALTER TABLE public.announcement OWNER TO postgres;

--
-- Name: announcement_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.announcement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.announcement_id_seq OWNER TO postgres;

--
-- Name: announcement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcement_id_seq OWNED BY public.announcement.id;


--
-- Name: auditlog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditlog (
    id integer NOT NULL,
    project_id integer NOT NULL,
    project_short_name text NOT NULL,
    user_id integer NOT NULL,
    user_name text NOT NULL,
    created text NOT NULL,
    action text NOT NULL,
    caller text NOT NULL,
    attribute text NOT NULL,
    old_value text,
    new_value text
);


ALTER TABLE public.auditlog OWNER TO postgres;

--
-- Name: auditlog_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditlog_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auditlog_id_seq OWNER TO postgres;

--
-- Name: auditlog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditlog_id_seq OWNED BY public.auditlog.id;


--
-- Name: blogpost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.blogpost (
    id integer NOT NULL,
    created text,
    updated text,
    project_id integer NOT NULL,
    user_id integer,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    info json,
    media_url text,
    published boolean NOT NULL
);


ALTER TABLE public.blogpost OWNER TO postgres;

--
-- Name: blogpost_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.blogpost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blogpost_id_seq OWNER TO postgres;

--
-- Name: blogpost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.blogpost_id_seq OWNED BY public.blogpost.id;


--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    id integer NOT NULL,
    name text NOT NULL,
    short_name text NOT NULL,
    description text NOT NULL,
    created text,
    info json
);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.category_id_seq OWNER TO postgres;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.category_id_seq OWNED BY public.category.id;


--
-- Name: counter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.counter (
    id integer NOT NULL,
    created timestamp without time zone,
    project_id integer NOT NULL,
    task_id integer NOT NULL,
    n_task_runs integer NOT NULL
);


ALTER TABLE public.counter OWNER TO postgres;

--
-- Name: counter_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.counter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.counter_id_seq OWNER TO postgres;

--
-- Name: counter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.counter_id_seq OWNED BY public.counter.id;


--
-- Name: task_run; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_run (
    id integer NOT NULL,
    created text,
    project_id integer NOT NULL,
    task_id integer NOT NULL,
    user_id integer,
    user_ip text,
    finish_time text,
    timeout integer,
    calibration integer,
    external_uid text,
    info json
);


ALTER TABLE public.task_run OWNER TO postgres;

--
-- Name: dashboard_week_anon; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_anon AS
 WITH crafters_per_day AS (
         SELECT to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day,
            task_run.user_ip,
            count(task_run.user_ip) AS day_crafters
           FROM public.task_run
          WHERE (to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval))
          GROUP BY (to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text)), task_run.user_ip
        )
 SELECT crafters_per_day.day,
    count(crafters_per_day.user_ip) AS n_users
   FROM crafters_per_day
  GROUP BY crafters_per_day.day
  ORDER BY crafters_per_day.day
  WITH NO DATA;


ALTER TABLE public.dashboard_week_anon OWNER TO postgres;

--
-- Name: task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task (
    id integer NOT NULL,
    created text,
    project_id integer NOT NULL,
    state text,
    quorum integer,
    calibration integer,
    priority_0 double precision,
    info json,
    n_answers integer,
    fav_user_ids integer[]
);


ALTER TABLE public.task OWNER TO postgres;

--
-- Name: dashboard_week_new_task; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_new_task AS
 SELECT to_date(task.created, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day,
    count(task.id) AS day_tasks
   FROM public.task
  WHERE (to_date(task.created, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval))
  GROUP BY (to_date(task.created, 'YYYY-MM-DD\THH24:MI:SS.US'::text))
  ORDER BY (to_date(task.created, 'YYYY-MM-DD\THH24:MI:SS.US'::text))
  WITH NO DATA;


ALTER TABLE public.dashboard_week_new_task OWNER TO postgres;

--
-- Name: dashboard_week_new_task_run; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_new_task_run AS
 SELECT to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day,
    count(task_run.id) AS day_task_runs
   FROM public.task_run
  WHERE (to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval))
  GROUP BY (to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text))
  WITH NO DATA;


ALTER TABLE public.dashboard_week_new_task_run OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    created text,
    email_addr character varying(254) NOT NULL,
    name character varying(254) NOT NULL,
    fullname character varying(500) NOT NULL,
    locale character varying(254) NOT NULL,
    api_key character varying(36),
    passwd_hash character varying(254),
    admin boolean,
    pro boolean,
    privacy_mode boolean NOT NULL,
    category integer,
    flags integer,
    twitter_user_id bigint,
    facebook_user_id bigint,
    google_user_id character varying,
    ckan_api character varying,
    newsletter_prompted boolean,
    valid_email boolean,
    confirmation_email_sent boolean,
    subscribed boolean,
    consent boolean,
    info json
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: dashboard_week_new_users; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_new_users AS
 SELECT to_date("user".created, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day,
    count("user".id) AS day_users
   FROM public."user"
  WHERE (to_date("user".created, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval))
  GROUP BY (to_date("user".created, 'YYYY-MM-DD\THH24:MI:SS.US'::text))
  WITH NO DATA;


ALTER TABLE public.dashboard_week_new_users OWNER TO postgres;

--
-- Name: dashboard_week_returning_users; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_returning_users AS
 WITH data AS (
         SELECT task_run.user_id,
            to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day
           FROM public.task_run
          WHERE (to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval))
          GROUP BY (to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text)), task_run.user_id
        )
 SELECT data.user_id,
    count(data.user_id) AS n_days
   FROM data
  GROUP BY data.user_id
 HAVING (count(data.user_id) > 1)
  ORDER BY (count(data.user_id))
  WITH NO DATA;


ALTER TABLE public.dashboard_week_returning_users OWNER TO postgres;

--
-- Name: dashboard_week_users; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_users AS
 WITH crafters_per_day AS (
         SELECT to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day,
            task_run.user_id,
            count(task_run.user_id) AS day_crafters
           FROM public.task_run
          WHERE (to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval))
          GROUP BY (to_date(task_run.finish_time, 'YYYY-MM-DD\THH24:MI:SS.US'::text)), task_run.user_id
        )
 SELECT crafters_per_day.day,
    count(crafters_per_day.user_id) AS n_users
   FROM crafters_per_day
  GROUP BY crafters_per_day.day
  ORDER BY crafters_per_day.day
  WITH NO DATA;


ALTER TABLE public.dashboard_week_users OWNER TO postgres;

--
-- Name: helpingmaterial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.helpingmaterial (
    id integer NOT NULL,
    created timestamp without time zone,
    project_id integer NOT NULL,
    info json,
    media_url text
);


ALTER TABLE public.helpingmaterial OWNER TO postgres;

--
-- Name: helpingmaterial_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.helpingmaterial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.helpingmaterial_id_seq OWNER TO postgres;

--
-- Name: helpingmaterial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.helpingmaterial_id_seq OWNED BY public.helpingmaterial.id;


--
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project (
    id integer NOT NULL,
    created text,
    updated text,
    name character varying(255) NOT NULL,
    short_name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    long_description text,
    webhook text,
    allow_anonymous_contributors boolean,
    published boolean NOT NULL,
    featured boolean NOT NULL,
    secret_key text,
    contacted boolean NOT NULL,
    owner_id integer NOT NULL,
    category_id integer NOT NULL,
    info json
);


ALTER TABLE public.project OWNER TO postgres;

--
-- Name: project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_id_seq OWNER TO postgres;

--
-- Name: project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_id_seq OWNED BY public.project.id;


--
-- Name: project_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_stats (
    id integer NOT NULL,
    project_id integer NOT NULL,
    n_tasks integer,
    n_task_runs integer,
    n_results integer,
    n_volunteers integer,
    n_completed_tasks integer,
    overall_progress integer,
    average_time double precision,
    n_blogposts integer,
    last_activity text,
    info json
);


ALTER TABLE public.project_stats OWNER TO postgres;

--
-- Name: project_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_stats_id_seq OWNER TO postgres;

--
-- Name: project_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_stats_id_seq OWNED BY public.project_stats.id;


--
-- Name: result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.result (
    id integer NOT NULL,
    created text,
    project_id integer NOT NULL,
    task_id integer NOT NULL,
    task_run_ids integer[] NOT NULL,
    last_version boolean,
    info json
);


ALTER TABLE public.result OWNER TO postgres;

--
-- Name: result_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.result_id_seq OWNER TO postgres;

--
-- Name: result_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.result_id_seq OWNED BY public.result.id;


--
-- Name: task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_id_seq OWNER TO postgres;

--
-- Name: task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_id_seq OWNED BY public.task.id;


--
-- Name: task_run_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_run_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_run_id_seq OWNER TO postgres;

--
-- Name: task_run_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_run_id_seq OWNED BY public.task_run.id;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: webhook; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.webhook (
    id integer NOT NULL,
    created text,
    updated text,
    project_id integer NOT NULL,
    payload json,
    response text,
    response_status_code integer
);


ALTER TABLE public.webhook OWNER TO postgres;

--
-- Name: webhook_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.webhook_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.webhook_id_seq OWNER TO postgres;

--
-- Name: webhook_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.webhook_id_seq OWNED BY public.webhook.id;


--
-- Name: announcement id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement ALTER COLUMN id SET DEFAULT nextval('public.announcement_id_seq'::regclass);


--
-- Name: auditlog id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditlog ALTER COLUMN id SET DEFAULT nextval('public.auditlog_id_seq'::regclass);


--
-- Name: blogpost id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blogpost ALTER COLUMN id SET DEFAULT nextval('public.blogpost_id_seq'::regclass);


--
-- Name: category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.category_id_seq'::regclass);


--
-- Name: counter id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counter ALTER COLUMN id SET DEFAULT nextval('public.counter_id_seq'::regclass);


--
-- Name: helpingmaterial id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.helpingmaterial ALTER COLUMN id SET DEFAULT nextval('public.helpingmaterial_id_seq'::regclass);


--
-- Name: project id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project ALTER COLUMN id SET DEFAULT nextval('public.project_id_seq'::regclass);


--
-- Name: project_stats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_stats ALTER COLUMN id SET DEFAULT nextval('public.project_stats_id_seq'::regclass);


--
-- Name: result id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result ALTER COLUMN id SET DEFAULT nextval('public.result_id_seq'::regclass);


--
-- Name: task id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task ALTER COLUMN id SET DEFAULT nextval('public.task_id_seq'::regclass);


--
-- Name: task_run id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_run ALTER COLUMN id SET DEFAULT nextval('public.task_run_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: webhook id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhook ALTER COLUMN id SET DEFAULT nextval('public.webhook_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
52209719b79e
\.


--
-- Data for Name: announcement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcement (id, created, user_id, updated, title, body, info, media_url, published) FROM stdin;
\.


--
-- Name: announcement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcement_id_seq', 1, false);


--
-- Data for Name: auditlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auditlog (id, project_id, project_short_name, user_id, user_name, created, action, caller, attribute, old_value, new_value) FROM stdin;
1	1	thing-tagging	1	admin	2018-03-16T01:52:16.329240	create	web	project	Nothing	New project
2	1	thing-tagging	1	admin	2018-03-16T01:55:13.426150	update	web	task_presenter	\N	<div class="row">\r\n    <!-- Success and Error Messages for the user --> \r\n    <div class="span6 offset2" style="height:50px">\r\n        <div id="success" class="alert alert-success" style="display:none;">\r\n            <a class="close">×</a>\r\n            <strong>Well done!</strong> Your answer has been saved\r\n        </div>\r\n        <div id="loading" class="alert alert-info" style="display:none;">\r\n            <a class="close">×</a>\r\n            Loading next task...\r\n        </div>\r\n        <div id="taskcompleted" class="alert alert-info" style="display:none;">\r\n            <strong>The task has been completed!</strong> Thanks a lot!\r\n        </div>\r\n        <div id="finish" class="alert alert-success" style="display:none;">\r\n            <strong>Congratulations!</strong> You have participated in all available tasks!\r\n            <br/>\r\n            <div class="alert-actions">\r\n                <a class="btn small" href="/">Go back</a>\r\n                <a class="btn small" href="/app">or, Check other applications</a>\r\n            </div>\r\n        </div>\r\n        <div id="error" class="alert alert-error" style="display:none;">\r\n            <a class="close">×</a>\r\n            <strong>Error!</strong> Something went wrong, please contact the site administrators\r\n        </div>\r\n    </div> <!-- End Success and Error Messages for the user -->\r\n</div> <!-- End of Row -->\r\n\r\n<!--\r\n    Task DOM for loading the Tweets\r\n    It uses the class="skeleton" to identify the elements that belong to the\r\n    task.\r\n-->\r\n<div class="row-fluid skeleton"> <!-- Start Skeleton Row-->\r\n    <div class="span12"><!-- Start of Question and Submission DIV (column) -->\r\n        <h1 id="question">Indique de 0 a 5 el grado de alegría del siguiente tweet</h1> <!-- The question will be loaded here -->\r\n        <div class="well well-small">\r\n            <p id="tweet"></p> <!-- Start DIV for the submission buttons -->\r\n        </div>\r\n        <div id="answer"> <!-- Start DIV for the submission buttons -->\r\n            <div class="input-append">\r\n                <input id="alegria" maxlength="1" size="1" type="text">\r\n                <button class="btn btn-success btn-answer" type="button"><i class="icon-ok"></i> Guardar valor</button>\r\n            </div>\r\n            <!-- If the user clicks this button, the saved answer will be value="yes"-->\r\n        </div><!-- End of DIV for the submission buttons -->\r\n        <!-- Feedback items for the user -->\r\n        <hr>\r\n        <p>You are working now on task: <span id="task-id" class="label label-warning">#</span></p>\r\n        <p>You have completed: <span id="done" class="label label-info"></span> tasks from\r\n        <!-- Progress bar for the user -->\r\n        <span id="total" class="label label-inverse"></span></p>\r\n        <div class="progress progress-striped">\r\n            <div id="progress" rel="tooltip" title="#" class="bar" style="width: 0%;"></div>\r\n        </div>\r\n        <!-- \r\n            This application uses Disqus to allow users to provide some feedback.\r\n            The next section includes a button that when a user clicks on it will\r\n            load the comments, if any, for the given task\r\n        -->\r\n        <div id="disqus_show_btn" style="margin-top:5px;">\r\n            <button class="btn btn-primary btn-large btn-disqus" onclick="loadDisqus()"><i class="icon-comments"></i> Show comments</button>\r\n            <button class="btn btn-large btn-disqus" onclick="loadDisqus()" style="display:none"><i class="icon-comments"></i> Hide comments</button>\r\n        </div><!-- End of Disqus Button section -->\r\n        <!-- Disqus thread for the given task -->\r\n        <div id="disqus_thread" style="margin-top:5px;display:none"></div>\r\n    </div><!-- End of Question and Submission DIV (column) -->\r\n</div><!-- End of Skeleton Row -->\r\n\r\n<script type="text/javascript">\r\n    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */\r\n    /* * * DON'T EDIT BELOW THIS LINE * * */\r\n    function loadDisqus() {\r\n    $("#disqus_thread").toggle();\r\n    $(".btn-disqus").toggle();\r\n    var disqus_shortname = 'pybossa'; // required: replace example with your forum shortname\r\n    //var disqus_identifier = taskId;\r\n    var disqus_developer = 1;\r\n    (function() {\r\n        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;\r\n        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';\r\n        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);\r\n    })();\r\n    }\r\n</script>\r\n<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>\r\n\r\n<script>\r\nfunction loadUserProgress() {\r\n    pybossa.userProgress('emotions').done(function(data){\r\n        var pct = Math.round((data.done*100)/data.total);\r\n        $("#progress").css("width", pct.toString() +"%");\r\n        $("#progress").attr("title", pct.toString() + "% completed!");\r\n        $("#progress").tooltip({'placement': 'left'}); \r\n        $("#total").text(data.total);\r\n        $("#done").text(data.done);\r\n    });\r\n}\r\npybossa.taskLoaded(function(task, deferred) {\r\n    if ( !$.isEmptyObject(task) ) {\r\n        // load image from flickr\r\n        var p = $('<p/>');\r\n        p.addClass('lead');\r\n        console.log(task.info);\r\n        p.text = task.info.tweet.text;\r\n        task.info.p = p;\r\n        task.answer = {'happiness': 0,\r\n                       'tweet': task.info.tweet.text,\r\n                       'task_id': task.id};\r\n        deferred.resolve(task);\r\n    }\r\n    else {\r\n        deferred.resolve(task);\r\n    }\r\n});\r\npybossa.presentTask(function(task, deferred) {\r\n    if ( !$.isEmptyObject(task) ) {\r\n        loadUserProgress();\r\n        $("#alegria").val("");\r\n        $('#tweet').text(task.info.tweet.text);\r\n        $('#task-id').html(task.id);\r\n        $('.btn-answer').off('click').on('click', function(evt) {\r\n            var answer = $(evt.target).attr("value");\r\n            if (typeof answer != 'undefined') {\r\n                task.answer.happiness = parseInt($("#alegria").val());\r\n                if ((task.answer.happiness >= 0) && (task.answer.happiness <=5)) {\r\n                    pybossa.saveTask(task.id, task.answer).done(function() {\r\n                        deferred.resolve();\r\n                    });\r\n                    $("#loading").fadeIn(500);\r\n                    if ($("#disqus_thread").is(":visible")) {\r\n                        $('#disqus_thread').toggle();\r\n                        $('.btn-disqus').toggle();\r\n                    }\r\n                }\r\n                else {\r\n                    alert("Sorry, the value should be between 0 and 5");\r\n                    return;\r\n                }\r\n            }\r\n            else {\r\n                $("#error").show();\r\n            }\r\n        });\r\n        $("#loading").hide();\r\n    }\r\n    else {\r\n        $(".skeleton").hide();\r\n        $("#loading").hide();\r\n        $("#finish").fadeIn(500);\r\n    }\r\n});\r\npybossa.run('thing-tagging');\r\n</script>
3	1	thing-tagging	1	admin	2018-03-16T01:55:19.283562	update	web	published	false	true
4	1	thing-tagging	1	admin	2018-03-16T01:57:21.526563	update	web	task_presenter	<div class="row">\r\n    <!-- Success and Error Messages for the user --> \r\n    <div class="span6 offset2" style="height:50px">\r\n        <div id="success" class="alert alert-success" style="display:none;">\r\n            <a class="close">×</a>\r\n            <strong>Well done!</strong> Your answer has been saved\r\n        </div>\r\n        <div id="loading" class="alert alert-info" style="display:none;">\r\n            <a class="close">×</a>\r\n            Loading next task...\r\n        </div>\r\n        <div id="taskcompleted" class="alert alert-info" style="display:none;">\r\n            <strong>The task has been completed!</strong> Thanks a lot!\r\n        </div>\r\n        <div id="finish" class="alert alert-success" style="display:none;">\r\n            <strong>Congratulations!</strong> You have participated in all available tasks!\r\n            <br/>\r\n            <div class="alert-actions">\r\n                <a class="btn small" href="/">Go back</a>\r\n                <a class="btn small" href="/app">or, Check other applications</a>\r\n            </div>\r\n        </div>\r\n        <div id="error" class="alert alert-error" style="display:none;">\r\n            <a class="close">×</a>\r\n            <strong>Error!</strong> Something went wrong, please contact the site administrators\r\n        </div>\r\n    </div> <!-- End Success and Error Messages for the user -->\r\n</div> <!-- End of Row -->\r\n\r\n<!--\r\n    Task DOM for loading the Tweets\r\n    It uses the class="skeleton" to identify the elements that belong to the\r\n    task.\r\n-->\r\n<div class="row-fluid skeleton"> <!-- Start Skeleton Row-->\r\n    <div class="span12"><!-- Start of Question and Submission DIV (column) -->\r\n        <h1 id="question">Indique de 0 a 5 el grado de alegría del siguiente tweet</h1> <!-- The question will be loaded here -->\r\n        <div class="well well-small">\r\n            <p id="tweet"></p> <!-- Start DIV for the submission buttons -->\r\n        </div>\r\n        <div id="answer"> <!-- Start DIV for the submission buttons -->\r\n            <div class="input-append">\r\n                <input id="alegria" maxlength="1" size="1" type="text">\r\n                <button class="btn btn-success btn-answer" type="button"><i class="icon-ok"></i> Guardar valor</button>\r\n            </div>\r\n            <!-- If the user clicks this button, the saved answer will be value="yes"-->\r\n        </div><!-- End of DIV for the submission buttons -->\r\n        <!-- Feedback items for the user -->\r\n        <hr>\r\n        <p>You are working now on task: <span id="task-id" class="label label-warning">#</span></p>\r\n        <p>You have completed: <span id="done" class="label label-info"></span> tasks from\r\n        <!-- Progress bar for the user -->\r\n        <span id="total" class="label label-inverse"></span></p>\r\n        <div class="progress progress-striped">\r\n            <div id="progress" rel="tooltip" title="#" class="bar" style="width: 0%;"></div>\r\n        </div>\r\n        <!-- \r\n            This application uses Disqus to allow users to provide some feedback.\r\n            The next section includes a button that when a user clicks on it will\r\n            load the comments, if any, for the given task\r\n        -->\r\n        <div id="disqus_show_btn" style="margin-top:5px;">\r\n            <button class="btn btn-primary btn-large btn-disqus" onclick="loadDisqus()"><i class="icon-comments"></i> Show comments</button>\r\n            <button class="btn btn-large btn-disqus" onclick="loadDisqus()" style="display:none"><i class="icon-comments"></i> Hide comments</button>\r\n        </div><!-- End of Disqus Button section -->\r\n        <!-- Disqus thread for the given task -->\r\n        <div id="disqus_thread" style="margin-top:5px;display:none"></div>\r\n    </div><!-- End of Question and Submission DIV (column) -->\r\n</div><!-- End of Skeleton Row -->\r\n\r\n<script type="text/javascript">\r\n    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */\r\n    /* * * DON'T EDIT BELOW THIS LINE * * */\r\n    function loadDisqus() {\r\n    $("#disqus_thread").toggle();\r\n    $(".btn-disqus").toggle();\r\n    var disqus_shortname = 'pybossa'; // required: replace example with your forum shortname\r\n    //var disqus_identifier = taskId;\r\n    var disqus_developer = 1;\r\n    (function() {\r\n        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;\r\n        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';\r\n        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);\r\n    })();\r\n    }\r\n</script>\r\n<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>\r\n\r\n<script>\r\nfunction loadUserProgress() {\r\n    pybossa.userProgress('emotions').done(function(data){\r\n        var pct = Math.round((data.done*100)/data.total);\r\n        $("#progress").css("width", pct.toString() +"%");\r\n        $("#progress").attr("title", pct.toString() + "% completed!");\r\n        $("#progress").tooltip({'placement': 'left'}); \r\n        $("#total").text(data.total);\r\n        $("#done").text(data.done);\r\n    });\r\n}\r\npybossa.taskLoaded(function(task, deferred) {\r\n    if ( !$.isEmptyObject(task) ) {\r\n        // load image from flickr\r\n        var p = $('<p/>');\r\n        p.addClass('lead');\r\n        console.log(task.info);\r\n        p.text = task.info.tweet.text;\r\n        task.info.p = p;\r\n        task.answer = {'happiness': 0,\r\n                       'tweet': task.info.tweet.text,\r\n                       'task_id': task.id};\r\n        deferred.resolve(task);\r\n    }\r\n    else {\r\n        deferred.resolve(task);\r\n    }\r\n});\r\npybossa.presentTask(function(task, deferred) {\r\n    if ( !$.isEmptyObject(task) ) {\r\n        loadUserProgress();\r\n        $("#alegria").val("");\r\n        $('#tweet').text(task.info.tweet.text);\r\n        $('#task-id').html(task.id);\r\n        $('.btn-answer').off('click').on('click', function(evt) {\r\n            var answer = $(evt.target).attr("value");\r\n            if (typeof answer != 'undefined') {\r\n                task.answer.happiness = parseInt($("#alegria").val());\r\n                if ((task.answer.happiness >= 0) && (task.answer.happiness <=5)) {\r\n                    pybossa.saveTask(task.id, task.answer).done(function() {\r\n                        deferred.resolve();\r\n                    });\r\n                    $("#loading").fadeIn(500);\r\n                    if ($("#disqus_thread").is(":visible")) {\r\n                        $('#disqus_thread').toggle();\r\n                        $('.btn-disqus').toggle();\r\n                    }\r\n                }\r\n                else {\r\n                    alert("Sorry, the value should be between 0 and 5");\r\n                    return;\r\n                }\r\n            }\r\n            else {\r\n                $("#error").show();\r\n            }\r\n        });\r\n        $("#loading").hide();\r\n    }\r\n    else {\r\n        $(".skeleton").hide();\r\n        $("#loading").hide();\r\n        $("#finish").fadeIn(500);\r\n    }\r\n});\r\npybossa.run('thing-tagging');\r\n</script>	<div class="row">\r\n    <!-- Success and Error Messages for the user --> \r\n    <div class="col-md-6 col-md-offset-2" style="height:50px">\r\n        <div id="success" class="alert alert-success" style="display:none;">\r\n            <a class="close">×</a>\r\n            <strong id="i18n_welldone">Well done!</strong> <span id="i18n_welldone_text">Your answer has been saved</span>\r\n        </div>\r\n        <div id="loading" class="alert alert-info" style="display:none;">\r\n            <a class="close">×</a>\r\n            <span id="i18n_loading_next_task">Loading next task...</span>\r\n        </div>\r\n        <div id="taskcompleted" class="alert alert-info" style="display:none;">\r\n            <strong id="i18n_task_completed">The task has been completed!</strong> <span id="i18n_thanks">Thanks a lot!</span>\r\n        </div>\r\n        <div id="finish" class="alert alert-success" style="display:none;">\r\n            <strong id="i18n_congratulations">Congratulations!</strong> <span id="i18n_congratulations_text">You have participated in all available tasks!</span>\r\n            <br/>\r\n            <div class="alert-actions">\r\n                <a class="btn small" href="/">Go back</a>\r\n                <a class="btn small" href="/app">or, Check other projects</a>\r\n            </div>\r\n        </div>\r\n        <div id="error" class="alert alert-danger" style="display:none;">\r\n            <a class="close">×</a>\r\n            <strong>Error!</strong> Something went wrong, please contact the site administrators\r\n        </div>\r\n    </div> <!-- End Success and Error Messages for the user -->\r\n</div> <!-- End of Row -->\r\n\r\n<!--\r\n    Task DOM for loading the Flickr Images\r\n    It uses the class="skeleton" to identify the elements that belong to the\r\n    task.\r\n-->\r\n<div class="row skeleton"> <!-- Start Skeleton Row-->\r\n    <div class="col-md-6 "><!-- Start of Question and Submission DIV (column) -->\r\n        <h1 id="question"><span id="i18n_question">Do you see a human face in this photo?</span></h1> <!-- The question will be loaded here -->\r\n        <div id="answer"> <!-- Start DIV for the submission buttons -->\r\n            <!-- If the user clicks this button, the saved answer will be value="yes"-->\r\n            <button class="btn btn-success btn-answer" value='Yes'><i class="fa fa-thumbs-o-up"></i> <span id="i18n_yes">Yes</span></button>\r\n            <!-- If the user clicks this button, the saved answer will be value="no"-->\r\n            <button class="btn btn-danger btn-answer" value='No'><i class="fa fa-thumbs-o-down"></i> No</button>\r\n            <!-- If the user clicks this button, the saved answer will be value="NoPhoto"-->\r\n            <button class="btn btn-answer" value='NoPhoto'><i class="fa fa-exclamation"></i> <span id="i18n_no_photo">No photo</span></button>\r\n            <!-- If the user clicks this button, the saved answer will be value="NotKnown"-->\r\n            <button class="btn btn-answer" value='NotKnown'><i class="fa fa-question-circle"></i> <span id="i18n_i_dont_know">I don't know</span></button>\r\n        </div><!-- End of DIV for the submission buttons -->\r\n        <!-- Feedback items for the user -->\r\n        <p><span id="i18n_working_task">You are working now on task:</span> <span id="task-id" class="label label-warning">#</span></p>\r\n        <p><span id="i18n_tasks_completed">You have completed:</span> <span id="done" class="label label-info"></span> <span id="i18n_tasks_from">tasks from</span>\r\n        <!-- Progress bar for the user -->\r\n        <span id="total" class="label label-info"></span></p>\r\n        <div class="progress progress-striped">\r\n            <div id="progress" rel="tooltip" title="#" class="progress-bar" style="width: 0%;"  role="progressbar"></div>\r\n        </div>\r\n        <!-- \r\n            This application uses Disqus to allow users to provide some feedback.\r\n            The next section includes a button that when a user clicks on it will\r\n            load the comments, if any, for the given task\r\n        -->\r\n        <div id="disqus_show_btn" style="margin-top:5px;">\r\n            <button class="btn btn-primary btn-large btn-disqus" onclick="loadDisqus()"><i class="fa fa-comments"></i> <span id="i18n_show_comments">Show comments</span></button>\r\n            <button class="btn btn-large btn-disqus" onclick="loadDisqus()" style="display:none"><i class="fa fa-comments"></i> <span id="i18n_hide_comments">Hide comments</span></button>\r\n        </div><!-- End of Disqus Button section -->\r\n        <!-- Disqus thread for the given task -->\r\n        <div id="disqus_thread" style="margin-top:5px;display:none"></div>\r\n    </div><!-- End of Question and Submission DIV (column) -->\r\n    <div class="col-md-6"><!-- Start of Photo DIV (column) -->\r\n        <a id="photo-link" href="#">\r\n            <img id="photo" src="http://i.imgur.com/GeHxzb7.png" style="max-width=100%">\r\n        </a>\r\n    </div><!-- End of Photo DIV (columnt) -->\r\n</div><!-- End of Skeleton Row -->\r\n\r\n<script type="text/javascript">\r\n    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */\r\n\r\n    /* * * DON'T EDIT BELOW THIS LINE * * */\r\n    function loadDisqus() {\r\n    $("#disqus_thread").toggle();\r\n    $(".btn-disqus").toggle();\r\n    var disqus_shortname = 'pybossa'; // required: replace example with your forum shortname\r\n    //var disqus_identifier = taskId;\r\n    var disqus_developer = 1;\r\n\r\n    (function() {\r\n        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;\r\n        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';\r\n        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);\r\n    })();\r\n    }\r\n\r\n</script>\r\n<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>\r\n\r\n<script>\r\n// Default language\r\nvar userLocale = "en";\r\n// Translations\r\nvar messages = {"en": {\r\n                        "i18n_welldone": "Well done!",\r\n                        "i18n_welldone_text": "Your answer has been saved",\r\n                        "i18n_loading_next_task": "Loading next task...",\r\n                        "i18n_task_completed": "The task has been completed!",\r\n                        "i18n_thanks": "Thanks a lot!",\r\n                        "i18n_congratulations": "Congratulations",\r\n                        "i18n_congratulations_text": "You have participated in all available tasks!",\r\n                        "i18n_yes": "Yes",\r\n                        "i18n_no_photo": "No photo",\r\n                        "i18n_i_dont_know": "I don't know",\r\n                        "i18n_working_task": "You are working now on task:",\r\n                        "i18n_tasks_completed": "You have completed:",\r\n                        "i18n_tasks_from": "tasks from",\r\n                        "i18n_show_comments": "Show comments:",\r\n                        "i18n_hide_comments": "Hide comments:",\r\n                        "i18n_question": "Do you see a human face in this photo?",\r\n                      },\r\n                "es": {\r\n                        "i18n_welldone": "Bien hecho!",\r\n                        "i18n_welldone_text": "Tu respuesta ha sido guardada",\r\n                        "i18n_loading_next_task": "Cargando la siguiente tarea...",\r\n                        "i18n_task_completed": "La tarea ha sido completadas!",\r\n                        "i18n_thanks": "Muchísimas gracias!",\r\n                        "i18n_congratulations": "Enhorabuena",\r\n                        "i18n_congratulations_text": "Has participado en todas las tareas disponibles!",\r\n                        "i18n_yes": "Sí",\r\n                        "i18n_no_photo": "No hay foto",\r\n                        "i18n_i_dont_know": "No lo sé",\r\n                        "i18n_working_task": "Estás trabajando en la tarea:",\r\n                        "i18n_tasks_completed": "Has completado:",\r\n                        "i18n_tasks_from": "tareas de",\r\n                        "i18n_show_comments": "Mostrar comentarios",\r\n                        "i18n_hide_comments": "Ocultar comentarios",\r\n                        "i18n_question": "¿Ves una cara humana en esta foto?",\r\n                      },\r\n               };\r\n// Update userLocale with server side information\r\n $(document).ready(function(){\r\n     userLocale = document.getElementById('PYBOSSA_USER_LOCALE').textContent.trim();\r\n\r\n});\r\n\r\nfunction i18n_translate() {\r\n    var ids = Object.keys(messages[userLocale])\r\n    for (i=0; i<ids.length; i++) {\r\n        console.log("Translating: " + ids[i]);\r\n        document.getElementById(ids[i]).innerHTML = messages[userLocale][ids[i]];\r\n    }\r\n}\r\n\r\n\r\nfunction loadUserProgress() {\r\n    pybossa.userProgress('flickrperson').done(function(data){\r\n        var pct = Math.round((data.done*100)/data.total);\r\n        $("#progress").css("width", pct.toString() +"%");\r\n        $("#progress").attr("title", pct.toString() + "% completed!");\r\n        $("#progress").tooltip({'placement': 'left'}); \r\n        $("#total").text(data.total);\r\n        $("#done").text(data.done);\r\n    });\r\n}\r\n\r\npybossa.taskLoaded(function(task, deferred) {\r\n    if ( !$.isEmptyObject(task) ) {\r\n        // load image from flickr\r\n        var img = $('<img />');\r\n        img.load(function() {\r\n            // continue as soon as the image is loaded\r\n            deferred.resolve(task);\r\n        });\r\n        img.attr('src', task.info.url_b).css('height', 460);\r\n        img.addClass('img-thumbnail img-responsive');\r\n        task.info.image = img;\r\n    }\r\n    else {\r\n        deferred.resolve(task);\r\n    }\r\n});\r\n\r\npybossa.presentTask(function(task, deferred) {\r\n    if ( !$.isEmptyObject(task) ) {\r\n        loadUserProgress();\r\n        i18n_translate();\r\n        $('#photo-link').html('').append(task.info.image);\r\n        $("#photo-link").attr("href", task.info.link);\r\n        //$("#question").html(task.info.question);\r\n        $('#task-id').html(task.id);\r\n        $('.btn-answer').off('click').on('click', function(evt) {\r\n            var answer = $(this).attr("value");\r\n            if (typeof answer != 'undefined') {\r\n                //console.log(answer);\r\n                pybossa.saveTask(task.id, answer).done(function() {\r\n                    deferred.resolve();\r\n                });\r\n                $("#loading").fadeIn(500);\r\n                if ($("#disqus_thread").is(":visible")) {\r\n                    $('#disqus_thread').toggle();\r\n                    $('.btn-disqus').toggle();\r\n                }\r\n            }\r\n            else {\r\n                $("#error").show();\r\n            }\r\n        });\r\n        $("#loading").hide();\r\n    }\r\n    else {\r\n        $(".skeleton").hide();\r\n        $("#loading").hide();\r\n        $("#finish").fadeIn(500);\r\n    }\r\n});\r\n\r\npybossa.run('thing-tagging');\r\n</script>\r\n
\.


--
-- Name: auditlog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditlog_id_seq', 4, true);


--
-- Data for Name: blogpost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.blogpost (id, created, updated, project_id, user_id, title, body, info, media_url, published) FROM stdin;
\.


--
-- Name: blogpost_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.blogpost_id_seq', 1, false);


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category (id, name, short_name, description, created, info) FROM stdin;
1	Thinking	thinking	Volunteer Thinking projects	2018-03-16T01:50:54.079232	{}
2	Volunteer Sensing	sensing	Volunteer Sensing projects	2018-03-16T01:50:54.081894	{}
\.


--
-- Name: category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.category_id_seq', 2, true);


--
-- Data for Name: counter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.counter (id, created, project_id, task_id, n_task_runs) FROM stdin;
1	2018-03-16 01:53:29.920989	1	1	0
2	2018-03-16 01:53:29.934271	1	2	0
3	2018-03-16 01:53:29.946584	1	3	0
4	2018-03-16 01:53:29.960435	1	4	0
5	2018-03-16 01:53:29.973336	1	5	0
6	2018-03-16 01:53:29.98512	1	6	0
7	2018-03-16 01:53:29.996288	1	7	0
8	2018-03-16 01:53:30.008936	1	8	0
9	2018-03-16 01:53:30.019798	1	9	0
10	2018-03-16 01:57:27.491938	1	1	1
11	2018-03-16 01:57:28.211766	1	2	1
12	2018-03-16 01:57:28.884799	1	3	1
13	2018-03-16 01:57:29.434827	1	4	1
14	2018-03-16 01:57:29.919197	1	5	1
15	2018-03-16 01:57:30.589851	1	6	1
16	2018-03-16 01:57:31.22888	1	7	1
17	2018-03-16 01:57:31.710803	1	8	1
18	2018-03-16 01:57:32.250403	1	9	1
\.


--
-- Name: counter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.counter_id_seq', 18, true);


--
-- Data for Name: helpingmaterial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.helpingmaterial (id, created, project_id, info, media_url) FROM stdin;
1	\N	1	\N	\N
\.


--
-- Name: helpingmaterial_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.helpingmaterial_id_seq', 1, true);


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (id, created, updated, name, short_name, description, long_description, webhook, allow_anonymous_contributors, published, featured, secret_key, contacted, owner_id, category_id, info) FROM stdin;
1	2018-03-16T01:52:16.314435	2018-03-16T01:57:32.250092	Thing Tagging	thing-tagging	Tagging things	Tagging things	\N	t	t	f	1c9107de-8602-4b6d-a6d7-93c8e956b7c6	f	1	1	{"task_presenter": "<div class=\\"row\\">\\r\\n    <!-- Success and Error Messages for the user --> \\r\\n    <div class=\\"col-md-6 col-md-offset-2\\" style=\\"height:50px\\">\\r\\n        <div id=\\"success\\" class=\\"alert alert-success\\" style=\\"display:none;\\">\\r\\n            <a class=\\"close\\">\\u00d7</a>\\r\\n            <strong id=\\"i18n_welldone\\">Well done!</strong> <span id=\\"i18n_welldone_text\\">Your answer has been saved</span>\\r\\n        </div>\\r\\n        <div id=\\"loading\\" class=\\"alert alert-info\\" style=\\"display:none;\\">\\r\\n            <a class=\\"close\\">\\u00d7</a>\\r\\n            <span id=\\"i18n_loading_next_task\\">Loading next task...</span>\\r\\n        </div>\\r\\n        <div id=\\"taskcompleted\\" class=\\"alert alert-info\\" style=\\"display:none;\\">\\r\\n            <strong id=\\"i18n_task_completed\\">The task has been completed!</strong> <span id=\\"i18n_thanks\\">Thanks a lot!</span>\\r\\n        </div>\\r\\n        <div id=\\"finish\\" class=\\"alert alert-success\\" style=\\"display:none;\\">\\r\\n            <strong id=\\"i18n_congratulations\\">Congratulations!</strong> <span id=\\"i18n_congratulations_text\\">You have participated in all available tasks!</span>\\r\\n            <br/>\\r\\n            <div class=\\"alert-actions\\">\\r\\n                <a class=\\"btn small\\" href=\\"/\\">Go back</a>\\r\\n                <a class=\\"btn small\\" href=\\"/app\\">or, Check other projects</a>\\r\\n            </div>\\r\\n        </div>\\r\\n        <div id=\\"error\\" class=\\"alert alert-danger\\" style=\\"display:none;\\">\\r\\n            <a class=\\"close\\">\\u00d7</a>\\r\\n            <strong>Error!</strong> Something went wrong, please contact the site administrators\\r\\n        </div>\\r\\n    </div> <!-- End Success and Error Messages for the user -->\\r\\n</div> <!-- End of Row -->\\r\\n\\r\\n<!--\\r\\n    Task DOM for loading the Flickr Images\\r\\n    It uses the class=\\"skeleton\\" to identify the elements that belong to the\\r\\n    task.\\r\\n-->\\r\\n<div class=\\"row skeleton\\"> <!-- Start Skeleton Row-->\\r\\n    <div class=\\"col-md-6 \\"><!-- Start of Question and Submission DIV (column) -->\\r\\n        <h1 id=\\"question\\"><span id=\\"i18n_question\\">Do you see a human face in this photo?</span></h1> <!-- The question will be loaded here -->\\r\\n        <div id=\\"answer\\"> <!-- Start DIV for the submission buttons -->\\r\\n            <!-- If the user clicks this button, the saved answer will be value=\\"yes\\"-->\\r\\n            <button class=\\"btn btn-success btn-answer\\" value='Yes'><i class=\\"fa fa-thumbs-o-up\\"></i> <span id=\\"i18n_yes\\">Yes</span></button>\\r\\n            <!-- If the user clicks this button, the saved answer will be value=\\"no\\"-->\\r\\n            <button class=\\"btn btn-danger btn-answer\\" value='No'><i class=\\"fa fa-thumbs-o-down\\"></i> No</button>\\r\\n            <!-- If the user clicks this button, the saved answer will be value=\\"NoPhoto\\"-->\\r\\n            <button class=\\"btn btn-answer\\" value='NoPhoto'><i class=\\"fa fa-exclamation\\"></i> <span id=\\"i18n_no_photo\\">No photo</span></button>\\r\\n            <!-- If the user clicks this button, the saved answer will be value=\\"NotKnown\\"-->\\r\\n            <button class=\\"btn btn-answer\\" value='NotKnown'><i class=\\"fa fa-question-circle\\"></i> <span id=\\"i18n_i_dont_know\\">I don't know</span></button>\\r\\n        </div><!-- End of DIV for the submission buttons -->\\r\\n        <!-- Feedback items for the user -->\\r\\n        <p><span id=\\"i18n_working_task\\">You are working now on task:</span> <span id=\\"task-id\\" class=\\"label label-warning\\">#</span></p>\\r\\n        <p><span id=\\"i18n_tasks_completed\\">You have completed:</span> <span id=\\"done\\" class=\\"label label-info\\"></span> <span id=\\"i18n_tasks_from\\">tasks from</span>\\r\\n        <!-- Progress bar for the user -->\\r\\n        <span id=\\"total\\" class=\\"label label-info\\"></span></p>\\r\\n        <div class=\\"progress progress-striped\\">\\r\\n            <div id=\\"progress\\" rel=\\"tooltip\\" title=\\"#\\" class=\\"progress-bar\\" style=\\"width: 0%;\\"  role=\\"progressbar\\"></div>\\r\\n        </div>\\r\\n        <!-- \\r\\n            This application uses Disqus to allow users to provide some feedback.\\r\\n            The next section includes a button that when a user clicks on it will\\r\\n            load the comments, if any, for the given task\\r\\n        -->\\r\\n        <div id=\\"disqus_show_btn\\" style=\\"margin-top:5px;\\">\\r\\n            <button class=\\"btn btn-primary btn-large btn-disqus\\" onclick=\\"loadDisqus()\\"><i class=\\"fa fa-comments\\"></i> <span id=\\"i18n_show_comments\\">Show comments</span></button>\\r\\n            <button class=\\"btn btn-large btn-disqus\\" onclick=\\"loadDisqus()\\" style=\\"display:none\\"><i class=\\"fa fa-comments\\"></i> <span id=\\"i18n_hide_comments\\">Hide comments</span></button>\\r\\n        </div><!-- End of Disqus Button section -->\\r\\n        <!-- Disqus thread for the given task -->\\r\\n        <div id=\\"disqus_thread\\" style=\\"margin-top:5px;display:none\\"></div>\\r\\n    </div><!-- End of Question and Submission DIV (column) -->\\r\\n    <div class=\\"col-md-6\\"><!-- Start of Photo DIV (column) -->\\r\\n        <a id=\\"photo-link\\" href=\\"#\\">\\r\\n            <img id=\\"photo\\" src=\\"http://i.imgur.com/GeHxzb7.png\\" style=\\"max-width=100%\\">\\r\\n        </a>\\r\\n    </div><!-- End of Photo DIV (columnt) -->\\r\\n</div><!-- End of Skeleton Row -->\\r\\n\\r\\n<script type=\\"text/javascript\\">\\r\\n    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */\\r\\n\\r\\n    /* * * DON'T EDIT BELOW THIS LINE * * */\\r\\n    function loadDisqus() {\\r\\n    $(\\"#disqus_thread\\").toggle();\\r\\n    $(\\".btn-disqus\\").toggle();\\r\\n    var disqus_shortname = 'pybossa'; // required: replace example with your forum shortname\\r\\n    //var disqus_identifier = taskId;\\r\\n    var disqus_developer = 1;\\r\\n\\r\\n    (function() {\\r\\n        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;\\r\\n        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';\\r\\n        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);\\r\\n    })();\\r\\n    }\\r\\n\\r\\n</script>\\r\\n<noscript>Please enable JavaScript to view the <a href=\\"http://disqus.com/?ref_noscript\\">comments powered by Disqus.</a></noscript>\\r\\n\\r\\n<script>\\r\\n// Default language\\r\\nvar userLocale = \\"en\\";\\r\\n// Translations\\r\\nvar messages = {\\"en\\": {\\r\\n                        \\"i18n_welldone\\": \\"Well done!\\",\\r\\n                        \\"i18n_welldone_text\\": \\"Your answer has been saved\\",\\r\\n                        \\"i18n_loading_next_task\\": \\"Loading next task...\\",\\r\\n                        \\"i18n_task_completed\\": \\"The task has been completed!\\",\\r\\n                        \\"i18n_thanks\\": \\"Thanks a lot!\\",\\r\\n                        \\"i18n_congratulations\\": \\"Congratulations\\",\\r\\n                        \\"i18n_congratulations_text\\": \\"You have participated in all available tasks!\\",\\r\\n                        \\"i18n_yes\\": \\"Yes\\",\\r\\n                        \\"i18n_no_photo\\": \\"No photo\\",\\r\\n                        \\"i18n_i_dont_know\\": \\"I don't know\\",\\r\\n                        \\"i18n_working_task\\": \\"You are working now on task:\\",\\r\\n                        \\"i18n_tasks_completed\\": \\"You have completed:\\",\\r\\n                        \\"i18n_tasks_from\\": \\"tasks from\\",\\r\\n                        \\"i18n_show_comments\\": \\"Show comments:\\",\\r\\n                        \\"i18n_hide_comments\\": \\"Hide comments:\\",\\r\\n                        \\"i18n_question\\": \\"Do you see a human face in this photo?\\",\\r\\n                      },\\r\\n                \\"es\\": {\\r\\n                        \\"i18n_welldone\\": \\"Bien hecho!\\",\\r\\n                        \\"i18n_welldone_text\\": \\"Tu respuesta ha sido guardada\\",\\r\\n                        \\"i18n_loading_next_task\\": \\"Cargando la siguiente tarea...\\",\\r\\n                        \\"i18n_task_completed\\": \\"La tarea ha sido completadas!\\",\\r\\n                        \\"i18n_thanks\\": \\"Much\\u00edsimas gracias!\\",\\r\\n                        \\"i18n_congratulations\\": \\"Enhorabuena\\",\\r\\n                        \\"i18n_congratulations_text\\": \\"Has participado en todas las tareas disponibles!\\",\\r\\n                        \\"i18n_yes\\": \\"S\\u00ed\\",\\r\\n                        \\"i18n_no_photo\\": \\"No hay foto\\",\\r\\n                        \\"i18n_i_dont_know\\": \\"No lo s\\u00e9\\",\\r\\n                        \\"i18n_working_task\\": \\"Est\\u00e1s trabajando en la tarea:\\",\\r\\n                        \\"i18n_tasks_completed\\": \\"Has completado:\\",\\r\\n                        \\"i18n_tasks_from\\": \\"tareas de\\",\\r\\n                        \\"i18n_show_comments\\": \\"Mostrar comentarios\\",\\r\\n                        \\"i18n_hide_comments\\": \\"Ocultar comentarios\\",\\r\\n                        \\"i18n_question\\": \\"\\u00bfVes una cara humana en esta foto?\\",\\r\\n                      },\\r\\n               };\\r\\n// Update userLocale with server side information\\r\\n $(document).ready(function(){\\r\\n     userLocale = document.getElementById('PYBOSSA_USER_LOCALE').textContent.trim();\\r\\n\\r\\n});\\r\\n\\r\\nfunction i18n_translate() {\\r\\n    var ids = Object.keys(messages[userLocale])\\r\\n    for (i=0; i<ids.length; i++) {\\r\\n        console.log(\\"Translating: \\" + ids[i]);\\r\\n        document.getElementById(ids[i]).innerHTML = messages[userLocale][ids[i]];\\r\\n    }\\r\\n}\\r\\n\\r\\n\\r\\nfunction loadUserProgress() {\\r\\n    pybossa.userProgress('flickrperson').done(function(data){\\r\\n        var pct = Math.round((data.done*100)/data.total);\\r\\n        $(\\"#progress\\").css(\\"width\\", pct.toString() +\\"%\\");\\r\\n        $(\\"#progress\\").attr(\\"title\\", pct.toString() + \\"% completed!\\");\\r\\n        $(\\"#progress\\").tooltip({'placement': 'left'}); \\r\\n        $(\\"#total\\").text(data.total);\\r\\n        $(\\"#done\\").text(data.done);\\r\\n    });\\r\\n}\\r\\n\\r\\npybossa.taskLoaded(function(task, deferred) {\\r\\n    if ( !$.isEmptyObject(task) ) {\\r\\n        // load image from flickr\\r\\n        var img = $('<img />');\\r\\n        img.load(function() {\\r\\n            // continue as soon as the image is loaded\\r\\n            deferred.resolve(task);\\r\\n        });\\r\\n        img.attr('src', task.info.url_b).css('height', 460);\\r\\n        img.addClass('img-thumbnail img-responsive');\\r\\n        task.info.image = img;\\r\\n    }\\r\\n    else {\\r\\n        deferred.resolve(task);\\r\\n    }\\r\\n});\\r\\n\\r\\npybossa.presentTask(function(task, deferred) {\\r\\n    if ( !$.isEmptyObject(task) ) {\\r\\n        loadUserProgress();\\r\\n        i18n_translate();\\r\\n        $('#photo-link').html('').append(task.info.image);\\r\\n        $(\\"#photo-link\\").attr(\\"href\\", task.info.link);\\r\\n        //$(\\"#question\\").html(task.info.question);\\r\\n        $('#task-id').html(task.id);\\r\\n        $('.btn-answer').off('click').on('click', function(evt) {\\r\\n            var answer = $(this).attr(\\"value\\");\\r\\n            if (typeof answer != 'undefined') {\\r\\n                //console.log(answer);\\r\\n                pybossa.saveTask(task.id, answer).done(function() {\\r\\n                    deferred.resolve();\\r\\n                });\\r\\n                $(\\"#loading\\").fadeIn(500);\\r\\n                if ($(\\"#disqus_thread\\").is(\\":visible\\")) {\\r\\n                    $('#disqus_thread').toggle();\\r\\n                    $('.btn-disqus').toggle();\\r\\n                }\\r\\n            }\\r\\n            else {\\r\\n                $(\\"#error\\").show();\\r\\n            }\\r\\n        });\\r\\n        $(\\"#loading\\").hide();\\r\\n    }\\r\\n    else {\\r\\n        $(\\".skeleton\\").hide();\\r\\n        $(\\"#loading\\").hide();\\r\\n        $(\\"#finish\\").fadeIn(500);\\r\\n    }\\r\\n});\\r\\n\\r\\npybossa.run('thing-tagging');\\r\\n</script>\\r\\n"}
\.


--
-- Name: project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_id_seq', 1, true);


--
-- Data for Name: project_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_stats (id, project_id, n_tasks, n_task_runs, n_results, n_volunteers, n_completed_tasks, overall_progress, average_time, n_blogposts, last_activity, info) FROM stdin;
1	1	9	9	0	1	0	0	1.35312800000000011	0	2018-03-16T01:57:32.246990	{"hours_stats": [{"disabled": "True", "max": 9, "values": [[0, 0, 0], [1, 9, 5], [2, 0, 0], [3, 0, 0], [4, 0, 0], [5, 0, 0], [6, 0, 0], [7, 0, 0], [8, 0, 0], [9, 0, 0], [10, 0, 0], [11, 0, 0], [12, 0, 0], [13, 0, 0], [14, 0, 0], [15, 0, 0], [16, 0, 0], [17, 0, 0], [18, 0, 0], [19, 0, 0], [20, 0, 0], [21, 0, 0], [22, 0, 0], [23, 0, 0]], "label": "Anon + Auth"}, {"max": null, "values": [[0, 0, 0], [1, 0, 0], [2, 0, 0], [3, 0, 0], [4, 0, 0], [5, 0, 0], [6, 0, 0], [7, 0, 0], [8, 0, 0], [9, 0, 0], [10, 0, 0], [11, 0, 0], [12, 0, 0], [13, 0, 0], [14, 0, 0], [15, 0, 0], [16, 0, 0], [17, 0, 0], [18, 0, 0], [19, 0, 0], [20, 0, 0], [21, 0, 0], [22, 0, 0], [23, 0, 0]], "label": "Anonymous"}, {"max": 9, "values": [[0, 0, 0], [1, 9, 5], [2, 0, 0], [3, 0, 0], [4, 0, 0], [5, 0, 0], [6, 0, 0], [7, 0, 0], [8, 0, 0], [9, 0, 0], [10, 0, 0], [11, 0, 0], [12, 0, 0], [13, 0, 0], [14, 0, 0], [15, 0, 0], [16, 0, 0], [17, 0, 0], [18, 0, 0], [19, 0, 0], [20, 0, 0], [21, 0, 0], [22, 0, 0], [23, 0, 0]], "label": "Authenticated"}], "dates_stats": [{"values": [[1520035200000, 0], [1520121600000, 0], [1520208000000, 0], [1520294400000, 0], [1520380800000, 0], [1520467200000, 0], [1520553600000, 0], [1520640000000, 0], [1520726400000, 0], [1520812800000, 0], [1520899200000, 0], [1520985600000, 0], [1521072000000, 0], [1521158400000, 9]], "label": "Anon + Auth"}, {"values": [[1520035200000, 0], [1520121600000, 0], [1520208000000, 0], [1520294400000, 0], [1520380800000, 0], [1520467200000, 0], [1520553600000, 0], [1520640000000, 0], [1520726400000, 0], [1520812800000, 0], [1520899200000, 0], [1520985600000, 0], [1521072000000, 0], [1521158400000, 0]], "label": "Anonymous"}, {"values": [[1520035200000, 0], [1520121600000, 0], [1520208000000, 0], [1520294400000, 0], [1520380800000, 0], [1520467200000, 0], [1520553600000, 0], [1520640000000, 0], [1520726400000, 0], [1520812800000, 0], [1520899200000, 0], [1520985600000, 0], [1521072000000, 0], [1521158400000, 9]], "label": "Authenticated"}, {"disabled": "True", "values": [[1520035200000, 0], [1520121600000, 0], [1520208000000, 0], [1520294400000, 0], [1520380800000, 0], [1520467200000, 0], [1520553600000, 0], [1520640000000, 0], [1520726400000, 0], [1520812800000, 0], [1520899200000, 0], [1520985600000, 0], [1521072000000, 0], [1521158400000, 9]], "label": "Completed Tasks"}], "users_stats": {"n_anon": 0, "anon": {"locs": [], "top5": [], "values": [], "label": "Anonymous Users"}, "n_auth": 1, "auth": {"top5": [{"fullname": "Admin", "tasks": 9, "name": "admin"}], "values": [{"value": [9], "label": 1}], "label": "Authenticated Users"}, "users": {"values": [{"value": [0, 0], "label": "Anonymous"}, {"value": [0, 1], "label": "Authenticated"}], "label": "User Statistics"}}}
\.


--
-- Name: project_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_stats_id_seq', 1, true);


--
-- Data for Name: result; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.result (id, created, project_id, task_id, task_run_ids, last_version, info) FROM stdin;
\.


--
-- Name: result_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.result_id_seq', 1, false);


--
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task (id, created, project_id, state, quorum, calibration, priority_0, info, n_answers, fav_user_ids) FROM stdin;
1	2018-03-16T01:53:29.917912	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/james_gordon_losangeles/7664319442/", "url_m": "http://farm9.staticflickr.com/8289/7664319442_903793356d_b.jpg", "question": "Is this building damaged?", "url_b": "http://farm9.staticflickr.com/8289/7664319442_903793356d_b.jpg"}	30	\N
2	2018-03-16T01:53:29.932404	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/teleyinex/3935049892/", "url_m": "http://farm3.staticflickr.com/2495/3935049892_1c9eff9c54_m.jpg", "question": "Do you see a human in this photo?", "url_b": "http://farm3.staticflickr.com/2495/3935049892_1c9eff9c54_b.jpg"}	30	\N
3	2018-03-16T01:53:29.944717	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/teleyinex/6286728068/", "url_m": "http://farm7.staticflickr.com/6109/6286728068_2f3c6912b8_m.jpg", "question": "Do you see a human in this photo?", "url_b": "http://farm7.staticflickr.com/6109/6286728068_2f3c6912b8_b.jpg"}	30	\N
4	2018-03-16T01:53:29.958149	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/teleyinex/5882457996/", "url_m": "http://farm7.staticflickr.com/6025/5882457996_a2e55e7219_m.jpg", "question": "Do you see a human in this photo?", "url_b": "http://farm7.staticflickr.com/6025/5882457996_a2e55e7219_b.jpg"}	30	\N
5	2018-03-16T01:53:29.971201	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/teleyinex/8288437481/", "url_m": "http://farm9.staticflickr.com/8217/8288437481_697ae7bda6_m.jpg", "question": "Do you see a human in this photo?", "url_b": "http://farm9.staticflickr.com/8217/8288437481_697ae7bda6_b.jpg"}	30	\N
6	2018-03-16T01:53:29.983204	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/teleyinex/5471374135/", "url_m": "http://farm6.staticflickr.com/5020/5471374135_9cd6de17a9_m.jpg", "question": "Do you see a human in this photo?", "url_b": "http://farm6.staticflickr.com/5020/5471374135_9cd6de17a9_b.jpg"}	30	\N
7	2018-03-16T01:53:29.994579	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/teleyinex/6453792093/", "url_m": "http://farm8.staticflickr.com/7152/6453792093_3690418daa_m.jpg", "question": "Do you see a human in this photo?", "url_b": "http://farm8.staticflickr.com/7152/6453792093_3690418daa_b.jpg"}	30	\N
8	2018-03-16T01:53:30.007162	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/teleyinex/4983443968/", "url_m": "http://farm5.staticflickr.com/4105/4983443968_60058ff085_m.jpg", "question": "Do you see a human in this photo?", "url_b": "http://farm5.staticflickr.com/4105/4983443968_60058ff085_b.jpg"}	30	\N
9	2018-03-16T01:53:30.018011	1	ongoing	0	0	0	{"link": "http://www.flickr.com/photos/teleyinex/398851722/", "url_m": "http://farm1.staticflickr.com/184/398851722_fc8e50e19e_m.jpg", "question": "Do you see a human in this photo?", "url_b": "http://farm1.staticflickr.com/184/398851722_fc8e50e19e_b.jpg"}	30	\N
\.


--
-- Name: task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_id_seq', 9, true);


--
-- Data for Name: task_run; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_run (id, created, project_id, task_id, user_id, user_ip, finish_time, timeout, calibration, external_uid, info) FROM stdin;
1	2018-03-16T01:57:25.463177	1	1	1	\N	2018-03-16T01:57:27.488586	\N	\N	\N	"Yes"
2	2018-03-16T01:57:26.038120	1	2	1	\N	2018-03-16T01:57:28.207215	\N	\N	\N	"No"
3	2018-03-16T01:57:27.527616	1	3	1	\N	2018-03-16T01:57:28.881547	\N	\N	\N	"Yes"
4	2018-03-16T01:57:28.250942	1	4	1	\N	2018-03-16T01:57:29.430288	\N	\N	\N	"No"
5	2018-03-16T01:57:28.918308	1	5	1	\N	2018-03-16T01:57:29.916273	\N	\N	\N	"Yes"
6	2018-03-16T01:57:29.477289	1	6	1	\N	2018-03-16T01:57:30.585585	\N	\N	\N	"No"
7	2018-03-16T01:57:29.956646	1	7	1	\N	2018-03-16T01:57:31.223384	\N	\N	\N	"Yes"
8	2018-03-16T01:57:30.621102	1	8	1	\N	2018-03-16T01:57:31.706427	\N	\N	\N	"No"
9	2018-03-16T01:57:31.254943	1	9	1	\N	2018-03-16T01:57:32.246990	\N	\N	\N	"Yes"
\.


--
-- Name: task_run_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_run_id_seq', 9, true);


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, created, email_addr, name, fullname, locale, api_key, passwd_hash, admin, pro, privacy_mode, category, flags, twitter_user_id, facebook_user_id, google_user_id, ckan_api, newsletter_prompted, valid_email, confirmation_email_sent, subscribed, consent, info) FROM stdin;
1	2018-03-16T01:51:44.106026	admin@example.com	admin	Admin	en	d95b3b28-e612-49bf-b238-1354c520961f	pbkdf2:sha256:50000$sLutLYsU$aee7efe0f63cc869246d1afcd8e32840bc140a51d9cfc375f21b6dc7ec7509b2	t	f	t	\N	\N	\N	\N	\N	\N	f	t	f	t	f	{}
\.


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 1, true);


--
-- Data for Name: webhook; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.webhook (id, created, updated, project_id, payload, response, response_status_code) FROM stdin;
\.


--
-- Name: webhook_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.webhook_id_seq', 1, false);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- Name: dashboard_week_project_draft; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_project_draft AS
 SELECT to_date(project.created, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day,
    project.id,
    project.short_name,
    project.name,
    project.owner_id,
    "user".name AS u_name,
    "user".email_addr
   FROM public.project,
    public."user"
  WHERE ((to_date(project.created, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval)) AND ("user".id = project.owner_id) AND (project.published = false))
  GROUP BY project.id, "user".name, "user".email_addr
  WITH NO DATA;


ALTER TABLE public.dashboard_week_project_draft OWNER TO postgres;

--
-- Name: auditlog auditlog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditlog
    ADD CONSTRAINT auditlog_pkey PRIMARY KEY (id);


--
-- Name: dashboard_week_project_published; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_project_published AS
 SELECT to_date(auditlog.created, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day,
    project.id,
    project.short_name,
    project.name,
    project.owner_id,
    "user".name AS u_name,
    "user".email_addr
   FROM public.auditlog,
    public.project,
    public."user"
  WHERE ((to_date(auditlog.created, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval)) AND ("user".id = project.owner_id) AND (project.owner_id = auditlog.user_id) AND (auditlog.project_id = project.id) AND (auditlog.attribute = 'published'::text))
  GROUP BY auditlog.id, "user".name, "user".email_addr, project.id
  WITH NO DATA;


ALTER TABLE public.dashboard_week_project_published OWNER TO postgres;

--
-- Name: dashboard_week_project_update; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.dashboard_week_project_update AS
 SELECT to_date(project.updated, 'YYYY-MM-DD\THH24:MI:SS.US'::text) AS day,
    project.id,
    project.short_name,
    project.name,
    project.owner_id,
    "user".name AS u_name,
    "user".email_addr
   FROM public.project,
    public."user"
  WHERE ((to_date(project.updated, 'YYYY-MM-DD\THH24:MI:SS.US'::text) >= (now() - '7 days'::interval)) AND ("user".id = project.owner_id))
  GROUP BY project.id, "user".name, "user".email_addr
  WITH NO DATA;


ALTER TABLE public.dashboard_week_project_update OWNER TO postgres;

--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: users_rank; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.users_rank AS
 WITH scores AS (
         SELECT "user".id,
            "user".created,
            "user".email_addr,
            "user".name,
            "user".fullname,
            "user".locale,
            "user".api_key,
            "user".passwd_hash,
            "user".admin,
            "user".pro,
            "user".privacy_mode,
            "user".category,
            "user".flags,
            "user".twitter_user_id,
            "user".facebook_user_id,
            "user".google_user_id,
            "user".ckan_api,
            "user".newsletter_prompted,
            "user".valid_email,
            "user".confirmation_email_sent,
            "user".subscribed,
            "user".consent,
            "user".info,
            count(task_run.user_id) AS score
           FROM (public."user"
             LEFT JOIN public.task_run ON ((task_run.user_id = "user".id)))
          GROUP BY "user".id
        )
 SELECT scores.id,
    scores.created,
    scores.email_addr,
    scores.name,
    scores.fullname,
    scores.locale,
    scores.api_key,
    scores.passwd_hash,
    scores.admin,
    scores.pro,
    scores.privacy_mode,
    scores.category,
    scores.flags,
    scores.twitter_user_id,
    scores.facebook_user_id,
    scores.google_user_id,
    scores.ckan_api,
    scores.newsletter_prompted,
    scores.valid_email,
    scores.confirmation_email_sent,
    scores.subscribed,
    scores.consent,
    scores.info,
    scores.score,
    row_number() OVER (ORDER BY scores.score DESC) AS rank
   FROM scores
  WITH NO DATA;


ALTER TABLE public.users_rank OWNER TO postgres;

--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: announcement announcement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement
    ADD CONSTRAINT announcement_pkey PRIMARY KEY (id);


--
-- Name: blogpost blogpost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blogpost
    ADD CONSTRAINT blogpost_pkey PRIMARY KEY (id);


--
-- Name: category category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_name_key UNIQUE (name);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: category category_short_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_short_name_key UNIQUE (short_name);


--
-- Name: counter counter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counter
    ADD CONSTRAINT counter_pkey PRIMARY KEY (id);


--
-- Name: helpingmaterial helpingmaterial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.helpingmaterial
    ADD CONSTRAINT helpingmaterial_pkey PRIMARY KEY (id);


--
-- Name: project project_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_name_key UNIQUE (name);


--
-- Name: project project_short_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_short_name_key UNIQUE (short_name);


--
-- Name: project_stats project_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_stats
    ADD CONSTRAINT project_stats_pkey PRIMARY KEY (id);


--
-- Name: result result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: task_run task_run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_run
    ADD CONSTRAINT task_run_pkey PRIMARY KEY (id);


--
-- Name: user user_api_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_api_key_key UNIQUE (api_key);


--
-- Name: user user_ckan_api_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_ckan_api_key UNIQUE (ckan_api);


--
-- Name: user user_email_addr_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_addr_key UNIQUE (email_addr);


--
-- Name: user user_facebook_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_facebook_user_id_key UNIQUE (facebook_user_id);


--
-- Name: user user_google_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_google_user_id_key UNIQUE (google_user_id);


--
-- Name: user user_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_name_key UNIQUE (name);


--
-- Name: user user_passwd_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_passwd_hash_key UNIQUE (passwd_hash);


--
-- Name: user user_twitter_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_twitter_user_id_key UNIQUE (twitter_user_id);


--
-- Name: webhook webhook_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhook
    ADD CONSTRAINT webhook_pkey PRIMARY KEY (id);


--
-- Name: users_rank_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_rank_idx ON public.users_rank USING btree (id, rank);


--
-- Name: announcement announcement_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement
    ADD CONSTRAINT announcement_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: blogpost blogpost_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blogpost
    ADD CONSTRAINT blogpost_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: blogpost blogpost_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blogpost
    ADD CONSTRAINT blogpost_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: counter counter_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counter
    ADD CONSTRAINT counter_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: counter counter_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counter
    ADD CONSTRAINT counter_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: helpingmaterial helpingmaterial_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.helpingmaterial
    ADD CONSTRAINT helpingmaterial_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: project project_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id);


--
-- Name: project project_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public."user"(id);


--
-- Name: project_stats project_stats_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_stats
    ADD CONSTRAINT project_stats_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: result result_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: result result_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: task_run task_run_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_run
    ADD CONSTRAINT task_run_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: task_run task_run_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_run
    ADD CONSTRAINT task_run_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: task_run task_run_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_run
    ADD CONSTRAINT task_run_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: webhook webhook_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhook
    ADD CONSTRAINT webhook_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: dashboard_week_anon; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_anon;


--
-- Name: dashboard_week_new_task; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_new_task;


--
-- Name: dashboard_week_new_task_run; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_new_task_run;


--
-- Name: dashboard_week_new_users; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_new_users;


--
-- Name: dashboard_week_project_draft; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_project_draft;


--
-- Name: dashboard_week_project_published; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_project_published;


--
-- Name: dashboard_week_project_update; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_project_update;


--
-- Name: dashboard_week_returning_users; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_returning_users;


--
-- Name: dashboard_week_users; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.dashboard_week_users;


--
-- Name: users_rank; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.users_rank;


--
-- PostgreSQL database dump complete
--


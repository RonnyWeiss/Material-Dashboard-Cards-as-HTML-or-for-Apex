prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_release=>'5.1.3.00.05'
,p_default_workspace_id=>21717127411908241868
,p_default_application_id=>103428
,p_default_owner=>'RD_DEV'
);
end;
/

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/apex_material_cards
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(50647647170575284673)
,p_plugin_type=>'REGION TYPE'
,p_name=>'APEX.MATERIAL.CARDS'
,p_display_name=>'APEX Material Cards'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'FUNCTION SQL_TO_SYS_REFCURSOR (',
'    P_IN_SQL_STATEMENT   CLOB,',
'    P_IN_BINDS           SYS.DBMS_SQL.VARCHAR2_TABLE',
') RETURN SYS_REFCURSOR AS',
'    VR_CURS         BINARY_INTEGER;',
'    VR_REF_CURSOR   SYS_REFCURSOR;',
'    VR_EXEC         BINARY_INTEGER;',
'/* TODO make size dynamic */',
'    VR_BINDS        VARCHAR(100);',
'BEGIN',
'    VR_CURS         := DBMS_SQL.OPEN_CURSOR;',
'    DBMS_SQL.PARSE(',
'        VR_CURS,',
'        P_IN_SQL_STATEMENT,',
'        DBMS_SQL.NATIVE',
'    );',
'    IF P_IN_BINDS.COUNT > 0 THEN',
'        FOR I IN 1..P_IN_BINDS.COUNT LOOP',
'        /* TODO find out how to prevent ltrim */',
'            VR_BINDS   := LTRIM(',
'                P_IN_BINDS(I),',
'                '':''',
'            );',
'            DBMS_SQL.BIND_VARIABLE(',
'                VR_CURS,',
'                VR_BINDS,',
'                V(VR_BINDS)',
'            );',
'        END LOOP;',
'    END IF;',
'',
'    VR_EXEC         := DBMS_SQL.EXECUTE(VR_CURS);',
'    VR_REF_CURSOR   := DBMS_SQL.TO_REFCURSOR(VR_CURS);',
'    RETURN VR_REF_CURSOR;',
'EXCEPTION',
'    WHEN OTHERS THEN',
'        IF DBMS_SQL.IS_OPEN(VR_CURS) THEN',
'            DBMS_SQL.CLOSE_CURSOR(VR_CURS);',
'        END IF;',
'        RAISE;',
'END;',
'',
'FUNCTION F_AJAX (',
'    P_REGION   IN         APEX_PLUGIN.T_REGION,',
'    P_PLUGIN   IN         APEX_PLUGIN.T_PLUGIN',
') RETURN APEX_PLUGIN.T_REGION_AJAX_RESULT IS',
'    VR_RESULT       APEX_PLUGIN.T_REGION_AJAX_RESULT;',
'    VR_CUR          SYS_REFCURSOR;',
'    VR_BIND_NAMES   SYS.DBMS_SQL.VARCHAR2_TABLE;',
'BEGIN',
'    /* undocumented function of APEX for get all bindings */',
'    VR_BIND_NAMES   := WWV_FLOW_UTILITIES.GET_BINDS(P_REGION.SOURCE);',
'',
'    /* execute binding*/',
'    VR_CUR          := SQL_TO_SYS_REFCURSOR(',
'        RTRIM(',
'            P_REGION.SOURCE,',
'            '';''',
'        ),',
'        VR_BIND_NAMES',
'    );',
'',
'    /* create json */',
'    APEX_JSON.OPEN_OBJECT;',
'    APEX_JSON.WRITE(',
'        ''row'',',
'        VR_CUR',
'    );',
'    APEX_JSON.CLOSE_OBJECT;',
'',
'    RETURN VR_RESULT;',
'END;',
'',
'FUNCTION F_RENDER (',
'    P_REGION                IN APEX_PLUGIN.T_REGION,',
'    P_PLUGIN                IN APEX_PLUGIN.T_PLUGIN,',
'    P_IS_PRINTER_FRIENDLY   IN BOOLEAN',
') RETURN APEX_PLUGIN.T_REGION_RENDER_RESULT IS',
'    VR_RESULT       APEX_PLUGIN.T_REGION_RENDER_RESULT;',
'    VR_CONF_JSON    CONSTANT APEX_APPLICATION_PAGE_REGIONS.ATTRIBUTE_01%TYPE := P_REGION.ATTRIBUTE_01;',
'    VR_ERR_MSG      CONSTANT APEX_APPLICATION_PAGE_REGIONS.ATTRIBUTE_04%TYPE := P_REGION.ATTRIBUTE_04;',
'    VR_ITEMS2SUBMIT CONSTANT APEX_APPLICATION_PAGE_REGIONS.AJAX_ITEMS_TO_SUBMIT%TYPE := APEX_PLUGIN_UTIL.PAGE_ITEM_NAMES_TO_JQUERY(P_REGION.AJAX_ITEMS_TO_SUBMIT);',
'    VR_REGION_ID    CONSTANT VARCHAR2(200) := ''mc-'' || P_REGION.STATIC_ID;',
'    VR_SANITIZE     BOOLEAN := TRUE;',
'    ',
'BEGIN',
'    APEX_CSS.ADD_FILE(',
'        P_NAME        => ''materialcards.pkgd.min'',',
'        P_DIRECTORY   => P_PLUGIN.FILE_PREFIX,',
'        P_VERSION     => NULL,',
'        P_KEY         => ''materialcardscsssrc''',
'    );',
'',
'    APEX_JAVASCRIPT.ADD_LIBRARY(',
'        P_NAME        => ''materialcards.pkgd.min'',',
'        P_DIRECTORY   => P_PLUGIN.FILE_PREFIX,',
'        P_VERSION     => NULL,',
'        P_KEY         => ''materialcardsjssrc''',
'    );',
'    ',
'    IF',
'        P_REGION.ATTRIBUTE_02 = ''N''',
'    THEN',
'        VR_SANITIZE   := FALSE;',
'    ELSE',
'        VR_SANITIZE   := TRUE;',
'    END IF;',
'',
'    HTP.P( ''<div id="'' || APEX_PLUGIN_UTIL.ESCAPE( VR_REGION_ID, TRUE ) || ''"></div>'' );',
'',
'    APEX_JAVASCRIPT.ADD_ONLOAD_CODE( ''materialCards.initialize(''',
'     || APEX_JAVASCRIPT.ADD_VALUE( VR_REGION_ID, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( APEX_PLUGIN.GET_AJAX_IDENTIFIER, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( P_REGION.NO_DATA_FOUND_MESSAGE, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( VR_ERR_MSG, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( VR_CONF_JSON, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( VR_ITEMS2SUBMIT, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( P_REGION.STATIC_ID, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( P_REGION.ESCAPE_OUTPUT, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( VR_SANITIZE, TRUE )',
'     || APEX_JAVASCRIPT.ADD_VALUE( P_REGION.ATTRIBUTE_03, FALSE )',
'     || '');'' );',
'',
'    RETURN VR_RESULT;',
'END;'))
,p_api_version=>1
,p_render_function=>'F_RENDER'
,p_ajax_function=>'F_AJAX'
,p_standard_attributes=>'SOURCE_SQL:AJAX_ITEMS_TO_SUBMIT:NO_DATA_FOUND_MESSAGE:ESCAPE_OUTPUT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'This Plug-in is used to draw some nice material design cards in APEX. Just add this region plug-in on your page and look into the help tab to learn about what you have to todo in sql statement. Normally when you add this Plug-in to your page the Defa'
||'ult SQL Statement will be set automatically to your Region SQL Source so you can have a look at your finished page to see that everything works. The Cards can just show an icon or some nice responsive charts. The Cards itself are also responsive with'
||' tehir own responsive grid so you can use them also in a not responsive theme. For licenses please take a look at the comments.'
,p_version_identifier=>'1.5'
,p_about_url=>'https://github.com/RonnyWeiss/Material-Dashboard-Cards-as-HTML-or-for-Apex'
,p_files_version=>1094
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(50647706839819500301)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'ConfigJSON'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{',
'  "cardWidth": 4,',
'  "refresh": 20',
'}'))
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'{',
'  "cardWidth": 4,',
'  "refresh": 0',
'}',
'</pre>',
'<br>',
'<h3>Explanation:</h3>',
'  <dl>',
'  <dt>cardWidth (number)</dt>',
'  <dd>width per card between 1 and 12</dd>',
'  <dl>',
'  <dt>refresh (number)</dt>',
'  <dd>wrefresh time of cards in seconds if 0 then no refresh will be set</dd>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(29458252675333455841)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Sanitize HTML'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Sanitizes HTML e.g. &lt;script&gt; tags will be removed.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(29459082557255458297)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Sanitize HTML Options'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{',
'  "ALLOWED_ATTR": [',
'    "accesskey",',
'    "align",',
'    "alt",',
'    "always",',
'    "autocomplete",',
'    "autoplay",',
'    "border",',
'    "cellpadding",',
'    "cellspacing",',
'    "charset",',
'    "class",',
'    "colspan",',
'    "dir",',
'    "height",',
'    "href",',
'    "id",',
'    "lang",',
'    "name",',
'    "rel",',
'    "required",',
'    "rowspan",',
'    "src",',
'    "style",',
'    "summary",',
'    "tabindex",',
'    "target",',
'    "title",',
'    "type",',
'    "value",',
'    "width"',
'  ],',
'  "ALLOWED_TAGS": [',
'    "a",',
'    "address",',
'    "b",',
'    "blockquote",',
'    "br",',
'    "caption",',
'    "code",',
'    "dd",',
'    "div",',
'    "dl",',
'    "dt",',
'    "em",',
'    "figcaption",',
'    "figure",',
'    "h1",',
'    "h2",',
'    "h3",',
'    "h4",',
'    "h5",',
'    "h6",',
'    "hr",',
'    "i",',
'    "img",',
'    "label",',
'    "li",',
'    "nl",',
'    "ol",',
'    "p",',
'    "pre",',
'    "s",',
'    "span",',
'    "strike",',
'    "strong",',
'    "sub",',
'    "sup",',
'    "table",',
'    "tbody",',
'    "td",',
'    "th",',
'    "thead",',
'    "tr",',
'    "u",',
'    "ul"',
'  ]',
'}'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(29458252675333455841)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'This Clob Loader includes a sanitizer for HTML as option to use:',
'A Full Description you will find on: https://github.com/cure53/DOMPurify',
'Example: ',
'<pre>',
'{',
'  "ALLOWED_ATTR": [',
'    "accesskey",',
'    "align",',
'    "alt",',
'    "always",',
'    "autocomplete",',
'    "autoplay",',
'    "border",',
'    "cellpadding",',
'    "cellspacing",',
'    "charset",',
'    "class",',
'    "colspan",',
'    "dir",',
'    "height",',
'    "href",',
'    "id",',
'    "lang",',
'    "name",',
'    "rel",',
'    "required",',
'    "rowspan",',
'    "src",',
'    "style",',
'    "summary",',
'    "tabindex",',
'    "target",',
'    "title",',
'    "type",',
'    "value",',
'    "width"',
'  ],',
'  "ALLOWED_TAGS": [',
'    "a",',
'    "address",',
'    "b",',
'    "blockquote",',
'    "br",',
'    "caption",',
'    "code",',
'    "dd",',
'    "div",',
'    "dl",',
'    "dt",',
'    "em",',
'    "figcaption",',
'    "figure",',
'    "h1",',
'    "h2",',
'    "h3",',
'    "h4",',
'    "h5",',
'    "h6",',
'    "hr",',
'    "i",',
'    "img",',
'    "label",',
'    "li",',
'    "nl",',
'    "ol",',
'    "p",',
'    "pre",',
'    "s",',
'    "span",',
'    "strike",',
'    "strong",',
'    "sub",',
'    "sup",',
'    "table",',
'    "tbody",',
'    "td",',
'    "th",',
'    "thead",',
'    "tr",',
'    "u",',
'    "ul"',
'  ]',
'}',
'</pre>',
'<pre>',
'# make output safe for usage in jQuery''s $()/html() method (default is false)',
'SAFE_FOR_JQUERY: true',
'',
'# strip {{ ... }} and &amp;lt;% ... %&amp;gt; to make output safe for template systems',
'# be careful please, this mode is not recommended for production usage.',
'# allowing template parsing in user-controlled HTML is not advised at all.',
'# only use this mode if there is really no alternative.',
'SAFE_FOR_TEMPLATES: true',
'',
'# allow only &amp;lt;b&amp;gt;',
'ALLOWED_TAGS: [''b'']',
'',
'# allow only &amp;lt;b&amp;gt; and &amp;lt;q&amp;gt; with style attributes (for whatever reason)',
'ALLOWED_TAGS: [''b'', ''q''], ALLOWED_ATTR: [''style'']',
'',
'# allow all safe HTML elements but neither SVG nor MathML',
'USE_PROFILES: {html: true}',
'',
'# allow all safe SVG elements and SVG Filters',
'USE_PROFILES: {svg: true, svgFilters: true}',
'',
'# allow all safe MathML elements and SVG',
'USE_PROFILES: {mathMl: true, svg: true}',
'',
'# leave all as it is but forbid &amp;lt;style&amp;gt;',
'FORBID_TAGS: [''style'']',
'',
'# leave all as it is but forbid style attributes',
'FORBID_ATTR: [''style'']',
'',
'# extend the existing array of allowed tags',
'ADD_TAGS: [''my-tag'']',
'',
'# extend the existing array of attributes',
'ADD_ATTR: [''my-attr'']',
'',
'# prohibit HTML5 data attributes (default is true)',
'ALLOW_DATA_ATTR: false',
'',
'# allow external protocol handlers in URL attributes (default is false)',
'# by default only http, https, ftp, ftps, tel, mailto, callto, cid and xmpp are allowed.',
'ALLOW_UNKNOWN_PROTOCOLS: true',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(33620191493475895361)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'When Error occured'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'Error occured'
,p_is_translatable=>true
,p_help_text=>'This message is shown when any error is occured. Please check Browser console for debug information when this text is shown.'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(50647655997799284703)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_name=>'SOURCE_SQL'
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'WITH DAT1 ',
'     AS (SELECT LISTAGG(ROUND(DBMS_RANDOM.VALUE(1, 5)), '','') ',
'                  WITHIN GROUP (ORDER BY ROWNUM) ',
'         FROM   DUAL ',
'         CONNECT BY ROWNUM <= 5), ',
'     DAT2 ',
'     AS (SELECT LISTAGG(ROUND(DBMS_RANDOM.VALUE(1, 20)), '','') ',
'                  WITHIN GROUP (ORDER BY ROWNUM) ',
'         FROM   DUAL ',
'         CONNECT BY ROWNUM <= 5), ',
'     DAT3 ',
'     AS (SELECT LISTAGG(ROUND(DBMS_RANDOM.VALUE(1, 20)), '','') ',
'                  WITHIN GROUP (ORDER BY ROWNUM) ',
'         FROM   DUAL ',
'         CONNECT BY ROWNUM <= 5),',
'    DAT4 AS (SELECT ROUND(DBMS_RANDOM.VALUE(40, 100)) AS VALUE FROM DUAL)',
'SELECT ',
'       ''icon'' AS CARD_TYPE, ',
'       DECODE(ROWNUM, 1, ''fa-globe'', 2, ''fa-gear'', ''https://raw.githubusercontent.com/RonnyWeiss/APEX-Advent-Calendar/master/img/thumb/01.jpg'') AS CARD_ICON, ',
'       NULL AS CARD_ICON_COLOR, ',
'       NULL AS CARD_HEADER_STYLE,',
'       NULL AS CARD_HEADER_CLASS,',
'       ''Material Card'' AS CARD_TITLE, ',
'       TO_CHAR(SYSDATE + ROWNUM / 24, ''HH24:MM:SS'') AS CARD_VALUE, ',
'       ''This is a Material Card that shows an icon and links to ValueTech'' AS CARD_FOOTER, ',
'       ''https://www.valuetech.de/'' AS CARD_LINK, ',
'       NULL AS CARD_CHART_DATA, ',
'       NULL AS CARD_CHART_CONFIG ',
'FROM   DUAL ',
'CONNECT BY ROWNUM <= 3 ',
'UNION ALL ',
'SELECT ',
'       ''chart-bar'' AS CARD_TYPE, ',
'       ''fa-bar-chart'' AS CARD_ICON, ',
'       NULL AS CARD_ICON_COLOR,',
'       NULL AS CARD_HEADER_STYLE,',
'       NULL AS CARD_HEADER_CLASS,',
'       ''Material Card with bar chart'' AS CARD_TITLE, ',
'       ''100%'' AS CARD_VALUE, ',
'       ''This is a Material Card that shows a bar chart and links to ValueTech'' AS CARD_FOOTER, ',
'       ''https://www.valuetech.de/'' AS CARD_LINK, ',
'       ''{',
'           "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'            "series": [['' ||(SELECT * FROM   DAT1) ||''], ',
'                       ['' ||(SELECT * FROM   DAT2) ||''],',
'                       ['' ||(SELECT * FROM   DAT3) ||'']]',
'        }'' AS CARD_CHART_DATA,',
'       NULL AS CARD_CHART_CONFIG',
'FROM   DUAL ',
'UNION ALL ',
'SELECT ',
'       ''chart-line'' AS CARD_TYPE, ',
'       ''fa-line-chart'' AS CARD_ICON, ',
'       NULL AS CARD_ICON_COLOR,',
'       NULL AS CARD_HEADER_STYLE,',
'       NULL AS CARD_HEADER_CLASS,',
'       ''Material Card with line chart'' AS CARD_TITLE, ',
'       ''100%'' AS CARD_VALUE, ',
'       ''This is a Material Card that shows a line chart and links to ValueTech'' AS CARD_FOOTER, ',
'       ''https://www.valuetech.de/'' AS CARD_LINK, ',
'       ''{',
'          "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'          "series": [['' ||(SELECT * FROM   DAT1) ||'']]',
'        }'' AS CARD_CHART_DATA,',
'       ''{',
'          "low": 0,',
'          "showArea": true',
'        }'' AS CARD_CHART_CONFIG ',
'FROM   DUAL ',
'UNION ALL ',
'SELECT',
'       ''chart-pie'' AS CARD_TYPE, ',
'       ''fa-pie-chart'' AS CARD_ICON, ',
'       NULL AS CARD_ICON_COLOR,',
'       ''background: linear-gradient(60deg, hsl(115, 55%, 60%), hsl(115, 50%, 60%));box-shadow: 0 12px 20px -10px rgba(230, 230, 230, 0.28), 0 4px 20px 0px rgba(0, 0, 0, 0.12), 0 7px 8px -5px rgba(230, 230, 230, 0.2);'' AS CARD_HEADER_STYLE,',
'       NULL AS CARD_HEADER_CLASS,',
'       ''Material Card with pie chart'' AS CARD_TITLE, ',
'       VALUE || '' %'' AS CARD_VALUE, ',
'       ''This is a Material Card that shows a gauge chart and links to ValueTech'' AS CARD_FOOTER, ',
'       ''https://www.valuetech.de/'' AS CARD_LINK, ',
'       ''{',
'          "labels": ["''|| VALUE ||'' %"],',
'          "series": [''|| VALUE ||'']',
'       }'' AS CARD_CHART_DATA,',
'       ''{',
'          "total": 100,',
'          "donut": true,',
'          "donutWidth": 260,',
'          "sliceWidth": 10',
'        }'' AS CARD_CHART_CONFIG',
'FROM DAT4'))
,p_sql_min_column_count=>1
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_depending_on_has_to_exist=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<h3>Large Card with Bar Chart and user defined Card Header Style:</h3>',
'<pre>',
'SELECT ''chart-bar'' AS CARD_TYPE,',
'       ''fa-bar-chart'' AS CARD_ICON,',
'       NULL AS CARD_ICON_COLOR,',
'       ''linear-gradient(60deg, hsl(46, 55%, 60%), hsl(46, 50%, 60%));box-shadow: 0 12px 20px -10px rgba(230, 230, 230, 0.28), 0 4px 20px 0px rgba(0, 0, 0, 0.12), 0 7px 8px -5px rgba(230, 230, 230, 0.2);'' AS CARD_HEADER_STYLE,',
'       ''Material Card with bar chart'' AS CARD_TITLE,',
'       ''100%'' AS CARD_VALUE,',
'       ''This is a Material Card that shows a bar chart and links to ValueTech'' AS CARD_FOOTER,',
'       ''https://www.valuetech.de/'' AS CARD_LINK,',
'       ''{',
'          "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'          "series": [[12, 9, 7, 8, 5], [2, 1, 3.5, 7, 3], [1, 3, 4, 5, 6]],',
'          "colors": ["green", "yellow", "blue", "red", "orange"]',
'        }'' AS CARD_CHART_DATA,',
'       NULL AS CARD_CHART_CONFIG',
'FROM   DUAL',
'</pre>',
'<h3>Large Card with Line Chart:</h3>',
'<pre>',
'SELECT ''chart-line'' AS CARD_TYPE,',
'       ''fa-line-chart'' AS CARD_ICON,',
'       NULL AS CARD_ICON_COLOR,',
'       NULL AS CARD_HEADER_STYLE,',
'       ''Material Card with line chart'' AS CARD_TITLE,',
'       ''100%'' AS CARD_VALUE,',
'       ''This is a Material Card that shows a line chart and links to ValueTech'' AS CARD_FOOTER,',
'       ''https://www.valuetech.de/'' AS CARD_LINK,',
'       ''{',
'          "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'          "series": [[12, 9, 7, 8, 5]]',
'        }'' AS CARD_CHART_DATA,',
'       ''{',
'            "low": 0,',
'            "showArea": true',
'        }'' AS CARD_CHART_CONFIG',
'FROM   DUAL',
'</pre>',
'<h3>Large Card with Pie Chart:</h3>',
'<pre>',
'SELECT ''chart-pie'' AS CARD_TYPE,',
'       ''fa-pie-chart'' AS CARD_ICON,',
'       NULL AS CARD_HEADER_STYLE,',
'       ''Material Card with pie chart'' AS CARD_TITLE,',
'       ''100%'' AS CARD_VALUE,',
'       ''This is a Material Card that shows a pie chart and links to ValueTech'' AS CARD_FOOTER,',
'       ''https://www.valuetech.de/'' AS CARD_LINK,',
'       ''{             ',
'          "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'          "series": [12, 9, 7, 8, 5]',
'        }'' AS CARD_CHART_DATA,',
'       NULL AS CARD_CHART_CONFIG',
'FROM   DUAL ',
'</pre>',
'<h3>Large Card with Gauge Chart:</h3>',
'<pre>',
'WITH DAT AS (SELECT ROUND(DBMS_RANDOM.VALUE(1, 100)) AS VALUE FROM DUAL)',
'SELECT',
'       ''chart-pie'' AS CARD_TYPE, ',
'       ''fa-pie-chart'' AS CARD_ICON, ',
'       NULL AS CARD_ICON_COLOR,',
'       NULL AS CARD_HEADER_STYLE,',
'       ''Material Card with pie chart'' AS CARD_TITLE, ',
'       VALUE || '' %'' AS CARD_VALUE, ',
'       ''This is a Material Card that shows a gauge chart and links to ValueTech'' AS CARD_FOOTER, ',
'       ''https://www.valuetech.de/'' AS CARD_LINK, ',
'       ''{',
'          "labels": ["''|| VALUE ||'' %"],',
'          "series": [''|| VALUE ||'']',
'       }'' AS CARD_CHART_DATA,',
'       ''{',
'          "total": 100,',
'          "donut": true,',
'          "donutWidth": 260,',
'          "sliceWidth": 10',
'        }'' AS CARD_CHART_CONFIG',
'FROM DAT',
'</pre>',
'<h3>Large Card with Horizontal Bar Chart:</h3>',
'<pre>',
'SELECT ',
'       ''chart-bar'' AS CARD_TYPE, ',
'       ''fa-bar-chart'' AS CARD_ICON, ',
'       NULL AS CARD_ICON_COLOR,',
'       NULL AS CARD_HEADER_STYLE,',
'       ''Material Card with bar chart'' AS CARD_TITLE, ',
'       ''100%'' AS CARD_VALUE, ',
'       ''This is a Material Card that shows a horizontal bar chart and links to ValueTech'' AS CARD_FOOTER, ',
'       ''https://www.valuetech.de/'' AS CARD_LINK, ',
'       ''{',
'           "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'            "series": [['' ||(SELECT LISTAGG(ROUND(DBMS_RANDOM.VALUE(1, 5)), '','') ',
'                              WITHIN GROUP (ORDER BY ROWNUM) FROM DUAL CONNECT BY ROWNUM < 5 ) ||'']]',
'        }'' AS CARD_CHART_DATA,',
'       ''{',
'            "horizontalBars": true,',
'            "chartPadding": {',
'                "top": 5',
'            },',
'            "strokeWidth": 12,',
'            "low": 0,',
'            "high": 5',
'        }'' AS CARD_CHART_CONFIG',
'FROM DUAL',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'SELECT ',
' /* defines the type of the chart => icon, chart-bar, chart-line, chart-pie */',
' ''icon'' AS CARD_TYPE,',
' /* defines the font-apex or fon-awesome icons that should used */',
' DECODE(ROWNUM, 1, ''fa-globe'', 2, ''fa-gear'', ''https://raw.githubusercontent.com/RonnyWeiss/APEX-Advent-Calendar/master/img/thumb/01.jpg'') AS CARD_ICON,',
' /* defines the color of the icon e.g white or #ffffff */',
' NULL AS CARD_ICON_COLOR,',
' /* defines the style of the header this could be just a background or maybe a nice gradient ',
' e.g. background: linear-gradient(60deg, hsl(115, 55%, 60%), hsl(115, 50%, 60%));',
'      box-shadow: 0 12px 20px -10px rgba(230, 230, 230, 0.28), 0 4px 20px 0px rgba(0, 0, 0, 0.12), 0 7px 8px -5px rgba(230, 230, 230, 0.2); */',
' NULL AS CARD_HEADER_STYLE,',
' /* add addtional style classes to header */ ',
' NULL AS CARD_HEADER_CLASS,',
' /* defines the title that should be shown */',
' ''Material Card'' AS CARD_TITLE,',
' /* defines the value that should be shown */',
' ROWNUM || ''%'' AS CARD_VALUE,',
' /* defines the subtext that should be shown */',
' ''This is a Material Card that shows an icon and links to ValueTech'' AS CARD_FOOTER,',
' /* defines the link when click on the card */',
' ''https://www.valuetech.de/'' AS CARD_LINK,',
' /* defines json data json for more information take a look for the examples in that statement or on https://gionkunz.github.io/chartist-js/ ',
' This Plug-in is also able to set your own colors just add to the data json the JSON tag "color" e.g.: ',
' colors: ["green", "red", "blue"] --> When use CARD_CHART_CONFIG: "donutSolid": true then color function is not working!!! */',
' '' '' AS CARD_CHART_DATA,',
' /* defines the chart configuration for more information take a look on https://gionkunz.github.io/chartist-js/ . ',
' The standard CHartist.js API has been extended: When you draw a Donut you can set "sliceWidth": number ',
' and when you draw a horizontal bar than you can set the "strokeWidth": number for example look into examples*/',
' NULL AS CARD_CHART_CONFIG',
'FROM DUAL',
'CONNECT BY ROWNUM <= 3',
'UNION ALL',
'SELECT ',
'  ''chart-bar'' AS CARD_TYPE,',
'  ''fa-bar-chart'' AS CARD_ICON,',
'  NULL AS CARD_ICON_COLOR,',
'  NULL AS CARD_HEADER_STYLE,',
'  NULL AS CARD_HEADER_CLASS,',
'  ''Material Card with bar chart'' AS CARD_TITLE,',
'  ''100%'' AS CARD_VALUE,',
'  ''This is a Material Card that shows a bar chart and links to ValueTech'' AS CARD_FOOTER,',
'  ''https://www.valuetech.de/'' AS CARD_LINK,',
'  ''{',
'    "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'    "series": [[12, 9, 7, 8, 5], [2, 1, 3.5, 7, 3], [1, 3, 4, 5, 6]]',
'   }'' AS CARD_CHART_DATA,',
'   NULL AS CARD_CHART_CONFIG',
'FROM DUAL',
'UNION ALL',
'SELECT',
'  ''chart-line'' AS CARD_TYPE,',
'  ''fa-line-chart'' AS CARD_ICON,',
'  NULL AS CARD_ICON_COLOR,',
'  NULL AS CARD_HEADER_STYLE,',
'  NULL AS CARD_HEADER_CLASS,',
'  ''Material Card with line chart'' AS CARD_TITLE,',
'  ''100%'' AS CARD_VALUE,',
'  ''This is a Material Card that shows a line chart and links to ValueTech'' AS CARD_FOOTER,',
'  ''https://www.valuetech.de/'' AS CARD_LINK,',
'  ''{',
'    "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'    "series": [[12, 9, 7, 8, 5]]',
'   }'' AS CARD_CHART_DATA,',
'   ''{',
'     "low": 0,',
'     "showArea": true',
'   }'' AS CARD_CHART_CONFIG',
'FROM DUAL',
'UNION ALL',
'SELECT',
'  ''chart-pie'' AS CARD_TYPE,',
'  ''fa-pie-chart'' AS CARD_ICON,',
'  NULL AS CARD_ICON_COLOR,',
'  NULL AS CARD_HEADER_STYLE,',
'  NULL AS CARD_HEADER_CLASS,',
'  ''Material Card with pie chart'' AS CARD_TITLE,',
'  ''100%'' AS CARD_VALUE,',
'  ''This is a Material Card that shows a pie chart and links to ValueTech'' AS CARD_FOOTER,',
'  ''https://www.valuetech.de/'' AS CARD_LINK,',
'  ''{             ',
'    "labels": ["Mo", "Tue", "Wed", "Th", "Fr"],',
'    "series": [12, 9, 7, 8, 5],',
'    "colors": ["green", "yellow", "blue", "red", "orange"]',
'  }'' AS CARD_CHART_DATA,',
'  NULL AS CARD_CHART_CONFIG',
'FROM DUAL ',
'</pre>'))
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '4D4954204C6963656E73650A0A436F7079726967687420286329203230323220526F6E6E792057656973730A0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E79207065';
wwv_flow_api.g_varchar2_table(2) := '72736F6E206F627461696E696E67206120636F70790A6F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468652022536F66747761726522292C20746F206465616C0A';
wwv_flow_api.g_varchar2_table(3) := '696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E20746865207269676874730A746F207573652C20636F70792C206D6F646966792C206D';
wwv_flow_api.g_varchar2_table(4) := '657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C0A636F70696573206F662074686520536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F20';
wwv_flow_api.g_varchar2_table(5) := '77686F6D2074686520536F6674776172652069730A6675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F6E733A0A0A5468652061626F766520636F70797269676874206E';
wwv_flow_api.g_varchar2_table(6) := '6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E20616C6C0A636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674';
wwv_flow_api.g_varchar2_table(7) := '776172652E0A0A54484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C2045585052455353204F520A494D504C4945442C20494E434C5544494E47';
wwv_flow_api.g_varchar2_table(8) := '20425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C0A4649544E45535320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E465249';
wwv_flow_api.g_varchar2_table(9) := '4E47454D454E542E20494E204E4F204556454E54205348414C4C205448450A415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F544845';
wwv_flow_api.g_varchar2_table(10) := '520A4C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C0A4F5554204F46204F5220494E20434F4E4E454354';
wwv_flow_api.g_varchar2_table(11) := '494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E205448450A534F4654574152452E0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(31838645142853318288)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_file_name=>'LICENSE'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E63742D6C6162656C7B66696C6C3A7267626128302C302C302C2E34293B636F6C6F723A7267626128302C302C302C2E34293B666F6E742D73697A653A2E373572656D3B6C696E652D6865696768743A317D2E63742D63686172742D626172202E63742D';
wwv_flow_api.g_varchar2_table(2) := '6C6162656C2C2E63742D63686172742D6C696E65202E63742D6C6162656C7B646973706C61793A626C6F636B3B646973706C61793A2D7765626B69742D626F783B646973706C61793A2D6D6F7A2D626F783B646973706C61793A2D6D732D666C6578626F';
wwv_flow_api.g_varchar2_table(3) := '783B646973706C61793A2D7765626B69742D666C65783B646973706C61793A666C65787D2E63742D63686172742D646F6E7574202E63742D6C6162656C2C2E63742D63686172742D706965202E63742D6C6162656C7B646F6D696E616E742D626173656C';
wwv_flow_api.g_varchar2_table(4) := '696E653A63656E7472616C7D2E63742D6C6162656C2E63742D686F72697A6F6E74616C2E63742D73746172747B2D7765626B69742D626F782D616C69676E3A666C65782D656E643B2D7765626B69742D616C69676E2D6974656D733A666C65782D656E64';
wwv_flow_api.g_varchar2_table(5) := '3B2D6D732D666C65782D616C69676E3A666C65782D656E643B616C69676E2D6974656D733A666C65782D656E643B2D7765626B69742D626F782D7061636B3A666C65782D73746172743B2D7765626B69742D6A7573746966792D636F6E74656E743A666C';
wwv_flow_api.g_varchar2_table(6) := '65782D73746172743B2D6D732D666C65782D7061636B3A666C65782D73746172743B6A7573746966792D636F6E74656E743A666C65782D73746172743B746578742D616C69676E3A6C6566743B746578742D616E63686F723A73746172747D2E63742D6C';
wwv_flow_api.g_varchar2_table(7) := '6162656C2E63742D686F72697A6F6E74616C2E63742D656E647B2D7765626B69742D626F782D616C69676E3A666C65782D73746172743B2D7765626B69742D616C69676E2D6974656D733A666C65782D73746172743B2D6D732D666C65782D616C69676E';
wwv_flow_api.g_varchar2_table(8) := '3A666C65782D73746172743B616C69676E2D6974656D733A666C65782D73746172743B2D7765626B69742D626F782D7061636B3A666C65782D73746172743B2D7765626B69742D6A7573746966792D636F6E74656E743A666C65782D73746172743B2D6D';
wwv_flow_api.g_varchar2_table(9) := '732D666C65782D7061636B3A666C65782D73746172743B6A7573746966792D636F6E74656E743A666C65782D73746172743B746578742D616C69676E3A6C6566743B746578742D616E63686F723A73746172747D2E63742D6C6162656C2E63742D766572';
wwv_flow_api.g_varchar2_table(10) := '746963616C2E63742D73746172747B2D7765626B69742D626F782D616C69676E3A666C65782D656E643B2D7765626B69742D616C69676E2D6974656D733A666C65782D656E643B2D6D732D666C65782D616C69676E3A666C65782D656E643B616C69676E';
wwv_flow_api.g_varchar2_table(11) := '2D6974656D733A666C65782D656E643B2D7765626B69742D626F782D7061636B3A666C65782D656E643B2D7765626B69742D6A7573746966792D636F6E74656E743A666C65782D656E643B2D6D732D666C65782D7061636B3A666C65782D656E643B6A75';
wwv_flow_api.g_varchar2_table(12) := '73746966792D636F6E74656E743A666C65782D656E643B746578742D616C69676E3A72696768743B746578742D616E63686F723A656E647D2E63742D6C6162656C2E63742D766572746963616C2E63742D656E647B2D7765626B69742D626F782D616C69';
wwv_flow_api.g_varchar2_table(13) := '676E3A666C65782D656E643B2D7765626B69742D616C69676E2D6974656D733A666C65782D656E643B2D6D732D666C65782D616C69676E3A666C65782D656E643B616C69676E2D6974656D733A666C65782D656E643B2D7765626B69742D626F782D7061';
wwv_flow_api.g_varchar2_table(14) := '636B3A666C65782D73746172743B2D7765626B69742D6A7573746966792D636F6E74656E743A666C65782D73746172743B2D6D732D666C65782D7061636B3A666C65782D73746172743B6A7573746966792D636F6E74656E743A666C65782D7374617274';
wwv_flow_api.g_varchar2_table(15) := '3B746578742D616C69676E3A6C6566743B746578742D616E63686F723A73746172747D2E63742D63686172742D626172202E63742D6C6162656C2E63742D686F72697A6F6E74616C2E63742D73746172747B2D7765626B69742D626F782D616C69676E3A';
wwv_flow_api.g_varchar2_table(16) := '666C65782D656E643B2D7765626B69742D616C69676E2D6974656D733A666C65782D656E643B2D6D732D666C65782D616C69676E3A666C65782D656E643B616C69676E2D6974656D733A666C65782D656E643B2D7765626B69742D626F782D7061636B3A';
wwv_flow_api.g_varchar2_table(17) := '63656E7465723B2D7765626B69742D6A7573746966792D636F6E74656E743A63656E7465723B2D6D732D666C65782D7061636B3A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B746578742D616C69676E3A63656E7465723B';
wwv_flow_api.g_varchar2_table(18) := '746578742D616E63686F723A73746172747D2E63742D63686172742D626172202E63742D6C6162656C2E63742D686F72697A6F6E74616C2E63742D656E647B2D7765626B69742D626F782D616C69676E3A666C65782D73746172743B2D7765626B69742D';
wwv_flow_api.g_varchar2_table(19) := '616C69676E2D6974656D733A666C65782D73746172743B2D6D732D666C65782D616C69676E3A666C65782D73746172743B616C69676E2D6974656D733A666C65782D73746172743B2D7765626B69742D626F782D7061636B3A63656E7465723B2D776562';
wwv_flow_api.g_varchar2_table(20) := '6B69742D6A7573746966792D636F6E74656E743A63656E7465723B2D6D732D666C65782D7061636B3A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B746578742D616C69676E3A63656E7465723B746578742D616E63686F72';
wwv_flow_api.g_varchar2_table(21) := '3A73746172747D2E63742D63686172742D6261722E63742D686F72697A6F6E74616C2D62617273202E63742D6C6162656C2E63742D686F72697A6F6E74616C2E63742D73746172747B2D7765626B69742D626F782D616C69676E3A666C65782D656E643B';
wwv_flow_api.g_varchar2_table(22) := '2D7765626B69742D616C69676E2D6974656D733A666C65782D656E643B2D6D732D666C65782D616C69676E3A666C65782D656E643B616C69676E2D6974656D733A666C65782D656E643B2D7765626B69742D626F782D7061636B3A666C65782D73746172';
wwv_flow_api.g_varchar2_table(23) := '743B2D7765626B69742D6A7573746966792D636F6E74656E743A666C65782D73746172743B2D6D732D666C65782D7061636B3A666C65782D73746172743B6A7573746966792D636F6E74656E743A666C65782D73746172743B746578742D616C69676E3A';
wwv_flow_api.g_varchar2_table(24) := '6C6566743B746578742D616E63686F723A73746172747D2E63742D63686172742D6261722E63742D686F72697A6F6E74616C2D62617273202E63742D6C6162656C2E63742D686F72697A6F6E74616C2E63742D656E647B2D7765626B69742D626F782D61';
wwv_flow_api.g_varchar2_table(25) := '6C69676E3A666C65782D73746172743B2D7765626B69742D616C69676E2D6974656D733A666C65782D73746172743B2D6D732D666C65782D616C69676E3A666C65782D73746172743B616C69676E2D6974656D733A666C65782D73746172743B2D776562';
wwv_flow_api.g_varchar2_table(26) := '6B69742D626F782D7061636B3A666C65782D73746172743B2D7765626B69742D6A7573746966792D636F6E74656E743A666C65782D73746172743B2D6D732D666C65782D7061636B3A666C65782D73746172743B6A7573746966792D636F6E74656E743A';
wwv_flow_api.g_varchar2_table(27) := '666C65782D73746172743B746578742D616C69676E3A6C6566743B746578742D616E63686F723A73746172747D2E63742D63686172742D6261722E63742D686F72697A6F6E74616C2D62617273202E63742D6C6162656C2E63742D766572746963616C2E';
wwv_flow_api.g_varchar2_table(28) := '63742D73746172747B2D7765626B69742D626F782D616C69676E3A63656E7465723B2D7765626B69742D616C69676E2D6974656D733A63656E7465723B2D6D732D666C65782D616C69676E3A63656E7465723B616C69676E2D6974656D733A63656E7465';
wwv_flow_api.g_varchar2_table(29) := '723B2D7765626B69742D626F782D7061636B3A666C65782D656E643B2D7765626B69742D6A7573746966792D636F6E74656E743A666C65782D656E643B2D6D732D666C65782D7061636B3A666C65782D656E643B6A7573746966792D636F6E74656E743A';
wwv_flow_api.g_varchar2_table(30) := '666C65782D656E643B746578742D616C69676E3A72696768743B746578742D616E63686F723A656E647D2E63742D63686172742D6261722E63742D686F72697A6F6E74616C2D62617273202E63742D6C6162656C2E63742D766572746963616C2E63742D';
wwv_flow_api.g_varchar2_table(31) := '656E647B2D7765626B69742D626F782D616C69676E3A63656E7465723B2D7765626B69742D616C69676E2D6974656D733A63656E7465723B2D6D732D666C65782D616C69676E3A63656E7465723B616C69676E2D6974656D733A63656E7465723B2D7765';
wwv_flow_api.g_varchar2_table(32) := '626B69742D626F782D7061636B3A666C65782D73746172743B2D7765626B69742D6A7573746966792D636F6E74656E743A666C65782D73746172743B2D6D732D666C65782D7061636B3A666C65782D73746172743B6A7573746966792D636F6E74656E74';
wwv_flow_api.g_varchar2_table(33) := '3A666C65782D73746172743B746578742D616C69676E3A6C6566743B746578742D616E63686F723A656E647D2E63742D677269647B7374726F6B653A7267626128302C302C302C2E32293B7374726F6B652D77696474683A3170783B7374726F6B652D64';
wwv_flow_api.g_varchar2_table(34) := '61736861727261793A3270787D2E63742D677269642D6261636B67726F756E647B66696C6C3A6E6F6E657D2E63742D706F696E747B7374726F6B652D77696474683A313070783B7374726F6B652D6C696E656361703A726F756E647D2E63742D6C696E65';
wwv_flow_api.g_varchar2_table(35) := '7B66696C6C3A6E6F6E653B7374726F6B652D77696474683A3470787D2E63742D617265617B7374726F6B653A6E6F6E653B66696C6C2D6F7061636974793A2E317D2E63742D6261727B66696C6C3A6E6F6E653B7374726F6B652D77696474683A31307078';
wwv_flow_api.g_varchar2_table(36) := '7D2E63742D736C6963652D646F6E75747B66696C6C3A6E6F6E653B7374726F6B652D77696474683A363070787D2E63742D7365726965732D61202E63742D6261722C2E63742D7365726965732D61202E63742D6C696E652C2E63742D7365726965732D61';
wwv_flow_api.g_varchar2_table(37) := '202E63742D706F696E742C2E63742D7365726965732D61202E63742D736C6963652D646F6E75747B7374726F6B653A236437303230367D2E63742D7365726965732D61202E63742D617265612C2E63742D7365726965732D61202E63742D736C6963652D';
wwv_flow_api.g_varchar2_table(38) := '646F6E75742D736F6C69642C2E63742D7365726965732D61202E63742D736C6963652D7069657B66696C6C3A236437303230367D2E63742D7365726965732D62202E63742D6261722C2E63742D7365726965732D62202E63742D6C696E652C2E63742D73';
wwv_flow_api.g_varchar2_table(39) := '65726965732D62202E63742D706F696E742C2E63742D7365726965732D62202E63742D736C6963652D646F6E75747B7374726F6B653A236630356234667D2E63742D7365726965732D62202E63742D617265612C2E63742D7365726965732D62202E6374';
wwv_flow_api.g_varchar2_table(40) := '2D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D62202E63742D736C6963652D7069657B66696C6C3A236630356234667D2E63742D7365726965732D63202E63742D6261722C2E63742D7365726965732D63202E63742D6C696E';
wwv_flow_api.g_varchar2_table(41) := '652C2E63742D7365726965732D63202E63742D706F696E742C2E63742D7365726965732D63202E63742D736C6963652D646F6E75747B7374726F6B653A236634633633647D2E63742D7365726965732D63202E63742D617265612C2E63742D7365726965';
wwv_flow_api.g_varchar2_table(42) := '732D63202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D63202E63742D736C6963652D7069657B66696C6C3A236634633633647D2E63742D7365726965732D64202E63742D6261722C2E63742D7365726965732D6420';
wwv_flow_api.g_varchar2_table(43) := '2E63742D6C696E652C2E63742D7365726965732D64202E63742D706F696E742C2E63742D7365726965732D64202E63742D736C6963652D646F6E75747B7374726F6B653A236431373930357D2E63742D7365726965732D64202E63742D617265612C2E63';
wwv_flow_api.g_varchar2_table(44) := '742D7365726965732D64202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D64202E63742D736C6963652D7069657B66696C6C3A236431373930357D2E63742D7365726965732D65202E63742D6261722C2E63742D7365';
wwv_flow_api.g_varchar2_table(45) := '726965732D65202E63742D6C696E652C2E63742D7365726965732D65202E63742D706F696E742C2E63742D7365726965732D65202E63742D736C6963652D646F6E75747B7374726F6B653A233435336433667D2E63742D7365726965732D65202E63742D';
wwv_flow_api.g_varchar2_table(46) := '617265612C2E63742D7365726965732D65202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D65202E63742D736C6963652D7069657B66696C6C3A233435336433667D2E63742D7365726965732D66202E63742D626172';
wwv_flow_api.g_varchar2_table(47) := '2C2E63742D7365726965732D66202E63742D6C696E652C2E63742D7365726965732D66202E63742D706F696E742C2E63742D7365726965732D66202E63742D736C6963652D646F6E75747B7374726F6B653A233539393232627D2E63742D736572696573';
wwv_flow_api.g_varchar2_table(48) := '2D66202E63742D617265612C2E63742D7365726965732D66202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D66202E63742D736C6963652D7069657B66696C6C3A233539393232627D2E63742D7365726965732D6720';
wwv_flow_api.g_varchar2_table(49) := '2E63742D6261722C2E63742D7365726965732D67202E63742D6C696E652C2E63742D7365726965732D67202E63742D706F696E742C2E63742D7365726965732D67202E63742D736C6963652D646F6E75747B7374726F6B653A233035343464337D2E6374';
wwv_flow_api.g_varchar2_table(50) := '2D7365726965732D67202E63742D617265612C2E63742D7365726965732D67202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D67202E63742D736C6963652D7069657B66696C6C3A233035343464337D2E63742D7365';
wwv_flow_api.g_varchar2_table(51) := '726965732D68202E63742D6261722C2E63742D7365726965732D68202E63742D6C696E652C2E63742D7365726965732D68202E63742D706F696E742C2E63742D7365726965732D68202E63742D736C6963652D646F6E75747B7374726F6B653A23366230';
wwv_flow_api.g_varchar2_table(52) := '3339327D2E63742D7365726965732D68202E63742D617265612C2E63742D7365726965732D68202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D68202E63742D736C6963652D7069657B66696C6C3A23366230333932';
wwv_flow_api.g_varchar2_table(53) := '7D2E63742D7365726965732D69202E63742D6261722C2E63742D7365726965732D69202E63742D6C696E652C2E63742D7365726965732D69202E63742D706F696E742C2E63742D7365726965732D69202E63742D736C6963652D646F6E75747B7374726F';
wwv_flow_api.g_varchar2_table(54) := '6B653A236630356234667D2E63742D7365726965732D69202E63742D617265612C2E63742D7365726965732D69202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D69202E63742D736C6963652D7069657B66696C6C3A';
wwv_flow_api.g_varchar2_table(55) := '236630356234667D2E63742D7365726965732D6A202E63742D6261722C2E63742D7365726965732D6A202E63742D6C696E652C2E63742D7365726965732D6A202E63742D706F696E742C2E63742D7365726965732D6A202E63742D736C6963652D646F6E';
wwv_flow_api.g_varchar2_table(56) := '75747B7374726F6B653A236464613435387D2E63742D7365726965732D6A202E63742D617265612C2E63742D7365726965732D6A202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D6A202E63742D736C6963652D7069';
wwv_flow_api.g_varchar2_table(57) := '657B66696C6C3A236464613435387D2E63742D7365726965732D6B202E63742D6261722C2E63742D7365726965732D6B202E63742D6C696E652C2E63742D7365726965732D6B202E63742D706F696E742C2E63742D7365726965732D6B202E63742D736C';
wwv_flow_api.g_varchar2_table(58) := '6963652D646F6E75747B7374726F6B653A236561636637647D2E63742D7365726965732D6B202E63742D617265612C2E63742D7365726965732D6B202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D6B202E63742D73';
wwv_flow_api.g_varchar2_table(59) := '6C6963652D7069657B66696C6C3A236561636637647D2E63742D7365726965732D6C202E63742D6261722C2E63742D7365726965732D6C202E63742D6C696E652C2E63742D7365726965732D6C202E63742D706F696E742C2E63742D7365726965732D6C';
wwv_flow_api.g_varchar2_table(60) := '202E63742D736C6963652D646F6E75747B7374726F6B653A233836373937647D2E63742D7365726965732D6C202E63742D617265612C2E63742D7365726965732D6C202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D7365726965732D';
wwv_flow_api.g_varchar2_table(61) := '6C202E63742D736C6963652D7069657B66696C6C3A233836373937647D2E63742D7365726965732D6D202E63742D6261722C2E63742D7365726965732D6D202E63742D6C696E652C2E63742D7365726965732D6D202E63742D706F696E742C2E63742D73';
wwv_flow_api.g_varchar2_table(62) := '65726965732D6D202E63742D736C6963652D646F6E75747B7374726F6B653A236232633332367D2E63742D7365726965732D6D202E63742D617265612C2E63742D7365726965732D6D202E63742D736C6963652D646F6E75742D736F6C69642C2E63742D';
wwv_flow_api.g_varchar2_table(63) := '7365726965732D6D202E63742D736C6963652D7069657B66696C6C3A236232633332367D2E63742D7365726965732D6E202E63742D6261722C2E63742D7365726965732D6E202E63742D6C696E652C2E63742D7365726965732D6E202E63742D706F696E';
wwv_flow_api.g_varchar2_table(64) := '742C2E63742D7365726965732D6E202E63742D736C6963652D646F6E75747B7374726F6B653A233631383865327D2E63742D7365726965732D6E202E63742D617265612C2E63742D7365726965732D6E202E63742D736C6963652D646F6E75742D736F6C';
wwv_flow_api.g_varchar2_table(65) := '69642C2E63742D7365726965732D6E202E63742D736C6963652D7069657B66696C6C3A233631383865327D2E63742D7365726965732D6F202E63742D6261722C2E63742D7365726965732D6F202E63742D6C696E652C2E63742D7365726965732D6F202E';
wwv_flow_api.g_varchar2_table(66) := '63742D706F696E742C2E63742D7365726965732D6F202E63742D736C6963652D646F6E75747B7374726F6B653A236137343863617D2E63742D7365726965732D6F202E63742D617265612C2E63742D7365726965732D6F202E63742D736C6963652D646F';
wwv_flow_api.g_varchar2_table(67) := '6E75742D736F6C69642C2E63742D7365726965732D6F202E63742D736C6963652D7069657B66696C6C3A236137343863617D2E63742D7371756172657B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A31';
wwv_flow_api.g_varchar2_table(68) := '3030257D2E63742D7371756172653A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A313030257D2E63742D73';
wwv_flow_api.g_varchar2_table(69) := '71756172653A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D7371756172653E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A30';
wwv_flow_api.g_varchar2_table(70) := '3B6C6566743A307D2E63742D6D696E6F722D7365636F6E647B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D696E6F722D7365636F6E643A6265666F72657B646973706C61793A';
wwv_flow_api.g_varchar2_table(71) := '626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A39332E3735257D2E63742D6D696E6F722D7365636F6E643A61667465727B636F6E74656E743A2222';
wwv_flow_api.g_varchar2_table(72) := '3B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D6D696E6F722D7365636F6E643E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D6D616A6F';
wwv_flow_api.g_varchar2_table(73) := '722D7365636F6E647B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D616A6F722D7365636F6E643A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C656674';
wwv_flow_api.g_varchar2_table(74) := '3B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A38382E38383838383838383839257D2E63742D6D616A6F722D7365636F6E643A61667465727B636F6E74656E743A22223B646973706C6179';
wwv_flow_api.g_varchar2_table(75) := '3A7461626C653B636C6561723A626F74687D2E63742D6D616A6F722D7365636F6E643E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D6D696E6F722D74686972647B';
wwv_flow_api.g_varchar2_table(76) := '646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D696E6F722D74686972643A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22';
wwv_flow_api.g_varchar2_table(77) := '223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A38332E33333333333333333333257D2E63742D6D696E6F722D74686972643A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561';
wwv_flow_api.g_varchar2_table(78) := '723A626F74687D2E63742D6D696E6F722D74686972643E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D6D616A6F722D74686972647B646973706C61793A626C6F63';
wwv_flow_api.g_varchar2_table(79) := '6B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D616A6F722D74686972643A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865';
wwv_flow_api.g_varchar2_table(80) := '696768743A303B70616464696E672D626F74746F6D3A3830257D2E63742D6D616A6F722D74686972643A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D6D616A6F722D74686972643E';
wwv_flow_api.g_varchar2_table(81) := '7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D706572666563742D666F757274687B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B';
wwv_flow_api.g_varchar2_table(82) := '77696474683A313030257D2E63742D706572666563742D666F757274683A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F';
wwv_flow_api.g_varchar2_table(83) := '74746F6D3A3735257D2E63742D706572666563742D666F757274683A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D706572666563742D666F757274683E7376677B646973706C6179';
wwv_flow_api.g_varchar2_table(84) := '3A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D706572666563742D66696674687B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E';
wwv_flow_api.g_varchar2_table(85) := '63742D706572666563742D66696674683A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A36362E3636363636';
wwv_flow_api.g_varchar2_table(86) := '3636363637257D2E63742D706572666563742D66696674683A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D706572666563742D66696674683E7376677B646973706C61793A626C6F';
wwv_flow_api.g_varchar2_table(87) := '636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D6D696E6F722D73697874687B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D696E';
wwv_flow_api.g_varchar2_table(88) := '6F722D73697874683A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A36322E35257D2E63742D6D696E6F722D';
wwv_flow_api.g_varchar2_table(89) := '73697874683A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D6D696E6F722D73697874683E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B';
wwv_flow_api.g_varchar2_table(90) := '746F703A303B6C6566743A307D2E63742D676F6C64656E2D73656374696F6E7B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D676F6C64656E2D73656374696F6E3A6265666F7265';
wwv_flow_api.g_varchar2_table(91) := '7B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A36312E383034363937313537257D2E63742D676F6C64656E2D73656374696F';
wwv_flow_api.g_varchar2_table(92) := '6E3A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D676F6C64656E2D73656374696F6E3E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B74';
wwv_flow_api.g_varchar2_table(93) := '6F703A303B6C6566743A307D2E63742D6D616A6F722D73697874687B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D616A6F722D73697874683A6265666F72657B646973706C61';
wwv_flow_api.g_varchar2_table(94) := '793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A3630257D2E63742D6D616A6F722D73697874683A61667465727B636F6E74656E743A22223B64';
wwv_flow_api.g_varchar2_table(95) := '6973706C61793A7461626C653B636C6561723A626F74687D2E63742D6D616A6F722D73697874683E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D6D696E6F722D73';
wwv_flow_api.g_varchar2_table(96) := '6576656E74687B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D696E6F722D736576656E74683A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B';
wwv_flow_api.g_varchar2_table(97) := '636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A35362E3235257D2E63742D6D696E6F722D736576656E74683A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B63';
wwv_flow_api.g_varchar2_table(98) := '6C6561723A626F74687D2E63742D6D696E6F722D736576656E74683E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D6D616A6F722D736576656E74687B646973706C';
wwv_flow_api.g_varchar2_table(99) := '61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D616A6F722D736576656E74683A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77';
wwv_flow_api.g_varchar2_table(100) := '696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A35332E33333333333333333333257D2E63742D6D616A6F722D736576656E74683A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C656172';
wwv_flow_api.g_varchar2_table(101) := '3A626F74687D2E63742D6D616A6F722D736576656E74683E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D6F63746176657B646973706C61793A626C6F636B3B706F';
wwv_flow_api.g_varchar2_table(102) := '736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6F63746176653A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B7061';
wwv_flow_api.g_varchar2_table(103) := '6464696E672D626F74746F6D3A3530257D2E63742D6F63746176653A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D6F63746176653E7376677B646973706C61793A626C6F636B3B70';
wwv_flow_api.g_varchar2_table(104) := '6F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D6D616A6F722D74656E74687B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D616A6F722D74';
wwv_flow_api.g_varchar2_table(105) := '656E74683A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A3430257D2E63742D6D616A6F722D74656E74683A';
wwv_flow_api.g_varchar2_table(106) := '61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D6D616A6F722D74656E74683E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B';
wwv_flow_api.g_varchar2_table(107) := '6C6566743A307D2E63742D6D616A6F722D656C6576656E74687B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D616A6F722D656C6576656E74683A6265666F72657B646973706C';
wwv_flow_api.g_varchar2_table(108) := '61793A626C6F636B3B666C6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A33372E35257D2E63742D6D616A6F722D656C6576656E74683A61667465727B636F6E74656E';
wwv_flow_api.g_varchar2_table(109) := '743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D6D616A6F722D656C6576656E74683E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63';
wwv_flow_api.g_varchar2_table(110) := '742D6D616A6F722D7477656C6674687B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D6D616A6F722D7477656C6674683A6265666F72657B646973706C61793A626C6F636B3B666C';
wwv_flow_api.g_varchar2_table(111) := '6F61743A6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A33332E33333333333333333333257D2E63742D6D616A6F722D7477656C6674683A61667465727B636F6E74656E743A22';
wwv_flow_api.g_varchar2_table(112) := '223B646973706C61793A7461626C653B636C6561723A626F74687D2E63742D6D616A6F722D7477656C6674683E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E63742D646F';
wwv_flow_api.g_varchar2_table(113) := '75626C652D6F63746176657B646973706C61793A626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E63742D646F75626C652D6F63746176653A6265666F72657B646973706C61793A626C6F636B3B666C6F61743A';
wwv_flow_api.g_varchar2_table(114) := '6C6566743B636F6E74656E743A22223B77696474683A303B6865696768743A303B70616464696E672D626F74746F6D3A3235257D2E63742D646F75626C652D6F63746176653A61667465727B636F6E74656E743A22223B646973706C61793A7461626C65';
wwv_flow_api.g_varchar2_table(115) := '3B636C6561723A626F74687D2E63742D646F75626C652D6F63746176653E7376677B646973706C61793A626C6F636B3B706F736974696F6E3A6162736F6C7574653B746F703A303B6C6566743A307D2E732D672D636F6E7461696E65727B77696474683A';
wwv_flow_api.g_varchar2_table(116) := '3938253B6D617267696E2D6C6566743A6175746F3B6D617267696E2D72696768743A6175746F7D2E732D672D726F777B706F736974696F6E3A72656C61746976653B77696474683A313030257D2E732D672D726F77205B636C6173735E3D732D672D636F';
wwv_flow_api.g_varchar2_table(117) := '6C5D7B666C6F61743A6C6566743B6D617267696E3A2E3572656D2032253B6D696E2D6865696768743A2E31323572656D7D2E732D672D636F6C2D312C2E732D672D636F6C2D31302C2E732D672D636F6C2D31312C2E732D672D636F6C2D31322C2E732D67';
wwv_flow_api.g_varchar2_table(118) := '2D636F6C2D322C2E732D672D636F6C2D332C2E732D672D636F6C2D342C2E732D672D636F6C2D352C2E732D672D636F6C2D362C2E732D672D636F6C2D372C2E732D672D636F6C2D382C2E732D672D636F6C2D397B77696474683A3936257D2E732D672D63';
wwv_flow_api.g_varchar2_table(119) := '6F6C2D312D736D7B77696474683A342E3333257D2E732D672D636F6C2D322D736D7B77696474683A31322E3636257D2E732D672D636F6C2D332D736D7B77696474683A3231257D2E732D672D636F6C2D342D736D7B77696474683A32392E3333257D2E73';
wwv_flow_api.g_varchar2_table(120) := '2D672D636F6C2D352D736D7B77696474683A33372E3636257D2E732D672D636F6C2D362D736D7B77696474683A3436257D2E732D672D636F6C2D372D736D7B77696474683A35342E3333257D2E732D672D636F6C2D382D736D7B77696474683A36322E36';
wwv_flow_api.g_varchar2_table(121) := '36257D2E732D672D636F6C2D392D736D7B77696474683A3731257D2E732D672D636F6C2D31302D736D7B77696474683A37392E3333257D2E732D672D636F6C2D31312D736D7B77696474683A38372E3636257D2E732D672D636F6C2D31322D736D7B7769';
wwv_flow_api.g_varchar2_table(122) := '6474683A3936257D2E732D672D726F773A3A61667465727B636F6E74656E743A22223B646973706C61793A7461626C653B636C6561723A626F74687D2E68696464656E2D736D7B646973706C61793A6E6F6E657D406D65646961206F6E6C792073637265';
wwv_flow_api.g_varchar2_table(123) := '656E20616E6420286D696E2D77696474683A33332E3735656D297B2E732D672D636F6E7461696E65727B77696474683A3938257D7D406D65646961206F6E6C792073637265656E20616E6420286D696E2D77696474683A3630656D297B2E732D672D636F';
wwv_flow_api.g_varchar2_table(124) := '6C2D312C2E732D672D636F6C2D322C2E732D672D636F6C2D332C2E732D672D636F6C2D342C2E732D672D636F6C2D352C2E732D672D636F6C2D367B77696474683A3436257D2E732D672D636F6C2D31302C2E732D672D636F6C2D31312C2E732D672D636F';
wwv_flow_api.g_varchar2_table(125) := '6C2D31322C2E732D672D636F6C2D372C2E732D672D636F6C2D382C2E732D672D636F6C2D397B77696474683A3936257D2E68696464656E2D736D7B646973706C61793A626C6F636B7D7D406D65646961206F6E6C792073637265656E20616E6420286D69';
wwv_flow_api.g_varchar2_table(126) := '6E2D77696474683A3636656D297B2E732D672D636F6E7461696E65727B77696474683A3938257D2E732D672D636F6C2D317B77696474683A342E3333257D2E732D672D636F6C2D327B77696474683A31322E3636257D2E732D672D636F6C2D337B776964';
wwv_flow_api.g_varchar2_table(127) := '74683A3231257D2E732D672D636F6C2D347B77696474683A32392E3333257D2E732D672D636F6C2D357B77696474683A33372E3636257D2E732D672D636F6C2D367B77696474683A3436257D2E732D672D636F6C2D377B77696474683A35342E3333257D';
wwv_flow_api.g_varchar2_table(128) := '2E732D672D636F6C2D387B77696474683A36322E3636257D2E732D672D636F6C2D397B77696474683A3731257D2E732D672D636F6C2D31307B77696474683A37392E3333257D2E732D672D636F6C2D31317B77696474683A38372E3636257D2E732D672D';
wwv_flow_api.g_varchar2_table(129) := '636F6C2D31327B77696474683A3936257D2E68696464656E2D736D7B646973706C61793A626C6F636B7D7D2E63742D6C6F616465727B706F736974696F6E3A6162736F6C7574653B746F703A373070783B77696474683A313030253B7A2D696E6465783A';
wwv_flow_api.g_varchar2_table(130) := '313B746578742D616C69676E3A63656E7465727D2E63742D6C6162656C7B666F6E742D73697A653A313270787D2E61742D636172647B646973706C61793A696E6C696E652D626C6F636B3B706F736974696F6E3A72656C61746976653B77696474683A31';
wwv_flow_api.g_varchar2_table(131) := '3030253B6D617267696E3A3235707820303B626F782D736861646F773A3020317078203470782030207267626128302C302C302C2E3434293B626F726465722D7261646975733A3170783B636F6C6F723A7267626128302C302C302C2E3837293B626163';
wwv_flow_api.g_varchar2_table(132) := '6B67726F756E643A236666667D2E61742D636172643A686F7665723E2E636172642D6865616465727B2D7765626B69742D66696C7465723A677261797363616C652831303025293B66696C7465723A677261797363616C652831303025297D2E61742D63';
wwv_flow_api.g_varchar2_table(133) := '617264202E636172642D6865696768742D696E64696361746F727B6D617267696E2D746F703A313030257D2E61742D63617264202E7469746C657B6D617267696E2D746F703A303B6D617267696E2D626F74746F6D3A3570787D2E61742D63617264202E';
wwv_flow_api.g_varchar2_table(134) := '636172642D696D6167657B6865696768743A3630253B706F736974696F6E3A72656C61746976653B6F766572666C6F773A68696464656E3B6D617267696E2D6C6566743A313570783B6D617267696E2D72696768743A313570783B6D617267696E2D746F';
wwv_flow_api.g_varchar2_table(135) := '703A2D333070783B626F726465722D7261646975733A3670787D2E61742D63617264202E636172642D696D61676520696D677B77696474683A313030253B6865696768743A313030253B626F726465722D7261646975733A3670783B706F696E7465722D';
wwv_flow_api.g_varchar2_table(136) := '6576656E74733A6E6F6E657D2E61742D63617264202E636172642D696D616765202E636172642D7469746C657B706F736974696F6E3A6162736F6C7574653B626F74746F6D3A313570783B6C6566743A313570783B636F6C6F723A236666663B666F6E74';
wwv_flow_api.g_varchar2_table(137) := '2D73697A653A312E33656D3B746578742D736861646F773A30203270782035707820726762612833332C33332C33332C2E35297D2E61742D63617264202E63617465676F72793A6E6F74285B636C6173732A3D746578742D5D297B636F6C6F723A233939';
wwv_flow_api.g_varchar2_table(138) := '397D2E61742D63617264202E636172642D636F6E74656E747B70616464696E673A3135707820323070787D2E61742D63617264202E636172642D636F6E74656E74202E63617465676F72797B6D617267696E2D626F74746F6D3A307D2E61742D63617264';
wwv_flow_api.g_varchar2_table(139) := '202E636172642D6865616465727B626F782D736861646F773A3020313070782033307078202D31327078207267626128302C302C302C2E3432292C302034707820323570782030207267626128302C302C302C2E3132292C30203870782031307078202D';
wwv_flow_api.g_varchar2_table(140) := '357078207267626128302C302C302C2E32293B6D617267696E3A2D32307078203135707820303B626F726465722D7261646975733A3170783B70616464696E673A313570783B6261636B67726F756E642D636F6C6F723A233939393B6261636B67726F75';
wwv_flow_api.g_varchar2_table(141) := '6E642D7265706561743A6E6F2D7265706561743B6261636B67726F756E642D73697A653A636F7665723B6261636B67726F756E642D706F736974696F6E3A63656E7465723B7472616E736974696F6E3A616C6C202E377320656173652D6F75747D2E6174';
wwv_flow_api.g_varchar2_table(142) := '2D63617264202E636172642D686561646572202E7469746C657B636F6C6F723A236666667D2E61742D63617264202E636172642D686561646572202E63617465676F72797B6D617267696E2D626F74746F6D3A303B636F6C6F723A72676261283235352C';
wwv_flow_api.g_varchar2_table(143) := '3235352C3235352C2E3632297D2E61742D63617264202E636172642D6865616465722E636172642D63686172747B70616464696E673A303B6D696E2D6865696768743A31363070787D2E61742D63617264202E636172642D6865616465722E636172642D';
wwv_flow_api.g_varchar2_table(144) := '63686172742B2E636F6E74656E742068347B6D617267696E2D746F703A307D2E61742D63617264202E636172642D686561646572202E63742D6C6162656C7B636F6C6F723A72676261283235352C3235352C3235352C2E37297D2E61742D63617264202E';
wwv_flow_api.g_varchar2_table(145) := '636172642D686561646572202E63742D677269647B7374726F6B653A72676261283235352C3235352C3235352C2E32297D2E61742D63617264202E63686172742D7469746C657B706F736974696F6E3A6162736F6C7574653B746F703A323570783B7769';
wwv_flow_api.g_varchar2_table(146) := '6474683A313030253B746578742D616C69676E3A63656E7465727D2E61742D63617264202E63686172742D7469746C652068337B6D617267696E3A303B636F6C6F723A236666667D2E61742D63617264202E63686172742D7469746C652068367B6D6172';
wwv_flow_api.g_varchar2_table(147) := '67696E3A303B636F6C6F723A72676261283235352C3235352C3235352C2E34297D2E61742D63617264202E636172642D666F6F7465727B6D617267696E3A30203230707820313070783B70616464696E672D746F703A313070783B626F726465722D746F';
wwv_flow_api.g_varchar2_table(148) := '703A31707820736F6C696420236565657D2E61742D63617264202E636172642D666F6F746572202E636F6E74656E747B646973706C61793A626C6F636B7D2E61742D63617264202E636172642D666F6F746572206469767B646973706C61793A696E6C69';
wwv_flow_api.g_varchar2_table(149) := '6E652D626C6F636B7D2E61742D63617264202E636172642D666F6F746572202E617574686F727B636F6C6F723A233939397D2E61742D63617264202E636172642D666F6F746572202E73746174737B6C696E652D6865696768743A323270783B636F6C6F';
wwv_flow_api.g_varchar2_table(150) := '723A233939393B666F6E742D73697A653A313270787D2E61742D63617264202E636172642D666F6F746572202E7374617473202E6D6174657269616C2D69636F6E737B706F736974696F6E3A72656C61746976653B746F703A3470783B666F6E742D7369';
wwv_flow_api.g_varchar2_table(151) := '7A653A313670787D2E61742D63617264202E636172642D666F6F7465722068367B636F6C6F723A233939397D2E61742D6361726420696D677B77696474683A313030253B6865696768743A6175746F7D2E61742D63617264202E7461626C657B6D617267';
wwv_flow_api.g_varchar2_table(152) := '696E2D626F74746F6D3A307D2E61742D63617264202E7461626C652074723A66697273742D6368696C642074647B626F726465722D746F703A6E6F6E657D2E61742D636172642D7374617473202E7469746C657B6D617267696E3A307D2E61742D636172';
wwv_flow_api.g_varchar2_table(153) := '642D7374617473202E636172642D6865616465727B666C6F61743A6C6566743B746578742D616C69676E3A63656E7465727D2E61742D636172642D7374617473202E636172642D68656164657220697B666F6E742D73697A653A333670783B6C696E652D';
wwv_flow_api.g_varchar2_table(154) := '6865696768743A353670783B77696474683A353670783B6865696768743A353670783B646973706C61793A626C6F636B7D2E61742D636172642D7374617473202E636172642D636F6E74656E747B746578742D616C69676E3A72696768743B7061646469';
wwv_flow_api.g_varchar2_table(155) := '6E672D746F703A313070787D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(31839203735381341359)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_file_name=>'materialcards.pkgd.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2166756E6374696F6E28652C74297B2266756E6374696F6E223D3D747970656F6620646566696E652626646566696E652E616D643F646566696E6528224368617274697374222C5B5D2C66756E6374696F6E28297B72657475726E20652E436861727469';
wwv_flow_api.g_varchar2_table(2) := '73743D7428297D293A226F626A656374223D3D747970656F66206D6F64756C6526266D6F64756C652E6578706F7274733F6D6F64756C652E6578706F7274733D7428293A652E43686172746973743D7428297D28746869732C66756E6374696F6E28297B';
wwv_flow_api.g_varchar2_table(3) := '76617220653D7B76657273696F6E3A22302E31312E34227D3B72657475726E2066756E6374696F6E28652C74297B2275736520737472696374223B76617220693D652E77696E646F772C6E3D652E646F63756D656E743B742E6E616D657370616365733D';
wwv_flow_api.g_varchar2_table(4) := '7B7376673A22687474703A2F2F7777772E77332E6F72672F323030302F737667222C786D6C6E733A22687474703A2F2F7777772E77332E6F72672F323030302F786D6C6E732F222C7868746D6C3A22687474703A2F2F7777772E77332E6F72672F313939';
wwv_flow_api.g_varchar2_table(5) := '392F7868746D6C222C786C696E6B3A22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B222C63743A22687474703A2F2F67696F6E6B756E7A2E6769746875622E636F6D2F63686172746973742D6A732F6374227D2C742E6E6F6F70';
wwv_flow_api.g_varchar2_table(6) := '3D66756E6374696F6E2865297B72657475726E20657D2C742E616C7068614E756D65726174653D66756E6374696F6E2865297B72657475726E20537472696E672E66726F6D43686172436F64652839372B65253236297D2C742E657874656E643D66756E';
wwv_flow_api.g_varchar2_table(7) := '6374696F6E2865297B76617220692C6E2C723B666F7228653D657C7C7B7D2C693D313B693C617267756D656E74732E6C656E6774683B692B2B297B6E3D617267756D656E74735B695D3B666F7228766172206120696E206E29226F626A65637422213D74';
wwv_flow_api.g_varchar2_table(8) := '7970656F6628723D6E5B615D297C7C6E756C6C3D3D3D727C7C7220696E7374616E63656F662041727261793F655B615D3D723A655B615D3D742E657874656E6428655B615D2C72297D72657475726E20657D2C742E7265706C616365416C6C3D66756E63';
wwv_flow_api.g_varchar2_table(9) := '74696F6E28652C742C69297B72657475726E20652E7265706C616365286E65772052656745787028742C226722292C69297D2C742E656E73757265556E69743D66756E6374696F6E28652C74297B72657475726E226E756D626572223D3D747970656F66';
wwv_flow_api.g_varchar2_table(10) := '2065262628652B3D74292C657D2C742E7175616E746974793D66756E6374696F6E2865297B69662822737472696E67223D3D747970656F662065297B76617220743D2F5E285C642B295C732A282E2A29242F672E657865632865293B72657475726E7B76';
wwv_flow_api.g_varchar2_table(11) := '616C75653A2B745B315D2C756E69743A745B325D7C7C766F696420307D7D72657475726E7B76616C75653A657D7D2C742E717565727953656C6563746F723D66756E6374696F6E2865297B72657475726E206520696E7374616E63656F66204E6F64653F';
wwv_flow_api.g_varchar2_table(12) := '653A6E2E717565727953656C6563746F722865297D2C742E74696D65733D66756E6374696F6E2865297B72657475726E2041727261792E6170706C79286E756C6C2C6E6577204172726179286529297D2C742E73756D3D66756E6374696F6E28652C7429';
wwv_flow_api.g_varchar2_table(13) := '7B72657475726E20652B28747C7C30297D2C742E6D61704D756C7469706C793D66756E6374696F6E2865297B72657475726E2066756E6374696F6E2874297B72657475726E20742A657D7D2C742E6D61704164643D66756E6374696F6E2865297B726574';
wwv_flow_api.g_varchar2_table(14) := '75726E2066756E6374696F6E2874297B72657475726E20742B657D7D2C742E73657269616C4D61703D66756E6374696F6E28652C69297B766172206E3D5B5D2C723D4D6174682E6D61782E6170706C79286E756C6C2C652E6D61702866756E6374696F6E';
wwv_flow_api.g_varchar2_table(15) := '2865297B72657475726E20652E6C656E6774687D29293B72657475726E20742E74696D65732872292E666F72456163682866756E6374696F6E28742C72297B76617220613D652E6D61702866756E6374696F6E2865297B72657475726E20655B725D7D29';
wwv_flow_api.g_varchar2_table(16) := '3B6E5B725D3D692E6170706C79286E756C6C2C61297D292C6E7D2C742E726F756E6457697468507265636973696F6E3D66756E6374696F6E28652C69297B766172206E3D4D6174682E706F772831302C697C7C742E707265636973696F6E293B72657475';
wwv_flow_api.g_varchar2_table(17) := '726E204D6174682E726F756E6428652A6E292F6E7D2C742E707265636973696F6E3D382C742E6573636170696E674D61703D7B2226223A2226616D703B222C223C223A22266C743B222C223E223A222667743B222C2722273A222671756F743B222C2227';
wwv_flow_api.g_varchar2_table(18) := '223A2226233033393B227D2C742E73657269616C697A653D66756E6374696F6E2865297B72657475726E206E756C6C3D3D3D657C7C766F696420303D3D3D653F653A28226E756D626572223D3D747970656F6620653F653D22222B653A226F626A656374';
wwv_flow_api.g_varchar2_table(19) := '223D3D747970656F662065262628653D4A534F4E2E737472696E67696679287B646174613A657D29292C4F626A6563742E6B65797328742E6573636170696E674D6170292E7265647563652866756E6374696F6E28652C69297B72657475726E20742E72';
wwv_flow_api.g_varchar2_table(20) := '65706C616365416C6C28652C692C742E6573636170696E674D61705B695D297D2C6529297D2C742E646573657269616C697A653D66756E6374696F6E2865297B69662822737472696E6722213D747970656F6620652972657475726E20653B653D4F626A';
wwv_flow_api.g_varchar2_table(21) := '6563742E6B65797328742E6573636170696E674D6170292E7265647563652866756E6374696F6E28652C69297B72657475726E20742E7265706C616365416C6C28652C742E6573636170696E674D61705B695D2C69297D2C65293B7472797B653D766F69';
wwv_flow_api.g_varchar2_table(22) := '642030213D3D28653D4A534F4E2E7061727365286529292E646174613F652E646174613A657D63617463682865297B7D72657475726E20657D2C742E6372656174655376673D66756E6374696F6E28652C692C6E2C72297B76617220613B72657475726E';
wwv_flow_api.g_varchar2_table(23) := '20693D697C7C2231303025222C6E3D6E7C7C2231303025222C41727261792E70726F746F747970652E736C6963652E63616C6C28652E717565727953656C6563746F72416C6C28227376672229292E66696C7465722866756E6374696F6E2865297B7265';
wwv_flow_api.g_varchar2_table(24) := '7475726E20652E6765744174747269627574654E5328742E6E616D657370616365732E786D6C6E732C22637422297D292E666F72456163682866756E6374696F6E2874297B652E72656D6F76654368696C642874297D292C613D6E657720742E53766728';
wwv_flow_api.g_varchar2_table(25) := '2273766722292E61747472287B77696474683A692C6865696768743A6E7D292E616464436C6173732872292C612E5F6E6F64652E7374796C652E77696474683D692C612E5F6E6F64652E7374796C652E6865696768743D6E2C652E617070656E64436869';
wwv_flow_api.g_varchar2_table(26) := '6C6428612E5F6E6F6465292C617D2C742E6E6F726D616C697A65446174613D66756E6374696F6E28652C692C6E297B76617220722C613D7B7261773A652C6E6F726D616C697A65643A7B7D7D3B72657475726E20612E6E6F726D616C697A65642E736572';
wwv_flow_api.g_varchar2_table(27) := '6965733D742E676574446174614172726179287B7365726965733A652E7365726965737C7C5B5D7D2C692C6E292C723D612E6E6F726D616C697A65642E7365726965732E65766572792866756E6374696F6E2865297B72657475726E206520696E737461';
wwv_flow_api.g_varchar2_table(28) := '6E63656F662041727261797D293F4D6174682E6D61782E6170706C79286E756C6C2C612E6E6F726D616C697A65642E7365726965732E6D61702866756E6374696F6E2865297B72657475726E20652E6C656E6774687D29293A612E6E6F726D616C697A65';
wwv_flow_api.g_varchar2_table(29) := '642E7365726965732E6C656E6774682C612E6E6F726D616C697A65642E6C6162656C733D28652E6C6162656C737C7C5B5D292E736C69636528292C41727261792E70726F746F747970652E707573682E6170706C7928612E6E6F726D616C697A65642E6C';
wwv_flow_api.g_varchar2_table(30) := '6162656C732C742E74696D6573284D6174682E6D617828302C722D612E6E6F726D616C697A65642E6C6162656C732E6C656E67746829292E6D61702866756E6374696F6E28297B72657475726E22227D29292C692626742E726576657273654461746128';
wwv_flow_api.g_varchar2_table(31) := '612E6E6F726D616C697A6564292C617D2C742E7361666548617350726F70657274793D66756E6374696F6E28652C74297B72657475726E206E756C6C213D3D652626226F626A656374223D3D747970656F6620652626652E6861734F776E50726F706572';
wwv_flow_api.g_varchar2_table(32) := '74792874297D2C742E697344617461486F6C6556616C75653D66756E6374696F6E2865297B72657475726E206E756C6C3D3D3D657C7C766F696420303D3D3D657C7C226E756D626572223D3D747970656F662065262669734E614E2865297D2C742E7265';
wwv_flow_api.g_varchar2_table(33) := '7665727365446174613D66756E6374696F6E2865297B652E6C6162656C732E7265766572736528292C652E7365726965732E7265766572736528293B666F722876617220743D303B743C652E7365726965732E6C656E6774683B742B2B29226F626A6563';
wwv_flow_api.g_varchar2_table(34) := '74223D3D747970656F6620652E7365726965735B745D2626766F69642030213D3D652E7365726965735B745D2E646174613F652E7365726965735B745D2E646174612E7265766572736528293A652E7365726965735B745D696E7374616E63656F662041';
wwv_flow_api.g_varchar2_table(35) := '727261792626652E7365726965735B745D2E7265766572736528297D2C742E6765744461746141727261793D66756E6374696F6E28652C692C6E297B66756E6374696F6E20722865297B696628742E7361666548617350726F706572747928652C227661';
wwv_flow_api.g_varchar2_table(36) := '6C756522292972657475726E207228652E76616C7565293B696628742E7361666548617350726F706572747928652C226461746122292972657475726E207228652E64617461293B6966286520696E7374616E63656F662041727261792972657475726E';
wwv_flow_api.g_varchar2_table(37) := '20652E6D61702872293B69662821742E697344617461486F6C6556616C7565286529297B6966286E297B76617220693D7B7D3B72657475726E22737472696E67223D3D747970656F66206E3F695B6E5D3D742E6765744E756D6265724F72556E64656669';
wwv_flow_api.g_varchar2_table(38) := '6E65642865293A692E793D742E6765744E756D6265724F72556E646566696E65642865292C692E783D652E6861734F776E50726F706572747928227822293F742E6765744E756D6265724F72556E646566696E656428652E78293A692E782C692E793D65';
wwv_flow_api.g_varchar2_table(39) := '2E6861734F776E50726F706572747928227922293F742E6765744E756D6265724F72556E646566696E656428652E79293A692E792C697D72657475726E20742E6765744E756D6265724F72556E646566696E65642865297D7D72657475726E20652E7365';
wwv_flow_api.g_varchar2_table(40) := '726965732E6D61702872297D2C742E6E6F726D616C697A6550616464696E673D66756E6374696F6E28652C74297B72657475726E20743D747C7C302C226E756D626572223D3D747970656F6620653F7B746F703A652C72696768743A652C626F74746F6D';
wwv_flow_api.g_varchar2_table(41) := '3A652C6C6566743A657D3A7B746F703A226E756D626572223D3D747970656F6620652E746F703F652E746F703A742C72696768743A226E756D626572223D3D747970656F6620652E72696768743F652E72696768743A742C626F74746F6D3A226E756D62';
wwv_flow_api.g_varchar2_table(42) := '6572223D3D747970656F6620652E626F74746F6D3F652E626F74746F6D3A742C6C6566743A226E756D626572223D3D747970656F6620652E6C6566743F652E6C6566743A747D7D2C742E6765744D657461446174613D66756E6374696F6E28652C74297B';
wwv_flow_api.g_varchar2_table(43) := '76617220693D652E646174613F652E646174615B745D3A655B745D3B72657475726E20693F692E6D6574613A766F696420307D2C742E6F726465724F664D61676E69747564653D66756E6374696F6E2865297B72657475726E204D6174682E666C6F6F72';
wwv_flow_api.g_varchar2_table(44) := '284D6174682E6C6F67284D6174682E616273286529292F4D6174682E4C4E3130297D2C742E70726F6A6563744C656E6774683D66756E6374696F6E28652C742C69297B72657475726E20742F692E72616E67652A657D2C742E676574417661696C61626C';
wwv_flow_api.g_varchar2_table(45) := '654865696768743D66756E6374696F6E28652C69297B72657475726E204D6174682E6D61782828742E7175616E7469747928692E686569676874292E76616C75657C7C652E6865696768742829292D28692E636861727450616464696E672E746F702B69';
wwv_flow_api.g_varchar2_table(46) := '2E636861727450616464696E672E626F74746F6D292D692E61786973582E6F66667365742C30297D2C742E676574486967684C6F773D66756E6374696F6E28652C692C6E297B66756E6374696F6E20722865297B696628766F69642030213D3D65296966';
wwv_flow_api.g_varchar2_table(47) := '286520696E7374616E63656F6620417272617929666F722876617220743D303B743C652E6C656E6774683B742B2B297228655B745D293B656C73657B76617220693D6E3F2B655B6E5D3A2B653B732626693E612E68696768262628612E686967683D6929';
wwv_flow_api.g_varchar2_table(48) := '2C6F2626693C612E6C6F77262628612E6C6F773D69297D7D76617220613D7B686967683A766F696420303D3D3D28693D742E657874656E64287B7D2C692C6E3F695B2261786973222B6E2E746F55707065724361736528295D3A7B7D29292E686967683F';
wwv_flow_api.g_varchar2_table(49) := '2D4E756D6265722E4D41585F56414C55453A2B692E686967682C6C6F773A766F696420303D3D3D692E6C6F773F4E756D6265722E4D41585F56414C55453A2B692E6C6F777D2C733D766F696420303D3D3D692E686967682C6F3D766F696420303D3D3D69';
wwv_flow_api.g_varchar2_table(50) := '2E6C6F773B72657475726E28737C7C6F292626722865292C28692E7265666572656E636556616C75657C7C303D3D3D692E7265666572656E636556616C756529262628612E686967683D4D6174682E6D617828692E7265666572656E636556616C75652C';
wwv_flow_api.g_varchar2_table(51) := '612E68696768292C612E6C6F773D4D6174682E6D696E28692E7265666572656E636556616C75652C612E6C6F7729292C612E686967683C3D612E6C6F77262628303D3D3D612E6C6F773F612E686967683D313A612E6C6F773C303F612E686967683D303A';
wwv_flow_api.g_varchar2_table(52) := '612E686967683E303F612E6C6F773D303A28612E686967683D312C612E6C6F773D3029292C617D2C742E69734E756D657269633D66756E6374696F6E2865297B72657475726E206E756C6C213D3D652626697346696E6974652865297D2C742E69734661';
wwv_flow_api.g_varchar2_table(53) := '6C7365794275745A65726F3D66756E6374696F6E2865297B72657475726E2165262630213D3D657D2C742E6765744E756D6265724F72556E646566696E65643D66756E6374696F6E2865297B72657475726E20742E69734E756D657269632865293F2B65';
wwv_flow_api.g_varchar2_table(54) := '3A766F696420307D2C742E69734D756C746956616C75653D66756E6374696F6E2865297B72657475726E226F626A656374223D3D747970656F662065262628227822696E20657C7C227922696E2065297D2C742E6765744D756C746956616C75653D6675';
wwv_flow_api.g_varchar2_table(55) := '6E6374696F6E28652C69297B72657475726E20742E69734D756C746956616C75652865293F742E6765744E756D6265724F72556E646566696E656428655B697C7C2279225D293A742E6765744E756D6265724F72556E646566696E65642865297D2C742E';
wwv_flow_api.g_varchar2_table(56) := '72686F3D66756E6374696F6E2865297B66756E6374696F6E207428652C69297B72657475726E206525693D3D303F693A7428692C652569297D66756E6374696F6E20692865297B72657475726E20652A652B317D696628313D3D3D652972657475726E20';
wwv_flow_api.g_varchar2_table(57) := '653B766172206E2C723D322C613D323B6966286525323D3D302972657475726E20323B646F7B723D6928722925652C613D6928692861292925652C6E3D74284D6174682E61627328722D61292C65297D7768696C6528313D3D3D6E293B72657475726E20';
wwv_flow_api.g_varchar2_table(58) := '6E7D2C742E676574426F756E64733D66756E6374696F6E28652C692C6E2C72297B66756E6374696F6E206128652C74297B72657475726E20653D3D3D28652B3D7429262628652A3D312B28743E303F703A2D7029292C657D76617220732C6F2C6C2C633D';
wwv_flow_api.g_varchar2_table(59) := '302C753D7B686967683A692E686967682C6C6F773A692E6C6F777D3B752E76616C756552616E67653D752E686967682D752E6C6F772C752E6F6F6D3D742E6F726465724F664D61676E697475646528752E76616C756552616E6765292C752E737465703D';
wwv_flow_api.g_varchar2_table(60) := '4D6174682E706F772831302C752E6F6F6D292C752E6D696E3D4D6174682E666C6F6F7228752E6C6F772F752E73746570292A752E737465702C752E6D61783D4D6174682E6365696C28752E686967682F752E73746570292A752E737465702C752E72616E';
wwv_flow_api.g_varchar2_table(61) := '67653D752E6D61782D752E6D696E2C752E6E756D6265724F6653746570733D4D6174682E726F756E6428752E72616E67652F752E73746570293B76617220643D742E70726F6A6563744C656E67746828652C752E737465702C75293C6E2C683D723F742E';
wwv_flow_api.g_varchar2_table(62) := '72686F28752E72616E6765293A303B696628722626742E70726F6A6563744C656E67746828652C312C75293E3D6E29752E737465703D313B656C736520696628722626683C752E737465702626742E70726F6A6563744C656E67746828652C682C75293E';
wwv_flow_api.g_varchar2_table(63) := '3D6E29752E737465703D683B656C736520666F72283B3B297B696628642626742E70726F6A6563744C656E67746828652C752E737465702C75293C3D6E29752E737465702A3D323B656C73657B696628647C7C2128742E70726F6A6563744C656E677468';
wwv_flow_api.g_varchar2_table(64) := '28652C752E737465702F322C75293E3D6E2929627265616B3B696628752E737465702F3D322C722626752E737465702531213D30297B752E737465702A3D323B627265616B7D7D696628632B2B3E316533297468726F77206E6577204572726F72282245';
wwv_flow_api.g_varchar2_table(65) := '78636565646564206D6178696D756D206E756D626572206F6620697465726174696F6E73207768696C65206F7074696D697A696E67207363616C6520737465702122297D76617220703D322E323231652D31363B666F7228752E737465703D4D6174682E';
wwv_flow_api.g_varchar2_table(66) := '6D617828752E737465702C70292C6F3D752E6D696E2C6C3D752E6D61783B6F2B752E737465703C3D752E6C6F773B296F3D61286F2C752E73746570293B666F72283B6C2D752E737465703E3D752E686967683B296C3D61286C2C2D752E73746570293B75';
wwv_flow_api.g_varchar2_table(67) := '2E6D696E3D6F2C752E6D61783D6C2C752E72616E67653D752E6D61782D752E6D696E3B76617220663D5B5D3B666F7228733D752E6D696E3B733C3D752E6D61783B733D6128732C752E7374657029297B766172206D3D742E726F756E6457697468507265';
wwv_flow_api.g_varchar2_table(68) := '636973696F6E2873293B6D213D3D665B662E6C656E6774682D315D2626662E70757368286D297D72657475726E20752E76616C7565733D662C757D2C742E706F6C6172546F43617274657369616E3D66756E6374696F6E28652C742C692C6E297B766172';
wwv_flow_api.g_varchar2_table(69) := '20723D286E2D3930292A4D6174682E50492F3138303B72657475726E7B783A652B692A4D6174682E636F732872292C793A742B692A4D6174682E73696E2872297D7D2C742E6372656174654368617274526563743D66756E6374696F6E28652C692C6E29';
wwv_flow_api.g_varchar2_table(70) := '7B76617220723D212821692E6178697358262621692E6178697359292C613D723F692E61786973592E6F66667365743A302C733D723F692E61786973582E6F66667365743A302C6F3D652E776964746828297C7C742E7175616E7469747928692E776964';
wwv_flow_api.g_varchar2_table(71) := '7468292E76616C75657C7C302C6C3D652E68656967687428297C7C742E7175616E7469747928692E686569676874292E76616C75657C7C302C633D742E6E6F726D616C697A6550616464696E6728692E636861727450616464696E672C6E293B6F3D4D61';
wwv_flow_api.g_varchar2_table(72) := '74682E6D6178286F2C612B632E6C6566742B632E7269676874292C6C3D4D6174682E6D6178286C2C732B632E746F702B632E626F74746F6D293B76617220753D7B70616464696E673A632C77696474683A66756E6374696F6E28297B72657475726E2074';
wwv_flow_api.g_varchar2_table(73) := '6869732E78322D746869732E78317D2C6865696768743A66756E6374696F6E28297B72657475726E20746869732E79312D746869732E79327D7D3B72657475726E20723F28227374617274223D3D3D692E61786973582E706F736974696F6E3F28752E79';
wwv_flow_api.g_varchar2_table(74) := '323D632E746F702B732C752E79313D4D6174682E6D6178286C2D632E626F74746F6D2C752E79322B3129293A28752E79323D632E746F702C752E79313D4D6174682E6D6178286C2D632E626F74746F6D2D732C752E79322B3129292C227374617274223D';
wwv_flow_api.g_varchar2_table(75) := '3D3D692E61786973592E706F736974696F6E3F28752E78313D632E6C6566742B612C752E78323D4D6174682E6D6178286F2D632E72696768742C752E78312B3129293A28752E78313D632E6C6566742C752E78323D4D6174682E6D6178286F2D632E7269';
wwv_flow_api.g_varchar2_table(76) := '6768742D612C752E78312B312929293A28752E78313D632E6C6566742C752E78323D4D6174682E6D6178286F2D632E72696768742C752E78312B31292C752E79323D632E746F702C752E79313D4D6174682E6D6178286C2D632E626F74746F6D2C752E79';
wwv_flow_api.g_varchar2_table(77) := '322B3129292C757D2C742E637265617465477269643D66756E6374696F6E28652C692C6E2C722C612C732C6F2C6C297B76617220633D7B7D3B635B6E2E756E6974732E706F732B2231225D3D652C635B6E2E756E6974732E706F732B2232225D3D652C63';
wwv_flow_api.g_varchar2_table(78) := '5B6E2E636F756E746572556E6974732E706F732B2231225D3D722C635B6E2E636F756E746572556E6974732E706F732B2232225D3D722B613B76617220753D732E656C656D28226C696E65222C632C6F2E6A6F696E2822202229293B6C2E656D69742822';
wwv_flow_api.g_varchar2_table(79) := '64726177222C742E657874656E64287B747970653A2267726964222C617869733A6E2C696E6465783A692C67726F75703A732C656C656D656E743A757D2C6329297D2C742E637265617465477269644261636B67726F756E643D66756E6374696F6E2865';
wwv_flow_api.g_varchar2_table(80) := '2C742C692C6E297B76617220723D652E656C656D282272656374222C7B783A742E78312C793A742E79322C77696474683A742E776964746828292C6865696768743A742E68656967687428297D2C692C2130293B6E2E656D6974282264726177222C7B74';
wwv_flow_api.g_varchar2_table(81) := '7970653A22677269644261636B67726F756E64222C67726F75703A652C656C656D656E743A727D297D2C742E6372656174654C6162656C3D66756E6374696F6E28652C692C722C612C732C6F2C6C2C632C752C642C68297B76617220702C663D7B7D3B69';
wwv_flow_api.g_varchar2_table(82) := '6628665B732E756E6974732E706F735D3D652B6C5B732E756E6974732E706F735D2C665B732E636F756E746572556E6974732E706F735D3D6C5B732E636F756E746572556E6974732E706F735D2C665B732E756E6974732E6C656E5D3D692C665B732E63';
wwv_flow_api.g_varchar2_table(83) := '6F756E746572556E6974732E6C656E5D3D4D6174682E6D617828302C6F2D3130292C64297B766172206D3D6E2E637265617465456C656D656E7428227370616E22293B6D2E636C6173734E616D653D752E6A6F696E28222022292C6D2E73657441747472';
wwv_flow_api.g_varchar2_table(84) := '69627574652822786D6C6E73222C742E6E616D657370616365732E7868746D6C292C6D2E696E6E6572546578743D615B725D2C6D2E7374796C655B732E756E6974732E6C656E5D3D4D6174682E726F756E6428665B732E756E6974732E6C656E5D292B22';
wwv_flow_api.g_varchar2_table(85) := '7078222C6D2E7374796C655B732E636F756E746572556E6974732E6C656E5D3D4D6174682E726F756E6428665B732E636F756E746572556E6974732E6C656E5D292B227078222C703D632E666F726569676E4F626A656374286D2C742E657874656E6428';
wwv_flow_api.g_varchar2_table(86) := '7B7374796C653A226F766572666C6F773A2076697369626C653B227D2C6629297D656C736520703D632E656C656D282274657874222C662C752E6A6F696E2822202229292E7465787428615B725D293B682E656D6974282264726177222C742E65787465';
wwv_flow_api.g_varchar2_table(87) := '6E64287B747970653A226C6162656C222C617869733A732C696E6465783A722C67726F75703A632C656C656D656E743A702C746578743A615B725D7D2C6629297D2C742E6765745365726965734F7074696F6E3D66756E6374696F6E28652C742C69297B';
wwv_flow_api.g_varchar2_table(88) := '696628652E6E616D652626742E7365726965732626742E7365726965735B652E6E616D655D297B766172206E3D742E7365726965735B652E6E616D655D3B72657475726E206E2E6861734F776E50726F70657274792869293F6E5B695D3A745B695D7D72';
wwv_flow_api.g_varchar2_table(89) := '657475726E20745B695D7D2C742E6F7074696F6E7350726F76696465723D66756E6374696F6E28652C6E2C72297B66756E6374696F6E20612865297B76617220613D733B696628733D742E657874656E64287B7D2C6C292C6E29666F72286F3D303B6F3C';
wwv_flow_api.g_varchar2_table(90) := '6E2E6C656E6774683B6F2B2B297B692E6D617463684D65646961286E5B6F5D5B305D292E6D617463686573262628733D742E657874656E6428732C6E5B6F5D5B315D29297D722626652626722E656D697428226F7074696F6E734368616E676564222C7B';
wwv_flow_api.g_varchar2_table(91) := '70726576696F75734F7074696F6E733A612C63757272656E744F7074696F6E733A737D297D76617220732C6F2C6C3D742E657874656E64287B7D2C65292C633D5B5D3B69662821692E6D617463684D65646961297468726F772277696E646F772E6D6174';
wwv_flow_api.g_varchar2_table(92) := '63684D65646961206E6F7420666F756E6421204D616B65207375726520796F75277265207573696E67206120706F6C7966696C6C2E223B6966286E29666F72286F3D303B6F3C6E2E6C656E6774683B6F2B2B297B76617220753D692E6D617463684D6564';
wwv_flow_api.g_varchar2_table(93) := '6961286E5B6F5D5B305D293B752E6164644C697374656E65722861292C632E707573682875297D72657475726E206128292C7B72656D6F76654D6564696151756572794C697374656E6572733A66756E6374696F6E28297B632E666F7245616368286675';
wwv_flow_api.g_varchar2_table(94) := '6E6374696F6E2865297B652E72656D6F76654C697374656E65722861297D297D2C67657443757272656E744F7074696F6E733A66756E6374696F6E28297B72657475726E20742E657874656E64287B7D2C73297D7D7D2C742E73706C6974496E746F5365';
wwv_flow_api.g_varchar2_table(95) := '676D656E74733D66756E6374696F6E28652C692C6E297B6E3D742E657874656E64287B7D2C7B696E6372656173696E67583A21312C66696C6C486F6C65733A21317D2C6E293B666F722876617220723D5B5D2C613D21302C733D303B733C652E6C656E67';
wwv_flow_api.g_varchar2_table(96) := '74683B732B3D3229766F696420303D3D3D742E6765744D756C746956616C756528695B732F325D2E76616C7565293F6E2E66696C6C486F6C65737C7C28613D2130293A286E2E696E6372656173696E67582626733E3D322626655B735D3C3D655B732D32';
wwv_flow_api.g_varchar2_table(97) := '5D262628613D2130292C61262628722E70757368287B70617468436F6F7264696E617465733A5B5D2C76616C7565446174613A5B5D7D292C613D2131292C725B722E6C656E6774682D315D2E70617468436F6F7264696E617465732E7075736828655B73';
wwv_flow_api.g_varchar2_table(98) := '5D2C655B732B315D292C725B722E6C656E6774682D315D2E76616C7565446174612E7075736828695B732F325D29293B72657475726E20727D7D28746869737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B2275736520737472696374';
wwv_flow_api.g_varchar2_table(99) := '223B742E496E746572706F6C6174696F6E3D7B7D2C742E496E746572706F6C6174696F6E2E6E6F6E653D66756E6374696F6E2865297B72657475726E20653D742E657874656E64287B7D2C7B66696C6C486F6C65733A21317D2C65292C66756E6374696F';
wwv_flow_api.g_varchar2_table(100) := '6E28692C6E297B666F722876617220723D6E657720742E5376672E506174682C613D21302C733D303B733C692E6C656E6774683B732B3D32297B766172206F3D695B735D2C6C3D695B732B315D2C633D6E5B732F325D3B766F69642030213D3D742E6765';
wwv_flow_api.g_varchar2_table(101) := '744D756C746956616C756528632E76616C7565293F28613F722E6D6F7665286F2C6C2C21312C63293A722E6C696E65286F2C6C2C21312C63292C613D2131293A652E66696C6C486F6C65737C7C28613D2130297D72657475726E20727D7D2C742E496E74';
wwv_flow_api.g_varchar2_table(102) := '6572706F6C6174696F6E2E73696D706C653D66756E6374696F6E2865297B653D742E657874656E64287B7D2C7B64697669736F723A322C66696C6C486F6C65733A21317D2C65293B76617220693D312F4D6174682E6D617828312C652E64697669736F72';
wwv_flow_api.g_varchar2_table(103) := '293B72657475726E2066756E6374696F6E286E2C72297B666F722876617220612C732C6F2C6C3D6E657720742E5376672E506174682C633D303B633C6E2E6C656E6774683B632B3D32297B76617220753D6E5B635D2C643D6E5B632B315D2C683D28752D';
wwv_flow_api.g_varchar2_table(104) := '61292A692C703D725B632F325D3B766F69642030213D3D702E76616C75653F28766F696420303D3D3D6F3F6C2E6D6F766528752C642C21312C70293A6C2E637572766528612B682C732C752D682C642C752C642C21312C70292C613D752C733D642C6F3D';
wwv_flow_api.g_varchar2_table(105) := '70293A652E66696C6C486F6C65737C7C28613D753D6F3D766F69642030297D72657475726E206C7D7D2C742E496E746572706F6C6174696F6E2E63617264696E616C3D66756E6374696F6E2865297B653D742E657874656E64287B7D2C7B74656E73696F';
wwv_flow_api.g_varchar2_table(106) := '6E3A312C66696C6C486F6C65733A21317D2C65293B76617220693D4D6174682E6D696E28312C4D6174682E6D617828302C652E74656E73696F6E29292C6E3D312D693B72657475726E2066756E6374696F6E207228612C73297B766172206F3D742E7370';
wwv_flow_api.g_varchar2_table(107) := '6C6974496E746F5365676D656E747328612C732C7B66696C6C486F6C65733A652E66696C6C486F6C65737D293B6966286F2E6C656E677468297B6966286F2E6C656E6774683E31297B766172206C3D5B5D3B72657475726E206F2E666F72456163682866';
wwv_flow_api.g_varchar2_table(108) := '756E6374696F6E2865297B6C2E70757368287228652E70617468436F6F7264696E617465732C652E76616C75654461746129297D292C742E5376672E506174682E6A6F696E286C297D696628613D6F5B305D2E70617468436F6F7264696E617465732C73';
wwv_flow_api.g_varchar2_table(109) := '3D6F5B305D2E76616C7565446174612C612E6C656E6774683C3D342972657475726E20742E496E746572706F6C6174696F6E2E6E6F6E65282928612C73293B666F722876617220633D286E657720742E5376672E50617468292E6D6F766528615B305D2C';
wwv_flow_api.g_varchar2_table(110) := '615B315D2C21312C735B305D292C753D302C643D612E6C656E6774683B642D323E753B752B3D32297B76617220683D5B7B783A2B615B752D325D2C793A2B615B752D315D7D2C7B783A2B615B755D2C793A2B615B752B315D7D2C7B783A2B615B752B325D';
wwv_flow_api.g_varchar2_table(111) := '2C793A2B615B752B335D7D2C7B783A2B615B752B345D2C793A2B615B752B355D7D5D3B642D343D3D3D753F685B335D3D685B325D3A757C7C28685B305D3D7B783A2B615B755D2C793A2B615B752B315D7D292C632E637572766528692A282D685B305D2E';
wwv_flow_api.g_varchar2_table(112) := '782B362A685B315D2E782B685B325D2E78292F362B6E2A685B325D2E782C692A282D685B305D2E792B362A685B315D2E792B685B325D2E79292F362B6E2A685B325D2E792C692A28685B315D2E782B362A685B325D2E782D685B335D2E78292F362B6E2A';
wwv_flow_api.g_varchar2_table(113) := '685B325D2E782C692A28685B315D2E792B362A685B325D2E792D685B335D2E79292F362B6E2A685B325D2E792C685B325D2E782C685B325D2E792C21312C735B28752B32292F325D297D72657475726E20637D72657475726E20742E496E746572706F6C';
wwv_flow_api.g_varchar2_table(114) := '6174696F6E2E6E6F6E652829285B5D297D7D2C742E496E746572706F6C6174696F6E2E6D6F6E6F746F6E6543756269633D66756E6374696F6E2865297B72657475726E20653D742E657874656E64287B7D2C7B66696C6C486F6C65733A21317D2C65292C';
wwv_flow_api.g_varchar2_table(115) := '66756E6374696F6E2069286E2C72297B76617220613D742E73706C6974496E746F5365676D656E7473286E2C722C7B66696C6C486F6C65733A652E66696C6C486F6C65732C696E6372656173696E67583A21307D293B696628612E6C656E677468297B69';
wwv_flow_api.g_varchar2_table(116) := '6628612E6C656E6774683E31297B76617220733D5B5D3B72657475726E20612E666F72456163682866756E6374696F6E2865297B732E70757368286928652E70617468436F6F7264696E617465732C652E76616C75654461746129297D292C742E537667';
wwv_flow_api.g_varchar2_table(117) := '2E506174682E6A6F696E2873297D6966286E3D615B305D2E70617468436F6F7264696E617465732C723D615B305D2E76616C7565446174612C6E2E6C656E6774683C3D342972657475726E20742E496E746572706F6C6174696F6E2E6E6F6E652829286E';
wwv_flow_api.g_varchar2_table(118) := '2C72293B766172206F2C6C2C633D5B5D2C753D5B5D2C643D6E2E6C656E6774682F322C683D5B5D2C703D5B5D2C663D5B5D2C6D3D5B5D3B666F72286F3D303B6F3C643B6F2B2B29635B6F5D3D6E5B322A6F5D2C755B6F5D3D6E5B322A6F2B315D3B666F72';
wwv_flow_api.g_varchar2_table(119) := '286F3D303B6F3C642D313B6F2B2B29665B6F5D3D755B6F2B315D2D755B6F5D2C6D5B6F5D3D635B6F2B315D2D635B6F5D2C705B6F5D3D665B6F5D2F6D5B6F5D3B666F7228685B305D3D705B305D2C685B642D315D3D705B642D325D2C6F3D313B6F3C642D';
wwv_flow_api.g_varchar2_table(120) := '313B6F2B2B29303D3D3D705B6F5D7C7C303D3D3D705B6F2D315D7C7C705B6F2D315D3E30213D705B6F5D3E303F685B6F5D3D303A28685B6F5D3D332A286D5B6F2D315D2B6D5B6F5D292F2828322A6D5B6F5D2B6D5B6F2D315D292F705B6F2D315D2B286D';
wwv_flow_api.g_varchar2_table(121) := '5B6F5D2B322A6D5B6F2D315D292F705B6F5D292C697346696E69746528685B6F5D297C7C28685B6F5D3D3029293B666F72286C3D286E657720742E5376672E50617468292E6D6F766528635B305D2C755B305D2C21312C725B305D292C6F3D303B6F3C64';
wwv_flow_api.g_varchar2_table(122) := '2D313B6F2B2B296C2E637572766528635B6F5D2B6D5B6F5D2F332C755B6F5D2B685B6F5D2A6D5B6F5D2F332C635B6F2B315D2D6D5B6F5D2F332C755B6F2B315D2D685B6F2B315D2A6D5B6F5D2F332C635B6F2B315D2C755B6F2B315D2C21312C725B6F2B';
wwv_flow_api.g_varchar2_table(123) := '315D293B72657475726E206C7D72657475726E20742E496E746572706F6C6174696F6E2E6E6F6E652829285B5D297D7D2C742E496E746572706F6C6174696F6E2E737465703D66756E6374696F6E2865297B72657475726E20653D742E657874656E6428';
wwv_flow_api.g_varchar2_table(124) := '7B7D2C7B706F7374706F6E653A21302C66696C6C486F6C65733A21317D2C65292C66756E6374696F6E28692C6E297B666F722876617220722C612C732C6F3D6E657720742E5376672E506174682C6C3D303B6C3C692E6C656E6774683B6C2B3D32297B76';
wwv_flow_api.g_varchar2_table(125) := '617220633D695B6C5D2C753D695B6C2B315D2C643D6E5B6C2F325D3B766F69642030213D3D642E76616C75653F28766F696420303D3D3D733F6F2E6D6F766528632C752C21312C64293A28652E706F7374706F6E653F6F2E6C696E6528632C612C21312C';
wwv_flow_api.g_varchar2_table(126) := '73293A6F2E6C696E6528722C752C21312C64292C6F2E6C696E6528632C752C21312C6429292C723D632C613D752C733D64293A652E66696C6C486F6C65737C7C28723D613D733D766F69642030297D72657475726E206F7D7D7D28746869737C7C676C6F';
wwv_flow_api.g_varchar2_table(127) := '62616C2C65292C66756E6374696F6E28742C69297B2275736520737472696374223B652E4576656E74456D69747465723D66756E6374696F6E28297B76617220653D5B5D3B72657475726E7B6164644576656E7448616E646C65723A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(128) := '28742C69297B655B745D3D655B745D7C7C5B5D2C655B745D2E707573682869297D2C72656D6F76654576656E7448616E646C65723A66756E6374696F6E28742C69297B655B745D262628693F28655B745D2E73706C69636528655B745D2E696E6465784F';
wwv_flow_api.g_varchar2_table(129) := '662869292C31292C303D3D3D655B745D2E6C656E677468262664656C65746520655B745D293A64656C65746520655B745D297D2C656D69743A66756E6374696F6E28742C69297B655B745D2626655B745D2E666F72456163682866756E6374696F6E2865';
wwv_flow_api.g_varchar2_table(130) := '297B652869297D292C655B222A225D2626655B222A225D2E666F72456163682866756E6374696F6E2865297B6528742C69297D297D7D7D7D28746869737C7C676C6F62616C292C66756E6374696F6E28652C74297B2275736520737472696374223B742E';
wwv_flow_api.g_varchar2_table(131) := '436C6173733D7B657874656E643A66756E6374696F6E28652C69297B766172206E3D697C7C746869732E70726F746F747970657C7C742E436C6173732C723D4F626A6563742E637265617465286E293B742E436C6173732E636C6F6E65446566696E6974';
wwv_flow_api.g_varchar2_table(132) := '696F6E7328722C65293B76617220613D66756E6374696F6E28297B76617220652C693D722E636F6E7374727563746F727C7C66756E6374696F6E28297B7D3B72657475726E20653D746869733D3D3D743F4F626A6563742E6372656174652872293A7468';
wwv_flow_api.g_varchar2_table(133) := '69732C692E6170706C7928652C41727261792E70726F746F747970652E736C6963652E63616C6C28617267756D656E74732C3029292C657D3B72657475726E20612E70726F746F747970653D722C612E73757065723D6E2C612E657874656E643D746869';
wwv_flow_api.g_varchar2_table(134) := '732E657874656E642C617D2C636C6F6E65446566696E6974696F6E733A66756E6374696F6E28297B76617220653D66756E6374696F6E2865297B76617220743D5B5D3B696628652E6C656E67746829666F722876617220693D303B693C652E6C656E6774';
wwv_flow_api.g_varchar2_table(135) := '683B692B2B29742E7075736828655B695D293B72657475726E20747D28617267756D656E7473292C743D655B305D3B72657475726E20652E73706C69636528312C652E6C656E6774682D31292E666F72456163682866756E6374696F6E2865297B4F626A';
wwv_flow_api.g_varchar2_table(136) := '6563742E6765744F776E50726F70657274794E616D65732865292E666F72456163682866756E6374696F6E2869297B64656C65746520745B695D2C4F626A6563742E646566696E6550726F706572747928742C692C4F626A6563742E6765744F776E5072';
wwv_flow_api.g_varchar2_table(137) := '6F706572747944657363726970746F7228652C6929297D297D292C747D7D7D28746869737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B2275736520737472696374223B76617220693D652E77696E646F773B742E426173653D742E43';
wwv_flow_api.g_varchar2_table(138) := '6C6173732E657874656E64287B636F6E7374727563746F723A66756E6374696F6E28652C6E2C722C612C73297B746869732E636F6E7461696E65723D742E717565727953656C6563746F722865292C746869732E646174613D6E7C7C7B7D2C746869732E';
wwv_flow_api.g_varchar2_table(139) := '646174612E6C6162656C733D746869732E646174612E6C6162656C737C7C5B5D2C746869732E646174612E7365726965733D746869732E646174612E7365726965737C7C5B5D2C746869732E64656661756C744F7074696F6E733D722C746869732E6F70';
wwv_flow_api.g_varchar2_table(140) := '74696F6E733D612C746869732E726573706F6E736976654F7074696F6E733D732C746869732E6576656E74456D69747465723D742E4576656E74456D697474657228292C746869732E737570706F727473466F726569676E4F626A6563743D742E537667';
wwv_flow_api.g_varchar2_table(141) := '2E6973537570706F727465642822457874656E736962696C69747922292C746869732E737570706F727473416E696D6174696F6E733D742E5376672E6973537570706F727465642822416E696D6174696F6E4576656E747341747472696275746522292C';
wwv_flow_api.g_varchar2_table(142) := '746869732E726573697A654C697374656E65723D66756E6374696F6E28297B746869732E75706461746528297D2E62696E642874686973292C746869732E636F6E7461696E6572262628746869732E636F6E7461696E65722E5F5F63686172746973745F';
wwv_flow_api.g_varchar2_table(143) := '5F2626746869732E636F6E7461696E65722E5F5F63686172746973745F5F2E64657461636828292C746869732E636F6E7461696E65722E5F5F63686172746973745F5F3D74686973292C746869732E696E697469616C697A6554696D656F757449643D73';
wwv_flow_api.g_varchar2_table(144) := '657454696D656F75742866756E6374696F6E28297B692E6164644576656E744C697374656E65722822726573697A65222C746869732E726573697A654C697374656E6572292C746869732E6F7074696F6E7350726F76696465723D742E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(145) := '50726F766964657228746869732E6F7074696F6E732C746869732E726573706F6E736976654F7074696F6E732C746869732E6576656E74456D6974746572292C746869732E6576656E74456D69747465722E6164644576656E7448616E646C657228226F';
wwv_flow_api.g_varchar2_table(146) := '7074696F6E734368616E676564222C66756E6374696F6E28297B746869732E75706461746528297D2E62696E64287468697329292C746869732E6F7074696F6E732E706C7567696E732626746869732E6F7074696F6E732E706C7567696E732E666F7245';
wwv_flow_api.g_varchar2_table(147) := '6163682866756E6374696F6E2865297B6520696E7374616E63656F662041727261793F655B305D28746869732C655B315D293A652874686973297D2E62696E64287468697329292C746869732E6576656E74456D69747465722E656D6974282264617461';
wwv_flow_api.g_varchar2_table(148) := '222C7B747970653A22696E697469616C222C646174613A746869732E646174617D292C746869732E637265617465436861727428746869732E6F7074696F6E7350726F76696465722E67657443757272656E744F7074696F6E732829292C746869732E69';
wwv_flow_api.g_varchar2_table(149) := '6E697469616C697A6554696D656F757449643D766F696420307D2E62696E642874686973292C30297D2C6F7074696F6E7350726F76696465723A766F696420302C636F6E7461696E65723A766F696420302C7376673A766F696420302C6576656E74456D';
wwv_flow_api.g_varchar2_table(150) := '69747465723A766F696420302C63726561746543686172743A66756E6374696F6E28297B7468726F77206E6577204572726F7228224261736520636861727420747970652063616E277420626520696E7374616E7469617465642122297D2C7570646174';
wwv_flow_api.g_varchar2_table(151) := '653A66756E6374696F6E28652C692C6E297B72657475726E2065262628746869732E646174613D657C7C7B7D2C746869732E646174612E6C6162656C733D746869732E646174612E6C6162656C737C7C5B5D2C746869732E646174612E7365726965733D';
wwv_flow_api.g_varchar2_table(152) := '746869732E646174612E7365726965737C7C5B5D2C746869732E6576656E74456D69747465722E656D6974282264617461222C7B747970653A22757064617465222C646174613A746869732E646174617D29292C69262628746869732E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(153) := '3D742E657874656E64287B7D2C6E3F746869732E6F7074696F6E733A746869732E64656661756C744F7074696F6E732C69292C746869732E696E697469616C697A6554696D656F757449647C7C28746869732E6F7074696F6E7350726F76696465722E72';
wwv_flow_api.g_varchar2_table(154) := '656D6F76654D6564696151756572794C697374656E65727328292C746869732E6F7074696F6E7350726F76696465723D742E6F7074696F6E7350726F766964657228746869732E6F7074696F6E732C746869732E726573706F6E736976654F7074696F6E';
wwv_flow_api.g_varchar2_table(155) := '732C746869732E6576656E74456D69747465722929292C746869732E696E697469616C697A6554696D656F757449647C7C746869732E637265617465436861727428746869732E6F7074696F6E7350726F76696465722E67657443757272656E744F7074';
wwv_flow_api.g_varchar2_table(156) := '696F6E732829292C746869737D2C6465746163683A66756E6374696F6E28297B72657475726E20746869732E696E697469616C697A6554696D656F757449643F692E636C65617254696D656F757428746869732E696E697469616C697A6554696D656F75';
wwv_flow_api.g_varchar2_table(157) := '744964293A28692E72656D6F76654576656E744C697374656E65722822726573697A65222C746869732E726573697A654C697374656E6572292C746869732E6F7074696F6E7350726F76696465722E72656D6F76654D6564696151756572794C69737465';
wwv_flow_api.g_varchar2_table(158) := '6E6572732829292C746869737D2C6F6E3A66756E6374696F6E28652C74297B72657475726E20746869732E6576656E74456D69747465722E6164644576656E7448616E646C657228652C74292C746869737D2C6F66663A66756E6374696F6E28652C7429';
wwv_flow_api.g_varchar2_table(159) := '7B72657475726E20746869732E6576656E74456D69747465722E72656D6F76654576656E7448616E646C657228652C74292C746869737D2C76657273696F6E3A742E76657273696F6E2C737570706F727473466F726569676E4F626A6563743A21317D29';
wwv_flow_api.g_varchar2_table(160) := '7D28746869737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B2275736520737472696374223B76617220693D652E646F63756D656E743B742E5376673D742E436C6173732E657874656E64287B636F6E7374727563746F723A66756E63';
wwv_flow_api.g_varchar2_table(161) := '74696F6E28652C6E2C722C612C73297B6520696E7374616E63656F6620456C656D656E743F746869732E5F6E6F64653D653A28746869732E5F6E6F64653D692E637265617465456C656D656E744E5328742E6E616D657370616365732E7376672C65292C';
wwv_flow_api.g_varchar2_table(162) := '22737667223D3D3D652626746869732E61747472287B22786D6C6E733A6374223A742E6E616D657370616365732E63747D29292C6E2626746869732E61747472286E292C722626746869732E616464436C6173732872292C61262628732626612E5F6E6F';
wwv_flow_api.g_varchar2_table(163) := '64652E66697273744368696C643F612E5F6E6F64652E696E736572744265666F726528746869732E5F6E6F64652C612E5F6E6F64652E66697273744368696C64293A612E5F6E6F64652E617070656E644368696C6428746869732E5F6E6F646529297D2C';
wwv_flow_api.g_varchar2_table(164) := '617474723A66756E6374696F6E28652C69297B72657475726E22737472696E67223D3D747970656F6620653F693F746869732E5F6E6F64652E6765744174747269627574654E5328692C65293A746869732E5F6E6F64652E676574417474726962757465';
wwv_flow_api.g_varchar2_table(165) := '2865293A284F626A6563742E6B6579732865292E666F72456163682866756E6374696F6E2869297B696628766F69642030213D3D655B695D296966282D31213D3D692E696E6465784F6628223A2229297B766172206E3D692E73706C697428223A22293B';
wwv_flow_api.g_varchar2_table(166) := '746869732E5F6E6F64652E7365744174747269627574654E5328742E6E616D657370616365735B6E5B305D5D2C692C655B695D297D656C736520746869732E5F6E6F64652E73657441747472696275746528692C655B695D297D2E62696E642874686973';
wwv_flow_api.g_varchar2_table(167) := '29292C74686973297D2C656C656D3A66756E6374696F6E28652C692C6E2C72297B72657475726E206E657720742E53766728652C692C6E2C746869732C72297D2C706172656E743A66756E6374696F6E28297B72657475726E20746869732E5F6E6F6465';
wwv_flow_api.g_varchar2_table(168) := '2E706172656E744E6F646520696E7374616E63656F6620535647456C656D656E743F6E657720742E53766728746869732E5F6E6F64652E706172656E744E6F6465293A6E756C6C7D2C726F6F743A66756E6374696F6E28297B666F722876617220653D74';
wwv_flow_api.g_varchar2_table(169) := '6869732E5F6E6F64653B2273766722213D3D652E6E6F64654E616D653B29653D652E706172656E744E6F64653B72657475726E206E657720742E5376672865297D2C717565727953656C6563746F723A66756E6374696F6E2865297B76617220693D7468';
wwv_flow_api.g_varchar2_table(170) := '69732E5F6E6F64652E717565727953656C6563746F722865293B72657475726E20693F6E657720742E5376672869293A6E756C6C7D2C717565727953656C6563746F72416C6C3A66756E6374696F6E2865297B76617220693D746869732E5F6E6F64652E';
wwv_flow_api.g_varchar2_table(171) := '717565727953656C6563746F72416C6C2865293B72657475726E20692E6C656E6774683F6E657720742E5376672E4C6973742869293A6E756C6C7D2C6765744E6F64653A66756E6374696F6E28297B72657475726E20746869732E5F6E6F64657D2C666F';
wwv_flow_api.g_varchar2_table(172) := '726569676E4F626A6563743A66756E6374696F6E28652C6E2C722C61297B69662822737472696E67223D3D747970656F662065297B76617220733D692E637265617465456C656D656E74282264697622293B732E696E6E657248544D4C3D652C653D732E';
wwv_flow_api.g_varchar2_table(173) := '66697273744368696C647D652E7365744174747269627574652822786D6C6E73222C742E6E616D657370616365732E786D6C6E73293B766172206F3D746869732E656C656D2822666F726569676E4F626A656374222C6E2C722C61293B72657475726E20';
wwv_flow_api.g_varchar2_table(174) := '6F2E5F6E6F64652E617070656E644368696C642865292C6F7D2C746578743A66756E6374696F6E2865297B72657475726E20746869732E5F6E6F64652E617070656E644368696C6428692E637265617465546578744E6F6465286529292C746869737D2C';
wwv_flow_api.g_varchar2_table(175) := '656D7074793A66756E6374696F6E28297B666F72283B746869732E5F6E6F64652E66697273744368696C643B29746869732E5F6E6F64652E72656D6F76654368696C6428746869732E5F6E6F64652E66697273744368696C64293B72657475726E207468';
wwv_flow_api.g_varchar2_table(176) := '69737D2C72656D6F76653A66756E6374696F6E28297B72657475726E20746869732E5F6E6F64652E706172656E744E6F64652E72656D6F76654368696C6428746869732E5F6E6F6465292C746869732E706172656E7428297D2C7265706C6163653A6675';
wwv_flow_api.g_varchar2_table(177) := '6E6374696F6E2865297B72657475726E20746869732E5F6E6F64652E706172656E744E6F64652E7265706C6163654368696C6428652E5F6E6F64652C746869732E5F6E6F6465292C657D2C617070656E643A66756E6374696F6E28652C74297B72657475';
wwv_flow_api.g_varchar2_table(178) := '726E20742626746869732E5F6E6F64652E66697273744368696C643F746869732E5F6E6F64652E696E736572744265666F726528652E5F6E6F64652C746869732E5F6E6F64652E66697273744368696C64293A746869732E5F6E6F64652E617070656E64';
wwv_flow_api.g_varchar2_table(179) := '4368696C6428652E5F6E6F6465292C746869737D2C636C61737365733A66756E6374696F6E28297B72657475726E20746869732E5F6E6F64652E6765744174747269627574652822636C61737322293F746869732E5F6E6F64652E676574417474726962';
wwv_flow_api.g_varchar2_table(180) := '7574652822636C61737322292E7472696D28292E73706C6974282F5C732B2F293A5B5D7D2C616464436C6173733A66756E6374696F6E2865297B72657475726E20746869732E5F6E6F64652E7365744174747269627574652822636C617373222C746869';
wwv_flow_api.g_varchar2_table(181) := '732E636C617373657328746869732E5F6E6F6465292E636F6E63617428652E7472696D28292E73706C6974282F5C732B2F29292E66696C7465722866756E6374696F6E28652C742C69297B72657475726E20692E696E6465784F662865293D3D3D747D29';
wwv_flow_api.g_varchar2_table(182) := '2E6A6F696E2822202229292C746869737D2C72656D6F7665436C6173733A66756E6374696F6E2865297B76617220743D652E7472696D28292E73706C6974282F5C732B2F293B72657475726E20746869732E5F6E6F64652E736574417474726962757465';
wwv_flow_api.g_varchar2_table(183) := '2822636C617373222C746869732E636C617373657328746869732E5F6E6F6465292E66696C7465722866756E6374696F6E2865297B72657475726E2D313D3D3D742E696E6465784F662865297D292E6A6F696E2822202229292C746869737D2C72656D6F';
wwv_flow_api.g_varchar2_table(184) := '7665416C6C436C61737365733A66756E6374696F6E28297B72657475726E20746869732E5F6E6F64652E7365744174747269627574652822636C617373222C2222292C746869737D2C6865696768743A66756E6374696F6E28297B72657475726E207468';
wwv_flow_api.g_varchar2_table(185) := '69732E5F6E6F64652E676574426F756E64696E67436C69656E745265637428292E6865696768747D2C77696474683A66756E6374696F6E28297B72657475726E20746869732E5F6E6F64652E676574426F756E64696E67436C69656E745265637428292E';
wwv_flow_api.g_varchar2_table(186) := '77696474687D2C616E696D6174653A66756E6374696F6E28652C692C6E297B72657475726E20766F696420303D3D3D69262628693D2130292C4F626A6563742E6B6579732865292E666F72456163682866756E6374696F6E2872297B66756E6374696F6E';
wwv_flow_api.g_varchar2_table(187) := '206128652C69297B76617220612C732C6F2C6C3D7B7D3B652E656173696E672626286F3D652E656173696E6720696E7374616E63656F662041727261793F652E656173696E673A742E5376672E456173696E675B652E656173696E675D2C64656C657465';
wwv_flow_api.g_varchar2_table(188) := '20652E656173696E67292C652E626567696E3D742E656E73757265556E697428652E626567696E2C226D7322292C652E6475723D742E656E73757265556E697428652E6475722C226D7322292C6F262628652E63616C634D6F64653D2273706C696E6522';
wwv_flow_api.g_varchar2_table(189) := '2C652E6B657953706C696E65733D6F2E6A6F696E28222022292C652E6B657954696D65733D22303B3122292C69262628652E66696C6C3D22667265657A65222C6C5B725D3D652E66726F6D2C746869732E61747472286C292C733D742E7175616E746974';
wwv_flow_api.g_varchar2_table(190) := '7928652E626567696E7C7C30292E76616C75652C652E626567696E3D22696E646566696E69746522292C613D746869732E656C656D2822616E696D617465222C742E657874656E64287B6174747269627574654E616D653A727D2C6529292C6926267365';
wwv_flow_api.g_varchar2_table(191) := '7454696D656F75742866756E6374696F6E28297B7472797B612E5F6E6F64652E626567696E456C656D656E7428297D63617463682874297B6C5B725D3D652E746F2C746869732E61747472286C292C612E72656D6F766528297D7D2E62696E6428746869';
wwv_flow_api.g_varchar2_table(192) := '73292C73292C6E2626612E5F6E6F64652E6164644576656E744C697374656E65722822626567696E4576656E74222C66756E6374696F6E28297B6E2E656D69742822616E696D6174696F6E426567696E222C7B656C656D656E743A746869732C616E696D';
wwv_flow_api.g_varchar2_table(193) := '6174653A612E5F6E6F64652C706172616D733A657D297D2E62696E64287468697329292C612E5F6E6F64652E6164644576656E744C697374656E65722822656E644576656E74222C66756E6374696F6E28297B6E26266E2E656D69742822616E696D6174';
wwv_flow_api.g_varchar2_table(194) := '696F6E456E64222C7B656C656D656E743A746869732C616E696D6174653A612E5F6E6F64652C706172616D733A657D292C692626286C5B725D3D652E746F2C746869732E61747472286C292C612E72656D6F76652829297D2E62696E6428746869732929';
wwv_flow_api.g_varchar2_table(195) := '7D655B725D696E7374616E63656F662041727261793F655B725D2E666F72456163682866756E6374696F6E2865297B612E62696E6428746869732928652C2131297D2E62696E64287468697329293A612E62696E6428746869732928655B725D2C69297D';
wwv_flow_api.g_varchar2_table(196) := '2E62696E64287468697329292C746869737D7D292C742E5376672E6973537570706F727465643D66756E6374696F6E2865297B72657475726E20692E696D706C656D656E746174696F6E2E686173466561747572652822687474703A2F2F7777772E7733';
wwv_flow_api.g_varchar2_table(197) := '2E6F72672F54522F53564731312F6665617475726523222B652C22312E3122297D3B742E5376672E456173696E673D7B65617365496E53696E653A5B2E34372C302C2E3734352C2E3731355D2C656173654F757453696E653A5B2E33392C2E3537352C2E';
wwv_flow_api.g_varchar2_table(198) := '3536352C315D2C65617365496E4F757453696E653A5B2E3434352C2E30352C2E35352C2E39355D2C65617365496E517561643A5B2E35352C2E3038352C2E36382C2E35335D2C656173654F7574517561643A5B2E32352C2E34362C2E34352C2E39345D2C';
wwv_flow_api.g_varchar2_table(199) := '65617365496E4F7574517561643A5B2E3435352C2E30332C2E3531352C2E3935355D2C65617365496E43756269633A5B2E35352C2E3035352C2E3637352C2E31395D2C656173654F757443756269633A5B2E3231352C2E36312C2E3335352C315D2C6561';
wwv_flow_api.g_varchar2_table(200) := '7365496E4F757443756269633A5B2E3634352C2E3034352C2E3335352C315D2C65617365496E51756172743A5B2E3839352C2E30332C2E3638352C2E32325D2C656173654F757451756172743A5B2E3136352C2E38342C2E34342C315D2C65617365496E';
wwv_flow_api.g_varchar2_table(201) := '4F757451756172743A5B2E37372C302C2E3137352C315D2C65617365496E5175696E743A5B2E3735352C2E30352C2E3835352C2E30365D2C656173654F75745175696E743A5B2E32332C312C2E33322C315D2C65617365496E4F75745175696E743A5B2E';
wwv_flow_api.g_varchar2_table(202) := '38362C302C2E30372C315D2C65617365496E4578706F3A5B2E39352C2E30352C2E3739352C2E3033355D2C656173654F75744578706F3A5B2E31392C312C2E32322C315D2C65617365496E4F75744578706F3A5B312C302C302C315D2C65617365496E43';
wwv_flow_api.g_varchar2_table(203) := '6972633A5B2E362C2E30342C2E39382C2E3333355D2C656173654F7574436972633A5B2E3037352C2E38322C2E3136352C315D2C65617365496E4F7574436972633A5B2E3738352C2E3133352C2E31352C2E38365D2C65617365496E4261636B3A5B2E36';
wwv_flow_api.g_varchar2_table(204) := '2C2D2E32382C2E3733352C2E3034355D2C656173654F75744261636B3A5B2E3137352C2E3838352C2E33322C312E3237355D2C65617365496E4F75744261636B3A5B2E36382C2D2E35352C2E3236352C312E35355D7D2C742E5376672E4C6973743D742E';
wwv_flow_api.g_varchar2_table(205) := '436C6173732E657874656E64287B636F6E7374727563746F723A66756E6374696F6E2865297B76617220693D746869733B746869732E737667456C656D656E74733D5B5D3B666F7228766172206E3D303B6E3C652E6C656E6774683B6E2B2B2974686973';
wwv_flow_api.g_varchar2_table(206) := '2E737667456C656D656E74732E70757368286E657720742E53766728655B6E5D29293B4F626A6563742E6B65797328742E5376672E70726F746F74797065292E66696C7465722866756E6374696F6E2865297B72657475726E2D313D3D3D5B22636F6E73';
wwv_flow_api.g_varchar2_table(207) := '74727563746F72222C22706172656E74222C22717565727953656C6563746F72222C22717565727953656C6563746F72416C6C222C227265706C616365222C22617070656E64222C22636C6173736573222C22686569676874222C227769647468225D2E';
wwv_flow_api.g_varchar2_table(208) := '696E6465784F662865297D292E666F72456163682866756E6374696F6E2865297B695B655D3D66756E6374696F6E28297B766172206E3D41727261792E70726F746F747970652E736C6963652E63616C6C28617267756D656E74732C30293B7265747572';
wwv_flow_api.g_varchar2_table(209) := '6E20692E737667456C656D656E74732E666F72456163682866756E6374696F6E2869297B742E5376672E70726F746F747970655B655D2E6170706C7928692C6E297D292C697D7D297D7D297D28746869737C7C676C6F62616C2C65292C66756E6374696F';
wwv_flow_api.g_varchar2_table(210) := '6E28652C74297B2275736520737472696374223B66756E6374696F6E206928652C692C6E2C722C612C73297B766172206F3D742E657874656E64287B636F6D6D616E643A613F652E746F4C6F7765724361736528293A652E746F55707065724361736528';
wwv_flow_api.g_varchar2_table(211) := '297D2C692C733F7B646174613A737D3A7B7D293B6E2E73706C69636528722C302C6F297D66756E6374696F6E206E28652C74297B652E666F72456163682866756E6374696F6E28692C6E297B725B692E636F6D6D616E642E746F4C6F7765724361736528';
wwv_flow_api.g_varchar2_table(212) := '295D2E666F72456163682866756E6374696F6E28722C61297B7428692C722C6E2C612C65297D297D297D76617220723D7B6D3A5B2278222C2279225D2C6C3A5B2278222C2279225D2C633A5B227831222C227931222C227832222C227932222C2278222C';
wwv_flow_api.g_varchar2_table(213) := '2279225D2C613A5B227278222C227279222C22784172222C226C4166222C227366222C2278222C2279225D7D2C613D7B61636375726163793A337D3B742E5376672E506174683D742E436C6173732E657874656E64287B636F6E7374727563746F723A66';
wwv_flow_api.g_varchar2_table(214) := '756E6374696F6E28652C69297B746869732E70617468456C656D656E74733D5B5D2C746869732E706F733D302C746869732E636C6F73653D652C746869732E6F7074696F6E733D742E657874656E64287B7D2C612C69297D2C706F736974696F6E3A6675';
wwv_flow_api.g_varchar2_table(215) := '6E6374696F6E2865297B72657475726E20766F69642030213D3D653F28746869732E706F733D4D6174682E6D617828302C4D6174682E6D696E28746869732E70617468456C656D656E74732E6C656E6774682C6529292C74686973293A746869732E706F';
wwv_flow_api.g_varchar2_table(216) := '737D2C72656D6F76653A66756E6374696F6E2865297B72657475726E20746869732E70617468456C656D656E74732E73706C69636528746869732E706F732C65292C746869737D2C6D6F76653A66756E6374696F6E28652C742C6E2C72297B7265747572';
wwv_flow_api.g_varchar2_table(217) := '6E206928224D222C7B783A2B652C793A2B747D2C746869732E70617468456C656D656E74732C746869732E706F732B2B2C6E2C72292C746869737D2C6C696E653A66756E6374696F6E28652C742C6E2C72297B72657475726E206928224C222C7B783A2B';
wwv_flow_api.g_varchar2_table(218) := '652C793A2B747D2C746869732E70617468456C656D656E74732C746869732E706F732B2B2C6E2C72292C746869737D2C63757276653A66756E6374696F6E28652C742C6E2C722C612C732C6F2C6C297B72657475726E2069282243222C7B78313A2B652C';
wwv_flow_api.g_varchar2_table(219) := '79313A2B742C78323A2B6E2C79323A2B722C783A2B612C793A2B737D2C746869732E70617468456C656D656E74732C746869732E706F732B2B2C6F2C6C292C746869737D2C6172633A66756E6374696F6E28652C742C6E2C722C612C732C6F2C6C2C6329';
wwv_flow_api.g_varchar2_table(220) := '7B72657475726E2069282241222C7B72783A2B652C72793A2B742C7841723A2B6E2C6C41663A2B722C73663A2B612C783A2B732C793A2B6F7D2C746869732E70617468456C656D656E74732C746869732E706F732B2B2C6C2C63292C746869737D2C7363';
wwv_flow_api.g_varchar2_table(221) := '616C653A66756E6374696F6E28652C74297B72657475726E206E28746869732E70617468456C656D656E74732C66756E6374696F6E28692C6E297B695B6E5D2A3D2278223D3D3D6E5B305D3F653A747D292C746869737D2C7472616E736C6174653A6675';
wwv_flow_api.g_varchar2_table(222) := '6E6374696F6E28652C74297B72657475726E206E28746869732E70617468456C656D656E74732C66756E6374696F6E28692C6E297B695B6E5D2B3D2278223D3D3D6E5B305D3F653A747D292C746869737D2C7472616E73666F726D3A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(223) := '2865297B72657475726E206E28746869732E70617468456C656D656E74732C66756E6374696F6E28742C692C6E2C722C61297B76617220733D6528742C692C6E2C722C61293B28737C7C303D3D3D7329262628745B695D3D73297D292C746869737D2C70';
wwv_flow_api.g_varchar2_table(224) := '617273653A66756E6374696F6E2865297B76617220693D652E7265706C616365282F285B412D5A612D7A5D29285B302D395D292F672C22243120243222292E7265706C616365282F285B302D395D29285B412D5A612D7A5D292F672C2224312024322229';
wwv_flow_api.g_varchar2_table(225) := '2E73706C6974282F5B5C732C5D2B2F292E7265647563652866756E6374696F6E28652C74297B72657475726E20742E6D61746368282F5B412D5A612D7A5D2F292626652E70757368285B5D292C655B652E6C656E6774682D315D2E707573682874292C65';
wwv_flow_api.g_varchar2_table(226) := '7D2C5B5D293B225A223D3D3D695B692E6C656E6774682D315D5B305D2E746F55707065724361736528292626692E706F7028293B766172206E3D692E6D61702866756E6374696F6E2865297B76617220693D652E736869667428292C6E3D725B692E746F';
wwv_flow_api.g_varchar2_table(227) := '4C6F7765724361736528295D3B72657475726E20742E657874656E64287B636F6D6D616E643A697D2C6E2E7265647563652866756E6374696F6E28742C692C6E297B72657475726E20745B695D3D2B655B6E5D2C747D2C7B7D29297D292C613D5B746869';
wwv_flow_api.g_varchar2_table(228) := '732E706F732C305D3B72657475726E2041727261792E70726F746F747970652E707573682E6170706C7928612C6E292C41727261792E70726F746F747970652E73706C6963652E6170706C7928746869732E70617468456C656D656E74732C61292C7468';
wwv_flow_api.g_varchar2_table(229) := '69732E706F732B3D6E2E6C656E6774682C746869737D2C737472696E676966793A66756E6374696F6E28297B76617220653D4D6174682E706F772831302C746869732E6F7074696F6E732E6163637572616379293B72657475726E20746869732E706174';
wwv_flow_api.g_varchar2_table(230) := '68456C656D656E74732E7265647563652866756E6374696F6E28742C69297B766172206E3D725B692E636F6D6D616E642E746F4C6F7765724361736528295D2E6D61702866756E6374696F6E2874297B72657475726E20746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(231) := '61636375726163793F4D6174682E726F756E6428695B745D2A65292F653A695B745D7D2E62696E64287468697329293B72657475726E20742B692E636F6D6D616E642B6E2E6A6F696E28222C22297D2E62696E642874686973292C2222292B2874686973';
wwv_flow_api.g_varchar2_table(232) := '2E636C6F73653F225A223A2222297D2C636C6F6E653A66756E6374696F6E2865297B76617220693D6E657720742E5376672E5061746828657C7C746869732E636C6F7365293B72657475726E20692E706F733D746869732E706F732C692E70617468456C';
wwv_flow_api.g_varchar2_table(233) := '656D656E74733D746869732E70617468456C656D656E74732E736C69636528292E6D61702866756E6374696F6E2865297B72657475726E20742E657874656E64287B7D2C65297D292C692E6F7074696F6E733D742E657874656E64287B7D2C746869732E';
wwv_flow_api.g_varchar2_table(234) := '6F7074696F6E73292C697D2C73706C69744279436F6D6D616E643A66756E6374696F6E2865297B76617220693D5B6E657720742E5376672E506174685D3B72657475726E20746869732E70617468456C656D656E74732E666F72456163682866756E6374';
wwv_flow_api.g_varchar2_table(235) := '696F6E286E297B6E2E636F6D6D616E643D3D3D652E746F5570706572436173652829262630213D3D695B692E6C656E6774682D315D2E70617468456C656D656E74732E6C656E6774682626692E70757368286E657720742E5376672E50617468292C695B';
wwv_flow_api.g_varchar2_table(236) := '692E6C656E6774682D315D2E70617468456C656D656E74732E70757368286E297D292C697D7D292C742E5376672E506174682E656C656D656E744465736372697074696F6E733D722C742E5376672E506174682E6A6F696E3D66756E6374696F6E28652C';
wwv_flow_api.g_varchar2_table(237) := '692C6E297B666F722876617220723D6E657720742E5376672E5061746828692C6E292C613D303B613C652E6C656E6774683B612B2B29666F722876617220733D655B615D2C6F3D303B6F3C732E70617468456C656D656E74732E6C656E6774683B6F2B2B';
wwv_flow_api.g_varchar2_table(238) := '29722E70617468456C656D656E74732E7075736828732E70617468456C656D656E74735B6F5D293B72657475726E20727D7D28746869737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B2275736520737472696374223B652E77696E64';
wwv_flow_api.g_varchar2_table(239) := '6F772C652E646F63756D656E743B76617220693D7B783A7B706F733A2278222C6C656E3A227769647468222C6469723A22686F72697A6F6E74616C222C7265637453746172743A227831222C72656374456E643A227832222C726563744F66667365743A';
wwv_flow_api.g_varchar2_table(240) := '227932227D2C793A7B706F733A2279222C6C656E3A22686569676874222C6469723A22766572746963616C222C7265637453746172743A227932222C72656374456E643A227931222C726563744F66667365743A227831227D7D3B742E417869733D742E';
wwv_flow_api.g_varchar2_table(241) := '436C6173732E657874656E64287B636F6E7374727563746F723A66756E6374696F6E28652C742C6E2C72297B746869732E756E6974733D652C746869732E636F756E746572556E6974733D653D3D3D692E783F692E793A692E782C746869732E63686172';
wwv_flow_api.g_varchar2_table(242) := '74526563743D742C746869732E617869734C656E6774683D745B652E72656374456E645D2D745B652E7265637453746172745D2C746869732E677269644F66667365743D745B652E726563744F66667365745D2C746869732E7469636B733D6E2C746869';
wwv_flow_api.g_varchar2_table(243) := '732E6F7074696F6E733D727D2C63726561746547726964416E644C6162656C733A66756E6374696F6E28652C692C6E2C722C61297B76617220733D725B2261786973222B746869732E756E6974732E706F732E746F55707065724361736528295D2C6F3D';
wwv_flow_api.g_varchar2_table(244) := '746869732E7469636B732E6D617028746869732E70726F6A65637456616C75652E62696E64287468697329292C6C3D746869732E7469636B732E6D617028732E6C6162656C496E746572706F6C6174696F6E466E63293B6F2E666F72456163682866756E';
wwv_flow_api.g_varchar2_table(245) := '6374696F6E28632C75297B76617220642C683D7B783A302C793A307D3B643D6F5B752B315D3F6F5B752B315D2D633A4D6174682E6D617828746869732E617869734C656E6774682D632C3330292C742E697346616C7365794275745A65726F286C5B755D';
wwv_flow_api.g_varchar2_table(246) := '2926262222213D3D6C5B755D7C7C282278223D3D3D746869732E756E6974732E706F733F28633D746869732E6368617274526563742E78312B632C682E783D722E61786973582E6C6162656C4F66667365742E782C227374617274223D3D3D722E617869';
wwv_flow_api.g_varchar2_table(247) := '73582E706F736974696F6E3F682E793D746869732E6368617274526563742E70616464696E672E746F702B722E61786973582E6C6162656C4F66667365742E792B286E3F353A3230293A682E793D746869732E6368617274526563742E79312B722E6178';
wwv_flow_api.g_varchar2_table(248) := '6973582E6C6162656C4F66667365742E792B286E3F353A323029293A28633D746869732E6368617274526563742E79312D632C682E793D722E61786973592E6C6162656C4F66667365742E792D286E3F643A30292C227374617274223D3D3D722E617869';
wwv_flow_api.g_varchar2_table(249) := '73592E706F736974696F6E3F682E783D6E3F746869732E6368617274526563742E70616464696E672E6C6566742B722E61786973592E6C6162656C4F66667365742E783A746869732E6368617274526563742E78312D31303A682E783D746869732E6368';
wwv_flow_api.g_varchar2_table(250) := '617274526563742E78322B722E61786973592E6C6162656C4F66667365742E782B3130292C732E73686F77477269642626742E6372656174654772696428632C752C746869732C746869732E677269644F66667365742C746869732E6368617274526563';
wwv_flow_api.g_varchar2_table(251) := '745B746869732E636F756E746572556E6974732E6C656E5D28292C652C5B722E636C6173734E616D65732E677269642C722E636C6173734E616D65735B746869732E756E6974732E6469725D5D2C61292C732E73686F774C6162656C2626742E63726561';
wwv_flow_api.g_varchar2_table(252) := '74654C6162656C28632C642C752C6C2C746869732C732E6F66667365742C682C692C5B722E636C6173734E616D65732E6C6162656C2C722E636C6173734E616D65735B746869732E756E6974732E6469725D2C227374617274223D3D3D732E706F736974';
wwv_flow_api.g_varchar2_table(253) := '696F6E3F722E636C6173734E616D65735B732E706F736974696F6E5D3A722E636C6173734E616D65732E656E645D2C6E2C6129297D2E62696E64287468697329297D2C70726F6A65637456616C75653A66756E6374696F6E28652C742C69297B7468726F';
wwv_flow_api.g_varchar2_table(254) := '77206E6577204572726F7228224261736520617869732063616E277420626520696E7374616E7469617465642122297D7D292C742E417869732E756E6974733D697D28746869737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B227573';
wwv_flow_api.g_varchar2_table(255) := '6520737472696374223B652E77696E646F772C652E646F63756D656E743B742E4175746F5363616C65417869733D742E417869732E657874656E64287B636F6E7374727563746F723A66756E6374696F6E28652C692C6E2C72297B76617220613D722E68';
wwv_flow_api.g_varchar2_table(256) := '6967684C6F777C7C742E676574486967684C6F7728692C722C652E706F73293B746869732E626F756E64733D742E676574426F756E6473286E5B652E72656374456E645D2D6E5B652E7265637453746172745D2C612C722E7363616C654D696E53706163';
wwv_flow_api.g_varchar2_table(257) := '657C7C32302C722E6F6E6C79496E7465676572292C746869732E72616E67653D7B6D696E3A746869732E626F756E64732E6D696E2C6D61783A746869732E626F756E64732E6D61787D2C742E4175746F5363616C65417869732E73757065722E636F6E73';
wwv_flow_api.g_varchar2_table(258) := '74727563746F722E63616C6C28746869732C652C6E2C746869732E626F756E64732E76616C7565732C72297D2C70726F6A65637456616C75653A66756E6374696F6E2865297B72657475726E20746869732E617869734C656E6774682A282B742E676574';
wwv_flow_api.g_varchar2_table(259) := '4D756C746956616C756528652C746869732E756E6974732E706F73292D746869732E626F756E64732E6D696E292F746869732E626F756E64732E72616E67657D7D297D28746869737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B2275';
wwv_flow_api.g_varchar2_table(260) := '736520737472696374223B652E77696E646F772C652E646F63756D656E743B742E46697865645363616C65417869733D742E417869732E657874656E64287B636F6E7374727563746F723A66756E6374696F6E28652C692C6E2C72297B76617220613D72';
wwv_flow_api.g_varchar2_table(261) := '2E686967684C6F777C7C742E676574486967684C6F7728692C722C652E706F73293B746869732E64697669736F723D722E64697669736F727C7C312C746869732E7469636B733D722E7469636B737C7C742E74696D657328746869732E64697669736F72';
wwv_flow_api.g_varchar2_table(262) := '292E6D61702866756E6374696F6E28652C74297B72657475726E20612E6C6F772B28612E686967682D612E6C6F77292F746869732E64697669736F722A747D2E62696E64287468697329292C746869732E7469636B732E736F72742866756E6374696F6E';
wwv_flow_api.g_varchar2_table(263) := '28652C74297B72657475726E20652D747D292C746869732E72616E67653D7B6D696E3A612E6C6F772C6D61783A612E686967687D2C742E46697865645363616C65417869732E73757065722E636F6E7374727563746F722E63616C6C28746869732C652C';
wwv_flow_api.g_varchar2_table(264) := '6E2C746869732E7469636B732C72292C746869732E737465704C656E6774683D746869732E617869734C656E6774682F746869732E64697669736F727D2C70726F6A65637456616C75653A66756E6374696F6E2865297B72657475726E20746869732E61';
wwv_flow_api.g_varchar2_table(265) := '7869734C656E6774682A282B742E6765744D756C746956616C756528652C746869732E756E6974732E706F73292D746869732E72616E67652E6D696E292F28746869732E72616E67652E6D61782D746869732E72616E67652E6D696E297D7D297D287468';
wwv_flow_api.g_varchar2_table(266) := '69737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B2275736520737472696374223B652E77696E646F772C652E646F63756D656E743B742E53746570417869733D742E417869732E657874656E64287B636F6E7374727563746F723A66';
wwv_flow_api.g_varchar2_table(267) := '756E6374696F6E28652C692C6E2C72297B742E53746570417869732E73757065722E636F6E7374727563746F722E63616C6C28746869732C652C6E2C722E7469636B732C72293B76617220613D4D6174682E6D617828312C722E7469636B732E6C656E67';
wwv_flow_api.g_varchar2_table(268) := '74682D28722E737472657463683F313A3029293B746869732E737465704C656E6774683D746869732E617869734C656E6774682F617D2C70726F6A65637456616C75653A66756E6374696F6E28652C74297B72657475726E20746869732E737465704C65';
wwv_flow_api.g_varchar2_table(269) := '6E6774682A747D7D297D28746869737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B2275736520737472696374223B652E77696E646F772C652E646F63756D656E743B76617220693D7B61786973583A7B6F66667365743A33302C706F';
wwv_flow_api.g_varchar2_table(270) := '736974696F6E3A22656E64222C6C6162656C4F66667365743A7B783A302C793A307D2C73686F774C6162656C3A21302C73686F77477269643A21302C6C6162656C496E746572706F6C6174696F6E466E633A742E6E6F6F702C747970653A766F69642030';
wwv_flow_api.g_varchar2_table(271) := '7D2C61786973593A7B6F66667365743A34302C706F736974696F6E3A227374617274222C6C6162656C4F66667365743A7B783A302C793A307D2C73686F774C6162656C3A21302C73686F77477269643A21302C6C6162656C496E746572706F6C6174696F';
wwv_flow_api.g_varchar2_table(272) := '6E466E633A742E6E6F6F702C747970653A766F696420302C7363616C654D696E53706163653A32302C6F6E6C79496E74656765723A21317D2C77696474683A766F696420302C6865696768743A766F696420302C73686F774C696E653A21302C73686F77';
wwv_flow_api.g_varchar2_table(273) := '506F696E743A21302C73686F77417265613A21312C61726561426173653A302C6C696E65536D6F6F74683A21302C73686F77477269644261636B67726F756E643A21312C6C6F773A766F696420302C686967683A766F696420302C636861727450616464';
wwv_flow_api.g_varchar2_table(274) := '696E673A7B746F703A31352C72696768743A31352C626F74746F6D3A352C6C6566743A31307D2C66756C6C57696474683A21312C72657665727365446174613A21312C636C6173734E616D65733A7B63686172743A2263742D63686172742D6C696E6522';
wwv_flow_api.g_varchar2_table(275) := '2C6C6162656C3A2263742D6C6162656C222C6C6162656C47726F75703A2263742D6C6162656C73222C7365726965733A2263742D736572696573222C6C696E653A2263742D6C696E65222C706F696E743A2263742D706F696E74222C617265613A226374';
wwv_flow_api.g_varchar2_table(276) := '2D61726561222C677269643A2263742D67726964222C6772696447726F75703A2263742D6772696473222C677269644261636B67726F756E643A2263742D677269642D6261636B67726F756E64222C766572746963616C3A2263742D766572746963616C';
wwv_flow_api.g_varchar2_table(277) := '222C686F72697A6F6E74616C3A2263742D686F72697A6F6E74616C222C73746172743A2263742D7374617274222C656E643A2263742D656E64227D7D3B742E4C696E653D742E426173652E657874656E64287B636F6E7374727563746F723A66756E6374';
wwv_flow_api.g_varchar2_table(278) := '696F6E28652C6E2C722C61297B742E4C696E652E73757065722E636F6E7374727563746F722E63616C6C28746869732C652C6E2C692C742E657874656E64287B7D2C692C72292C61297D2C63726561746543686172743A66756E6374696F6E2865297B76';
wwv_flow_api.g_varchar2_table(279) := '6172206E3D742E6E6F726D616C697A654461746128746869732E646174612C652E72657665727365446174612C2130293B746869732E7376673D742E63726561746553766728746869732E636F6E7461696E65722C652E77696474682C652E6865696768';
wwv_flow_api.g_varchar2_table(280) := '742C652E636C6173734E616D65732E6368617274293B76617220722C612C733D746869732E7376672E656C656D28226722292E616464436C61737328652E636C6173734E616D65732E6772696447726F7570292C6F3D746869732E7376672E656C656D28';
wwv_flow_api.g_varchar2_table(281) := '226722292C6C3D746869732E7376672E656C656D28226722292E616464436C61737328652E636C6173734E616D65732E6C6162656C47726F7570292C633D742E63726561746543686172745265637428746869732E7376672C652C692E70616464696E67';
wwv_flow_api.g_varchar2_table(282) := '293B723D766F696420303D3D3D652E61786973582E747970653F6E657720742E537465704178697328742E417869732E756E6974732E782C6E2E6E6F726D616C697A65642E7365726965732C632C742E657874656E64287B7D2C652E61786973582C7B74';
wwv_flow_api.g_varchar2_table(283) := '69636B733A6E2E6E6F726D616C697A65642E6C6162656C732C737472657463683A652E66756C6C57696474687D29293A652E61786973582E747970652E63616C6C28742C742E417869732E756E6974732E782C6E2E6E6F726D616C697A65642E73657269';
wwv_flow_api.g_varchar2_table(284) := '65732C632C652E6178697358292C613D766F696420303D3D3D652E61786973592E747970653F6E657720742E4175746F5363616C654178697328742E417869732E756E6974732E792C6E2E6E6F726D616C697A65642E7365726965732C632C742E657874';
wwv_flow_api.g_varchar2_table(285) := '656E64287B7D2C652E61786973592C7B686967683A742E69734E756D6572696328652E68696768293F652E686967683A652E61786973592E686967682C6C6F773A742E69734E756D6572696328652E6C6F77293F652E6C6F773A652E61786973592E6C6F';
wwv_flow_api.g_varchar2_table(286) := '777D29293A652E61786973592E747970652E63616C6C28742C742E417869732E756E6974732E792C6E2E6E6F726D616C697A65642E7365726965732C632C652E6178697359292C722E63726561746547726964416E644C6162656C7328732C6C2C746869';
wwv_flow_api.g_varchar2_table(287) := '732E737570706F727473466F726569676E4F626A6563742C652C746869732E6576656E74456D6974746572292C612E63726561746547726964416E644C6162656C7328732C6C2C746869732E737570706F727473466F726569676E4F626A6563742C652C';
wwv_flow_api.g_varchar2_table(288) := '746869732E6576656E74456D6974746572292C652E73686F77477269644261636B67726F756E642626742E637265617465477269644261636B67726F756E6428732C632C652E636C6173734E616D65732E677269644261636B67726F756E642C74686973';
wwv_flow_api.g_varchar2_table(289) := '2E6576656E74456D6974746572292C6E2E7261772E7365726965732E666F72456163682866756E6374696F6E28692C73297B766172206C3D6F2E656C656D28226722293B6C2E61747472287B2263743A7365726965732D6E616D65223A692E6E616D652C';
wwv_flow_api.g_varchar2_table(290) := '2263743A6D657461223A742E73657269616C697A6528692E6D657461297D292C6C2E616464436C617373285B652E636C6173734E616D65732E7365726965732C692E636C6173734E616D657C7C652E636C6173734E616D65732E7365726965732B222D22';
wwv_flow_api.g_varchar2_table(291) := '2B742E616C7068614E756D65726174652873295D2E6A6F696E2822202229293B76617220753D5B5D2C643D5B5D3B6E2E6E6F726D616C697A65642E7365726965735B735D2E666F72456163682866756E6374696F6E28652C6F297B766172206C3D7B783A';
wwv_flow_api.g_varchar2_table(292) := '632E78312B722E70726F6A65637456616C756528652C6F2C6E2E6E6F726D616C697A65642E7365726965735B735D292C793A632E79312D612E70726F6A65637456616C756528652C6F2C6E2E6E6F726D616C697A65642E7365726965735B735D297D3B75';
wwv_flow_api.g_varchar2_table(293) := '2E70757368286C2E782C6C2E79292C642E70757368287B76616C75653A652C76616C7565496E6465783A6F2C6D6574613A742E6765744D6574614461746128692C6F297D297D2E62696E64287468697329293B76617220683D7B6C696E65536D6F6F7468';
wwv_flow_api.g_varchar2_table(294) := '3A742E6765745365726965734F7074696F6E28692C652C226C696E65536D6F6F746822292C73686F77506F696E743A742E6765745365726965734F7074696F6E28692C652C2273686F77506F696E7422292C73686F774C696E653A742E67657453657269';
wwv_flow_api.g_varchar2_table(295) := '65734F7074696F6E28692C652C2273686F774C696E6522292C73686F77417265613A742E6765745365726965734F7074696F6E28692C652C2273686F774172656122292C61726561426173653A742E6765745365726965734F7074696F6E28692C652C22';
wwv_flow_api.g_varchar2_table(296) := '617265614261736522297D2C703D282266756E6374696F6E223D3D747970656F6620682E6C696E65536D6F6F74683F682E6C696E65536D6F6F74683A682E6C696E65536D6F6F74683F742E496E746572706F6C6174696F6E2E6D6F6E6F746F6E65437562';
wwv_flow_api.g_varchar2_table(297) := '696328293A742E496E746572706F6C6174696F6E2E6E6F6E6528292928752C64293B696628682E73686F77506F696E742626702E70617468456C656D656E74732E666F72456163682866756E6374696F6E286E297B766172206F3D6C2E656C656D28226C';
wwv_flow_api.g_varchar2_table(298) := '696E65222C7B78313A6E2E782C79313A6E2E792C78323A6E2E782B2E30312C79323A6E2E797D2C652E636C6173734E616D65732E706F696E74292E61747472287B2263743A76616C7565223A5B6E2E646174612E76616C75652E782C6E2E646174612E76';
wwv_flow_api.g_varchar2_table(299) := '616C75652E795D2E66696C74657228742E69734E756D65726963292E6A6F696E28222C22292C2263743A6D657461223A742E73657269616C697A65286E2E646174612E6D657461297D293B746869732E6576656E74456D69747465722E656D6974282264';
wwv_flow_api.g_varchar2_table(300) := '726177222C7B747970653A22706F696E74222C76616C75653A6E2E646174612E76616C75652C696E6465783A6E2E646174612E76616C7565496E6465782C6D6574613A6E2E646174612E6D6574612C7365726965733A692C736572696573496E6465783A';
wwv_flow_api.g_varchar2_table(301) := '732C61786973583A722C61786973593A612C67726F75703A6C2C656C656D656E743A6F2C783A6E2E782C793A6E2E797D297D2E62696E64287468697329292C682E73686F774C696E65297B76617220663D6C2E656C656D282270617468222C7B643A702E';
wwv_flow_api.g_varchar2_table(302) := '737472696E6769667928297D2C652E636C6173734E616D65732E6C696E652C2130293B746869732E6576656E74456D69747465722E656D6974282264726177222C7B747970653A226C696E65222C76616C7565733A6E2E6E6F726D616C697A65642E7365';
wwv_flow_api.g_varchar2_table(303) := '726965735B735D2C706174683A702E636C6F6E6528292C6368617274526563743A632C696E6465783A732C7365726965733A692C736572696573496E6465783A732C7365726965734D6574613A692E6D6574612C61786973583A722C61786973593A612C';
wwv_flow_api.g_varchar2_table(304) := '67726F75703A6C2C656C656D656E743A667D297D696628682E73686F77417265612626612E72616E6765297B766172206D3D4D6174682E6D6178284D6174682E6D696E28682E61726561426173652C612E72616E67652E6D6178292C612E72616E67652E';
wwv_flow_api.g_varchar2_table(305) := '6D696E292C673D632E79312D612E70726F6A65637456616C7565286D293B702E73706C69744279436F6D6D616E6428224D22292E66696C7465722866756E6374696F6E2865297B72657475726E20652E70617468456C656D656E74732E6C656E6774683E';
wwv_flow_api.g_varchar2_table(306) := '317D292E6D61702866756E6374696F6E2865297B76617220743D652E70617468456C656D656E74735B305D2C693D652E70617468456C656D656E74735B652E70617468456C656D656E74732E6C656E6774682D315D3B72657475726E20652E636C6F6E65';
wwv_flow_api.g_varchar2_table(307) := '282130292E706F736974696F6E2830292E72656D6F76652831292E6D6F766528742E782C67292E6C696E6528742E782C742E79292E706F736974696F6E28652E70617468456C656D656E74732E6C656E6774682B31292E6C696E6528692E782C67297D29';
wwv_flow_api.g_varchar2_table(308) := '2E666F72456163682866756E6374696F6E2874297B766172206F3D6C2E656C656D282270617468222C7B643A742E737472696E6769667928297D2C652E636C6173734E616D65732E617265612C2130293B746869732E6576656E74456D69747465722E65';
wwv_flow_api.g_varchar2_table(309) := '6D6974282264726177222C7B747970653A2261726561222C76616C7565733A6E2E6E6F726D616C697A65642E7365726965735B735D2C706174683A742E636C6F6E6528292C7365726965733A692C736572696573496E6465783A732C61786973583A722C';
wwv_flow_api.g_varchar2_table(310) := '61786973593A612C6368617274526563743A632C696E6465783A732C67726F75703A6C2C656C656D656E743A6F7D297D2E62696E64287468697329297D7D2E62696E64287468697329292C746869732E6576656E74456D69747465722E656D6974282263';
wwv_flow_api.g_varchar2_table(311) := '726561746564222C7B626F756E64733A612E626F756E64732C6368617274526563743A632C61786973583A722C61786973593A612C7376673A746869732E7376672C6F7074696F6E733A657D297D7D297D28746869737C7C676C6F62616C2C65292C6675';
wwv_flow_api.g_varchar2_table(312) := '6E6374696F6E28652C74297B2275736520737472696374223B652E77696E646F772C652E646F63756D656E743B76617220693D7B61786973583A7B6F66667365743A33302C706F736974696F6E3A22656E64222C6C6162656C4F66667365743A7B783A30';
wwv_flow_api.g_varchar2_table(313) := '2C793A307D2C73686F774C6162656C3A21302C73686F77477269643A21302C6C6162656C496E746572706F6C6174696F6E466E633A742E6E6F6F702C7363616C654D696E53706163653A33302C6F6E6C79496E74656765723A21317D2C61786973593A7B';
wwv_flow_api.g_varchar2_table(314) := '6F66667365743A34302C706F736974696F6E3A227374617274222C6C6162656C4F66667365743A7B783A302C793A307D2C73686F774C6162656C3A21302C73686F77477269643A21302C6C6162656C496E746572706F6C6174696F6E466E633A742E6E6F';
wwv_flow_api.g_varchar2_table(315) := '6F702C7363616C654D696E53706163653A32302C6F6E6C79496E74656765723A21317D2C77696474683A766F696420302C6865696768743A766F696420302C686967683A766F696420302C6C6F773A766F696420302C7265666572656E636556616C7565';
wwv_flow_api.g_varchar2_table(316) := '3A302C636861727450616464696E673A7B746F703A31352C72696768743A31352C626F74746F6D3A352C6C6566743A31307D2C73657269657342617244697374616E63653A31352C737461636B426172733A21312C737461636B4D6F64653A2261636375';
wwv_flow_api.g_varchar2_table(317) := '6D756C617465222C686F72697A6F6E74616C426172733A21312C646973747269627574655365726965733A21312C72657665727365446174613A21312C73686F77477269644261636B67726F756E643A21312C636C6173734E616D65733A7B6368617274';
wwv_flow_api.g_varchar2_table(318) := '3A2263742D63686172742D626172222C686F72697A6F6E74616C426172733A2263742D686F72697A6F6E74616C2D62617273222C6C6162656C3A2263742D6C6162656C222C6C6162656C47726F75703A2263742D6C6162656C73222C7365726965733A22';
wwv_flow_api.g_varchar2_table(319) := '63742D736572696573222C6261723A2263742D626172222C677269643A2263742D67726964222C6772696447726F75703A2263742D6772696473222C677269644261636B67726F756E643A2263742D677269642D6261636B67726F756E64222C76657274';
wwv_flow_api.g_varchar2_table(320) := '6963616C3A2263742D766572746963616C222C686F72697A6F6E74616C3A2263742D686F72697A6F6E74616C222C73746172743A2263742D7374617274222C656E643A2263742D656E64227D7D3B742E4261723D742E426173652E657874656E64287B63';
wwv_flow_api.g_varchar2_table(321) := '6F6E7374727563746F723A66756E6374696F6E28652C6E2C722C61297B742E4261722E73757065722E636F6E7374727563746F722E63616C6C28746869732C652C6E2C692C742E657874656E64287B7D2C692C72292C61297D2C63726561746543686172';
wwv_flow_api.g_varchar2_table(322) := '743A66756E6374696F6E2865297B766172206E2C723B652E646973747269627574655365726965733F286E3D742E6E6F726D616C697A654461746128746869732E646174612C652E72657665727365446174612C652E686F72697A6F6E74616C42617273';
wwv_flow_api.g_varchar2_table(323) := '3F2278223A22792229292E6E6F726D616C697A65642E7365726965733D6E2E6E6F726D616C697A65642E7365726965732E6D61702866756E6374696F6E2865297B72657475726E5B655D7D293A6E3D742E6E6F726D616C697A654461746128746869732E';
wwv_flow_api.g_varchar2_table(324) := '646174612C652E72657665727365446174612C652E686F72697A6F6E74616C426172733F2278223A227922292C746869732E7376673D742E63726561746553766728746869732E636F6E7461696E65722C652E77696474682C652E6865696768742C652E';
wwv_flow_api.g_varchar2_table(325) := '636C6173734E616D65732E63686172742B28652E686F72697A6F6E74616C426172733F2220222B652E636C6173734E616D65732E686F72697A6F6E74616C426172733A222229293B76617220613D746869732E7376672E656C656D28226722292E616464';
wwv_flow_api.g_varchar2_table(326) := '436C61737328652E636C6173734E616D65732E6772696447726F7570292C733D746869732E7376672E656C656D28226722292C6F3D746869732E7376672E656C656D28226722292E616464436C61737328652E636C6173734E616D65732E6C6162656C47';
wwv_flow_api.g_varchar2_table(327) := '726F7570293B696628652E737461636B42617273262630213D3D6E2E6E6F726D616C697A65642E7365726965732E6C656E677468297B766172206C3D742E73657269616C4D6170286E2E6E6F726D616C697A65642E7365726965732C66756E6374696F6E';
wwv_flow_api.g_varchar2_table(328) := '28297B72657475726E2041727261792E70726F746F747970652E736C6963652E63616C6C28617267756D656E7473292E6D61702866756E6374696F6E2865297B72657475726E20657D292E7265647563652866756E6374696F6E28652C74297B72657475';
wwv_flow_api.g_varchar2_table(329) := '726E7B783A652E782B28742626742E78297C7C302C793A652E792B28742626742E79297C7C307D7D2C7B783A302C793A307D297D293B723D742E676574486967684C6F77285B6C5D2C652C652E686F72697A6F6E74616C426172733F2278223A22792229';
wwv_flow_api.g_varchar2_table(330) := '7D656C736520723D742E676574486967684C6F77286E2E6E6F726D616C697A65642E7365726965732C652C652E686F72697A6F6E74616C426172733F2278223A227922293B722E686967683D2B652E686967687C7C28303D3D3D652E686967683F303A72';
wwv_flow_api.g_varchar2_table(331) := '2E68696768292C722E6C6F773D2B652E6C6F777C7C28303D3D3D652E6C6F773F303A722E6C6F77293B76617220632C752C642C682C702C663D742E63726561746543686172745265637428746869732E7376672C652C692E70616464696E67293B753D65';
wwv_flow_api.g_varchar2_table(332) := '2E646973747269627574655365726965732626652E737461636B426172733F6E2E6E6F726D616C697A65642E6C6162656C732E736C69636528302C31293A6E2E6E6F726D616C697A65642E6C6162656C732C652E686F72697A6F6E74616C426172733F28';
wwv_flow_api.g_varchar2_table(333) := '633D683D766F696420303D3D3D652E61786973582E747970653F6E657720742E4175746F5363616C654178697328742E417869732E756E6974732E782C6E2E6E6F726D616C697A65642E7365726965732C662C742E657874656E64287B7D2C652E617869';
wwv_flow_api.g_varchar2_table(334) := '73582C7B686967684C6F773A722C7265666572656E636556616C75653A307D29293A652E61786973582E747970652E63616C6C28742C742E417869732E756E6974732E782C6E2E6E6F726D616C697A65642E7365726965732C662C742E657874656E6428';
wwv_flow_api.g_varchar2_table(335) := '7B7D2C652E61786973582C7B686967684C6F773A722C7265666572656E636556616C75653A307D29292C643D703D766F696420303D3D3D652E61786973592E747970653F6E657720742E537465704178697328742E417869732E756E6974732E792C6E2E';
wwv_flow_api.g_varchar2_table(336) := '6E6F726D616C697A65642E7365726965732C662C7B7469636B733A757D293A652E61786973592E747970652E63616C6C28742C742E417869732E756E6974732E792C6E2E6E6F726D616C697A65642E7365726965732C662C652E617869735929293A2864';
wwv_flow_api.g_varchar2_table(337) := '3D683D766F696420303D3D3D652E61786973582E747970653F6E657720742E537465704178697328742E417869732E756E6974732E782C6E2E6E6F726D616C697A65642E7365726965732C662C7B7469636B733A757D293A652E61786973582E74797065';
wwv_flow_api.g_varchar2_table(338) := '2E63616C6C28742C742E417869732E756E6974732E782C6E2E6E6F726D616C697A65642E7365726965732C662C652E6178697358292C633D703D766F696420303D3D3D652E61786973592E747970653F6E657720742E4175746F5363616C654178697328';
wwv_flow_api.g_varchar2_table(339) := '742E417869732E756E6974732E792C6E2E6E6F726D616C697A65642E7365726965732C662C742E657874656E64287B7D2C652E61786973592C7B686967684C6F773A722C7265666572656E636556616C75653A307D29293A652E61786973592E74797065';
wwv_flow_api.g_varchar2_table(340) := '2E63616C6C28742C742E417869732E756E6974732E792C6E2E6E6F726D616C697A65642E7365726965732C662C742E657874656E64287B7D2C652E61786973592C7B686967684C6F773A722C7265666572656E636556616C75653A307D2929293B766172';
wwv_flow_api.g_varchar2_table(341) := '206D3D652E686F72697A6F6E74616C426172733F662E78312B632E70726F6A65637456616C75652830293A662E79312D632E70726F6A65637456616C75652830292C673D5B5D3B642E63726561746547726964416E644C6162656C7328612C6F2C746869';
wwv_flow_api.g_varchar2_table(342) := '732E737570706F727473466F726569676E4F626A6563742C652C746869732E6576656E74456D6974746572292C632E63726561746547726964416E644C6162656C7328612C6F2C746869732E737570706F727473466F726569676E4F626A6563742C652C';
wwv_flow_api.g_varchar2_table(343) := '746869732E6576656E74456D6974746572292C652E73686F77477269644261636B67726F756E642626742E637265617465477269644261636B67726F756E6428612C662C652E636C6173734E616D65732E677269644261636B67726F756E642C74686973';
wwv_flow_api.g_varchar2_table(344) := '2E6576656E74456D6974746572292C6E2E7261772E7365726965732E666F72456163682866756E6374696F6E28692C72297B76617220612C6F2C6C3D722D286E2E7261772E7365726965732E6C656E6774682D31292F323B613D652E6469737472696275';
wwv_flow_api.g_varchar2_table(345) := '7465536572696573262621652E737461636B426172733F642E617869734C656E6774682F6E2E6E6F726D616C697A65642E7365726965732E6C656E6774682F323A652E646973747269627574655365726965732626652E737461636B426172733F642E61';
wwv_flow_api.g_varchar2_table(346) := '7869734C656E6774682F323A642E617869734C656E6774682F6E2E6E6F726D616C697A65642E7365726965735B725D2E6C656E6774682F322C286F3D732E656C656D2822672229292E61747472287B2263743A7365726965732D6E616D65223A692E6E61';
wwv_flow_api.g_varchar2_table(347) := '6D652C2263743A6D657461223A742E73657269616C697A6528692E6D657461297D292C6F2E616464436C617373285B652E636C6173734E616D65732E7365726965732C692E636C6173734E616D657C7C652E636C6173734E616D65732E7365726965732B';
wwv_flow_api.g_varchar2_table(348) := '222D222B742E616C7068614E756D65726174652872295D2E6A6F696E2822202229292C6E2E6E6F726D616C697A65642E7365726965735B725D2E666F72456163682866756E6374696F6E28732C75297B76617220762C792C782C623B696628623D652E64';
wwv_flow_api.g_varchar2_table(349) := '697374726962757465536572696573262621652E737461636B426172733F723A652E646973747269627574655365726965732626652E737461636B426172733F303A752C763D652E686F72697A6F6E74616C426172733F7B783A662E78312B632E70726F';
wwv_flow_api.g_varchar2_table(350) := '6A65637456616C756528732626732E783F732E783A302C752C6E2E6E6F726D616C697A65642E7365726965735B725D292C793A662E79312D642E70726F6A65637456616C756528732626732E793F732E793A302C622C6E2E6E6F726D616C697A65642E73';
wwv_flow_api.g_varchar2_table(351) := '65726965735B725D297D3A7B783A662E78312B642E70726F6A65637456616C756528732626732E783F732E783A302C622C6E2E6E6F726D616C697A65642E7365726965735B725D292C793A662E79312D632E70726F6A65637456616C756528732626732E';
wwv_flow_api.g_varchar2_table(352) := '793F732E793A302C752C6E2E6E6F726D616C697A65642E7365726965735B725D297D2C6420696E7374616E63656F6620742E5374657041786973262628642E6F7074696F6E732E737472657463687C7C28765B642E756E6974732E706F735D2B3D612A28';
wwv_flow_api.g_varchar2_table(353) := '652E686F72697A6F6E74616C426172733F2D313A3129292C765B642E756E6974732E706F735D2B3D652E737461636B426172737C7C652E646973747269627574655365726965733F303A6C2A652E73657269657342617244697374616E63652A28652E68';
wwv_flow_api.g_varchar2_table(354) := '6F72697A6F6E74616C426172733F2D313A3129292C783D675B755D7C7C6D2C675B755D3D782D286D2D765B642E636F756E746572556E6974732E706F735D292C766F69642030213D3D73297B76617220413D7B7D3B415B642E756E6974732E706F732B22';
wwv_flow_api.g_varchar2_table(355) := '31225D3D765B642E756E6974732E706F735D2C415B642E756E6974732E706F732B2232225D3D765B642E756E6974732E706F735D2C21652E737461636B426172737C7C22616363756D756C61746522213D3D652E737461636B4D6F64652626652E737461';
wwv_flow_api.g_varchar2_table(356) := '636B4D6F64653F28415B642E636F756E746572556E6974732E706F732B2231225D3D6D2C415B642E636F756E746572556E6974732E706F732B2232225D3D765B642E636F756E746572556E6974732E706F735D293A28415B642E636F756E746572556E69';
wwv_flow_api.g_varchar2_table(357) := '74732E706F732B2231225D3D782C415B642E636F756E746572556E6974732E706F732B2232225D3D675B755D292C412E78313D4D6174682E6D696E284D6174682E6D617828412E78312C662E7831292C662E7832292C412E78323D4D6174682E6D696E28';
wwv_flow_api.g_varchar2_table(358) := '4D6174682E6D617828412E78322C662E7831292C662E7832292C412E79313D4D6174682E6D696E284D6174682E6D617828412E79312C662E7932292C662E7931292C412E79323D4D6174682E6D696E284D6174682E6D617828412E79322C662E7932292C';
wwv_flow_api.g_varchar2_table(359) := '662E7931293B76617220773D742E6765744D6574614461746128692C75293B793D6F2E656C656D28226C696E65222C412C652E636C6173734E616D65732E626172292E61747472287B2263743A76616C7565223A5B732E782C732E795D2E66696C746572';
wwv_flow_api.g_varchar2_table(360) := '28742E69734E756D65726963292E6A6F696E28222C22292C2263743A6D657461223A742E73657269616C697A652877297D292C746869732E6576656E74456D69747465722E656D6974282264726177222C742E657874656E64287B747970653A22626172';
wwv_flow_api.g_varchar2_table(361) := '222C76616C75653A732C696E6465783A752C6D6574613A772C7365726965733A692C736572696573496E6465783A722C61786973583A682C61786973593A702C6368617274526563743A662C67726F75703A6F2C656C656D656E743A797D2C4129297D7D';
wwv_flow_api.g_varchar2_table(362) := '2E62696E64287468697329297D2E62696E64287468697329292C746869732E6576656E74456D69747465722E656D6974282263726561746564222C7B626F756E64733A632E626F756E64732C6368617274526563743A662C61786973583A682C61786973';
wwv_flow_api.g_varchar2_table(363) := '593A702C7376673A746869732E7376672C6F7074696F6E733A657D297D7D297D28746869737C7C676C6F62616C2C65292C66756E6374696F6E28652C74297B2275736520737472696374223B66756E6374696F6E206928652C742C69297B766172206E3D';
wwv_flow_api.g_varchar2_table(364) := '742E783E652E783B72657475726E206E2626226578706C6F6465223D3D3D697C7C216E262622696D706C6F6465223D3D3D693F227374617274223A6E262622696D706C6F6465223D3D3D697C7C216E2626226578706C6F6465223D3D3D693F22656E6422';
wwv_flow_api.g_varchar2_table(365) := '3A226D6964646C65227D652E77696E646F772C652E646F63756D656E743B766172206E3D7B77696474683A766F696420302C6865696768743A766F696420302C636861727450616464696E673A352C636C6173734E616D65733A7B63686172745069653A';
wwv_flow_api.g_varchar2_table(366) := '2263742D63686172742D706965222C6368617274446F6E75743A2263742D63686172742D646F6E7574222C7365726965733A2263742D736572696573222C736C6963655069653A2263742D736C6963652D706965222C736C696365446F6E75743A226374';
wwv_flow_api.g_varchar2_table(367) := '2D736C6963652D646F6E7574222C736C696365446F6E7574536F6C69643A2263742D736C6963652D646F6E75742D736F6C6964222C6C6162656C3A2263742D6C6162656C227D2C7374617274416E676C653A302C746F74616C3A766F696420302C646F6E';
wwv_flow_api.g_varchar2_table(368) := '75743A21312C646F6E7574536F6C69643A21312C646F6E757457696474683A36302C73686F774C6162656C3A21302C6C6162656C4F66667365743A302C6C6162656C506F736974696F6E3A22696E73696465222C6C6162656C496E746572706F6C617469';
wwv_flow_api.g_varchar2_table(369) := '6F6E466E633A742E6E6F6F702C6C6162656C446972656374696F6E3A226E65757472616C222C72657665727365446174613A21312C69676E6F7265456D70747956616C7565733A21317D3B742E5069653D742E426173652E657874656E64287B636F6E73';
wwv_flow_api.g_varchar2_table(370) := '74727563746F723A66756E6374696F6E28652C692C722C61297B742E5069652E73757065722E636F6E7374727563746F722E63616C6C28746869732C652C692C6E2C742E657874656E64287B7D2C6E2C72292C61297D2C63726561746543686172743A66';
wwv_flow_api.g_varchar2_table(371) := '756E6374696F6E2865297B76617220722C612C732C6F2C6C2C633D742E6E6F726D616C697A654461746128746869732E64617461292C753D5B5D2C643D652E7374617274416E676C653B746869732E7376673D742E63726561746553766728746869732E';
wwv_flow_api.g_varchar2_table(372) := '636F6E7461696E65722C652E77696474682C652E6865696768742C652E646F6E75743F652E636C6173734E616D65732E6368617274446F6E75743A652E636C6173734E616D65732E6368617274506965292C613D742E6372656174654368617274526563';
wwv_flow_api.g_varchar2_table(373) := '7428746869732E7376672C652C6E2E70616464696E67292C733D4D6174682E6D696E28612E776964746828292F322C612E68656967687428292F32292C6C3D652E746F74616C7C7C632E6E6F726D616C697A65642E7365726965732E7265647563652866';
wwv_flow_api.g_varchar2_table(374) := '756E6374696F6E28652C74297B72657475726E20652B747D2C30293B76617220683D742E7175616E7469747928652E646F6E75745769647468293B2225223D3D3D682E756E6974262628682E76616C75652A3D732F313030292C732D3D652E646F6E7574';
wwv_flow_api.g_varchar2_table(375) := '262621652E646F6E7574536F6C69643F682E76616C75652F323A302C6F3D226F757473696465223D3D3D652E6C6162656C506F736974696F6E7C7C652E646F6E7574262621652E646F6E7574536F6C69643F733A2263656E746572223D3D3D652E6C6162';
wwv_flow_api.g_varchar2_table(376) := '656C506F736974696F6E3F303A652E646F6E7574536F6C69643F732D682E76616C75652F323A732F322C6F2B3D652E6C6162656C4F66667365743B76617220703D7B783A612E78312B612E776964746828292F322C793A612E79322B612E686569676874';
wwv_flow_api.g_varchar2_table(377) := '28292F327D2C663D313D3D3D632E7261772E7365726965732E66696C7465722866756E6374696F6E2865297B72657475726E20652E6861734F776E50726F7065727479282276616C756522293F30213D3D652E76616C75653A30213D3D657D292E6C656E';
wwv_flow_api.g_varchar2_table(378) := '6774683B632E7261772E7365726965732E666F72456163682866756E6374696F6E28652C74297B755B745D3D746869732E7376672E656C656D282267222C6E756C6C2C6E756C6C297D2E62696E64287468697329292C652E73686F774C6162656C262628';
wwv_flow_api.g_varchar2_table(379) := '723D746869732E7376672E656C656D282267222C6E756C6C2C6E756C6C29292C632E7261772E7365726965732E666F72456163682866756E6374696F6E286E2C61297B69662830213D3D632E6E6F726D616C697A65642E7365726965735B615D7C7C2165';
wwv_flow_api.g_varchar2_table(380) := '2E69676E6F7265456D70747956616C756573297B755B615D2E61747472287B2263743A7365726965732D6E616D65223A6E2E6E616D657D292C755B615D2E616464436C617373285B652E636C6173734E616D65732E7365726965732C6E2E636C6173734E';
wwv_flow_api.g_varchar2_table(381) := '616D657C7C652E636C6173734E616D65732E7365726965732B222D222B742E616C7068614E756D65726174652861295D2E6A6F696E2822202229293B766172206D3D6C3E303F642B632E6E6F726D616C697A65642E7365726965735B615D2F6C2A333630';
wwv_flow_api.g_varchar2_table(382) := '3A302C673D4D6174682E6D617828302C642D28303D3D3D617C7C663F303A2E3229293B6D2D673E3D3335392E39392626286D3D672B3335392E3939293B76617220762C792C782C623D742E706F6C6172546F43617274657369616E28702E782C702E792C';
wwv_flow_api.g_varchar2_table(383) := '732C67292C413D742E706F6C6172546F43617274657369616E28702E782C702E792C732C6D292C773D6E657720742E5376672E506174682821652E646F6E75747C7C652E646F6E7574536F6C6964292E6D6F766528412E782C412E79292E61726328732C';
wwv_flow_api.g_varchar2_table(384) := '732C302C6D2D643E3138302C302C622E782C622E79293B652E646F6E75743F652E646F6E7574536F6C6964262628783D732D682E76616C75652C763D742E706F6C6172546F43617274657369616E28702E782C702E792C782C642D28303D3D3D617C7C66';
wwv_flow_api.g_varchar2_table(385) := '3F303A2E3229292C793D742E706F6C6172546F43617274657369616E28702E782C702E792C782C6D292C772E6C696E6528762E782C762E79292C772E61726328782C782C302C6D2D643E3138302C312C792E782C792E7929293A772E6C696E6528702E78';
wwv_flow_api.g_varchar2_table(386) := '2C702E79293B76617220433D652E636C6173734E616D65732E736C6963655069653B652E646F6E7574262628433D652E636C6173734E616D65732E736C696365446F6E75742C652E646F6E7574536F6C6964262628433D652E636C6173734E616D65732E';
wwv_flow_api.g_varchar2_table(387) := '736C696365446F6E7574536F6C696429293B76617220453D755B615D2E656C656D282270617468222C7B643A772E737472696E6769667928297D2C43293B696628452E61747472287B2263743A76616C7565223A632E6E6F726D616C697A65642E736572';
wwv_flow_api.g_varchar2_table(388) := '6965735B615D2C2263743A6D657461223A742E73657269616C697A65286E2E6D657461297D292C652E646F6E7574262621652E646F6E7574536F6C6964262628452E5F6E6F64652E7374796C652E7374726F6B6557696474683D682E76616C75652B2270';
wwv_flow_api.g_varchar2_table(389) := '7822292C746869732E6576656E74456D69747465722E656D6974282264726177222C7B747970653A22736C696365222C76616C75653A632E6E6F726D616C697A65642E7365726965735B615D2C746F74616C4461746153756D3A6C2C696E6465783A612C';
wwv_flow_api.g_varchar2_table(390) := '6D6574613A6E2E6D6574612C7365726965733A6E2C67726F75703A755B615D2C656C656D656E743A452C706174683A772E636C6F6E6528292C63656E7465723A702C7261646975733A732C7374617274416E676C653A642C656E64416E676C653A6D7D29';
wwv_flow_api.g_varchar2_table(391) := '2C652E73686F774C6162656C297B766172204E3B4E3D313D3D3D632E7261772E7365726965732E6C656E6774683F7B783A702E782C793A702E797D3A742E706F6C6172546F43617274657369616E28702E782C702E792C6F2C642B286D2D64292F32293B';
wwv_flow_api.g_varchar2_table(392) := '76617220533B533D632E6E6F726D616C697A65642E6C6162656C73262621742E697346616C7365794275745A65726F28632E6E6F726D616C697A65642E6C6162656C735B615D293F632E6E6F726D616C697A65642E6C6162656C735B615D3A632E6E6F72';
wwv_flow_api.g_varchar2_table(393) := '6D616C697A65642E7365726965735B615D3B766172205F3D652E6C6162656C496E746572706F6C6174696F6E466E6328532C61293B6966285F7C7C303D3D3D5F297B76617220443D722E656C656D282274657874222C7B64783A4E2E782C64793A4E2E79';
wwv_flow_api.g_varchar2_table(394) := '2C22746578742D616E63686F72223A6928702C4E2C652E6C6162656C446972656374696F6E297D2C652E636C6173734E616D65732E6C6162656C292E746578742822222B5F293B746869732E6576656E74456D69747465722E656D697428226472617722';
wwv_flow_api.g_varchar2_table(395) := '2C7B747970653A226C6162656C222C696E6465783A612C67726F75703A722C656C656D656E743A442C746578743A22222B5F2C783A4E2E782C793A4E2E797D297D7D643D6D7D7D2E62696E64287468697329292C746869732E6576656E74456D69747465';
wwv_flow_api.g_varchar2_table(396) := '722E656D6974282263726561746564222C7B6368617274526563743A612C7376673A746869732E7376672C6F7074696F6E733A657D297D2C64657465726D696E65416E63686F72506F736974696F6E3A697D297D28746869737C7C676C6F62616C2C6529';
wwv_flow_api.g_varchar2_table(397) := '2C657D292C66756E6374696F6E28652C74297B226F626A656374223D3D747970656F66206578706F727473262622756E646566696E656422213D747970656F66206D6F64756C653F6D6F64756C652E6578706F7274733D7428293A2266756E6374696F6E';
wwv_flow_api.g_varchar2_table(398) := '223D3D747970656F6620646566696E652626646566696E652E616D643F646566696E652874293A28653D657C7C73656C662C652E444F4D5075726966793D742829297D28746869732C66756E6374696F6E28297B2275736520737472696374223B66756E';
wwv_flow_api.g_varchar2_table(399) := '6374696F6E20652865297B72657475726E2066756E6374696F6E2874297B666F722876617220693D617267756D656E74732E6C656E6774682C6E3D417272617928693E313F692D313A30292C723D313B723C693B722B2B296E5B722D315D3D617267756D';
wwv_flow_api.g_varchar2_table(400) := '656E74735B725D3B72657475726E206D28652C742C6E297D7D66756E6374696F6E207428652C74297B6F26266F28652C6E756C6C293B666F722876617220693D742E6C656E6774683B692D2D3B297B766172206E3D745B695D3B69662822737472696E67';
wwv_flow_api.g_varchar2_table(401) := '223D3D747970656F66206E297B76617220723D62286E293B72213D3D6E2626286C2874297C7C28745B695D3D72292C6E3D72297D655B6E5D3D21307D72657475726E20657D66756E6374696F6E20692865297B76617220743D70286E756C6C292C693D76';
wwv_flow_api.g_varchar2_table(402) := '6F696420303B666F72286920696E2065296D28732C652C5B695D29262628745B695D3D655B695D293B72657475726E20747D66756E6374696F6E206E28742C69297B666F72283B6E756C6C213D3D743B297B766172206E3D7528742C69293B6966286E29';
wwv_flow_api.g_varchar2_table(403) := '7B6966286E2E6765742972657475726E2065286E2E676574293B6966282266756E6374696F6E223D3D747970656F66206E2E76616C75652972657475726E2065286E2E76616C7565297D743D632874297D72657475726E2066756E6374696F6E2865297B';
wwv_flow_api.g_varchar2_table(404) := '72657475726E20636F6E736F6C652E7761726E282266616C6C6261636B2076616C756520666F72222C65292C6E756C6C7D7D66756E6374696F6E20722865297B69662841727261792E69734172726179286529297B666F722876617220743D302C693D41';
wwv_flow_api.g_varchar2_table(405) := '7272617928652E6C656E677468293B743C652E6C656E6774683B742B2B29695B745D3D655B745D3B72657475726E20697D72657475726E2041727261792E66726F6D2865297D66756E6374696F6E206128297B76617220653D617267756D656E74732E6C';
wwv_flow_api.g_varchar2_table(406) := '656E6774683E302626766F69642030213D3D617267756D656E74735B305D3F617267756D656E74735B305D3A5828292C733D66756E6374696F6E2865297B72657475726E20612865297D3B696628732E76657273696F6E3D22322E332E34222C732E7265';
wwv_flow_api.g_varchar2_table(407) := '6D6F7665643D5B5D2C21657C7C21652E646F63756D656E747C7C39213D3D652E646F63756D656E742E6E6F6465547970652972657475726E20732E6973537570706F727465643D21312C733B766172206F3D652E646F63756D656E742C6C3D652E646F63';
wwv_flow_api.g_varchar2_table(408) := '756D656E742C633D652E446F63756D656E74467261676D656E742C753D652E48544D4C54656D706C617465456C656D656E742C683D652E4E6F64652C703D652E456C656D656E742C663D652E4E6F646546696C7465722C6D3D652E4E616D65644E6F6465';
wwv_flow_api.g_varchar2_table(409) := '4D61702C673D766F696420303D3D3D6D3F652E4E616D65644E6F64654D61707C7C652E4D6F7A4E616D6564417474724D61703A6D2C573D652E48544D4C466F726D456C656D656E742C713D652E444F4D5061727365722C4A3D652E747275737465645479';
wwv_flow_api.g_varchar2_table(410) := '7065732C513D702E70726F746F747970652C5A3D6E28512C22636C6F6E654E6F646522292C4B3D6E28512C226E6578745369626C696E6722292C65653D6E28512C226368696C644E6F64657322292C74653D6E28512C22706172656E744E6F646522293B';
wwv_flow_api.g_varchar2_table(411) := '6966282266756E6374696F6E223D3D747970656F662075297B7661722069653D6C2E637265617465456C656D656E74282274656D706C61746522293B69652E636F6E74656E74262669652E636F6E74656E742E6F776E6572446F63756D656E742626286C';
wwv_flow_api.g_varchar2_table(412) := '3D69652E636F6E74656E742E6F776E6572446F63756D656E74297D766172206E653D59284A2C6F292C72653D6E65262649653F6E652E63726561746548544D4C282222293A22222C61653D6C2C73653D61652E696D706C656D656E746174696F6E2C6F65';
wwv_flow_api.g_varchar2_table(413) := '3D61652E6372656174654E6F64654974657261746F722C6C653D61652E637265617465446F63756D656E74467261676D656E742C63653D61652E676574456C656D656E747342795461674E616D652C75653D6F2E696D706F72744E6F64652C64653D7B7D';
wwv_flow_api.g_varchar2_table(414) := '3B7472797B64653D69286C292E646F63756D656E744D6F64653F6C2E646F63756D656E744D6F64653A7B7D7D63617463682865297B7D7661722068653D7B7D3B732E6973537570706F727465643D2266756E6374696F6E223D3D747970656F6620746526';
wwv_flow_api.g_varchar2_table(415) := '2673652626766F69642030213D3D73652E63726561746548544D4C446F63756D656E74262639213D3D64653B7661722070653D482C66653D6A2C6D653D422C67653D462C76653D242C79653D472C78653D552C62653D6E756C6C2C41653D74287B7D2C5B';
wwv_flow_api.g_varchar2_table(416) := '5D2E636F6E6361742872285F292C722844292C72284F292C722852292C72284D2929292C77653D6E756C6C2C43653D74287B7D2C5B5D2E636F6E6361742872286B292C72287A292C722849292C7228502929292C45653D4F626A6563742E7365616C284F';
wwv_flow_api.g_varchar2_table(417) := '626A6563742E637265617465286E756C6C2C7B7461674E616D65436865636B3A7B7772697461626C653A21302C636F6E666967757261626C653A21312C656E756D657261626C653A21302C76616C75653A6E756C6C7D2C6174747269627574654E616D65';
wwv_flow_api.g_varchar2_table(418) := '436865636B3A7B7772697461626C653A21302C636F6E666967757261626C653A21312C656E756D657261626C653A21302C76616C75653A6E756C6C7D2C616C6C6F77437573746F6D697A65644275696C74496E456C656D656E74733A7B7772697461626C';
wwv_flow_api.g_varchar2_table(419) := '653A21302C636F6E666967757261626C653A21312C656E756D657261626C653A21302C76616C75653A21317D7D29292C4E653D6E756C6C2C53653D6E756C6C2C5F653D21302C44653D21302C4F653D21312C54653D21312C52653D21312C4C653D21312C';
wwv_flow_api.g_varchar2_table(420) := '4D653D21312C6B653D21312C7A653D21312C49653D21312C50653D21302C48653D21302C6A653D21312C42653D7B7D2C46653D6E756C6C2C55653D74287B7D2C5B22616E6E6F746174696F6E2D786D6C222C22617564696F222C22636F6C67726F757022';
wwv_flow_api.g_varchar2_table(421) := '2C2264657363222C22666F726569676E6F626A656374222C2268656164222C22696672616D65222C226D617468222C226D69222C226D6E222C226D6F222C226D73222C226D74657874222C226E6F656D626564222C226E6F6672616D6573222C226E6F73';
wwv_flow_api.g_varchar2_table(422) := '6372697074222C22706C61696E74657874222C22736372697074222C227374796C65222C22737667222C2274656D706C617465222C227468656164222C227469746C65222C22766964656F222C22786D70225D292C24653D6E756C6C2C47653D74287B7D';
wwv_flow_api.g_varchar2_table(423) := '2C5B22617564696F222C22766964656F222C22696D67222C22736F75726365222C22696D616765222C22747261636B225D292C56653D6E756C6C2C58653D74287B7D2C5B22616C74222C22636C617373222C22666F72222C226964222C226C6162656C22';
wwv_flow_api.g_varchar2_table(424) := '2C226E616D65222C227061747465726E222C22706C616365686F6C646572222C22726F6C65222C2273756D6D617279222C227469746C65222C2276616C7565222C227374796C65222C22786D6C6E73225D292C59653D22687474703A2F2F7777772E7733';
wwv_flow_api.g_varchar2_table(425) := '2E6F72672F313939382F4D6174682F4D6174684D4C222C57653D22687474703A2F2F7777772E77332E6F72672F323030302F737667222C71653D22687474703A2F2F7777772E77332E6F72672F313939392F7868746D6C222C4A653D71652C51653D2131';
wwv_flow_api.g_varchar2_table(426) := '2C5A653D766F696420302C4B653D5B226170706C69636174696F6E2F7868746D6C2B786D6C222C22746578742F68746D6C225D2C65743D766F696420302C74743D6E756C6C2C69743D6C2E637265617465456C656D656E742822666F726D22292C6E743D';
wwv_flow_api.g_varchar2_table(427) := '66756E6374696F6E2865297B72657475726E206520696E7374616E63656F66205265674578707C7C6520696E7374616E63656F662046756E6374696F6E7D2C72743D66756E6374696F6E2865297B7474262674743D3D3D657C7C28652626226F626A6563';
wwv_flow_api.g_varchar2_table(428) := '74223D3D3D28766F696420303D3D3D653F22756E646566696E6564223A56286529297C7C28653D7B7D292C653D692865292C62653D22414C4C4F5745445F5441475322696E20653F74287B7D2C652E414C4C4F5745445F54414753293A41652C77653D22';
wwv_flow_api.g_varchar2_table(429) := '414C4C4F5745445F4154545222696E20653F74287B7D2C652E414C4C4F5745445F41545452293A43652C56653D224144445F5552495F534146455F4154545222696E20653F742869285865292C652E4144445F5552495F534146455F41545452293A5865';
wwv_flow_api.g_varchar2_table(430) := '2C24653D224144445F444154415F5552495F5441475322696E20653F742869284765292C652E4144445F444154415F5552495F54414753293A47652C46653D22464F524249445F434F4E54454E545322696E20653F74287B7D2C652E464F524249445F43';
wwv_flow_api.g_varchar2_table(431) := '4F4E54454E5453293A55652C4E653D22464F524249445F5441475322696E20653F74287B7D2C652E464F524249445F54414753293A7B7D2C53653D22464F524249445F4154545222696E20653F74287B7D2C652E464F524249445F41545452293A7B7D2C';
wwv_flow_api.g_varchar2_table(432) := '42653D225553455F50524F46494C455322696E20652626652E5553455F50524F46494C45532C5F653D2131213D3D652E414C4C4F575F415249415F415454522C44653D2131213D3D652E414C4C4F575F444154415F415454522C4F653D652E414C4C4F57';
wwv_flow_api.g_varchar2_table(433) := '5F554E4B4E4F574E5F50524F544F434F4C537C7C21312C54653D652E534146455F464F525F54454D504C415445537C7C21312C52653D652E57484F4C455F444F43554D454E547C7C21312C6B653D652E52455455524E5F444F4D7C7C21312C7A653D652E';
wwv_flow_api.g_varchar2_table(434) := '52455455524E5F444F4D5F465241474D454E547C7C21312C49653D652E52455455524E5F545255535445445F545950457C7C21312C4D653D652E464F5243455F424F44597C7C21312C50653D2131213D3D652E53414E4954495A455F444F4D2C48653D21';
wwv_flow_api.g_varchar2_table(435) := '31213D3D652E4B4545505F434F4E54454E542C6A653D652E494E5F504C4143457C7C21312C78653D652E414C4C4F5745445F5552495F5245474558507C7C78652C4A653D652E4E414D4553504143457C7C71652C652E435553544F4D5F454C454D454E54';
wwv_flow_api.g_varchar2_table(436) := '5F48414E444C494E4726266E7428652E435553544F4D5F454C454D454E545F48414E444C494E472E7461674E616D65436865636B2926262845652E7461674E616D65436865636B3D652E435553544F4D5F454C454D454E545F48414E444C494E472E7461';
wwv_flow_api.g_varchar2_table(437) := '674E616D65436865636B292C652E435553544F4D5F454C454D454E545F48414E444C494E4726266E7428652E435553544F4D5F454C454D454E545F48414E444C494E472E6174747269627574654E616D65436865636B2926262845652E61747472696275';
wwv_flow_api.g_varchar2_table(438) := '74654E616D65436865636B3D652E435553544F4D5F454C454D454E545F48414E444C494E472E6174747269627574654E616D65436865636B292C652E435553544F4D5F454C454D454E545F48414E444C494E47262622626F6F6C65616E223D3D74797065';
wwv_flow_api.g_varchar2_table(439) := '6F6620652E435553544F4D5F454C454D454E545F48414E444C494E472E616C6C6F77437573746F6D697A65644275696C74496E456C656D656E747326262845652E616C6C6F77437573746F6D697A65644275696C74496E456C656D656E74733D652E4355';
wwv_flow_api.g_varchar2_table(440) := '53544F4D5F454C454D454E545F48414E444C494E472E616C6C6F77437573746F6D697A65644275696C74496E456C656D656E7473292C5A653D5A653D2D313D3D3D4B652E696E6465784F6628652E5041525345525F4D454449415F54595045293F227465';
wwv_flow_api.g_varchar2_table(441) := '78742F68746D6C223A652E5041525345525F4D454449415F545950452C65743D226170706C69636174696F6E2F7868746D6C2B786D6C223D3D3D5A653F66756E6374696F6E2865297B72657475726E20657D3A622C546526262844653D2131292C7A6526';
wwv_flow_api.g_varchar2_table(442) := '26286B653D2130292C426526262862653D74287B7D2C5B5D2E636F6E6361742872284D2929292C77653D5B5D2C21303D3D3D42652E68746D6C262628742862652C5F292C742877652C6B29292C21303D3D3D42652E737667262628742862652C44292C74';
wwv_flow_api.g_varchar2_table(443) := '2877652C7A292C742877652C5029292C21303D3D3D42652E73766746696C74657273262628742862652C4F292C742877652C7A292C742877652C5029292C21303D3D3D42652E6D6174684D6C262628742862652C52292C742877652C49292C742877652C';
wwv_flow_api.g_varchar2_table(444) := '502929292C652E4144445F5441475326262862653D3D3D416526262862653D6928626529292C742862652C652E4144445F5441475329292C652E4144445F4154545226262877653D3D3D436526262877653D6928776529292C742877652C652E4144445F';
wwv_flow_api.g_varchar2_table(445) := '4154545229292C652E4144445F5552495F534146455F415454522626742856652C652E4144445F5552495F534146455F41545452292C652E464F524249445F434F4E54454E545326262846653D3D3D556526262846653D6928466529292C742846652C65';
wwv_flow_api.g_varchar2_table(446) := '2E464F524249445F434F4E54454E545329292C486526262862655B222374657874225D3D2130292C52652626742862652C5B2268746D6C222C2268656164222C22626F6479225D292C62652E7461626C65262628742862652C5B2274626F6479225D292C';
wwv_flow_api.g_varchar2_table(447) := '64656C657465204E652E74626F6479292C642626642865292C74743D65297D2C61743D74287B7D2C5B226D69222C226D6F222C226D6E222C226D73222C226D74657874225D292C73743D74287B7D2C5B22666F726569676E6F626A656374222C22646573';
wwv_flow_api.g_varchar2_table(448) := '63222C227469746C65222C22616E6E6F746174696F6E2D786D6C225D292C6F743D74287B7D2C44293B74286F742C4F292C74286F742C54293B766172206C743D74287B7D2C52293B74286C742C4C293B7661722063743D66756E6374696F6E2865297B78';
wwv_flow_api.g_varchar2_table(449) := '28732E72656D6F7665642C7B656C656D656E743A657D293B7472797B652E706172656E744E6F64652E72656D6F76654368696C642865297D63617463682874297B7472797B652E6F7574657248544D4C3D72657D63617463682874297B652E72656D6F76';
wwv_flow_api.g_varchar2_table(450) := '6528297D7D7D2C75743D66756E6374696F6E28652C74297B7472797B7828732E72656D6F7665642C7B6174747269627574653A742E6765744174747269627574654E6F64652865292C66726F6D3A747D297D63617463682865297B7828732E72656D6F76';
wwv_flow_api.g_varchar2_table(451) := '65642C7B6174747269627574653A6E756C6C2C66726F6D3A747D297D696628742E72656D6F76654174747269627574652865292C226973223D3D3D6526262177655B655D296966286B657C7C7A65297472797B63742874297D63617463682865297B7D65';
wwv_flow_api.g_varchar2_table(452) := '6C7365207472797B742E73657441747472696275746528652C2222297D63617463682865297B7D7D2C64743D66756E6374696F6E2865297B76617220743D766F696420302C693D766F696420303B6966284D6529653D223C72656D6F76653E3C2F72656D';
wwv_flow_api.g_varchar2_table(453) := '6F76653E222B653B656C73657B766172206E3D4128652C2F5E5B5C725C6E5C74205D2B2F293B693D6E26266E5B305D7D226170706C69636174696F6E2F7868746D6C2B786D6C223D3D3D5A65262628653D273C68746D6C20786D6C6E733D22687474703A';
wwv_flow_api.g_varchar2_table(454) := '2F2F7777772E77332E6F72672F313939392F7868746D6C223E3C686561643E3C2F686561643E3C626F64793E272B652B223C2F626F64793E3C2F68746D6C3E22293B76617220723D6E653F6E652E63726561746548544D4C2865293A653B6966284A653D';
wwv_flow_api.g_varchar2_table(455) := '3D3D7165297472797B743D286E65772071292E706172736546726F6D537472696E6728722C5A65297D63617463682865297B7D69662821747C7C21742E646F63756D656E74456C656D656E74297B743D73652E637265617465446F63756D656E74284A65';
wwv_flow_api.g_varchar2_table(456) := '2C2274656D706C617465222C6E756C6C293B7472797B742E646F63756D656E74456C656D656E742E696E6E657248544D4C3D51653F22223A727D63617463682865297B7D7D76617220613D742E626F64797C7C742E646F63756D656E74456C656D656E74';
wwv_flow_api.g_varchar2_table(457) := '3B72657475726E20652626692626612E696E736572744265666F7265286C2E637265617465546578744E6F64652869292C612E6368696C644E6F6465735B305D7C7C6E756C6C292C4A653D3D3D71653F63652E63616C6C28742C52653F2268746D6C223A';
wwv_flow_api.g_varchar2_table(458) := '22626F647922295B305D3A52653F742E646F63756D656E74456C656D656E743A617D2C68743D66756E6374696F6E2865297B72657475726E206F652E63616C6C28652E6F776E6572446F63756D656E747C7C652C652C662E53484F575F454C454D454E54';
wwv_flow_api.g_varchar2_table(459) := '7C662E53484F575F434F4D4D454E547C662E53484F575F544558542C6E756C6C2C2131297D2C70743D66756E6374696F6E2865297B72657475726E226F626A656374223D3D3D28766F696420303D3D3D683F22756E646566696E6564223A56286829293F';
wwv_flow_api.g_varchar2_table(460) := '6520696E7374616E63656F6620683A652626226F626A656374223D3D3D28766F696420303D3D3D653F22756E646566696E6564223A56286529292626226E756D626572223D3D747970656F6620652E6E6F646554797065262622737472696E67223D3D74';
wwv_flow_api.g_varchar2_table(461) := '7970656F6620652E6E6F64654E616D657D2C66743D66756E6374696F6E28652C742C69297B68655B655D2626762868655B655D2C66756E6374696F6E2865297B652E63616C6C28732C742C692C7474297D297D2C6D743D66756E6374696F6E2865297B76';
wwv_flow_api.g_varchar2_table(462) := '617220693D766F696420303B696628667428226265666F726553616E6974697A65456C656D656E7473222C652C6E756C6C292C66756E6374696F6E2865297B72657475726E206520696E7374616E63656F66205726262822737472696E6722213D747970';
wwv_flow_api.g_varchar2_table(463) := '656F6620652E6E6F64654E616D657C7C22737472696E6722213D747970656F6620652E74657874436F6E74656E747C7C2266756E6374696F6E22213D747970656F6620652E72656D6F76654368696C647C7C2128652E6174747269627574657320696E73';
wwv_flow_api.g_varchar2_table(464) := '74616E63656F662067297C7C2266756E6374696F6E22213D747970656F6620652E72656D6F76654174747269627574657C7C2266756E6374696F6E22213D747970656F6620652E7365744174747269627574657C7C22737472696E6722213D747970656F';
wwv_flow_api.g_varchar2_table(465) := '6620652E6E616D6573706163655552497C7C2266756E6374696F6E22213D747970656F6620652E696E736572744265666F7265297D2865292972657475726E2063742865292C21303B6966284128652E6E6F64654E616D652C2F5B5C75303038302D5C75';
wwv_flow_api.g_varchar2_table(466) := '464646465D2F292972657475726E2063742865292C21303B766172206E3D657428652E6E6F64654E616D65293B6966286674282275706F6E53616E6974697A65456C656D656E74222C652C7B7461674E616D653A6E2C616C6C6F776564546167733A6265';
wwv_flow_api.g_varchar2_table(467) := '7D292C21707428652E6669727374456C656D656E744368696C642926262821707428652E636F6E74656E74297C7C21707428652E636F6E74656E742E6669727374456C656D656E744368696C64292926264E282F3C5B2F5C775D2F672C652E696E6E6572';
wwv_flow_api.g_varchar2_table(468) := '48544D4C2926264E282F3C5B2F5C775D2F672C652E74657874436F6E74656E74292972657475726E2063742865292C21303B6966282273656C656374223D3D3D6E26264E282F3C74656D706C6174652F692C652E696E6E657248544D4C29297265747572';
wwv_flow_api.g_varchar2_table(469) := '6E2063742865292C21303B6966282162655B6E5D7C7C4E655B6E5D297B696628486526262146655B6E5D297B76617220723D74652865297C7C652E706172656E744E6F64652C613D65652865297C7C652E6368696C644E6F6465733B6966286126267229';
wwv_flow_api.g_varchar2_table(470) := '666F7228766172206F3D612E6C656E6774682D313B6F3E3D303B2D2D6F29722E696E736572744265666F7265285A28615B6F5D2C2130292C4B286529297D696628214E655B6E5D26267674286E29297B69662845652E7461674E616D65436865636B2069';
wwv_flow_api.g_varchar2_table(471) := '6E7374616E63656F662052656745787026264E2845652E7461674E616D65436865636B2C6E292972657475726E21313B69662845652E7461674E616D65436865636B20696E7374616E63656F662046756E6374696F6E262645652E7461674E616D654368';
wwv_flow_api.g_varchar2_table(472) := '65636B286E292972657475726E21317D72657475726E2063742865292C21307D72657475726E206520696E7374616E63656F66207026262166756E6374696F6E2865297B76617220693D74652865293B692626692E7461674E616D657C7C28693D7B6E61';
wwv_flow_api.g_varchar2_table(473) := '6D6573706163655552493A71652C7461674E616D653A2274656D706C617465227D293B766172206E3D6228652E7461674E616D65292C723D6228692E7461674E616D65293B696628652E6E616D6573706163655552493D3D3D57652972657475726E2069';
wwv_flow_api.g_varchar2_table(474) := '2E6E616D6573706163655552493D3D3D71653F22737667223D3D3D6E3A692E6E616D6573706163655552493D3D3D59653F22737667223D3D3D6E26262822616E6E6F746174696F6E2D786D6C223D3D3D727C7C61745B725D293A426F6F6C65616E286F74';
wwv_flow_api.g_varchar2_table(475) := '5B6E5D293B696628652E6E616D6573706163655552493D3D3D59652972657475726E20692E6E616D6573706163655552493D3D3D71653F226D617468223D3D3D6E3A692E6E616D6573706163655552493D3D3D57653F226D617468223D3D3D6E26267374';
wwv_flow_api.g_varchar2_table(476) := '5B725D3A426F6F6C65616E286C745B6E5D293B696628652E6E616D6573706163655552493D3D3D7165297B696628692E6E616D6573706163655552493D3D3D576526262173745B725D2972657475726E21313B696628692E6E616D657370616365555249';
wwv_flow_api.g_varchar2_table(477) := '3D3D3D596526262161745B725D2972657475726E21313B76617220613D74287B7D2C5B227469746C65222C227374796C65222C22666F6E74222C2261222C22736372697074225D293B72657475726E216C745B6E5D262628615B6E5D7C7C216F745B6E5D';
wwv_flow_api.g_varchar2_table(478) := '297D72657475726E21317D2865293F2863742865292C2130293A226E6F73637269707422213D3D6E2626226E6F656D62656422213D3D6E7C7C214E282F3C5C2F6E6F287363726970747C656D626564292F692C652E696E6E657248544D4C293F28546526';
wwv_flow_api.g_varchar2_table(479) := '26333D3D3D652E6E6F646554797065262628693D652E74657874436F6E74656E742C693D7728692C70652C222022292C693D7728692C66652C222022292C652E74657874436F6E74656E74213D3D692626287828732E72656D6F7665642C7B656C656D65';
wwv_flow_api.g_varchar2_table(480) := '6E743A652E636C6F6E654E6F646528297D292C652E74657874436F6E74656E743D6929292C66742822616674657253616E6974697A65456C656D656E7473222C652C6E756C6C292C2131293A2863742865292C2130297D2C67743D66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(481) := '652C742C69297B6966285065262628226964223D3D3D747C7C226E616D65223D3D3D74292626286920696E206C7C7C6920696E206974292972657475726E21313B696628446526262153655B745D26264E286D652C7429293B656C7365206966285F6526';
wwv_flow_api.g_varchar2_table(482) := '264E2867652C7429293B656C7365206966282177655B745D7C7C53655B745D297B6966282128767428652926262845652E7461674E616D65436865636B20696E7374616E63656F662052656745787026264E2845652E7461674E616D65436865636B2C65';
wwv_flow_api.g_varchar2_table(483) := '297C7C45652E7461674E616D65436865636B20696E7374616E63656F662046756E6374696F6E262645652E7461674E616D65436865636B2865292926262845652E6174747269627574654E616D65436865636B20696E7374616E63656F66205265674578';
wwv_flow_api.g_varchar2_table(484) := '7026264E2845652E6174747269627574654E616D65436865636B2C74297C7C45652E6174747269627574654E616D65436865636B20696E7374616E63656F662046756E6374696F6E262645652E6174747269627574654E616D65436865636B287429297C';
wwv_flow_api.g_varchar2_table(485) := '7C226973223D3D3D74262645652E616C6C6F77437573746F6D697A65644275696C74496E456C656D656E747326262845652E7461674E616D65436865636B20696E7374616E63656F662052656745787026264E2845652E7461674E616D65436865636B2C';
wwv_flow_api.g_varchar2_table(486) := '69297C7C45652E7461674E616D65436865636B20696E7374616E63656F662046756E6374696F6E262645652E7461674E616D65436865636B28692929292972657475726E21317D656C73652069662856655B745D293B656C7365206966284E2878652C77';
wwv_flow_api.g_varchar2_table(487) := '28692C79652C22222929293B656C7365206966282273726322213D3D74262622786C696E6B3A6872656622213D3D742626226872656622213D3D747C7C22736372697074223D3D3D657C7C30213D3D4328692C22646174613A22297C7C2124655B655D29';
wwv_flow_api.g_varchar2_table(488) := '7B6966284F652626214E2876652C7728692C79652C22222929293B656C736520696628692972657475726E21317D656C73653B72657475726E21307D2C76743D66756E6374696F6E2865297B72657475726E20652E696E6465784F6628222D22293E307D';
wwv_flow_api.g_varchar2_table(489) := '2C79743D66756E6374696F6E2865297B76617220743D766F696420302C693D766F696420302C6E3D766F696420302C723D766F696420303B667428226265666F726553616E6974697A6541747472696275746573222C652C6E756C6C293B76617220613D';
wwv_flow_api.g_varchar2_table(490) := '652E617474726962757465733B69662861297B766172206F3D7B617474724E616D653A22222C6174747256616C75653A22222C6B656570417474723A21302C616C6C6F776564417474726962757465733A77657D3B666F7228723D612E6C656E6774683B';
wwv_flow_api.g_varchar2_table(491) := '722D2D3B297B766172206C3D743D615B725D2C633D6C2E6E616D652C753D6C2E6E616D6573706163655552493B696628693D4528742E76616C7565292C6E3D65742863292C6F2E617474724E616D653D6E2C6F2E6174747256616C75653D692C6F2E6B65';
wwv_flow_api.g_varchar2_table(492) := '6570417474723D21302C6F2E666F7263654B656570417474723D766F696420302C6674282275706F6E53616E6974697A65417474726962757465222C652C6F292C693D6F2E6174747256616C75652C216F2E666F7263654B656570417474722626287574';
wwv_flow_api.g_varchar2_table(493) := '28632C65292C6F2E6B6565704174747229296966284E282F5C2F3E2F692C692929757428632C65293B656C73657B5465262628693D7728692C70652C222022292C693D7728692C66652C22202229293B76617220643D657428652E6E6F64654E616D6529';
wwv_flow_api.g_varchar2_table(494) := '3B696628677428642C6E2C6929297472797B753F652E7365744174747269627574654E5328752C632C69293A652E73657441747472696275746528632C69292C7928732E72656D6F766564297D63617463682865297B7D7D7D6674282261667465725361';
wwv_flow_api.g_varchar2_table(495) := '6E6974697A6541747472696275746573222C652C6E756C6C297D7D2C78743D66756E6374696F6E20652874297B76617220693D766F696420302C6E3D68742874293B666F7228667428226265666F726553616E6974697A65536861646F77444F4D222C74';
wwv_flow_api.g_varchar2_table(496) := '2C6E756C6C293B693D6E2E6E6578744E6F646528293B296674282275706F6E53616E6974697A65536861646F774E6F6465222C692C6E756C6C292C6D742869297C7C28692E636F6E74656E7420696E7374616E63656F66206326266528692E636F6E7465';
wwv_flow_api.g_varchar2_table(497) := '6E74292C7974286929293B66742822616674657253616E6974697A65536861646F77444F4D222C742C6E756C6C297D3B72657475726E20732E73616E6974697A653D66756E6374696F6E28742C69297B766172206E3D766F696420302C723D766F696420';
wwv_flow_api.g_varchar2_table(498) := '302C613D766F696420302C6C3D766F696420302C753D766F696420303B6966282851653D217429262628743D225C783363212D2D5C78336522292C22737472696E6722213D747970656F6620742626217074287429297B6966282266756E6374696F6E22';
wwv_flow_api.g_varchar2_table(499) := '213D747970656F6620742E746F537472696E67297468726F7720532822746F537472696E67206973206E6F7420612066756E6374696F6E22293B69662822737472696E6722213D747970656F6628743D742E746F537472696E67282929297468726F7720';
wwv_flow_api.g_varchar2_table(500) := '5328226469727479206973206E6F74206120737472696E672C2061626F7274696E6722297D69662821732E6973537570706F72746564297B696628226F626A656374223D3D3D5628652E746F53746174696348544D4C297C7C2266756E6374696F6E223D';
wwv_flow_api.g_varchar2_table(501) := '3D747970656F6620652E746F53746174696348544D4C297B69662822737472696E67223D3D747970656F6620742972657475726E20652E746F53746174696348544D4C2874293B69662870742874292972657475726E20652E746F53746174696348544D';
wwv_flow_api.g_varchar2_table(502) := '4C28742E6F7574657248544D4C297D72657475726E20747D6966284C657C7C72742869292C732E72656D6F7665643D5B5D2C22737472696E67223D3D747970656F6620742626286A653D2131292C6A65293B656C7365206966287420696E7374616E6365';
wwv_flow_api.g_varchar2_table(503) := '6F66206829313D3D3D28723D286E3D647428225C783363212D2D2D2D5C7833652229292E6F776E6572446F63756D656E742E696D706F72744E6F646528742C213029292E6E6F646554797065262622424F4459223D3D3D722E6E6F64654E616D653F6E3D';
wwv_flow_api.g_varchar2_table(504) := '723A2248544D4C223D3D3D722E6E6F64654E616D653F6E3D723A6E2E617070656E644368696C642872293B656C73657B696628216B652626215465262621526526262D313D3D3D742E696E6465784F6628223C22292972657475726E206E65262649653F';
wwv_flow_api.g_varchar2_table(505) := '6E652E63726561746548544D4C2874293A743B69662821286E3D6474287429292972657475726E206B653F6E756C6C3A72657D6E26264D6526266374286E2E66697273744368696C64293B666F722876617220643D6874286A653F743A6E293B613D642E';
wwv_flow_api.g_varchar2_table(506) := '6E6578744E6F646528293B29333D3D3D612E6E6F6465547970652626613D3D3D6C7C7C6D742861297C7C28612E636F6E74656E7420696E7374616E63656F6620632626787428612E636F6E74656E74292C79742861292C6C3D61293B6966286C3D6E756C';
wwv_flow_api.g_varchar2_table(507) := '6C2C6A652972657475726E20743B6966286B65297B6966287A6529666F7228753D6C652E63616C6C286E2E6F776E6572446F63756D656E74293B6E2E66697273744368696C643B29752E617070656E644368696C64286E2E66697273744368696C64293B';
wwv_flow_api.g_varchar2_table(508) := '656C736520753D6E3B72657475726E2077652E736861646F77726F6F74262628753D75652E63616C6C286F2C752C213029292C757D76617220703D52653F6E2E6F7574657248544D4C3A6E2E696E6E657248544D4C3B72657475726E205465262628703D';
wwv_flow_api.g_varchar2_table(509) := '7728702C70652C222022292C703D7728702C66652C22202229292C6E65262649653F6E652E63726561746548544D4C2870293A707D2C732E736574436F6E6669673D66756E6374696F6E2865297B72742865292C4C653D21307D2C732E636C656172436F';
wwv_flow_api.g_varchar2_table(510) := '6E6669673D66756E6374696F6E28297B74743D6E756C6C2C4C653D21317D2C732E697356616C69644174747269627574653D66756E6374696F6E28652C742C69297B74747C7C7274287B7D293B766172206E3D65742865292C723D65742874293B726574';
wwv_flow_api.g_varchar2_table(511) := '75726E206774286E2C722C69297D2C732E616464486F6F6B3D66756E6374696F6E28652C74297B2266756E6374696F6E223D3D747970656F66207426262868655B655D3D68655B655D7C7C5B5D2C782868655B655D2C7429297D2C732E72656D6F766548';
wwv_flow_api.g_varchar2_table(512) := '6F6F6B3D66756E6374696F6E2865297B68655B655D2626792868655B655D297D2C732E72656D6F7665486F6F6B733D66756E6374696F6E2865297B68655B655D26262868655B655D3D5B5D297D2C732E72656D6F7665416C6C486F6F6B733D66756E6374';
wwv_flow_api.g_varchar2_table(513) := '696F6E28297B68653D7B7D7D2C737D76617220733D4F626A6563742E6861734F776E50726F70657274792C6F3D4F626A6563742E73657450726F746F747970654F662C6C3D4F626A6563742E697346726F7A656E2C633D4F626A6563742E67657450726F';
wwv_flow_api.g_varchar2_table(514) := '746F747970654F662C753D4F626A6563742E6765744F776E50726F706572747944657363726970746F722C643D4F626A6563742E667265657A652C683D4F626A6563742E7365616C2C703D4F626A6563742E6372656174652C663D22756E646566696E65';
wwv_flow_api.g_varchar2_table(515) := '6422213D747970656F66205265666C65637426265265666C6563742C6D3D662E6170706C792C673D662E636F6E7374727563743B6D7C7C286D3D66756E6374696F6E28652C742C69297B72657475726E20652E6170706C7928742C69297D292C647C7C28';
wwv_flow_api.g_varchar2_table(516) := '643D66756E6374696F6E2865297B72657475726E20657D292C687C7C28683D66756E6374696F6E2865297B72657475726E20657D292C677C7C28673D66756E6374696F6E28652C74297B72657475726E206E65772846756E6374696F6E2E70726F746F74';
wwv_flow_api.g_varchar2_table(517) := '7970652E62696E642E6170706C7928652C5B6E756C6C5D2E636F6E6361742866756E6374696F6E2865297B69662841727261792E69734172726179286529297B666F722876617220743D302C693D417272617928652E6C656E677468293B743C652E6C65';
wwv_flow_api.g_varchar2_table(518) := '6E6774683B742B2B29695B745D3D655B745D3B72657475726E20697D72657475726E2041727261792E66726F6D2865297D2874292929297D293B76617220763D652841727261792E70726F746F747970652E666F7245616368292C793D65284172726179';
wwv_flow_api.g_varchar2_table(519) := '2E70726F746F747970652E706F70292C783D652841727261792E70726F746F747970652E70757368292C623D6528537472696E672E70726F746F747970652E746F4C6F77657243617365292C413D6528537472696E672E70726F746F747970652E6D6174';
wwv_flow_api.g_varchar2_table(520) := '6368292C773D6528537472696E672E70726F746F747970652E7265706C616365292C433D6528537472696E672E70726F746F747970652E696E6465784F66292C453D6528537472696E672E70726F746F747970652E7472696D292C4E3D65285265674578';
wwv_flow_api.g_varchar2_table(521) := '702E70726F746F747970652E74657374292C533D66756E6374696F6E2865297B72657475726E2066756E6374696F6E28297B666F722876617220743D617267756D656E74732E6C656E6774682C693D41727261792874292C6E3D303B6E3C743B6E2B2B29';
wwv_flow_api.g_varchar2_table(522) := '695B6E5D3D617267756D656E74735B6E5D3B72657475726E206728652C69297D7D28547970654572726F72292C5F3D64285B2261222C2261626272222C226163726F6E796D222C2261646472657373222C2261726561222C2261727469636C65222C2261';
wwv_flow_api.g_varchar2_table(523) := '73696465222C22617564696F222C2262222C22626469222C2262646F222C22626967222C22626C696E6B222C22626C6F636B71756F7465222C22626F6479222C226272222C22627574746F6E222C2263616E766173222C2263617074696F6E222C226365';
wwv_flow_api.g_varchar2_table(524) := '6E746572222C2263697465222C22636F6465222C22636F6C222C22636F6C67726F7570222C22636F6E74656E74222C2264617461222C22646174616C697374222C226464222C226465636F7261746F72222C2264656C222C2264657461696C73222C2264';
wwv_flow_api.g_varchar2_table(525) := '666E222C226469616C6F67222C22646972222C22646976222C22646C222C226474222C22656C656D656E74222C22656D222C226669656C64736574222C2266696763617074696F6E222C22666967757265222C22666F6E74222C22666F6F746572222C22';
wwv_flow_api.g_varchar2_table(526) := '666F726D222C226831222C226832222C226833222C226834222C226835222C226836222C2268656164222C22686561646572222C226867726F7570222C226872222C2268746D6C222C2269222C22696D67222C22696E707574222C22696E73222C226B62';
wwv_flow_api.g_varchar2_table(527) := '64222C226C6162656C222C226C6567656E64222C226C69222C226D61696E222C226D6170222C226D61726B222C226D617271756565222C226D656E75222C226D656E756974656D222C226D65746572222C226E6176222C226E6F6272222C226F6C222C22';
wwv_flow_api.g_varchar2_table(528) := '6F707467726F7570222C226F7074696F6E222C226F7574707574222C2270222C2270696374757265222C22707265222C2270726F6772657373222C2271222C227270222C227274222C2272756279222C2273222C2273616D70222C2273656374696F6E22';
wwv_flow_api.g_varchar2_table(529) := '2C2273656C656374222C22736861646F77222C22736D616C6C222C22736F75726365222C22737061636572222C227370616E222C22737472696B65222C227374726F6E67222C227374796C65222C22737562222C2273756D6D617279222C22737570222C';
wwv_flow_api.g_varchar2_table(530) := '227461626C65222C2274626F6479222C227464222C2274656D706C617465222C227465787461726561222C2274666F6F74222C227468222C227468656164222C2274696D65222C227472222C22747261636B222C227474222C2275222C22756C222C2276';
wwv_flow_api.g_varchar2_table(531) := '6172222C22766964656F222C22776272225D292C443D64285B22737667222C2261222C22616C74676C797068222C22616C74676C797068646566222C22616C74676C7970686974656D222C22616E696D617465636F6C6F72222C22616E696D6174656D6F';
wwv_flow_api.g_varchar2_table(532) := '74696F6E222C22616E696D6174657472616E73666F726D222C22636972636C65222C22636C697070617468222C2264656673222C2264657363222C22656C6C69707365222C2266696C746572222C22666F6E74222C2267222C22676C797068222C22676C';
wwv_flow_api.g_varchar2_table(533) := '797068726566222C22686B65726E222C22696D616765222C226C696E65222C226C696E6561726772616469656E74222C226D61726B6572222C226D61736B222C226D65746164617461222C226D70617468222C2270617468222C227061747465726E222C';
wwv_flow_api.g_varchar2_table(534) := '22706F6C79676F6E222C22706F6C796C696E65222C2272616469616C6772616469656E74222C2272656374222C2273746F70222C227374796C65222C22737769746368222C2273796D626F6C222C2274657874222C227465787470617468222C22746974';
wwv_flow_api.g_varchar2_table(535) := '6C65222C2274726566222C22747370616E222C2276696577222C22766B65726E225D292C4F3D64285B226665426C656E64222C226665436F6C6F724D6174726978222C226665436F6D706F6E656E745472616E73666572222C226665436F6D706F736974';
wwv_flow_api.g_varchar2_table(536) := '65222C226665436F6E766F6C76654D6174726978222C226665446966667573654C69676874696E67222C226665446973706C6163656D656E744D6170222C22666544697374616E744C69676874222C226665466C6F6F64222C22666546756E6341222C22';
wwv_flow_api.g_varchar2_table(537) := '666546756E6342222C22666546756E6347222C22666546756E6352222C226665476175737369616E426C7572222C226665496D616765222C2266654D65726765222C2266654D657267654E6F6465222C2266654D6F7270686F6C6F6779222C2266654F66';
wwv_flow_api.g_varchar2_table(538) := '66736574222C226665506F696E744C69676874222C22666553706563756C61724C69676874696E67222C22666553706F744C69676874222C22666554696C65222C22666554757262756C656E6365225D292C543D64285B22616E696D617465222C22636F';
wwv_flow_api.g_varchar2_table(539) := '6C6F722D70726F66696C65222C22637572736F72222C2264697363617264222C22666564726F70736861646F77222C22666F6E742D66616365222C22666F6E742D666163652D666F726D6174222C22666F6E742D666163652D6E616D65222C22666F6E74';
wwv_flow_api.g_varchar2_table(540) := '2D666163652D737263222C22666F6E742D666163652D757269222C22666F726569676E6F626A656374222C226861746368222C22686174636870617468222C226D657368222C226D6573686772616469656E74222C226D6573687061746368222C226D65';
wwv_flow_api.g_varchar2_table(541) := '7368726F77222C226D697373696E672D676C797068222C22736372697074222C22736574222C22736F6C6964636F6C6F72222C22756E6B6E6F776E222C22757365225D292C523D64285B226D617468222C226D656E636C6F7365222C226D6572726F7222';
wwv_flow_api.g_varchar2_table(542) := '2C226D66656E636564222C226D66726163222C226D676C797068222C226D69222C226D6C6162656C65647472222C226D6D756C746973637269707473222C226D6E222C226D6F222C226D6F766572222C226D706164646564222C226D7068616E746F6D22';
wwv_flow_api.g_varchar2_table(543) := '2C226D726F6F74222C226D726F77222C226D73222C226D7370616365222C226D73717274222C226D7374796C65222C226D737562222C226D737570222C226D737562737570222C226D7461626C65222C226D7464222C226D74657874222C226D7472222C';
wwv_flow_api.g_varchar2_table(544) := '226D756E646572222C226D756E6465726F766572225D292C4C3D64285B226D616374696F6E222C226D616C69676E67726F7570222C226D616C69676E6D61726B222C226D6C6F6E67646976222C226D7363617272696573222C226D736361727279222C22';
wwv_flow_api.g_varchar2_table(545) := '6D7367726F7570222C226D737461636B222C226D736C696E65222C226D73726F77222C2273656D616E74696373222C22616E6E6F746174696F6E222C22616E6E6F746174696F6E2D786D6C222C226D70726573637269707473222C226E6F6E65225D292C';
wwv_flow_api.g_varchar2_table(546) := '4D3D64285B222374657874225D292C6B3D64285B22616363657074222C22616374696F6E222C22616C69676E222C22616C74222C226175746F6361706974616C697A65222C226175746F636F6D706C657465222C226175746F70696374757265696E7069';
wwv_flow_api.g_varchar2_table(547) := '6374757265222C226175746F706C6179222C226261636B67726F756E64222C226267636F6C6F72222C22626F72646572222C2263617074757265222C2263656C6C70616464696E67222C2263656C6C73706163696E67222C22636865636B6564222C2263';
wwv_flow_api.g_varchar2_table(548) := '697465222C22636C617373222C22636C656172222C22636F6C6F72222C22636F6C73222C22636F6C7370616E222C22636F6E74726F6C73222C22636F6E74726F6C736C697374222C22636F6F726473222C2263726F73736F726967696E222C2264617465';
wwv_flow_api.g_varchar2_table(549) := '74696D65222C226465636F64696E67222C2264656661756C74222C22646972222C2264697361626C6564222C2264697361626C6570696374757265696E70696374757265222C2264697361626C6572656D6F7465706C61796261636B222C22646F776E6C';
wwv_flow_api.g_varchar2_table(550) := '6F6164222C22647261676761626C65222C22656E6374797065222C22656E7465726B657968696E74222C2266616365222C22666F72222C2268656164657273222C22686569676874222C2268696464656E222C2268696768222C2268726566222C226872';
wwv_flow_api.g_varchar2_table(551) := '65666C616E67222C226964222C22696E7075746D6F6465222C22696E74656772697479222C2269736D6170222C226B696E64222C226C6162656C222C226C616E67222C226C697374222C226C6F6164696E67222C226C6F6F70222C226C6F77222C226D61';
wwv_flow_api.g_varchar2_table(552) := '78222C226D61786C656E677468222C226D65646961222C226D6574686F64222C226D696E222C226D696E6C656E677468222C226D756C7469706C65222C226D75746564222C226E616D65222C226E6F6E6365222C226E6F7368616465222C226E6F76616C';
wwv_flow_api.g_varchar2_table(553) := '6964617465222C226E6F77726170222C226F70656E222C226F7074696D756D222C227061747465726E222C22706C616365686F6C646572222C22706C617973696E6C696E65222C22706F73746572222C227072656C6F6164222C2270756264617465222C';
wwv_flow_api.g_varchar2_table(554) := '22726164696F67726F7570222C22726561646F6E6C79222C2272656C222C227265717569726564222C22726576222C227265766572736564222C22726F6C65222C22726F7773222C22726F777370616E222C227370656C6C636865636B222C2273636F70';
wwv_flow_api.g_varchar2_table(555) := '65222C2273656C6563746564222C227368617065222C2273697A65222C2273697A6573222C227370616E222C227372636C616E67222C227374617274222C22737263222C22737263736574222C2273746570222C227374796C65222C2273756D6D617279';
wwv_flow_api.g_varchar2_table(556) := '222C22746162696E646578222C227469746C65222C227472616E736C617465222C2274797065222C227573656D6170222C2276616C69676E222C2276616C7565222C227769647468222C22786D6C6E73222C22736C6F74225D292C7A3D64285B22616363';
wwv_flow_api.g_varchar2_table(557) := '656E742D686569676874222C22616363756D756C617465222C226164646974697665222C22616C69676E6D656E742D626173656C696E65222C22617363656E74222C226174747269627574656E616D65222C2261747472696275746574797065222C2261';
wwv_flow_api.g_varchar2_table(558) := '7A696D757468222C22626173656672657175656E6379222C22626173656C696E652D7368696674222C22626567696E222C2262696173222C226279222C22636C617373222C22636C6970222C22636C697070617468756E697473222C22636C69702D7061';
wwv_flow_api.g_varchar2_table(559) := '7468222C22636C69702D72756C65222C22636F6C6F72222C22636F6C6F722D696E746572706F6C6174696F6E222C22636F6C6F722D696E746572706F6C6174696F6E2D66696C74657273222C22636F6C6F722D70726F66696C65222C22636F6C6F722D72';
wwv_flow_api.g_varchar2_table(560) := '656E646572696E67222C226378222C226379222C2264222C226478222C226479222C2264696666757365636F6E7374616E74222C22646972656374696F6E222C22646973706C6179222C2264697669736F72222C22647572222C22656467656D6F646522';
wwv_flow_api.g_varchar2_table(561) := '2C22656C65766174696F6E222C22656E64222C2266696C6C222C2266696C6C2D6F706163697479222C2266696C6C2D72756C65222C2266696C746572222C2266696C746572756E697473222C22666C6F6F642D636F6C6F72222C22666C6F6F642D6F7061';
wwv_flow_api.g_varchar2_table(562) := '63697479222C22666F6E742D66616D696C79222C22666F6E742D73697A65222C22666F6E742D73697A652D61646A757374222C22666F6E742D73747265746368222C22666F6E742D7374796C65222C22666F6E742D76617269616E74222C22666F6E742D';
wwv_flow_api.g_varchar2_table(563) := '776569676874222C226678222C226679222C226731222C226732222C22676C7970682D6E616D65222C22676C797068726566222C226772616469656E74756E697473222C226772616469656E747472616E73666F726D222C22686569676874222C226872';
wwv_flow_api.g_varchar2_table(564) := '6566222C226964222C22696D6167652D72656E646572696E67222C22696E222C22696E32222C226B222C226B31222C226B32222C226B33222C226B34222C226B65726E696E67222C226B6579706F696E7473222C226B657973706C696E6573222C226B65';
wwv_flow_api.g_varchar2_table(565) := '7974696D6573222C226C616E67222C226C656E67746861646A757374222C226C65747465722D73706163696E67222C226B65726E656C6D6174726978222C226B65726E656C756E69746C656E677468222C226C69676874696E672D636F6C6F72222C226C';
wwv_flow_api.g_varchar2_table(566) := '6F63616C222C226D61726B65722D656E64222C226D61726B65722D6D6964222C226D61726B65722D7374617274222C226D61726B6572686569676874222C226D61726B6572756E697473222C226D61726B65727769647468222C226D61736B636F6E7465';
wwv_flow_api.g_varchar2_table(567) := '6E74756E697473222C226D61736B756E697473222C226D6178222C226D61736B222C226D65646961222C226D6574686F64222C226D6F6465222C226D696E222C226E616D65222C226E756D6F637461766573222C226F6666736574222C226F7065726174';
wwv_flow_api.g_varchar2_table(568) := '6F72222C226F706163697479222C226F72646572222C226F7269656E74222C226F7269656E746174696F6E222C226F726967696E222C226F766572666C6F77222C227061696E742D6F72646572222C2270617468222C22706174686C656E677468222C22';
wwv_flow_api.g_varchar2_table(569) := '7061747465726E636F6E74656E74756E697473222C227061747465726E7472616E73666F726D222C227061747465726E756E697473222C22706F696E7473222C227072657365727665616C706861222C227072657365727665617370656374726174696F';
wwv_flow_api.g_varchar2_table(570) := '222C227072696D6974697665756E697473222C2272222C227278222C227279222C22726164697573222C2272656678222C2272656679222C22726570656174636F756E74222C22726570656174647572222C2272657374617274222C22726573756C7422';
wwv_flow_api.g_varchar2_table(571) := '2C22726F74617465222C227363616C65222C2273656564222C2273686170652D72656E646572696E67222C2273706563756C6172636F6E7374616E74222C2273706563756C61726578706F6E656E74222C227370726561646D6574686F64222C22737461';
wwv_flow_api.g_varchar2_table(572) := '72746F6666736574222C22737464646576696174696F6E222C2273746974636874696C6573222C2273746F702D636F6C6F72222C2273746F702D6F706163697479222C227374726F6B652D646173686172726179222C227374726F6B652D646173686F66';
wwv_flow_api.g_varchar2_table(573) := '66736574222C227374726F6B652D6C696E65636170222C227374726F6B652D6C696E656A6F696E222C227374726F6B652D6D697465726C696D6974222C227374726F6B652D6F706163697479222C227374726F6B65222C227374726F6B652D7769647468';
wwv_flow_api.g_varchar2_table(574) := '222C227374796C65222C22737572666163657363616C65222C2273797374656D6C616E6775616765222C22746162696E646578222C2274617267657478222C2274617267657479222C227472616E73666F726D222C22746578742D616E63686F72222C22';
wwv_flow_api.g_varchar2_table(575) := '746578742D6465636F726174696F6E222C22746578742D72656E646572696E67222C22746578746C656E677468222C2274797065222C227531222C227532222C22756E69636F6465222C2276616C756573222C2276696577626F78222C22766973696269';
wwv_flow_api.g_varchar2_table(576) := '6C697479222C2276657273696F6E222C22766572742D6164762D79222C22766572742D6F726967696E2D78222C22766572742D6F726967696E2D79222C227769647468222C22776F72642D73706163696E67222C2277726170222C2277726974696E672D';
wwv_flow_api.g_varchar2_table(577) := '6D6F6465222C22786368616E6E656C73656C6563746F72222C22796368616E6E656C73656C6563746F72222C2278222C227831222C227832222C22786D6C6E73222C2279222C227931222C227932222C227A222C227A6F6F6D616E6470616E225D292C49';
wwv_flow_api.g_varchar2_table(578) := '3D64285B22616363656E74222C22616363656E74756E646572222C22616C69676E222C22626576656C6C6564222C22636C6F7365222C22636F6C756D6E73616C69676E222C22636F6C756D6E6C696E6573222C22636F6C756D6E7370616E222C2264656E';
wwv_flow_api.g_varchar2_table(579) := '6F6D616C69676E222C226465707468222C22646972222C22646973706C6179222C22646973706C61797374796C65222C22656E636F64696E67222C2266656E6365222C226672616D65222C22686569676874222C2268726566222C226964222C226C6172';
wwv_flow_api.g_varchar2_table(580) := '67656F70222C226C656E677468222C226C696E65746869636B6E657373222C226C7370616365222C226C71756F7465222C226D6174686261636B67726F756E64222C226D617468636F6C6F72222C226D61746873697A65222C226D61746876617269616E';
wwv_flow_api.g_varchar2_table(581) := '74222C226D617873697A65222C226D696E73697A65222C226D6F7661626C656C696D697473222C226E6F746174696F6E222C226E756D616C69676E222C226F70656E222C22726F77616C69676E222C22726F776C696E6573222C22726F7773706163696E';
wwv_flow_api.g_varchar2_table(582) := '67222C22726F777370616E222C22727370616365222C227271756F7465222C227363726970746C6576656C222C227363726970746D696E73697A65222C2273637269707473697A656D756C7469706C696572222C2273656C656374696F6E222C22736570';
wwv_flow_api.g_varchar2_table(583) := '617261746F72222C22736570617261746F7273222C227374726574636879222C227375627363726970747368696674222C227375707363726970747368696674222C2273796D6D6574726963222C22766F6666736574222C227769647468222C22786D6C';
wwv_flow_api.g_varchar2_table(584) := '6E73225D292C503D64285B22786C696E6B3A68726566222C22786D6C3A6964222C22786C696E6B3A7469746C65222C22786D6C3A7370616365222C22786D6C6E733A786C696E6B225D292C483D68282F5C7B5C7B5B5C735C535D2A7C5B5C735C535D2A5C';
wwv_flow_api.g_varchar2_table(585) := '7D5C7D2F676D292C6A3D68282F3C255B5C735C535D2A7C5B5C735C535D2A253E2F676D292C423D68282F5E646174612D5B5C2D5C772E5C75303042372D5C75464646465D2F292C463D68282F5E617269612D5B5C2D5C775D2B242F292C553D68282F5E28';
wwv_flow_api.g_varchar2_table(586) := '3F3A283F3A283F3A667C6874297470733F7C6D61696C746F7C74656C7C63616C6C746F7C6369647C786D7070293A7C5B5E612D7A5D7C5B612D7A2B2E5C2D5D2B283F3A5B5E612D7A2B2E5C2D3A5D7C2429292F69292C243D68282F5E283F3A5C772B7363';
wwv_flow_api.g_varchar2_table(587) := '726970747C64617461293A2F69292C473D68282F5B5C75303030302D5C75303032305C75303041305C75313638305C75313830455C75323030302D5C75323032395C75323035465C75333030305D2F67292C563D2266756E6374696F6E223D3D74797065';
wwv_flow_api.g_varchar2_table(588) := '6F662053796D626F6C26262273796D626F6C223D3D747970656F662053796D626F6C2E6974657261746F723F66756E6374696F6E2865297B72657475726E20747970656F6620657D3A66756E6374696F6E2865297B72657475726E206526262266756E63';
wwv_flow_api.g_varchar2_table(589) := '74696F6E223D3D747970656F662053796D626F6C2626652E636F6E7374727563746F723D3D3D53796D626F6C262665213D3D53796D626F6C2E70726F746F747970653F2273796D626F6C223A747970656F6620657D2C583D66756E6374696F6E28297B72';
wwv_flow_api.g_varchar2_table(590) := '657475726E22756E646566696E6564223D3D747970656F662077696E646F773F6E756C6C3A77696E646F777D2C593D66756E6374696F6E28652C74297B696628226F626A65637422213D3D28766F696420303D3D3D653F22756E646566696E6564223A56';
wwv_flow_api.g_varchar2_table(591) := '286529297C7C2266756E6374696F6E22213D747970656F6620652E637265617465506F6C6963792972657475726E206E756C6C3B76617220693D6E756C6C2C6E3D22646174612D74742D706F6C6963792D737566666978223B742E63757272656E745363';
wwv_flow_api.g_varchar2_table(592) := '726970742626742E63757272656E745363726970742E686173417474726962757465286E29262628693D742E63757272656E745363726970742E676574417474726962757465286E29293B76617220723D22646F6D707572696679222B28693F2223222B';
wwv_flow_api.g_varchar2_table(593) := '693A2222293B7472797B72657475726E20652E637265617465506F6C69637928722C7B63726561746548544D4C3A66756E6374696F6E2865297B72657475726E20657D7D297D63617463682865297B72657475726E20636F6E736F6C652E7761726E2822';
wwv_flow_api.g_varchar2_table(594) := '54727573746564547970657320706F6C69637920222B722B2220636F756C64206E6F7420626520637265617465642E22292C6E756C6C7D7D3B72657475726E206128297D293B766172206D6174657269616C43617264733D66756E6374696F6E28297B22';
wwv_flow_api.g_varchar2_table(595) := '75736520737472696374223B76617220653D7B66656174757265496E666F3A7B6E616D653A2241504558204D6174657269616C204361726473222C696E666F3A7B73637269707456657273696F6E3A22312E35222C7574696C56657273696F6E3A22312E';
wwv_flow_api.g_varchar2_table(596) := '332E35222C75726C3A2268747470733A2F2F6769746875622E636F6D2F526F6E6E795765697373222C6C6963656E73653A224D4954227D7D2C6973446566696E6564416E644E6F744E756C6C3A66756E6374696F6E2865297B72657475726E20766F6964';
wwv_flow_api.g_varchar2_table(597) := '2030213D3D6526266E756C6C213D3D6526262222213D657D2C6973415045583A66756E6374696F6E28297B72657475726E22756E646566696E656422213D747970656F6620617065787D2C766172547970653A66756E6374696F6E2865297B696628226F';
wwv_flow_api.g_varchar2_table(598) := '626A65637422213D747970656F6620652972657475726E20747970656F6620653B76617220743D5B5D2E636F6E7374727563746F722C693D7B7D2E636F6E7374727563746F723B72657475726E20652E636F6E7374727563746F723D3D3D743F22617272';
wwv_flow_api.g_varchar2_table(599) := '6179223A652E636F6E7374727563746F723D3D3D693F226A736F6E223A766F696420307D2C64656275673A7B696E666F3A66756E6374696F6E28297B696628652E6973415045582829297B76617220743D302C693D5B5D3B666F7228766172206E20696E';
wwv_flow_api.g_varchar2_table(600) := '20617267756D656E747329695B745D3D617267756D656E74735B6E5D2C742B2B3B692E7075736828652E66656174757265496E666F292C617065782E64656275672E696E666F2E6170706C7928746869732C69297D7D2C6572726F723A66756E6374696F';
wwv_flow_api.g_varchar2_table(601) := '6E28297B76617220743D302C693D5B5D3B666F7228766172206E20696E20617267756D656E747329695B745D3D617267756D656E74735B6E5D2C742B2B3B692E7075736828652E66656174757265496E666F292C652E69734150455828293F617065782E';
wwv_flow_api.g_varchar2_table(602) := '64656275672E6572726F722E6170706C7928746869732C69293A636F6E736F6C652E6572726F722E6170706C7928746869732C69297D7D2C65736361706548544D4C3A66756E6374696F6E2874297B6966286E756C6C3D3D3D742972657475726E206E75';
wwv_flow_api.g_varchar2_table(603) := '6C6C3B696628766F69642030213D3D74297B696628226F626A656374223D3D747970656F662074297472797B743D4A534F4E2E737472696E676966792874297D63617463682865297B7D72657475726E20652E69734150455828293F617065782E757469';
wwv_flow_api.g_varchar2_table(604) := '6C2E65736361706548544D4C28537472696E67287429293A28743D537472696E67287429292E7265706C616365282F262F672C2226616D703B22292E7265706C616365282F3C2F672C22266C743B22292E7265706C616365282F3E2F672C222667743B22';
wwv_flow_api.g_varchar2_table(605) := '292E7265706C616365282F222F672C222671756F743B22292E7265706C616365282F272F672C2226237832373B22292E7265706C616365282F5C2F2F672C2226237832463B22297D7D2C6C6F616465723A7B73746172743A66756E6374696F6E28742C69';
wwv_flow_api.g_varchar2_table(606) := '297B696628692626242874292E63737328226D696E2D686569676874222C22313030707822292C652E697341504558282929617065782E7574696C2E73686F775370696E6E65722824287429293B656C73657B766172206E3D2428223C7370616E3E3C2F';
wwv_flow_api.g_varchar2_table(607) := '7370616E3E22293B6E2E6174747228226964222C226C6F61646572222B74292C6E2E616464436C617373282263742D6C6F6164657222292C6E2E6373732822746578742D616C69676E222C2263656E74657222292C6E2E63737328227769647468222C22';
wwv_flow_api.g_varchar2_table(608) := '3130302522292C6E2E6373732822646973706C6179222C22626C6F636B22293B76617220723D2428223C693E3C2F693E22293B722E616464436C617373282266612066612D726566726573682066612D32782066612D616E696D2D7370696E22292C722E';
wwv_flow_api.g_varchar2_table(609) := '63737328226261636B67726F756E64222C2272676261283132312C3132312C3132312C302E362922292C722E6373732822626F726465722D726164697573222C223130302522292C722E637373282270616464696E67222C223135707822292C722E6373';
wwv_flow_api.g_varchar2_table(610) := '732822636F6C6F72222C22776869746522292C6E2E617070656E642872292C242874292E617070656E64286E297D7D2C73746F703A66756E6374696F6E28652C74297B742626242865292E63737328226D696E2D686569676874222C2222292C2428652B';
wwv_flow_api.g_varchar2_table(611) := '22203E202E752D50726F63657373696E6722292E72656D6F766528292C2428652B22203E202E63742D6C6F6164657222292E72656D6F766528297D7D2C6A736F6E53617665457874656E643A66756E6374696F6E28742C69297B766172206E3D7B7D2C72';
wwv_flow_api.g_varchar2_table(612) := '3D7B7D3B69662822737472696E67223D3D747970656F662069297472797B723D4A534F4E2E70617273652869297D63617463682874297B652E64656275672E6572726F72287B6D73673A224572726F72207768696C652074727920746F20706172736520';
wwv_flow_api.g_varchar2_table(613) := '746172676574436F6E6669672E20506C6561736520636865636B20796F757220436F6E666967204A534F4E2E205374616E6461726420436F6E6669672077696C6C20626520757365642E222C6572723A742C746172676574436F6E6669673A697D297D65';
wwv_flow_api.g_varchar2_table(614) := '6C736520723D242E657874656E642821302C7B7D2C69293B7472797B6E3D242E657874656E642821302C7B7D2C742C72297D63617463682869297B6E3D242E657874656E642821302C7B7D2C74292C652E64656275672E6572726F72287B6D73673A2245';
wwv_flow_api.g_varchar2_table(615) := '72726F72207768696C652074727920746F206D657267652032204A534F4E7320696E746F207374616E64617264204A534F4E20696620616E7920617474726962757465206973206D697373696E672E20506C6561736520636865636B20796F757220436F';
wwv_flow_api.g_varchar2_table(616) := '6E666967204A534F4E2E205374616E6461726420436F6E6669672077696C6C20626520757365642E222C6572723A692C66696E616C436F6E6669673A6E7D297D72657475726E206E7D2C7072696E74444F4D4D6573736167653A7B73686F773A66756E63';
wwv_flow_api.g_varchar2_table(617) := '74696F6E28652C742C692C6E297B76617220723D2428223C6469763E3C2F6469763E22292E63737328226D617267696E222C223132707822292E6373732822746578742D616C69676E222C2263656E74657222292E637373282270616464696E67222C22';
wwv_flow_api.g_varchar2_table(618) := '33357078203022292E616464436C6173732822646F6D696E666F6D65737361676564697622292C613D2428223C6469763E3C2F6469763E22292C733D2428223C7370616E3E3C2F7370616E3E22292E616464436C6173732822666122292E616464436C61';
wwv_flow_api.g_varchar2_table(619) := '737328697C7C2266612D696E666F2D636972636C652D6F22292E616464436C617373282266612D327822292E6373732822686569676874222C223332707822292E63737328227769647468222C223332707822292E6373732822636F6C6F72222C222344';
wwv_flow_api.g_varchar2_table(620) := '304430443022292E63737328226D617267696E2D626F74746F6D222C223136707822292E6373732822636F6C6F72222C6E7C7C22696E68686572697422293B612E617070656E642873293B766172206F3D2428223C7370616E3E3C2F7370616E3E22292E';
wwv_flow_api.g_varchar2_table(621) := '746578742874292E6373732822646973706C6179222C22626C6F636B22292E6373732822636F6C6F72222C222337303730373022292E6373732822746578742D6F766572666C6F77222C22656C6C697073697322292E63737328226F766572666C6F7722';
wwv_flow_api.g_varchar2_table(622) := '2C2268696464656E22292E637373282277686974652D7370616365222C226E6F7772617022292E6373732822666F6E742D73697A65222C223132707822293B722E617070656E642861292E617070656E64286F292C242865292E617070656E642872297D';
wwv_flow_api.g_varchar2_table(623) := '2C686964653A66756E6374696F6E2865297B242865292E6368696C6472656E28222E646F6D696E666F6D65737361676564697622292E72656D6F766528297D7D2C6E6F446174614D6573736167653A7B73686F773A66756E6374696F6E28742C69297B65';
wwv_flow_api.g_varchar2_table(624) := '2E7072696E74444F4D4D6573736167652E73686F7728742C692C2266612D73656172636822297D2C686964653A66756E6374696F6E2874297B652E7072696E74444F4D4D6573736167652E686964652874297D7D2C6572726F724D6573736167653A7B73';
wwv_flow_api.g_varchar2_table(625) := '686F773A66756E6374696F6E28742C69297B652E7072696E74444F4D4D6573736167652E73686F7728742C692C2266612D6578636C616D6174696F6E2D747269616E676C65222C222346464342334422297D2C686964653A66756E6374696F6E2874297B';
wwv_flow_api.g_varchar2_table(626) := '652E7072696E74444F4D4D6573736167652E686964652874297D7D7D3B72657475726E7B696E697469616C697A653A66756E6374696F6E28742C692C6E2C722C612C732C6F2C6C2C632C75297B66756E6374696F6E20642874297B72657475726E213121';
wwv_flow_api.g_varchar2_table(627) := '3D3D6C3F652E65736361706548544D4C2874293A2131213D3D633F444F4D5075726966792E73616E6974697A6528742C76293A747D66756E6374696F6E20682869297B412E656D70747928292C692E726F772626692E726F772E6C656E6774683E303F66';
wwv_flow_api.g_varchar2_table(628) := '756E6374696F6E28692C6E297B696628692626692E6C656E6774683E30297B76617220723D702841292C613D303B242E6561636828692C66756E6374696F6E28692C73297B612B3D622E6361726457696474682C732E434152445F5449544C453D642873';
wwv_flow_api.g_varchar2_table(629) := '2E434152445F5449544C45292C732E434152445F56414C55453D6428732E434152445F56414C5545292C732E434152445F464F4F5445523D6428732E434152445F464F4F544552292C732E434152445F545950453F2269636F6E223D3D3D732E43415244';
wwv_flow_api.g_varchar2_table(630) := '5F545950452E746F4C6F7765724361736528293F6728692C722C732C6E293A66756E6374696F6E28692C6E2C722C612C73297B766172206F3D7B66756C6C57696474683A21302C636861727450616464696E673A7B626F74746F6D3A2D31322C746F703A';
wwv_flow_api.g_varchar2_table(631) := '32382C72696768743A33302C6C6566743A2D357D7D2C6C3D7B7D3B69662873262622737472696E67223D3D747970656F662073297472797B6C3D4A534F4E2E70617273652873297D63617463682874297B652E64656275672E6572726F72287B6D6F6475';
wwv_flow_api.g_varchar2_table(632) := '6C653A22647261774C6172676543617264222C6D73673A224572726F72207768696C652074727920746F20706172736520434152445F43484152545F434F4E464947222C6572723A742C6368617274436F6E6669673A737D297D656C7365206C3D733B24';
wwv_flow_api.g_varchar2_table(633) := '2E657874656E642821302C6F2C6C293B76617220633D2263742D63686172742D222B742B692C753D2428223C6469763E3C2F6469763E22293B752E616464436C6173732822732D672D636F6C2D222B612E636172645769647468293B76617220643D2428';
wwv_flow_api.g_varchar2_table(634) := '223C6469763E3C2F6469763E22293B642E616464436C617373282261742D6361726422293B76617220683D2428223C6469763E3C2F6469763E22293B682E616464436C6173732822636172642D68656164657222292C682E616464436C61737328226361';
wwv_flow_api.g_varchar2_table(635) := '72642D636861727422292C652E6973446566696E6564416E644E6F744E756C6C28722E434152445F4845414445525F434C415353292626682E616464436C61737328722E434152445F4845414445525F434C415353293B652E6973446566696E6564416E';
wwv_flow_api.g_varchar2_table(636) := '644E6F744E756C6C28722E434152445F4845414445525F5354594C45293F682E6174747228227374796C65222C722E434152445F4845414445525F5354594C45293A652E6973446566696E6564416E644E6F744E756C6C28722E434152445F4845414445';
wwv_flow_api.g_varchar2_table(637) := '525F434C415353297C7C682E6174747228227374796C65222C6D286929293B76617220703D2428223C6469763E3C2F6469763E22293B702E616464436C617373282263742D636861727422292C702E6174747228226964222C63292C682E617070656E64';
wwv_flow_api.g_varchar2_table(638) := '2870292C642E617070656E642868293B76617220663D2428223C6469763E3C2F6469763E22293B662E616464436C6173732822636172642D636F6E74656E7422293B76617220673D2428223C703E3C2F703E22293B672E616464436C6173732822636174';
wwv_flow_api.g_varchar2_table(639) := '65676F727922292C652E6973446566696E6564416E644E6F744E756C6C28722E434152445F5449544C45292626672E68746D6C28722E434152445F5449544C45293B662E617070656E642867293B76617220763D2428223C68323E3C2F68323E22293B76';
wwv_flow_api.g_varchar2_table(640) := '2E616464436C61737328227469746C6522292C652E6973446566696E6564416E644E6F744E756C6C28722E434152445F56414C5545293F762E68746D6C28722E434152445F56414C5545293A762E68746D6C28222D22293B662E617070656E642876292C';
wwv_flow_api.g_varchar2_table(641) := '642E617070656E642866293B76617220793D2428223C6469763E3C2F6469763E22293B792E616464436C6173732822636172642D666F6F74657222293B76617220783D2428223C6469763E3C2F6469763E22293B722E434152445F464F4F544552262628';
wwv_flow_api.g_varchar2_table(642) := '28783D2428223C6469763E3C2F6469763E2229292E616464436C6173732822737461747322292C782E617070656E6428722E434152445F464F4F54455229293B696628792E617070656E642878292C642E617070656E642879292C752E617070656E6428';
wwv_flow_api.g_varchar2_table(643) := '64292C722E434152445F4C494E4B297B76617220623D2428223C613E3C2F613E22293B622E61747472282268726566222C722E434152445F4C494E4B292C622E617070656E642875292C6E2E617070656E642862297D656C7365206E2E617070656E6428';
wwv_flow_api.g_varchar2_table(644) := '75293B76617220413B696628722E434152445F43484152545F44415441297B76617220773D7B7D3B69662822737472696E67223D3D747970656F6620722E434152445F43484152545F44415441297472797B773D4A534F4E2E706172736528722E434152';
wwv_flow_api.g_varchar2_table(645) := '445F43484152545F44415441297D63617463682874297B652E64656275672E6572726F72287B6D6F64756C653A22647261774C6172676543617264222C6D73673A224572726F72207768696C652074727920746F20706172736520434152445F43484152';
wwv_flow_api.g_varchar2_table(646) := '545F44415441222C434152445F43484152545F444154413A722E434152445F43484152545F444154417D297D656C736520773D722E434152445F43484152545F444154413B73776974636828722E434152445F545950452E746F4C6F7765724361736528';
wwv_flow_api.g_varchar2_table(647) := '29297B636173652263686172742D6C696E65223A413D6E65772043686172746973742E4C696E65282223222B632C772C6F293B627265616B3B636173652263686172742D626172223A413D6E65772043686172746973742E426172282223222B632C772C';
wwv_flow_api.g_varchar2_table(648) := '6F293B627265616B3B636173652263686172742D706965223A6F2E636861727450616464696E673D7B7D2C413D6E65772043686172746973742E506965282223222B632C772C6F293B627265616B3B64656661756C743A652E64656275672E696E666F28';
wwv_flow_api.g_varchar2_table(649) := '7B6D6F64756C653A22647261774C6172676543617264222C6D73673A224E6F2076616C69642043686172742074797065227D297D76617220433D652E6973446566696E6564416E644E6F744E756C6C28722E434152445F49434F4E5F434F4C4F52293F72';
wwv_flow_api.g_varchar2_table(650) := '2E434152445F49434F4E5F434F4C4F523A227768697465223B412E6F6E282264726177222C66756E6374696F6E2874297B76617220693D7B7D3B696628722E434152445F43484152545F44415441262622737472696E67223D3D747970656F6620722E43';
wwv_flow_api.g_varchar2_table(651) := '4152445F43484152545F44415441297472797B693D4A534F4E2E706172736528722E434152445F43484152545F44415441297D63617463682874297B652E64656275672E6572726F72287B6D6F64756C653A22647261774C6172676543617264222C6D73';
wwv_flow_api.g_varchar2_table(652) := '673A224572726F72207768696C652074727920746F20706172736520434152445F43484152545F434F4E464947222C6368617274436F6E6669673A737D297D656C736520693D722E434152445F43484152545F444154413B692E636F6C6F727326262843';
wwv_flow_api.g_varchar2_table(653) := '3D692E636F6C6F72735B742E696E6465785D7C7C692E636F6C6F72735B305D292C2262617222213D3D742E747970652626226C696E6522213D3D742E74797065262622706F696E7422213D3D742E747970657C7C286F2E7374726F6B6557696474683F74';
wwv_flow_api.g_varchar2_table(654) := '2E656C656D656E742E61747472287B7374796C653A227374726F6B653A2020222B432B223B207374726F6B652D77696474683A222B6F2E7374726F6B6557696474682B2270783B227D293A742E656C656D656E742E61747472287B7374796C653A227374';
wwv_flow_api.g_varchar2_table(655) := '726F6B653A2020222B437D29292C22736C696365223D3D3D742E747970652626742E656C656D656E742E61747472287B7374796C653A2266696C6C3A20222B432B223B2066696C6C2D6F7061636974793A20222B28692E636F6C6F72733F2E363A28742E';
wwv_flow_api.g_varchar2_table(656) := '696E6465782531302B32292F3130297D292C2261726561223D3D3D742E747970652626742E656C656D656E742E61747472287B7374796C653A2266696C6C3A20222B432B223B2066696C6C2D6F7061636974793A20222B28742E696E6465782531302B32';
wwv_flow_api.g_varchar2_table(657) := '292F31307D292C21303D3D3D6F2E646F6E75742626286F2E736C69636557696474682626242870292E66696E6428222E63742D736C6963652D646F6E757422292E63737328227374726F6B652D7769647468222C6F2E736C69636557696474682E746F53';
wwv_flow_api.g_varchar2_table(658) := '7472696E6728292B22707822292C742E656C656D656E742E61747472287B7374796C653A227374726F6B652D6F7061636974793A20222B282D742E696E6465782531302B3130292F31302B223B207374726F6B653A2020222B437D292C242870292E6669';
wwv_flow_api.g_varchar2_table(659) := '6E6428222E63742D6C6162656C22292E63737328227374726F6B65222C22696E697469616C22292C242870292E66696E6428222E63742D6C6162656C22292E637373282266696C6C222C692E636F6C6F72733F227768697465223A4329292C242870292E';
wwv_flow_api.g_varchar2_table(660) := '66696E6428222E63742D736C6963652D70696522292E6174747228227374726F6B65222C692E636F6C6F72733F227267626128302C302C302C3029223A43292C242870292E66696E6428222E63742D736C6963652D646F6E757422292E61747472282273';
wwv_flow_api.g_varchar2_table(661) := '74726F6B65222C43292C242870292E66696E6428222E63742D6C6162656C22292E6373732822636F6C6F72222C692E636F6C6F72733F227768697465223A43292C242870292E66696E6428222E63742D6772696422292E63737328227374726F6B65222C';
wwv_flow_api.g_varchar2_table(662) := '692E636F6C6F72733F227768697465223A43292C242870292E66696E6428222E63742D6772696422292E63737328226F706163697479222C22302E3422297D297D7D28692C722C732C6E2C732E434152445F43484152545F434F4E464947293A6728692C';
wwv_flow_api.g_varchar2_table(663) := '722C732C6E292C613E3D3132262628723D702841292C613D30297D297D7D28692E726F772C62293A28412E63737328226D696E2D686569676874222C2222292C652E6E6F446174614D6573736167652E73686F7728412C6E29297D66756E6374696F6E20';
wwv_flow_api.g_varchar2_table(664) := '702865297B76617220743D2428223C6469763E3C2F6469763E22293B72657475726E20742E616464436C6173732822732D672D726F7722292C652E617070656E642874292C747D66756E6374696F6E206628297B696628652E6973415045582829297B65';
wwv_flow_api.g_varchar2_table(665) := '2E6C6F616465722E73746172742841293B76617220743D733B617065782E7365727665722E706C7567696E28692C7B706167654974656D733A747D2C7B737563636573733A682C6572726F723A66756E6374696F6E2874297B412E656D70747928292C65';
wwv_flow_api.g_varchar2_table(666) := '2E6572726F724D6573736167652E73686F7728412C72292C652E64656275672E6572726F72287B6D6F64756C653A2267657444617461222C6D73673A224572726F72206F636375726564206F6E2063616C6C696E6720414A4158222C643A747D297D2C64';
wwv_flow_api.g_varchar2_table(667) := '617461547970653A226A736F6E227D297D656C7365207472797B652E6C6F616465722E73746172742841292C6828646174614A534F4E297D63617463682874297B652E64656275672E6572726F72287B6D6F64756C653A2267657444617461222C6D7367';
wwv_flow_api.g_varchar2_table(668) := '3A224E6565642064617461206A736F6E222C6572723A747D297D7D66756E6374696F6E206D2865297B72657475726E226261636B67726F756E643A206C696E6561722D6772616469656E742836306465672C2068736C28222B32332A65253335302B222C';
wwv_flow_api.g_varchar2_table(669) := '203535252C20363025292C2068736C28222B32332A65253335302B222C203530252C2036302529293B626F782D736861646F773A203020313270782032307078202D313070782072676261283233302C203233302C203233302C20302E3238292C203020';
wwv_flow_api.g_varchar2_table(670) := '347078203230707820307078207267626128302C20302C20302C20302E3132292C20302037707820387078202D3570782072676261283233302C203233302C203233302C20302E32293B227D66756E6374696F6E206728742C692C6E2C72297B76617220';
wwv_flow_api.g_varchar2_table(671) := '613D2428223C6469763E3C2F6469763E22293B612E616464436C6173732822732D672D636F6C2D222B722E636172645769647468293B76617220733D2428223C6469763E3C2F6469763E22293B696628732E616464436C617373282261742D6361726422';
wwv_flow_api.g_varchar2_table(672) := '292C732E616464436C617373282261742D636172642D737461747322292C652E6973446566696E6564416E644E6F744E756C6C286E2E434152445F49434F4E29297B766172206F3D2428223C6469763E3C2F6469763E22293B6F2E616464436C61737328';
wwv_flow_api.g_varchar2_table(673) := '22636172642D68656164657222292C652E6973446566696E6564416E644E6F744E756C6C286E2E434152445F4845414445525F434C4153532926266F2E616464436C617373286E2E434152445F4845414445525F434C415353293B766172206C3D242822';
wwv_flow_api.g_varchar2_table(674) := '3C693E3C2F693E22293B6966286E2E434152445F49434F4E26262266612D223D3D3D6E2E434152445F49434F4E2E73756273747228302C2266612D222E6C656E67746829297B76617220633D652E6973446566696E6564416E644E6F744E756C6C286E2E';
wwv_flow_api.g_varchar2_table(675) := '434152445F49434F4E5F434F4C4F52293F6E2E434152445F49434F4E5F434F4C4F523A227768697465223B6C2E616464436C6173732822666122292C6C2E616464436C617373286E2E434152445F49434F4E292C6C2E6373732822636F6C6F72222C6329';
wwv_flow_api.g_varchar2_table(676) := '2C652E6973446566696E6564416E644E6F744E756C6C286E2E434152445F4845414445525F5354594C45293F6F2E6174747228227374796C65222C6E2E434152445F4845414445525F5354594C45293A652E6973446566696E6564416E644E6F744E756C';
wwv_flow_api.g_varchar2_table(677) := '6C286E2E434152445F4845414445525F434C415353297C7C6F2E6174747228227374796C65222C6D287429297D656C736520652E6973446566696E6564416E644E6F744E756C6C286E2E434152445F4845414445525F5354594C452926266F2E61747472';
wwv_flow_api.g_varchar2_table(678) := '28227374796C65222C6E2E434152445F4845414445525F5354594C45292C6F2E63737328226261636B67726F756E642D696D616765222C2275726C28222B6E2E434152445F49434F4E2B222922293B6F2E617070656E64286C292C732E617070656E6428';
wwv_flow_api.g_varchar2_table(679) := '6F297D76617220753D2428223C6469763E3C2F6469763E22293B696628752E616464436C6173732822636172642D636F6E74656E7422292C652E6973446566696E6564416E644E6F744E756C6C286E2E434152445F5449544C4529297B76617220643D24';
wwv_flow_api.g_varchar2_table(680) := '28223C703E3C2F703E22293B642E616464436C617373282263617465676F727922292C642E68746D6C286E2E434152445F5449544C45292C752E617070656E642864292C6F2E637373282270616464696E67222C223135707822297D656C7365206F2E63';
wwv_flow_api.g_varchar2_table(681) := '7373282270616464696E67222C2235707822293B76617220683D2428223C68323E3C2F68323E22293B682E616464436C61737328227469746C6522292C652E6973446566696E6564416E644E6F744E756C6C286E2E434152445F56414C5545292626682E';
wwv_flow_api.g_varchar2_table(682) := '68746D6C286E2E434152445F56414C5545292C752E617070656E642868292C732E617070656E642875293B76617220703D2428223C6469763E3C2F6469763E22293B702E616464436C6173732822636172642D666F6F74657222293B76617220663D2428';
wwv_flow_api.g_varchar2_table(683) := '223C6469763E3C2F6469763E22293B6966286E2E434152445F464F4F54455226262828663D2428223C6469763E3C2F6469763E2229292E616464436C6173732822737461747322292C662E617070656E64286E2E434152445F464F4F54455229292C702E';
wwv_flow_api.g_varchar2_table(684) := '617070656E642866292C732E617070656E642870292C612E617070656E642873292C6E2E434152445F4C494E4B297B76617220673D2428223C613E3C2F613E22293B672E61747472282268726566222C6E2E434152445F4C494E4B292C672E617070656E';
wwv_flow_api.g_varchar2_table(685) := '642861292C692E617070656E642867297D656C736520692E617070656E642861297D652E64656275672E696E666F287B6D6F64756C653A22696E697469616C697A65222C706172656E7449443A742C616A617849443A692C6E6F44617461466F756E644D';
wwv_flow_api.g_varchar2_table(686) := '6573736167653A6E2C7564436F6E6669674A534F4E3A612C6974656D73325375626D69743A732C62696E64526566726573684F6E49643A6F2C65736361706552657175697265643A6C2C73616E6974697A6548544D4C3A632C73616E6974697A654F7074';
wwv_flow_api.g_varchar2_table(687) := '696F6E733A757D293B76617220762C793D7B414C4C4F5745445F415454523A5B226163636573736B6579222C22616C69676E222C22616C74222C22616C77617973222C226175746F636F6D706C657465222C226175746F706C6179222C22626F72646572';
wwv_flow_api.g_varchar2_table(688) := '222C2263656C6C70616464696E67222C2263656C6C73706163696E67222C2263686172736574222C22636C617373222C22636F6C7370616E222C22646972222C22686569676874222C2268726566222C226964222C226C616E67222C226E616D65222C22';
wwv_flow_api.g_varchar2_table(689) := '72656C222C227265717569726564222C22726F777370616E222C22737263222C227374796C65222C2273756D6D617279222C22746162696E646578222C22746172676574222C227469746C65222C2274797065222C2276616C7565222C22776964746822';
wwv_flow_api.g_varchar2_table(690) := '5D2C414C4C4F5745445F544147533A5B2261222C2261646472657373222C2262222C22626C6F636B71756F7465222C226272222C2263617074696F6E222C22636F6465222C226464222C22646976222C22646C222C226474222C22656D222C2266696763';
wwv_flow_api.g_varchar2_table(691) := '617074696F6E222C22666967757265222C226831222C226832222C226833222C226834222C226835222C226836222C226872222C2269222C22696D67222C226C6162656C222C226C69222C226E6C222C226F6C222C2270222C22707265222C2273222C22';
wwv_flow_api.g_varchar2_table(692) := '7370616E222C22737472696B65222C227374726F6E67222C22737562222C22737570222C227461626C65222C2274626F6479222C227464222C227468222C227468656164222C227472222C2275222C22756C225D7D3B2131213D3D63262628763D753F65';
wwv_flow_api.g_varchar2_table(693) := '2E6A736F6E53617665457874656E6428792C75293A79293B76617220783D24282223222B74293B696628782E6C656E6774683E30297B76617220623D7B7D3B623D652E6A736F6E53617665457874656E64287B6361726457696474683A342C7265667265';
wwv_flow_api.g_varchar2_table(694) := '73683A307D2C61293B76617220413D66756E6374696F6E2865297B76617220743D2428223C6469763E3C2F6469763E22293B72657475726E20742E616464436C6173732822732D672D636F6E7461696E657222292C742E63737328226D696E2D68656967';
wwv_flow_api.g_varchar2_table(695) := '6874222C22313730707822292C652E617070656E642874292C747D2878293B6628293B7472797B617065782E6A5175657279282223222B6F292E62696E6428226170657872656672657368222C66756E6374696F6E28297B303D3D412E6368696C647265';
wwv_flow_api.g_varchar2_table(696) := '6E28227370616E22292E6C656E67746826266628297D297D63617463682874297B652E64656275672E696E666F287B6D6F64756C653A22696E697469616C697A65222C6D73673A2243616E27742062696E642072656672657368206576656E74206F6E20';
wwv_flow_api.g_varchar2_table(697) := '222B6F2B222E2041706578206973206D697373696E67222C6572723A747D297D622E726566726573683E302626736574496E74657276616C2866756E6374696F6E28297B303D3D412E6368696C6472656E28227370616E22292E6C656E67746826266628';
wwv_flow_api.g_varchar2_table(698) := '297D2C3165332A622E72656672657368297D656C736520652E64656275672E696E666F287B6D6F64756C653A22696E697469616C697A65222C6D73673A2243616E27742066696E6420706172656E7449443A20222B747D297D7D7D28293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(31839204028936341360)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_file_name=>'materialcards.pkgd.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '4368617274733A0D0A0D0A68747470733A2F2F67696F6E6B756E7A2E6769746875622E696F2F63686172746973742D6A732F3A0D0A0D0A4D4954204C6963656E73650D0A0D0A436F707972696768742028632920323031332047696F6E204B756E7A203C';
wwv_flow_api.g_varchar2_table(2) := '67696F6E2E6B756E7A40676D61696C2E636F6D3E0D0A0D0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F7079';
wwv_flow_api.g_varchar2_table(3) := '206F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468652022536F66747761726522292C20746F206465616C20696E2074686520536F66747761726520776974686F';
wwv_flow_api.g_varchar2_table(4) := '7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E207468652072696768747320746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269';
wwv_flow_api.g_varchar2_table(5) := '627574652C207375626C6963656E73652C20616E642F6F722073656C6C20636F70696573206F662074686520536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F2077686F6D2074686520536F66747761726520697320';
wwv_flow_api.g_varchar2_table(6) := '6675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F6E733A0D0A0D0A5468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D';
wwv_flow_api.g_varchar2_table(7) := '697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E20616C6C20636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0D0A0D0A54484520534F46545741';
wwv_flow_api.g_varchar2_table(8) := '52452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C2045585052455353204F5220494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420';
wwv_flow_api.g_varchar2_table(9) := '544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C204649544E45535320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E4652494E47454D454E542E20494E204E4F204556';
wwv_flow_api.g_varchar2_table(10) := '454E54205348414C4C2054484520415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F54484552204C494142494C4954592C2057484554';
wwv_flow_api.g_varchar2_table(11) := '48455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C204F5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F4654';
wwv_flow_api.g_varchar2_table(12) := '57415245204F522054484520555345204F52204F54484552204445414C494E475320494E2054484520534F4654574152452E0D0A0D0A4361726473204373733A0D0A0D0A68747470733A2F2F6769746875622E636F6D2F637265617469766574696D6F66';
wwv_flow_api.g_varchar2_table(13) := '66696369616C2F6D6174657269616C2D64617368626F6172643A0D0A0D0A4D4954204C6963656E73650D0A0D0A436F707972696768742028632920323031372043726561746976652054696D0D0A0D0A5065726D697373696F6E20697320686572656279';
wwv_flow_api.g_varchar2_table(14) := '206772616E7465642C2066726565206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F7079206F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E74617469';
wwv_flow_api.g_varchar2_table(15) := '6F6E2066696C657320287468652022536F66747761726522292C20746F206465616C20696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E';
wwv_flow_api.g_varchar2_table(16) := '207468652072696768747320746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C20636F70696573206F662074686520';
wwv_flow_api.g_varchar2_table(17) := '536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F2077686F6D2074686520536F667477617265206973206675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E67';
wwv_flow_api.g_varchar2_table(18) := '20636F6E646974696F6E733A0D0A0D0A5468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E20616C6C20636F706965';
wwv_flow_api.g_varchar2_table(19) := '73206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0D0A0D0A54484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620';
wwv_flow_api.g_varchar2_table(20) := '414E59204B494E442C2045585052455353204F5220494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C204649544E4553';
wwv_flow_api.g_varchar2_table(21) := '5320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E4652494E47454D454E542E20494E204E4F204556454E54205348414C4C2054484520415554484F5253204F5220434F5059524947485420484F4C444552532042';
wwv_flow_api.g_varchar2_table(22) := '45204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F54484552204C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F5448455257';
wwv_flow_api.g_varchar2_table(23) := '4953452C2041524953494E472046524F4D2C204F5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E2054484520534F46';
wwv_flow_api.g_varchar2_table(24) := '54574152452E0D0A0D0A6A51756572793A0D0A0D0A68747470733A2F2F6769746875622E636F6D2F6A71756572792F6A71756572793A0D0A0D0A436F70797269676874204A5320466F756E646174696F6E20616E64206F7468657220636F6E7472696275';
wwv_flow_api.g_varchar2_table(25) := '746F72732C2068747470733A2F2F6A732E666F756E646174696F6E2F0D0A0D0A5468697320736F66747761726520636F6E7369737473206F6620766F6C756E7461727920636F6E747269627574696F6E73206D616465206279206D616E790D0A696E6469';
wwv_flow_api.g_varchar2_table(26) := '76696475616C732E20466F7220657861637420636F6E747269627574696F6E20686973746F72792C2073656520746865207265766973696F6E20686973746F72790D0A617661696C61626C652061742068747470733A2F2F6769746875622E636F6D2F6A';
wwv_flow_api.g_varchar2_table(27) := '71756572792F6A71756572790D0A0D0A54686520666F6C6C6F77696E67206C6963656E7365206170706C69657320746F20616C6C207061727473206F66207468697320736F667477617265206578636570742061730D0A646F63756D656E746564206265';
wwv_flow_api.g_varchar2_table(28) := '6C6F773A0D0A0D0A3D3D3D3D0D0A0D0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E670D0A6120636F7079206F6620746869';
wwv_flow_api.g_varchar2_table(29) := '7320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468650D0A22536F66747761726522292C20746F206465616C20696E2074686520536F66747761726520776974686F757420726573';
wwv_flow_api.g_varchar2_table(30) := '7472696374696F6E2C20696E636C7564696E670D0A776974686F7574206C696D69746174696F6E207468652072696768747320746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C0D0A64697374726962757465';
wwv_flow_api.g_varchar2_table(31) := '2C207375626C6963656E73652C20616E642F6F722073656C6C20636F70696573206F662074686520536F6674776172652C20616E6420746F0D0A7065726D697420706572736F6E7320746F2077686F6D2074686520536F66747761726520697320667572';
wwv_flow_api.g_varchar2_table(32) := '6E697368656420746F20646F20736F2C207375626A65637420746F0D0A74686520666F6C6C6F77696E6720636F6E646974696F6E733A0D0A0D0A5468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D6973';
wwv_flow_api.g_varchar2_table(33) := '73696F6E206E6F74696365207368616C6C2062650D0A696E636C7564656420696E20616C6C20636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0D0A0D0A54484520534F4654574152';
wwv_flow_api.g_varchar2_table(34) := '452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C0D0A45585052455353204F5220494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420';
wwv_flow_api.g_varchar2_table(35) := '544F205448452057415252414E54494553204F460D0A4D45524348414E544142494C4954592C204649544E45535320464F52204120504152544943554C415220505552504F534520414E440D0A4E4F4E494E4652494E47454D454E542E20494E204E4F20';
wwv_flow_api.g_varchar2_table(36) := '4556454E54205348414C4C2054484520415554484F5253204F5220434F5059524947485420484F4C444552532042450D0A4C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F54484552204C494142494C4954592C2057';
wwv_flow_api.g_varchar2_table(37) := '48455448455220494E20414E20414354494F4E0D0A4F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C204F5554204F46204F5220494E20434F4E4E454354494F4E0D0A5749544820544845';
wwv_flow_api.g_varchar2_table(38) := '20534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E2054484520534F4654574152452E0D0A0D0A3D3D3D3D0D0A0D0A416C6C2066696C6573206C6F636174656420696E20746865206E6F64655F6D6F64';
wwv_flow_api.g_varchar2_table(39) := '756C657320616E642065787465726E616C206469726563746F72696573206172650D0A65787465726E616C6C79206D61696E7461696E6564206C69627261726965732075736564206279207468697320736F667477617265207768696368206861766520';
wwv_flow_api.g_varchar2_table(40) := '74686569720D0A6F776E206C6963656E7365733B207765207265636F6D6D656E6420796F752072656164207468656D2C206173207468656972207465726D73206D6179206469666665722066726F6D0D0A746865207465726D732061626F76652E0D0A0D';
wwv_flow_api.g_varchar2_table(41) := '0A626F6F7473747261703A0D0A0D0A68747470733A2F2F6769746875622E636F6D2F747762732F626F6F7473747261703A0D0A0D0A546865204D4954204C6963656E736520284D4954290D0A0D0A436F707972696768742028632920323031312D323031';
wwv_flow_api.g_varchar2_table(42) := '3720547769747465722C20496E632E0D0A436F707972696768742028632920323031312D323031372054686520426F6F74737472617020417574686F72730D0A0D0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565';
wwv_flow_api.g_varchar2_table(43) := '206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F70790D0A6F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C65732028746865';
wwv_flow_api.g_varchar2_table(44) := '2022536F66747761726522292C20746F206465616C0D0A696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E20746865207269676874730D';
wwv_flow_api.g_varchar2_table(45) := '0A746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C0D0A636F70696573206F662074686520536F6674776172652C20';
wwv_flow_api.g_varchar2_table(46) := '616E6420746F207065726D697420706572736F6E7320746F2077686F6D2074686520536F6674776172652069730D0A6675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F';
wwv_flow_api.g_varchar2_table(47) := '6E733A0D0A0D0A5468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E0D0A616C6C20636F70696573206F7220737562';
wwv_flow_api.g_varchar2_table(48) := '7374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0D0A0D0A54484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E44';
wwv_flow_api.g_varchar2_table(49) := '2C2045585052455353204F520D0A494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C0D0A4649544E45535320464F5220';
wwv_flow_api.g_varchar2_table(50) := '4120504152544943554C415220505552504F534520414E44204E4F4E494E4652494E47454D454E542E20494E204E4F204556454E54205348414C4C205448450D0A415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941';
wwv_flow_api.g_varchar2_table(51) := '424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F544845520D0A4C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C';
wwv_flow_api.g_varchar2_table(52) := '2041524953494E472046524F4D2C0D0A4F5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E0D0A54484520534F465457';
wwv_flow_api.g_varchar2_table(53) := '4152452E0D0A0D0A466F6E742041504558204C6963656E73650D0A0D0A466F6E74733A0D0A53494C204F464C20312E31204C6963656E7365202868747470733A2F2F736372697074732E73696C2E6F72672F4F464C290D0A0D0A49636F6E7320616E6420';
wwv_flow_api.g_varchar2_table(54) := '436F64653A0D0A4D4954204C6963656E7365202868747470733A2F2F6F70656E736F757263652E6F72672F6C6963656E7365732F4D4954290D0A0D0A2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(55) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A53494C204F50454E20464F4E54204C4943454E53450D0A200D0A56657273696F6E20312E31202D20323620466562727561727920323030370D0A505245414D424C450D0A200D0A54686520676F616C';
wwv_flow_api.g_varchar2_table(56) := '73206F6620746865204F70656E20466F6E74204C6963656E736520284F464C292061726520746F207374696D756C61746520776F726C64776964650D0A646576656C6F706D656E74206F6620636F6C6C61626F72617469766520666F6E742070726F6A65';
wwv_flow_api.g_varchar2_table(57) := '6374732C20746F20737570706F72742074686520666F6E74206372656174696F6E0D0A6566666F727473206F662061636164656D696320616E64206C696E6775697374696320636F6D6D756E69746965732C20616E6420746F2070726F76696465206120';
wwv_flow_api.g_varchar2_table(58) := '6672656520616E640D0A6F70656E206672616D65776F726B20696E20776869636820666F6E7473206D61792062652073686172656420616E6420696D70726F76656420696E20706172746E6572736869700D0A77697468206F74686572732E0D0A200D0A';
wwv_flow_api.g_varchar2_table(59) := '546865204F464C20616C6C6F777320746865206C6963656E73656420666F6E747320746F20626520757365642C20737475646965642C206D6F64696669656420616E640D0A7265646973747269627574656420667265656C79206173206C6F6E67206173';
wwv_flow_api.g_varchar2_table(60) := '207468657920617265206E6F7420736F6C64206279207468656D73656C7665732E205468650D0A666F6E74732C20696E636C7564696E6720616E79206465726976617469766520776F726B732C2063616E2062652062756E646C65642C20656D62656464';
wwv_flow_api.g_varchar2_table(61) := '65642C0D0A7265646973747269627574656420616E642F6F7220736F6C64207769746820616E7920736F6674776172652070726F7669646564207468617420616E792072657365727665640D0A6E616D657320617265206E6F7420757365642062792064';
wwv_flow_api.g_varchar2_table(62) := '65726976617469766520776F726B732E2054686520666F6E747320616E642064657269766174697665732C0D0A686F77657665722C2063616E6E6F742062652072656C656173656420756E64657220616E79206F746865722074797065206F66206C6963';
wwv_flow_api.g_varchar2_table(63) := '656E73652E205468650D0A726571756972656D656E7420666F7220666F6E747320746F2072656D61696E20756E6465722074686973206C6963656E736520646F6573206E6F74206170706C790D0A746F20616E7920646F63756D656E7420637265617465';
wwv_flow_api.g_varchar2_table(64) := '64207573696E672074686520666F6E7473206F722074686569722064657269766174697665732E0D0A444546494E4954494F4E530D0A200D0A22466F6E7420536F667477617265222072656665727320746F2074686520736574206F662066696C657320';
wwv_flow_api.g_varchar2_table(65) := '72656C65617365642062792074686520436F707972696768740D0A486F6C64657228732920756E6465722074686973206C6963656E736520616E6420636C6561726C79206D61726B656420617320737563682E2054686973206D61790D0A696E636C7564';
wwv_flow_api.g_varchar2_table(66) := '6520736F757263652066696C65732C206275696C64207363726970747320616E6420646F63756D656E746174696F6E2E0D0A200D0A22526573657276656420466F6E74204E616D65222072656665727320746F20616E79206E616D657320737065636966';
wwv_flow_api.g_varchar2_table(67) := '6965642061732073756368206166746572207468650D0A636F707972696768742073746174656D656E742873292E0D0A200D0A224F726967696E616C2056657273696F6E222072656665727320746F2074686520636F6C6C656374696F6E206F6620466F';
wwv_flow_api.g_varchar2_table(68) := '6E7420536F66747761726520636F6D706F6E656E74732061730D0A64697374726962757465642062792074686520436F7079726967687420486F6C6465722873292E0D0A200D0A224D6F6469666965642056657273696F6E222072656665727320746F20';
wwv_flow_api.g_varchar2_table(69) := '616E792064657269766174697665206D61646520627920616464696E6720746F2C2064656C6574696E672C0D0A6F7220737562737469747574696E67209720696E2070617274206F7220696E2077686F6C65209720616E79206F662074686520636F6D70';
wwv_flow_api.g_varchar2_table(70) := '6F6E656E7473206F66207468650D0A4F726967696E616C2056657273696F6E2C206279206368616E67696E6720666F726D617473206F7220627920706F7274696E672074686520466F6E7420536F66747761726520746F20610D0A6E657720656E766972';
wwv_flow_api.g_varchar2_table(71) := '6F6E6D656E742E0D0A200D0A22417574686F72222072656665727320746F20616E792064657369676E65722C20656E67696E6565722C2070726F6772616D6D65722C20746563686E6963616C0D0A777269746572206F72206F7468657220706572736F6E';
wwv_flow_api.g_varchar2_table(72) := '2077686F20636F6E747269627574656420746F2074686520466F6E7420536F6674776172652E0D0A5045524D495353494F4E202620434F4E444954494F4E530D0A200D0A5065726D697373696F6E20697320686572656279206772616E7465642C206672';
wwv_flow_api.g_varchar2_table(73) := '6565206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E670D0A6120636F7079206F662074686520466F6E7420536F6674776172652C20746F207573652C2073747564792C20636F70792C206D657267652C20656D6265';
wwv_flow_api.g_varchar2_table(74) := '642C206D6F646966792C0D0A7265646973747269627574652C20616E642073656C6C206D6F64696669656420616E6420756E6D6F64696669656420636F70696573206F662074686520466F6E740D0A536F6674776172652C207375626A65637420746F20';
wwv_flow_api.g_varchar2_table(75) := '74686520666F6C6C6F77696E6720636F6E646974696F6E733A0D0A200D0A3129204E6569746865722074686520466F6E7420536F667477617265206E6F7220616E79206F662069747320696E646976696475616C20636F6D706F6E656E74732C0D0A696E';
wwv_flow_api.g_varchar2_table(76) := '204F726967696E616C206F72204D6F6469666965642056657273696F6E732C206D617920626520736F6C6420627920697473656C662E0D0A200D0A3229204F726967696E616C206F72204D6F6469666965642056657273696F6E73206F66207468652046';
wwv_flow_api.g_varchar2_table(77) := '6F6E7420536F667477617265206D61792062652062756E646C65642C0D0A7265646973747269627574656420616E642F6F7220736F6C64207769746820616E7920736F6674776172652C2070726F76696465642074686174206561636820636F70790D0A';
wwv_flow_api.g_varchar2_table(78) := '636F6E7461696E73207468652061626F766520636F70797269676874206E6F7469636520616E642074686973206C6963656E73652E2054686573652063616E2062650D0A696E636C7564656420656974686572206173207374616E642D616C6F6E652074';
wwv_flow_api.g_varchar2_table(79) := '6578742066696C65732C2068756D616E2D7265616461626C652068656164657273206F720D0A696E2074686520617070726F707269617465206D616368696E652D7265616461626C65206D65746164617461206669656C64732077697468696E20746578';
wwv_flow_api.g_varchar2_table(80) := '74206F720D0A62696E6172792066696C6573206173206C6F6E672061732074686F7365206669656C64732063616E20626520656173696C79207669657765642062792074686520757365722E0D0A200D0A3329204E6F204D6F6469666965642056657273';
wwv_flow_api.g_varchar2_table(81) := '696F6E206F662074686520466F6E7420536F667477617265206D6179207573652074686520526573657276656420466F6E740D0A4E616D6528732920756E6C657373206578706C69636974207772697474656E207065726D697373696F6E206973206772';
wwv_flow_api.g_varchar2_table(82) := '616E7465642062792074686520636F72726573706F6E64696E670D0A436F7079726967687420486F6C6465722E2054686973207265737472696374696F6E206F6E6C79206170706C69657320746F20746865207072696D61727920666F6E74206E616D65';
wwv_flow_api.g_varchar2_table(83) := '2061730D0A70726573656E74656420746F207468652075736572732E0D0A200D0A342920546865206E616D65287329206F662074686520436F7079726967687420486F6C646572287329206F722074686520417574686F72287329206F66207468652046';
wwv_flow_api.g_varchar2_table(84) := '6F6E740D0A536F667477617265207368616C6C206E6F74206265207573656420746F2070726F6D6F74652C20656E646F727365206F722061647665727469736520616E790D0A4D6F6469666965642056657273696F6E2C2065786365707420746F206163';
wwv_flow_api.g_varchar2_table(85) := '6B6E6F776C656467652074686520636F6E747269627574696F6E287329206F66207468650D0A436F7079726967687420486F6C64657228732920616E642074686520417574686F72287329206F722077697468207468656972206578706C696369742077';
wwv_flow_api.g_varchar2_table(86) := '72697474656E0D0A7065726D697373696F6E2E0D0A200D0A35292054686520466F6E7420536F6674776172652C206D6F646966696564206F7220756E6D6F6469666965642C20696E2070617274206F7220696E2077686F6C652C0D0A6D75737420626520';
wwv_flow_api.g_varchar2_table(87) := '646973747269627574656420656E746972656C7920756E6465722074686973206C6963656E73652C20616E64206D757374206E6F742062650D0A646973747269627574656420756E64657220616E79206F74686572206C6963656E73652E205468652072';
wwv_flow_api.g_varchar2_table(88) := '6571756972656D656E7420666F7220666F6E747320746F0D0A72656D61696E20756E6465722074686973206C6963656E736520646F6573206E6F74206170706C7920746F20616E7920646F63756D656E7420637265617465640D0A7573696E6720746865';
wwv_flow_api.g_varchar2_table(89) := '20466F6E7420536F6674776172652E0D0A5445524D494E4154494F4E0D0A200D0A54686973206C6963656E7365206265636F6D6573206E756C6C20616E6420766F696420696620616E79206F66207468652061626F766520636F6E646974696F6E732061';
wwv_flow_api.g_varchar2_table(90) := '72650D0A6E6F74206D65742E0D0A0D0A444953434C41494D45520D0A54484520464F4E5420534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C0D0A4558';
wwv_flow_api.g_varchar2_table(91) := '5052455353204F5220494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420544F20414E592057415252414E54494553204F460D0A4D45524348414E544142494C4954592C204649544E45535320464F52204120504152';
wwv_flow_api.g_varchar2_table(92) := '544943554C415220505552504F534520414E44204E4F4E494E4652494E47454D454E540D0A4F4620434F505952494748542C20504154454E542C2054524144454D41524B2C204F52204F544845522052494748542E20494E204E4F204556454E54205348';
wwv_flow_api.g_varchar2_table(93) := '414C4C205448450D0A434F5059524947485420484F4C444552204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F54484552204C494142494C4954592C0D0A494E434C5544494E4720414E592047454E455241';
wwv_flow_api.g_varchar2_table(94) := '4C2C205350454349414C2C20494E4449524543542C20494E434944454E54414C2C204F5220434F4E53455155454E5449414C0D0A44414D414745532C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F525420';
wwv_flow_api.g_varchar2_table(95) := '4F52204F54484552574953452C2041524953494E470D0A46524F4D2C204F5554204F462054484520555345204F5220494E4142494C49545920544F205553452054484520464F4E5420534F465457415245204F522046524F4D0D0A4F5448455220444541';
wwv_flow_api.g_varchar2_table(96) := '4C494E475320494E2054484520464F4E5420534F4654574152452E0D0A200D0A0D0A2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A466F6E7420';
wwv_flow_api.g_varchar2_table(97) := '417765736F6D65204353532C204C4553532C20616E6420534153532066696C6573207765726520726563656976656420756E6465722074686520666F6C6C6F77696E67206C6963656E73653A0D0A200D0A5065726D697373696F6E206973206865726562';
wwv_flow_api.g_varchar2_table(98) := '79206772616E7465642C2066726565206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F70790D0A6F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E7461';
wwv_flow_api.g_varchar2_table(99) := '74696F6E2066696C657320287468652022536F66747761726522292C20746F206465616C0D0A696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174';
wwv_flow_api.g_varchar2_table(100) := '696F6E20746865207269676874730D0A746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C0D0A636F70696573206F66';
wwv_flow_api.g_varchar2_table(101) := '2074686520536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F2077686F6D2074686520536F6674776172652069730D0A6675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C';
wwv_flow_api.g_varchar2_table(102) := '6C6F77696E6720636F6E646974696F6E733A0D0A200D0A5468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E0D0A61';
wwv_flow_api.g_varchar2_table(103) := '6C6C20636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0D0A200D0A54484520534F4654574152452049532050524F564944454420224153204953222C20574954484F555420574152';
wwv_flow_api.g_varchar2_table(104) := '52414E5459204F4620414E59204B494E442C2045585052455353204F520D0A494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C49';
wwv_flow_api.g_varchar2_table(105) := '54592C0D0A4649544E45535320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E4652494E47454D454E542E20494E204E4F204556454E54205348414C4C205448450D0A415554484F5253204F5220434F5059524947';
wwv_flow_api.g_varchar2_table(106) := '485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F544845520D0A4C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C2054';
wwv_flow_api.g_varchar2_table(107) := '4F5254204F52204F54484552574953452C2041524953494E472046524F4D2C0D0A4F5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C49';
wwv_flow_api.g_varchar2_table(108) := '4E475320494E0D0A54484520534F4654574152452E0D0A0D0A68747470733A2F2F6769746875622E636F6D2F6375726535332F444F4D5075726966790D0A0D0A444F4D5075726966790D0A436F707972696768742032303135204D6172696F2048656964';
wwv_flow_api.g_varchar2_table(109) := '65726963680D0A0D0A444F4D507572696679206973206672656520736F6674776172653B20796F752063616E2072656469737472696275746520697420616E642F6F72206D6F6469667920697420756E646572207468650D0A7465726D73206F66206569';
wwv_flow_api.g_varchar2_table(110) := '746865723A0D0A0D0A61292074686520417061636865204C6963656E73652056657273696F6E20322E302C206F720D0A622920746865204D6F7A696C6C61205075626C6963204C6963656E73652056657273696F6E20322E300D0A0D0A2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(111) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A0D0A4C6963656E73656420756E646572207468652041706163686520';
wwv_flow_api.g_varchar2_table(112) := '4C6963656E73652C2056657273696F6E20322E30202874686520224C6963656E736522293B0D0A796F75206D6179206E6F742075736520746869732066696C652065786365707420696E20636F6D706C69616E6365207769746820746865204C6963656E';
wwv_flow_api.g_varchar2_table(113) := '73652E0D0A596F75206D6179206F627461696E206120636F7079206F6620746865204C6963656E73652061740D0A0D0A20202020687474703A2F2F7777772E6170616368652E6F72672F6C6963656E7365732F4C4943454E53452D322E300D0A0D0A2020';
wwv_flow_api.g_varchar2_table(114) := '2020556E6C657373207265717569726564206279206170706C696361626C65206C6177206F722061677265656420746F20696E2077726974696E672C20736F6674776172650D0A20202020646973747269627574656420756E64657220746865204C6963';
wwv_flow_api.g_varchar2_table(115) := '656E7365206973206469737472696275746564206F6E20616E20224153204953222042415349532C0D0A20202020574954484F55542057415252414E54494553204F5220434F4E444954494F4E53204F4620414E59204B494E442C206569746865722065';
wwv_flow_api.g_varchar2_table(116) := '787072657373206F7220696D706C6965642E0D0A2020202053656520746865204C6963656E736520666F7220746865207370656369666963206C616E677561676520676F7665726E696E67207065726D697373696F6E7320616E640D0A202020206C696D';
wwv_flow_api.g_varchar2_table(117) := '69746174696F6E7320756E64657220746865204C6963656E73652E0D0A0D0A2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(118) := '2D2D2D2D2D2D2D2D0D0A4D6F7A696C6C61205075626C6963204C6963656E73652C2076657273696F6E20322E300D0A0D0A312E20446566696E6974696F6E730D0A0D0A312E312E2093436F6E7472696275746F72940D0A0D0A20202020206D65616E7320';
wwv_flow_api.g_varchar2_table(119) := '6561636820696E646976696475616C206F72206C6567616C20656E74697479207468617420637265617465732C20636F6E747269627574657320746F207468650D0A20202020206372656174696F6E206F662C206F72206F776E7320436F766572656420';
wwv_flow_api.g_varchar2_table(120) := '536F6674776172652E0D0A0D0A312E322E2093436F6E7472696275746F722056657273696F6E940D0A0D0A20202020206D65616E732074686520636F6D62696E6174696F6E206F662074686520436F6E747269627574696F6E73206F66206F7468657273';
wwv_flow_api.g_varchar2_table(121) := '2028696620616E7929207573656420627920610D0A2020202020436F6E7472696275746F7220616E64207468617420706172746963756C617220436F6E7472696275746F72927320436F6E747269627574696F6E2E0D0A0D0A312E332E2093436F6E7472';
wwv_flow_api.g_varchar2_table(122) := '69627574696F6E940D0A0D0A20202020206D65616E7320436F766572656420536F667477617265206F66206120706172746963756C617220436F6E7472696275746F722E0D0A0D0A312E342E2093436F766572656420536F667477617265940D0A0D0A20';
wwv_flow_api.g_varchar2_table(123) := '202020206D65616E7320536F7572636520436F646520466F726D20746F2077686963682074686520696E697469616C20436F6E7472696275746F7220686173206174746163686564207468650D0A20202020206E6F7469636520696E2045786869626974';
wwv_flow_api.g_varchar2_table(124) := '20412C207468652045786563757461626C6520466F726D206F66207375636820536F7572636520436F646520466F726D2C20616E640D0A20202020204D6F64696669636174696F6E73206F66207375636820536F7572636520436F646520466F726D2C20';
wwv_flow_api.g_varchar2_table(125) := '696E2065616368206361736520696E636C7564696E6720706F7274696F6E730D0A202020202074686572656F662E0D0A0D0A312E352E2093496E636F6D70617469626C652057697468205365636F6E64617279204C6963656E736573940D0A2020202020';
wwv_flow_api.g_varchar2_table(126) := '6D65616E730D0A0D0A2020202020612E20746861742074686520696E697469616C20436F6E7472696275746F722068617320617474616368656420746865206E6F746963652064657363726962656420696E0D0A20202020202020204578686962697420';
wwv_flow_api.g_varchar2_table(127) := '4220746F2074686520436F766572656420536F6674776172653B206F720D0A0D0A2020202020622E20746861742074686520436F766572656420536F66747761726520776173206D61646520617661696C61626C6520756E64657220746865207465726D';
wwv_flow_api.g_varchar2_table(128) := '73206F662076657273696F6E0D0A2020202020202020312E31206F72206561726C696572206F6620746865204C6963656E73652C20627574206E6F7420616C736F20756E64657220746865207465726D73206F6620610D0A20202020202020205365636F';
wwv_flow_api.g_varchar2_table(129) := '6E64617279204C6963656E73652E0D0A0D0A312E362E209345786563757461626C6520466F726D940D0A0D0A20202020206D65616E7320616E7920666F726D206F662074686520776F726B206F74686572207468616E20536F7572636520436F64652046';
wwv_flow_api.g_varchar2_table(130) := '6F726D2E0D0A0D0A312E372E20934C617267657220576F726B940D0A0D0A20202020206D65616E73206120776F726B207468617420636F6D62696E657320436F766572656420536F6674776172652077697468206F74686572206D6174657269616C2C20';
wwv_flow_api.g_varchar2_table(131) := '696E20612073657061726174650D0A202020202066696C65206F722066696C65732C2074686174206973206E6F7420436F766572656420536F6674776172652E0D0A0D0A312E382E20934C6963656E7365940D0A0D0A20202020206D65616E7320746869';
wwv_flow_api.g_varchar2_table(132) := '7320646F63756D656E742E0D0A0D0A312E392E20934C6963656E7361626C65940D0A0D0A20202020206D65616E7320686176696E672074686520726967687420746F206772616E742C20746F20746865206D6178696D756D20657874656E7420706F7373';
wwv_flow_api.g_varchar2_table(133) := '69626C652C2077686574686572206174207468650D0A202020202074696D65206F662074686520696E697469616C206772616E74206F722073756273657175656E746C792C20616E7920616E6420616C6C206F66207468652072696768747320636F6E76';
wwv_flow_api.g_varchar2_table(134) := '657965642062790D0A202020202074686973204C6963656E73652E0D0A0D0A312E31302E20934D6F64696669636174696F6E73940D0A0D0A20202020206D65616E7320616E79206F662074686520666F6C6C6F77696E673A0D0A0D0A2020202020612E20';
wwv_flow_api.g_varchar2_table(135) := '616E792066696C6520696E20536F7572636520436F646520466F726D207468617420726573756C74732066726F6D20616E206164646974696F6E20746F2C2064656C6574696F6E0D0A202020202020202066726F6D2C206F72206D6F6469666963617469';
wwv_flow_api.g_varchar2_table(136) := '6F6E206F662074686520636F6E74656E7473206F6620436F766572656420536F6674776172653B206F720D0A0D0A2020202020622E20616E79206E65772066696C6520696E20536F7572636520436F646520466F726D207468617420636F6E7461696E73';
wwv_flow_api.g_varchar2_table(137) := '20616E7920436F766572656420536F6674776172652E0D0A0D0A312E31312E2093506174656E7420436C61696D7394206F66206120436F6E7472696275746F720D0A0D0A2020202020206D65616E7320616E7920706174656E7420636C61696D2873292C';
wwv_flow_api.g_varchar2_table(138) := '20696E636C7564696E6720776974686F7574206C696D69746174696F6E2C206D6574686F642C2070726F636573732C0D0A202020202020616E642061707061726174757320636C61696D732C20696E20616E7920706174656E74204C6963656E7361626C';
wwv_flow_api.g_varchar2_table(139) := '65206279207375636820436F6E7472696275746F7220746861740D0A202020202020776F756C6420626520696E6672696E6765642C2062757420666F7220746865206772616E74206F6620746865204C6963656E73652C20627920746865206D616B696E';
wwv_flow_api.g_varchar2_table(140) := '672C0D0A2020202020207573696E672C2073656C6C696E672C206F66666572696E6720666F722073616C652C20686176696E67206D6164652C20696D706F72742C206F72207472616E73666572206F660D0A202020202020656974686572206974732043';
wwv_flow_api.g_varchar2_table(141) := '6F6E747269627574696F6E73206F722069747320436F6E7472696275746F722056657273696F6E2E0D0A0D0A312E31322E20935365636F6E64617279204C6963656E7365940D0A0D0A2020202020206D65616E73206569746865722074686520474E5520';
wwv_flow_api.g_varchar2_table(142) := '47656E6572616C205075626C6963204C6963656E73652C2056657273696F6E20322E302C2074686520474E55204C65737365720D0A20202020202047656E6572616C205075626C6963204C6963656E73652C2056657273696F6E20322E312C2074686520';
wwv_flow_api.g_varchar2_table(143) := '474E552041666665726F2047656E6572616C205075626C69630D0A2020202020204C6963656E73652C2056657273696F6E20332E302C206F7220616E79206C617465722076657273696F6E73206F662074686F7365206C6963656E7365732E0D0A0D0A31';
wwv_flow_api.g_varchar2_table(144) := '2E31332E2093536F7572636520436F646520466F726D940D0A0D0A2020202020206D65616E732074686520666F726D206F662074686520776F726B2070726566657272656420666F72206D616B696E67206D6F64696669636174696F6E732E0D0A0D0A31';
wwv_flow_api.g_varchar2_table(145) := '2E31342E2093596F759420286F722093596F757294290D0A0D0A2020202020206D65616E7320616E20696E646976696475616C206F722061206C6567616C20656E746974792065786572636973696E672072696768747320756E64657220746869730D0A';
wwv_flow_api.g_varchar2_table(146) := '2020202020204C6963656E73652E20466F72206C6567616C20656E7469746965732C2093596F759420696E636C7564657320616E7920656E74697479207468617420636F6E74726F6C732C2069730D0A202020202020636F6E74726F6C6C65642062792C';
wwv_flow_api.g_varchar2_table(147) := '206F7220697320756E64657220636F6D6D6F6E20636F6E74726F6C207769746820596F752E20466F7220707572706F736573206F6620746869730D0A202020202020646566696E6974696F6E2C2093636F6E74726F6C94206D65616E7320286129207468';
wwv_flow_api.g_varchar2_table(148) := '6520706F7765722C20646972656374206F7220696E6469726563742C20746F2063617573650D0A20202020202074686520646972656374696F6E206F72206D616E6167656D656E74206F66207375636820656E746974792C207768657468657220627920';
wwv_flow_api.g_varchar2_table(149) := '636F6E7472616374206F720D0A2020202020206F74686572776973652C206F7220286229206F776E657273686970206F66206D6F7265207468616E2066696674792070657263656E74202835302529206F66207468650D0A2020202020206F7574737461';
wwv_flow_api.g_varchar2_table(150) := '6E64696E6720736861726573206F722062656E6566696369616C206F776E657273686970206F66207375636820656E746974792E0D0A0D0A0D0A322E204C6963656E7365204772616E747320616E6420436F6E646974696F6E730D0A0D0A322E312E2047';
wwv_flow_api.g_varchar2_table(151) := '72616E74730D0A0D0A20202020204561636820436F6E7472696275746F7220686572656279206772616E747320596F75206120776F726C642D776964652C20726F79616C74792D667265652C0D0A20202020206E6F6E2D6578636C7573697665206C6963';
wwv_flow_api.g_varchar2_table(152) := '656E73653A0D0A0D0A2020202020612E20756E64657220696E74656C6C65637475616C2070726F70657274792072696768747320286F74686572207468616E20706174656E74206F722074726164656D61726B290D0A20202020202020204C6963656E73';
wwv_flow_api.g_varchar2_table(153) := '61626C65206279207375636820436F6E7472696275746F7220746F207573652C20726570726F647563652C206D616B6520617661696C61626C652C0D0A20202020202020206D6F646966792C20646973706C61792C20706572666F726D2C206469737472';
wwv_flow_api.g_varchar2_table(154) := '69627574652C20616E64206F7468657277697365206578706C6F6974206974730D0A2020202020202020436F6E747269627574696F6E732C20656974686572206F6E20616E20756E6D6F6469666965642062617369732C2077697468204D6F6469666963';
wwv_flow_api.g_varchar2_table(155) := '6174696F6E732C206F722061730D0A202020202020202070617274206F662061204C617267657220576F726B3B20616E640D0A0D0A2020202020622E20756E64657220506174656E7420436C61696D73206F66207375636820436F6E7472696275746F72';
wwv_flow_api.g_varchar2_table(156) := '20746F206D616B652C207573652C2073656C6C2C206F6666657220666F720D0A202020202020202073616C652C2068617665206D6164652C20696D706F72742C20616E64206F7468657277697365207472616E7366657220656974686572206974732043';
wwv_flow_api.g_varchar2_table(157) := '6F6E747269627574696F6E730D0A20202020202020206F722069747320436F6E7472696275746F722056657273696F6E2E0D0A0D0A322E322E2045666665637469766520446174650D0A0D0A2020202020546865206C6963656E736573206772616E7465';
wwv_flow_api.g_varchar2_table(158) := '6420696E2053656374696F6E20322E312077697468207265737065637420746F20616E7920436F6E747269627574696F6E206265636F6D650D0A202020202065666665637469766520666F72206561636820436F6E747269627574696F6E206F6E207468';
wwv_flow_api.g_varchar2_table(159) := '6520646174652074686520436F6E7472696275746F722066697273742064697374726962757465730D0A20202020207375636820436F6E747269627574696F6E2E0D0A0D0A322E332E204C696D69746174696F6E73206F6E204772616E742053636F7065';
wwv_flow_api.g_varchar2_table(160) := '0D0A0D0A2020202020546865206C6963656E736573206772616E74656420696E20746869732053656374696F6E20322061726520746865206F6E6C7920726967687473206772616E74656420756E64657220746869730D0A20202020204C6963656E7365';
wwv_flow_api.g_varchar2_table(161) := '2E204E6F206164646974696F6E616C20726967687473206F72206C6963656E7365732077696C6C20626520696D706C6965642066726F6D2074686520646973747269627574696F6E0D0A20202020206F72206C6963656E73696E67206F6620436F766572';
wwv_flow_api.g_varchar2_table(162) := '656420536F66747761726520756E6465722074686973204C6963656E73652E204E6F74776974687374616E64696E672053656374696F6E0D0A2020202020322E312862292061626F76652C206E6F20706174656E74206C6963656E736520697320677261';
wwv_flow_api.g_varchar2_table(163) := '6E746564206279206120436F6E7472696275746F723A0D0A0D0A2020202020612E20666F7220616E7920636F64652074686174206120436F6E7472696275746F72206861732072656D6F7665642066726F6D20436F766572656420536F6674776172653B';
wwv_flow_api.g_varchar2_table(164) := '206F720D0A0D0A2020202020622E20666F7220696E6672696E67656D656E7473206361757365642062793A2028692920596F757220616E6420616E79206F7468657220746869726420706172747992730D0A20202020202020206D6F6469666963617469';
wwv_flow_api.g_varchar2_table(165) := '6F6E73206F6620436F766572656420536F6674776172652C206F7220286969292074686520636F6D62696E6174696F6E206F66206974730D0A2020202020202020436F6E747269627574696F6E732077697468206F7468657220736F6674776172652028';
wwv_flow_api.g_varchar2_table(166) := '6578636570742061732070617274206F662069747320436F6E7472696275746F720D0A202020202020202056657273696F6E293B206F720D0A0D0A2020202020632E20756E64657220506174656E7420436C61696D7320696E6672696E67656420627920';
wwv_flow_api.g_varchar2_table(167) := '436F766572656420536F66747761726520696E2074686520616273656E6365206F66206974730D0A2020202020202020436F6E747269627574696F6E732E0D0A0D0A202020202054686973204C6963656E736520646F6573206E6F74206772616E742061';
wwv_flow_api.g_varchar2_table(168) := '6E792072696768747320696E207468652074726164656D61726B732C2073657276696365206D61726B732C206F720D0A20202020206C6F676F73206F6620616E7920436F6E7472696275746F722028657863657074206173206D6179206265206E656365';
wwv_flow_api.g_varchar2_table(169) := '737361727920746F20636F6D706C792077697468207468650D0A20202020206E6F7469636520726571756972656D656E747320696E2053656374696F6E20332E34292E0D0A0D0A322E342E2053756273657175656E74204C6963656E7365730D0A0D0A20';
wwv_flow_api.g_varchar2_table(170) := '202020204E6F20436F6E7472696275746F72206D616B6573206164646974696F6E616C206772616E7473206173206120726573756C74206F6620596F75722063686F69636520746F0D0A2020202020646973747269627574652074686520436F76657265';
wwv_flow_api.g_varchar2_table(171) := '6420536F66747761726520756E64657220612073756273657175656E742076657273696F6E206F662074686973204C6963656E73650D0A2020202020287365652053656374696F6E2031302E3229206F7220756E64657220746865207465726D73206F66';
wwv_flow_api.g_varchar2_table(172) := '2061205365636F6E64617279204C6963656E736520286966207065726D69747465640D0A2020202020756E64657220746865207465726D73206F662053656374696F6E20332E33292E0D0A0D0A322E352E20526570726573656E746174696F6E0D0A0D0A';
wwv_flow_api.g_varchar2_table(173) := '20202020204561636820436F6E7472696275746F7220726570726573656E747320746861742074686520436F6E7472696275746F722062656C69657665732069747320436F6E747269627574696F6E730D0A202020202061726520697473206F72696769';
wwv_flow_api.g_varchar2_table(174) := '6E616C206372656174696F6E287329206F72206974206861732073756666696369656E742072696768747320746F206772616E74207468650D0A202020202072696768747320746F2069747320436F6E747269627574696F6E7320636F6E766579656420';
wwv_flow_api.g_varchar2_table(175) := '62792074686973204C6963656E73652E0D0A0D0A322E362E2046616972205573650D0A0D0A202020202054686973204C6963656E7365206973206E6F7420696E74656E64656420746F206C696D697420616E792072696768747320596F75206861766520';
wwv_flow_api.g_varchar2_table(176) := '756E646572206170706C696361626C650D0A2020202020636F7079726967687420646F637472696E6573206F662066616972207573652C2066616972206465616C696E672C206F72206F74686572206571756976616C656E74732E0D0A0D0A322E372E20';
wwv_flow_api.g_varchar2_table(177) := '436F6E646974696F6E730D0A0D0A202020202053656374696F6E7320332E312C20332E322C20332E332C20616E6420332E342061726520636F6E646974696F6E73206F6620746865206C6963656E736573206772616E74656420696E0D0A202020202053';
wwv_flow_api.g_varchar2_table(178) := '656374696F6E20322E312E0D0A0D0A0D0A332E20526573706F6E736962696C69746965730D0A0D0A332E312E20446973747269627574696F6E206F6620536F7572636520466F726D0D0A0D0A2020202020416C6C20646973747269627574696F6E206F66';
wwv_flow_api.g_varchar2_table(179) := '20436F766572656420536F66747761726520696E20536F7572636520436F646520466F726D2C20696E636C7564696E6720616E790D0A20202020204D6F64696669636174696F6E73207468617420596F7520637265617465206F7220746F207768696368';
wwv_flow_api.g_varchar2_table(180) := '20596F7520636F6E747269627574652C206D75737420626520756E646572207468650D0A20202020207465726D73206F662074686973204C6963656E73652E20596F75206D75737420696E666F726D20726563697069656E747320746861742074686520';
wwv_flow_api.g_varchar2_table(181) := '536F7572636520436F646520466F726D0D0A20202020206F662074686520436F766572656420536F66747761726520697320676F7665726E656420627920746865207465726D73206F662074686973204C6963656E73652C20616E6420686F770D0A2020';
wwv_flow_api.g_varchar2_table(182) := '202020746865792063616E206F627461696E206120636F7079206F662074686973204C6963656E73652E20596F75206D6179206E6F7420617474656D707420746F20616C746572206F720D0A202020202072657374726963742074686520726563697069';
wwv_flow_api.g_varchar2_table(183) := '656E7473922072696768747320696E2074686520536F7572636520436F646520466F726D2E0D0A0D0A332E322E20446973747269627574696F6E206F662045786563757461626C6520466F726D0D0A0D0A2020202020496620596F752064697374726962';
wwv_flow_api.g_varchar2_table(184) := '75746520436F766572656420536F66747761726520696E2045786563757461626C6520466F726D207468656E3A0D0A0D0A2020202020612E207375636820436F766572656420536F667477617265206D75737420616C736F206265206D61646520617661';
wwv_flow_api.g_varchar2_table(185) := '696C61626C6520696E20536F7572636520436F646520466F726D2C0D0A202020202020202061732064657363726962656420696E2053656374696F6E20332E312C20616E6420596F75206D75737420696E666F726D20726563697069656E7473206F6620';
wwv_flow_api.g_varchar2_table(186) := '7468650D0A202020202020202045786563757461626C6520466F726D20686F7720746865792063616E206F627461696E206120636F7079206F66207375636820536F7572636520436F646520466F726D2062790D0A2020202020202020726561736F6E61';
wwv_flow_api.g_varchar2_table(187) := '626C65206D65616E7320696E20612074696D656C79206D616E6E65722C206174206120636861726765206E6F206D6F7265207468616E2074686520636F73740D0A20202020202020206F6620646973747269627574696F6E20746F207468652072656369';
wwv_flow_api.g_varchar2_table(188) := '7069656E743B20616E640D0A0D0A2020202020622E20596F75206D6179206469737472696275746520737563682045786563757461626C6520466F726D20756E64657220746865207465726D73206F662074686973204C6963656E73652C0D0A20202020';
wwv_flow_api.g_varchar2_table(189) := '202020206F72207375626C6963656E736520697420756E64657220646966666572656E74207465726D732C2070726F7669646564207468617420746865206C6963656E736520666F720D0A20202020202020207468652045786563757461626C6520466F';
wwv_flow_api.g_varchar2_table(190) := '726D20646F6573206E6F7420617474656D707420746F206C696D6974206F7220616C7465722074686520726563697069656E7473920D0A202020202020202072696768747320696E2074686520536F7572636520436F646520466F726D20756E64657220';
wwv_flow_api.g_varchar2_table(191) := '74686973204C6963656E73652E0D0A0D0A332E332E20446973747269627574696F6E206F662061204C617267657220576F726B0D0A0D0A2020202020596F75206D61792063726561746520616E6420646973747269627574652061204C61726765722057';
wwv_flow_api.g_varchar2_table(192) := '6F726B20756E646572207465726D73206F6620596F75722063686F6963652C0D0A202020202070726F7669646564207468617420596F7520616C736F20636F6D706C7920776974682074686520726571756972656D656E7473206F662074686973204C69';
wwv_flow_api.g_varchar2_table(193) := '63656E736520666F72207468650D0A2020202020436F766572656420536F6674776172652E20496620746865204C617267657220576F726B206973206120636F6D62696E6174696F6E206F6620436F766572656420536F6674776172650D0A2020202020';
wwv_flow_api.g_varchar2_table(194) := '77697468206120776F726B20676F7665726E6564206279206F6E65206F72206D6F7265205365636F6E64617279204C6963656E7365732C20616E642074686520436F76657265640D0A2020202020536F667477617265206973206E6F7420496E636F6D70';
wwv_flow_api.g_varchar2_table(195) := '617469626C652057697468205365636F6E64617279204C6963656E7365732C2074686973204C6963656E7365207065726D6974730D0A2020202020596F7520746F206164646974696F6E616C6C792064697374726962757465207375636820436F766572';
wwv_flow_api.g_varchar2_table(196) := '656420536F66747761726520756E64657220746865207465726D73206F660D0A202020202073756368205365636F6E64617279204C6963656E73652873292C20736F20746861742074686520726563697069656E74206F6620746865204C617267657220';
wwv_flow_api.g_varchar2_table(197) := '576F726B206D61792C2061740D0A20202020207468656972206F7074696F6E2C206675727468657220646973747269627574652074686520436F766572656420536F66747761726520756E64657220746865207465726D73206F660D0A20202020206569';
wwv_flow_api.g_varchar2_table(198) := '746865722074686973204C6963656E7365206F722073756368205365636F6E64617279204C6963656E73652873292E0D0A0D0A332E342E204E6F74696365730D0A0D0A2020202020596F75206D6179206E6F742072656D6F7665206F7220616C74657220';
wwv_flow_api.g_varchar2_table(199) := '746865207375627374616E6365206F6620616E79206C6963656E7365206E6F74696365732028696E636C7564696E670D0A2020202020636F70797269676874206E6F74696365732C20706174656E74206E6F74696365732C20646973636C61696D657273';
wwv_flow_api.g_varchar2_table(200) := '206F662077617272616E74792C206F72206C696D69746174696F6E730D0A20202020206F66206C696162696C6974792920636F6E7461696E65642077697468696E2074686520536F7572636520436F646520466F726D206F662074686520436F76657265';
wwv_flow_api.g_varchar2_table(201) := '640D0A2020202020536F6674776172652C20657863657074207468617420596F75206D617920616C74657220616E79206C6963656E7365206E6F746963657320746F2074686520657874656E740D0A2020202020726571756972656420746F2072656D65';
wwv_flow_api.g_varchar2_table(202) := '6479206B6E6F776E206661637475616C20696E616363757261636965732E0D0A0D0A332E352E204170706C69636174696F6E206F66204164646974696F6E616C205465726D730D0A0D0A2020202020596F75206D61792063686F6F736520746F206F6666';
wwv_flow_api.g_varchar2_table(203) := '65722C20616E6420746F2063686172676520612066656520666F722C2077617272616E74792C20737570706F72742C0D0A2020202020696E64656D6E697479206F72206C696162696C697479206F626C69676174696F6E7320746F206F6E65206F72206D';
wwv_flow_api.g_varchar2_table(204) := '6F726520726563697069656E7473206F6620436F76657265640D0A2020202020536F6674776172652E20486F77657665722C20596F75206D617920646F20736F206F6E6C79206F6E20596F7572206F776E20626568616C662C20616E64206E6F74206F6E';
wwv_flow_api.g_varchar2_table(205) := '20626568616C660D0A20202020206F6620616E7920436F6E7472696275746F722E20596F75206D757374206D616B65206974206162736F6C7574656C7920636C656172207468617420616E7920737563680D0A202020202077617272616E74792C207375';
wwv_flow_api.g_varchar2_table(206) := '70706F72742C20696E64656D6E6974792C206F72206C696162696C697479206F626C69676174696F6E206973206F66666572656420627920596F750D0A2020202020616C6F6E652C20616E6420596F752068657265627920616772656520746F20696E64';
wwv_flow_api.g_varchar2_table(207) := '656D6E69667920657665727920436F6E7472696275746F7220666F7220616E790D0A20202020206C696162696C69747920696E637572726564206279207375636820436F6E7472696275746F72206173206120726573756C74206F662077617272616E74';
wwv_flow_api.g_varchar2_table(208) := '792C20737570706F72742C0D0A2020202020696E64656D6E697479206F72206C696162696C697479207465726D7320596F75206F666665722E20596F75206D617920696E636C756465206164646974696F6E616C0D0A2020202020646973636C61696D65';
wwv_flow_api.g_varchar2_table(209) := '7273206F662077617272616E747920616E64206C696D69746174696F6E73206F66206C696162696C69747920737065636966696320746F20616E790D0A20202020206A7572697364696374696F6E2E0D0A0D0A342E20496E6162696C69747920746F2043';
wwv_flow_api.g_varchar2_table(210) := '6F6D706C792044756520746F2053746174757465206F7220526567756C6174696F6E0D0A0D0A202020496620697420697320696D706F737369626C6520666F7220596F7520746F20636F6D706C79207769746820616E79206F6620746865207465726D73';
wwv_flow_api.g_varchar2_table(211) := '206F662074686973204C6963656E73650D0A20202077697468207265737065637420746F20736F6D65206F7220616C6C206F662074686520436F766572656420536F6674776172652064756520746F20737461747574652C206A7564696369616C0D0A20';
wwv_flow_api.g_varchar2_table(212) := '20206F726465722C206F7220726567756C6174696F6E207468656E20596F75206D7573743A2028612920636F6D706C79207769746820746865207465726D73206F662074686973204C6963656E73650D0A202020746F20746865206D6178696D756D2065';
wwv_flow_api.g_varchar2_table(213) := '7874656E7420706F737369626C653B20616E642028622920646573637269626520746865206C696D69746174696F6E7320616E642074686520636F64650D0A20202074686579206166666563742E2053756368206465736372697074696F6E206D757374';
wwv_flow_api.g_varchar2_table(214) := '20626520706C6163656420696E206120746578742066696C6520696E636C75646564207769746820616C6C0D0A202020646973747269627574696F6E73206F662074686520436F766572656420536F66747761726520756E6465722074686973204C6963';
wwv_flow_api.g_varchar2_table(215) := '656E73652E2045786365707420746F207468650D0A202020657874656E742070726F686962697465642062792073746174757465206F7220726567756C6174696F6E2C2073756368206465736372697074696F6E206D7573742062650D0A202020737566';
wwv_flow_api.g_varchar2_table(216) := '66696369656E746C792064657461696C656420666F72206120726563697069656E74206F66206F7264696E61727920736B696C6C20746F2062652061626C6520746F0D0A202020756E6465727374616E642069742E0D0A0D0A352E205465726D696E6174';
wwv_flow_api.g_varchar2_table(217) := '696F6E0D0A0D0A352E312E2054686520726967687473206772616E74656420756E6465722074686973204C6963656E73652077696C6C207465726D696E617465206175746F6D61746963616C6C7920696620596F750D0A20202020206661696C20746F20';
wwv_flow_api.g_varchar2_table(218) := '636F6D706C79207769746820616E79206F6620697473207465726D732E20486F77657665722C20696620596F75206265636F6D6520636F6D706C69616E742C0D0A20202020207468656E2074686520726967687473206772616E74656420756E64657220';
wwv_flow_api.g_varchar2_table(219) := '74686973204C6963656E73652066726F6D206120706172746963756C617220436F6E7472696275746F720D0A2020202020617265207265696E737461746564202861292070726F766973696F6E616C6C792C20756E6C65737320616E6420756E74696C20';
wwv_flow_api.g_varchar2_table(220) := '7375636820436F6E7472696275746F720D0A20202020206578706C696369746C7920616E642066696E616C6C79207465726D696E6174657320596F7572206772616E74732C20616E6420286229206F6E20616E206F6E676F696E672062617369732C0D0A';
wwv_flow_api.g_varchar2_table(221) := '20202020206966207375636820436F6E7472696275746F72206661696C7320746F206E6F7469667920596F75206F6620746865206E6F6E2D636F6D706C69616E636520627920736F6D650D0A2020202020726561736F6E61626C65206D65616E73207072';
wwv_flow_api.g_varchar2_table(222) := '696F7220746F203630206461797320616674657220596F75206861766520636F6D65206261636B20696E746F20636F6D706C69616E63652E0D0A20202020204D6F72656F7665722C20596F7572206772616E74732066726F6D206120706172746963756C';
wwv_flow_api.g_varchar2_table(223) := '617220436F6E7472696275746F7220617265207265696E737461746564206F6E20616E0D0A20202020206F6E676F696E67206261736973206966207375636820436F6E7472696275746F72206E6F74696669657320596F75206F6620746865206E6F6E2D';
wwv_flow_api.g_varchar2_table(224) := '636F6D706C69616E63652062790D0A2020202020736F6D6520726561736F6E61626C65206D65616E732C2074686973206973207468652066697273742074696D6520596F752068617665207265636569766564206E6F74696365206F660D0A2020202020';
wwv_flow_api.g_varchar2_table(225) := '6E6F6E2D636F6D706C69616E636520776974682074686973204C6963656E73652066726F6D207375636820436F6E7472696275746F722C20616E6420596F75206265636F6D650D0A2020202020636F6D706C69616E74207072696F7220746F2033302064';
wwv_flow_api.g_varchar2_table(226) := '61797320616674657220596F75722072656365697074206F6620746865206E6F746963652E0D0A0D0A352E322E20496620596F7520696E697469617465206C697469676174696F6E20616761696E737420616E7920656E74697479206279206173736572';
wwv_flow_api.g_varchar2_table(227) := '74696E67206120706174656E740D0A2020202020696E6672696E67656D656E7420636C61696D20286578636C7564696E67206465636C617261746F7279206A7564676D656E7420616374696F6E732C20636F756E7465722D636C61696D732C0D0A202020';
wwv_flow_api.g_varchar2_table(228) := '2020616E642063726F73732D636C61696D732920616C6C6567696E672074686174206120436F6E7472696275746F722056657273696F6E206469726563746C79206F720D0A2020202020696E6469726563746C7920696E6672696E67657320616E792070';
wwv_flow_api.g_varchar2_table(229) := '6174656E742C207468656E2074686520726967687473206772616E74656420746F20596F7520627920616E7920616E640D0A2020202020616C6C20436F6E7472696275746F727320666F722074686520436F766572656420536F66747761726520756E64';
wwv_flow_api.g_varchar2_table(230) := '65722053656374696F6E20322E31206F662074686973204C6963656E73650D0A20202020207368616C6C207465726D696E6174652E0D0A0D0A352E332E20496E20746865206576656E74206F66207465726D696E6174696F6E20756E6465722053656374';
wwv_flow_api.g_varchar2_table(231) := '696F6E7320352E31206F7220352E322061626F76652C20616C6C20656E6420757365720D0A20202020206C6963656E73652061677265656D656E747320286578636C7564696E67206469737472696275746F727320616E6420726573656C6C6572732920';
wwv_flow_api.g_varchar2_table(232) := '77686963682068617665206265656E0D0A202020202076616C69646C79206772616E74656420627920596F75206F7220596F7572206469737472696275746F727320756E6465722074686973204C6963656E7365207072696F7220746F0D0A2020202020';
wwv_flow_api.g_varchar2_table(233) := '7465726D696E6174696F6E207368616C6C2073757276697665207465726D696E6174696F6E2E0D0A0D0A362E20446973636C61696D6572206F662057617272616E74790D0A0D0A202020436F766572656420536F6674776172652069732070726F766964';
wwv_flow_api.g_varchar2_table(234) := '656420756E6465722074686973204C6963656E7365206F6E20616E20936173206973942062617369732C20776974686F75740D0A20202077617272616E7479206F6620616E79206B696E642C20656974686572206578707265737365642C20696D706C69';
wwv_flow_api.g_varchar2_table(235) := '65642C206F72207374617475746F72792C20696E636C7564696E672C0D0A202020776974686F7574206C696D69746174696F6E2C2077617272616E7469657320746861742074686520436F766572656420536F6674776172652069732066726565206F66';
wwv_flow_api.g_varchar2_table(236) := '20646566656374732C0D0A2020206D65726368616E7461626C652C2066697420666F72206120706172746963756C617220707572706F7365206F72206E6F6E2D696E6672696E67696E672E2054686520656E746972650D0A2020207269736B2061732074';
wwv_flow_api.g_varchar2_table(237) := '6F20746865207175616C69747920616E6420706572666F726D616E6365206F662074686520436F766572656420536F667477617265206973207769746820596F752E0D0A20202053686F756C6420616E7920436F766572656420536F6674776172652070';
wwv_flow_api.g_varchar2_table(238) := '726F76652064656665637469766520696E20616E7920726573706563742C20596F7520286E6F7420616E790D0A202020436F6E7472696275746F722920617373756D652074686520636F7374206F6620616E79206E656365737361727920736572766963';
wwv_flow_api.g_varchar2_table(239) := '696E672C207265706169722C206F720D0A202020636F7272656374696F6E2E205468697320646973636C61696D6572206F662077617272616E747920636F6E737469747574657320616E20657373656E7469616C2070617274206F6620746869730D0A20';
wwv_flow_api.g_varchar2_table(240) := '20204C6963656E73652E204E6F20757365206F662020616E7920436F766572656420536F66747761726520697320617574686F72697A656420756E6465722074686973204C6963656E73650D0A20202065786365707420756E6465722074686973206469';
wwv_flow_api.g_varchar2_table(241) := '73636C61696D65722E0D0A0D0A372E204C696D69746174696F6E206F66204C696162696C6974790D0A0D0A202020556E646572206E6F2063697263756D7374616E63657320616E6420756E646572206E6F206C6567616C207468656F72792C2077686574';
wwv_flow_api.g_varchar2_table(242) := '68657220746F72742028696E636C7564696E670D0A2020206E65676C6967656E6365292C20636F6E74726163742C206F72206F74686572776973652C207368616C6C20616E7920436F6E7472696275746F722C206F7220616E796F6E652077686F0D0A20';
wwv_flow_api.g_varchar2_table(243) := '2020646973747269627574657320436F766572656420536F667477617265206173207065726D69747465642061626F76652C206265206C6961626C6520746F20596F7520666F7220616E790D0A2020206469726563742C20696E6469726563742C207370';
wwv_flow_api.g_varchar2_table(244) := '656369616C2C20696E636964656E74616C2C206F7220636F6E73657175656E7469616C2064616D61676573206F6620616E790D0A20202063686172616374657220696E636C7564696E672C20776974686F7574206C696D69746174696F6E2C2064616D61';
wwv_flow_api.g_varchar2_table(245) := '67657320666F72206C6F73742070726F666974732C206C6F7373206F660D0A202020676F6F6477696C6C2C20776F726B2073746F70706167652C20636F6D7075746572206661696C757265206F72206D616C66756E6374696F6E2C206F7220616E792061';
wwv_flow_api.g_varchar2_table(246) := '6E6420616C6C0D0A2020206F7468657220636F6D6D65726369616C2064616D61676573206F72206C6F737365732C206576656E2069662073756368207061727479207368616C6C2068617665206265656E0D0A202020696E666F726D6564206F66207468';
wwv_flow_api.g_varchar2_table(247) := '6520706F73736962696C697479206F6620737563682064616D616765732E2054686973206C696D69746174696F6E206F66206C696162696C6974790D0A2020207368616C6C206E6F74206170706C7920746F206C696162696C69747920666F7220646561';
wwv_flow_api.g_varchar2_table(248) := '7468206F7220706572736F6E616C20696E6A75727920726573756C74696E672066726F6D20737563680D0A20202070617274799273206E65676C6967656E636520746F2074686520657874656E74206170706C696361626C65206C61772070726F686962';
wwv_flow_api.g_varchar2_table(249) := '6974732073756368206C696D69746174696F6E2E0D0A202020536F6D65206A7572697364696374696F6E7320646F206E6F7420616C6C6F7720746865206578636C7573696F6E206F72206C696D69746174696F6E206F6620696E636964656E74616C206F';
wwv_flow_api.g_varchar2_table(250) := '720D0A202020636F6E73657175656E7469616C2064616D616765732C20736F2074686973206578636C7573696F6E20616E64206C696D69746174696F6E206D6179206E6F74206170706C7920746F20596F752E0D0A0D0A382E204C697469676174696F6E';
wwv_flow_api.g_varchar2_table(251) := '0D0A0D0A202020416E79206C697469676174696F6E2072656C6174696E6720746F2074686973204C6963656E7365206D61792062652062726F75676874206F6E6C7920696E2074686520636F75727473206F660D0A20202061206A757269736469637469';
wwv_flow_api.g_varchar2_table(252) := '6F6E2077686572652074686520646566656E64616E74206D61696E7461696E7320697473207072696E636970616C20706C616365206F6620627573696E6573730D0A202020616E642073756368206C697469676174696F6E207368616C6C20626520676F';
wwv_flow_api.g_varchar2_table(253) := '7665726E6564206279206C617773206F662074686174206A7572697364696374696F6E2C20776974686F75740D0A2020207265666572656E636520746F2069747320636F6E666C6963742D6F662D6C61772070726F766973696F6E732E204E6F7468696E';
wwv_flow_api.g_varchar2_table(254) := '6720696E20746869732053656374696F6E207368616C6C0D0A20202070726576656E7420612070617274799273206162696C69747920746F206272696E672063726F73732D636C61696D73206F7220636F756E7465722D636C61696D732E0D0A0D0A392E';
wwv_flow_api.g_varchar2_table(255) := '204D697363656C6C616E656F75730D0A0D0A20202054686973204C6963656E736520726570726573656E74732074686520636F6D706C6574652061677265656D656E7420636F6E6365726E696E6720746865207375626A656374206D61747465720D0A20';
wwv_flow_api.g_varchar2_table(256) := '2020686572656F662E20496620616E792070726F766973696F6E206F662074686973204C6963656E73652069732068656C6420746F20626520756E656E666F72636561626C652C20737563680D0A20202070726F766973696F6E207368616C6C20626520';
wwv_flow_api.g_varchar2_table(257) := '7265666F726D6564206F6E6C7920746F2074686520657874656E74206E656365737361727920746F206D616B652069740D0A202020656E666F72636561626C652E20416E79206C6177206F7220726567756C6174696F6E2077686963682070726F766964';
wwv_flow_api.g_varchar2_table(258) := '6573207468617420746865206C616E6775616765206F6620610D0A202020636F6E7472616374207368616C6C20626520636F6E73747275656420616761696E7374207468652064726166746572207368616C6C206E6F74206265207573656420746F2063';
wwv_flow_api.g_varchar2_table(259) := '6F6E73747275650D0A20202074686973204C6963656E736520616761696E7374206120436F6E7472696275746F722E0D0A0D0A0D0A31302E2056657273696F6E73206F6620746865204C6963656E73650D0A0D0A31302E312E204E65772056657273696F';
wwv_flow_api.g_varchar2_table(260) := '6E730D0A0D0A2020202020204D6F7A696C6C6120466F756E646174696F6E20697320746865206C6963656E736520737465776172642E204578636570742061732070726F766964656420696E2053656374696F6E0D0A20202020202031302E332C206E6F';
wwv_flow_api.g_varchar2_table(261) := '206F6E65206F74686572207468616E20746865206C6963656E73652073746577617264206861732074686520726967687420746F206D6F64696679206F720D0A2020202020207075626C697368206E65772076657273696F6E73206F662074686973204C';
wwv_flow_api.g_varchar2_table(262) := '6963656E73652E20456163682076657273696F6E2077696C6C20626520676976656E20610D0A20202020202064697374696E6775697368696E672076657273696F6E206E756D6265722E0D0A0D0A31302E322E20456666656374206F66204E6577205665';
wwv_flow_api.g_varchar2_table(263) := '7273696F6E730D0A0D0A202020202020596F75206D617920646973747269627574652074686520436F766572656420536F66747761726520756E64657220746865207465726D73206F66207468652076657273696F6E206F660D0A202020202020746865';
wwv_flow_api.g_varchar2_table(264) := '204C6963656E736520756E64657220776869636820596F75206F726967696E616C6C792072656365697665642074686520436F766572656420536F6674776172652C206F720D0A202020202020756E64657220746865207465726D73206F6620616E7920';
wwv_flow_api.g_varchar2_table(265) := '73756273657175656E742076657273696F6E207075626C697368656420627920746865206C6963656E73650D0A202020202020737465776172642E0D0A0D0A31302E332E204D6F6469666965642056657273696F6E730D0A0D0A20202020202049662079';
wwv_flow_api.g_varchar2_table(266) := '6F752063726561746520736F667477617265206E6F7420676F7665726E65642062792074686973204C6963656E73652C20616E6420796F752077616E7420746F0D0A2020202020206372656174652061206E6577206C6963656E736520666F7220737563';
wwv_flow_api.g_varchar2_table(267) := '6820736F6674776172652C20796F75206D61792063726561746520616E64207573652061206D6F6469666965640D0A20202020202076657273696F6E206F662074686973204C6963656E736520696620796F752072656E616D6520746865206C6963656E';
wwv_flow_api.g_varchar2_table(268) := '736520616E642072656D6F766520616E790D0A2020202020207265666572656E63657320746F20746865206E616D65206F6620746865206C6963656E73652073746577617264202865786365707420746F206E6F7465207468617420737563680D0A2020';
wwv_flow_api.g_varchar2_table(269) := '202020206D6F646966696564206C6963656E736520646966666572732066726F6D2074686973204C6963656E7365292E0D0A0D0A31302E342E20446973747269627574696E6720536F7572636520436F646520466F726D207468617420697320496E636F';
wwv_flow_api.g_varchar2_table(270) := '6D70617469626C652057697468205365636F6E64617279204C6963656E7365730D0A202020202020496620596F752063686F6F736520746F206469737472696275746520536F7572636520436F646520466F726D207468617420697320496E636F6D7061';
wwv_flow_api.g_varchar2_table(271) := '7469626C6520576974680D0A2020202020205365636F6E64617279204C6963656E73657320756E64657220746865207465726D73206F6620746869732076657273696F6E206F6620746865204C6963656E73652C207468650D0A2020202020206E6F7469';
wwv_flow_api.g_varchar2_table(272) := '63652064657363726962656420696E20457868696269742042206F662074686973204C6963656E7365206D7573742062652061747461636865642E0D0A0D0A457868696269742041202D20536F7572636520436F646520466F726D204C6963656E736520';
wwv_flow_api.g_varchar2_table(273) := '4E6F746963650D0A0D0A2020202020205468697320536F7572636520436F646520466F726D206973207375626A65637420746F207468650D0A2020202020207465726D73206F6620746865204D6F7A696C6C61205075626C6963204C6963656E73652C20';
wwv_flow_api.g_varchar2_table(274) := '762E0D0A202020202020322E302E204966206120636F7079206F6620746865204D504C20776173206E6F740D0A2020202020206469737472696275746564207769746820746869732066696C652C20596F752063616E0D0A2020202020206F627461696E';
wwv_flow_api.g_varchar2_table(275) := '206F6E652061740D0A202020202020687474703A2F2F6D6F7A696C6C612E6F72672F4D504C2F322E302F2E0D0A0D0A4966206974206973206E6F7420706F737369626C65206F7220646573697261626C6520746F2070757420746865206E6F7469636520';
wwv_flow_api.g_varchar2_table(276) := '696E206120706172746963756C61722066696C652C207468656E0D0A596F75206D617920696E636C75646520746865206E6F7469636520696E2061206C6F636174696F6E2028737563682061732061204C4943454E53452066696C6520696E2061207265';
wwv_flow_api.g_varchar2_table(277) := '6C6576616E740D0A6469726563746F727929207768657265206120726563697069656E7420776F756C64206265206C696B656C7920746F206C6F6F6B20666F7220737563682061206E6F746963652E0D0A0D0A596F75206D617920616464206164646974';
wwv_flow_api.g_varchar2_table(278) := '696F6E616C206163637572617465206E6F7469636573206F6620636F70797269676874206F776E6572736869702E0D0A0D0A457868696269742042202D2093496E636F6D70617469626C652057697468205365636F6E64617279204C6963656E73657394';
wwv_flow_api.g_varchar2_table(279) := '204E6F746963650D0A0D0A2020202020205468697320536F7572636520436F646520466F726D2069732093496E636F6D70617469626C650D0A20202020202057697468205365636F6E64617279204C6963656E736573942C20617320646566696E656420';
wwv_flow_api.g_varchar2_table(280) := '62790D0A202020202020746865204D6F7A696C6C61205075626C6963204C6963656E73652C20762E20322E302E0D0A0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(31957496683172507064)
,p_plugin_id=>wwv_flow_api.id(50647647170575284673)
,p_file_name=>'LICENSE4LIBS'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done

var materialCards = (function () {
    "use strict";
    var util = {
        /**********************************************************************************
         ** required functions 
         *********************************************************************************/
        featureInfo: {
            name: "APEX Material Cards",
            info: {
                scriptVersion: "1.4",
                utilVersion: "1.3.5",
                url: "https://github.com/RonnyWeiss",
                license: "MIT"
            }
        },
        isDefinedAndNotNull: function (pInput) {
            if (typeof pInput !== "undefined" && pInput !== null && pInput != "") {
                return true;
            } else {
                return false;
            }
        },
        isAPEX: function () {
            if (typeof (apex) !== 'undefined') {
                return true;
            } else {
                return false;
            }
        },
        varType: function (pObj) {
            if (typeof pObj === "object") {
                var arrayConstructor = [].constructor;
                var objectConstructor = ({}).constructor;
                if (pObj.constructor === arrayConstructor) {
                    return "array";
                }
                if (pObj.constructor === objectConstructor) {
                    return "json";
                }
            } else {
                return typeof pObj;
            }
        },
        debug: {
            info: function () {
                if (util.isAPEX()) {
                    var i = 0;
                    var arr = [];
                    for (var prop in arguments) {
                        arr[i] = arguments[prop];
                        i++;
                    }
                    arr.push(util.featureInfo);
                    apex.debug.info.apply(this, arr);
                }
            },
            error: function () {
                var i = 0;
                var arr = [];
                for (var prop in arguments) {
                    arr[i] = arguments[prop];
                    i++;
                }
                arr.push(util.featureInfo);
                if (util.isAPEX()) {
                    apex.debug.error.apply(this, arr);
                } else {
                    console.error.apply(this, arr);
                }
            }
        },
        /**********************************************************************************
         ** optinal functions 
         *********************************************************************************/
        escapeHTML: function (str) {
            if (str === null) {
                return null;
            }
            if (typeof str === "undefined") {
                return;
            }
            if (typeof str === "object") {
                try {
                    str = JSON.stringify(str);
                } catch (e) {
                    /*do nothing */
                }
            }
            if (util.isAPEX()) {
                return apex.util.escapeHTML(String(str));
            } else {
                str = String(str);
                return str
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/"/g, "&quot;")
                    .replace(/'/g, "&#x27;")
                    .replace(/\//g, "&#x2F;");
            }
        },
        loader: {
            start: function (id, setMinHeight) {
                if (setMinHeight) {
                    $(id).css("min-height", "100px");
                }
                if (util.isAPEX()) {
                    apex.util.showSpinner($(id));
                } else {
                    /* define loader */
                    var faLoader = $("<span></span>");
                    faLoader.attr("id", "loader" + id);
                    faLoader.addClass("ct-loader");
                    faLoader.css("text-align", "center");
                    faLoader.css("width", "100%");
                    faLoader.css("display", "block");

                    /* define refresh icon with animation */
                    var faRefresh = $("<i></i>");
                    faRefresh.addClass("fa fa-refresh fa-2x fa-anim-spin");
                    faRefresh.css("background", "rgba(121,121,121,0.6)");
                    faRefresh.css("border-radius", "100%");
                    faRefresh.css("padding", "15px");
                    faRefresh.css("color", "white");

                    /* append loader */
                    faLoader.append(faRefresh);
                    $(id).append(faLoader);
                }
            },
            stop: function (id, removeMinHeight) {
                if (removeMinHeight) {
                    $(id).css("min-height", "");
                }
                $(id + " > .u-Processing").remove();
                $(id + " > .ct-loader").remove();
            }
        },
        jsonSaveExtend: function (srcConfig, targetConfig) {
            var finalConfig = {};
            var tmpJSON = {};
            /* try to parse config json when string or just set */
            if (typeof targetConfig === 'string') {
                try {
                    tmpJSON = JSON.parse(targetConfig);
                } catch (e) {
                    util.debug.error({
                        "msg": "Error while try to parse targetConfig. Please check your Config JSON. Standard Config will be used.",
                        "err": e,
                        "targetConfig": targetConfig
                    });
                }
            } else {
                tmpJSON = $.extend(true, {}, targetConfig);
            }
            /* try to merge with standard if any attribute is missing */
            try {
                finalConfig = $.extend(true, {}, srcConfig, tmpJSON);
            } catch (e) {
                finalConfig = $.extend(true, {}, srcConfig);
                util.debug.error({
                    "msg": "Error while try to merge 2 JSONs into standard JSON if any attribute is missing. Please check your Config JSON. Standard Config will be used.",
                    "err": e,
                    "finalConfig": finalConfig
                });
            }
            return finalConfig;
        },
        printDOMMessage: {
            show: function (id, text, icon, color) {
                var div = $("<div></div>")
                    .css("margin", "12px")
                    .css("text-align", "center")
                    .css("padding", "35px 0")
                    .addClass("dominfomessagediv");

                var subDiv = $("<div></div>");

                var subDivSpan = $("<span></span>")
                    .addClass("fa")
                    .addClass(icon || "fa-info-circle-o")
                    .addClass("fa-2x")
                    .css("height", "32px")
                    .css("width", "32px")
                    .css("color", "#D0D0D0")
                    .css("margin-bottom", "16px")
                    .css("color", color || "inhherit");

                subDiv.append(subDivSpan);

                var span = $("<span></span>")
                    .text(text)
                    .css("display", "block")
                    .css("color", "#707070")
                    .css("text-overflow", "ellipsis")
                    .css("overflow", "hidden")
                    .css("white-space", "nowrap")
                    .css("font-size", "12px");

                div
                    .append(subDiv)
                    .append(span);

                $(id).append(div);
            },
            hide: function (id) {
                $(id).children('.dominfomessagediv').remove();
            }
        },
        noDataMessage: {
            show: function (id, text) {
                util.printDOMMessage.show(id, text, "fa-search");
            },
            hide: function (id) {
                util.printDOMMessage.hide(id);
            }
        },
        errorMessage: {
            show: function (id, text) {
                util.printDOMMessage.show(id, text, "fa-exclamation-triangle", "#FFCB3D");
            },
            hide: function (id) {
                util.printDOMMessage.hide(id);
            }
        }
    };

    return {
        /* Initialize function for cards */
        initialize: function (parentID, ajaxID, noDataFoundMessage, errMessage, udConfigJSON, items2Submit, bindRefreshOnId, escapeRequired, sanitizeHTML, sanitizeOptions) {

            util.debug.info({
                "module": "initialize",
                "parentID": parentID,
                "ajaxID": ajaxID,
                "noDataFoundMessage": noDataFoundMessage,
                "udConfigJSON": udConfigJSON,
                "items2Submit": items2Submit,
                "bindRefreshOnId": bindRefreshOnId,
                "escapeRequired": escapeRequired,
                "sanitizeHTML": sanitizeHTML,
                "sanitizeOptions": sanitizeOptions
            });

            var stdConfigJSON = {
                "cardWidth": 4,
                "refresh": 0
            };

            /* this is the default json for purify js */
            var sanitizeConfigJSON;
            var stdSanatizerConfigJSON = {
                "ALLOWED_ATTR": ["accesskey", "align", "alt", "always", "autocomplete", "autoplay", "border", "cellpadding", "cellspacing", "charset", "class", "dir", "height", "href", "id", "lang", "name", "rel", "required", "src", "style", "summary", "tabindex", "target", "title", "type", "value", "width"],
                "ALLOWED_TAGS": ["a", "address", "b", "blockquote", "br", "caption", "code", "dd", "div", "dl", "dt", "em", "figcaption", "figure", "h1", "h2", "h3", "h4", "h5", "h6", "hr", "i", "img", "label", "li", "nl", "ol", "p", "pre", "s", "span", "strike", "strong", "sub", "sup", "table", "tbody", "td", "th", "thead", "tr", "u", "ul"]
            };

            if (sanitizeHTML !== false) {
                if (sanitizeOptions) {
                    sanitizeConfigJSON = util.jsonSaveExtend(stdSanatizerConfigJSON, sanitizeOptions);
                } else {
                    sanitizeConfigJSON = stdSanatizerConfigJSON;
                }
            }

            /* get parent */
            var parent = $("#" + parentID);

            if (parent.length > 0) {
                var configJSON = {};
                configJSON = util.jsonSaveExtend(stdConfigJSON, udConfigJSON);

                /* define container and add it to parent */
                var container = drawContainer(parent);

                /* get data and draw */
                getData();

                /* try to bind apex refreh event if "apex" exists */
                try {
                    apex.jQuery("#" + bindRefreshOnId).bind("apexrefresh", function () {
                        if (container.children("span").length == 0) {
                            getData();
                        }
                    });
                } catch (e) {
                    util.debug.info({
                        "module": "initialize",
                        "msg": "Can't bind refresh event on " + bindRefreshOnId + ". Apex is missing",
                        "err": e
                    });
                }

                /* Used to set a refresh via json configuration */
                if (configJSON.refresh > 0) {
                    setInterval(function () {
                        if (container.children("span").length == 0) {
                            getData();
                        }
                    }, configJSON.refresh * 1000);
                }
            } else {
                util.debug.info({
                    "module": "initialize",
                    "msg": "Can't find parentID: " + parentID
                });
            }

            /***********************************************************************
             **
             ** function to escape of sanitize html
             **
             ***********************************************************************/
            function escapeOrSanitizeHTML(pHTML) {
                /* escape html if escape is set */
                if (escapeRequired !== false) {
                    return util.escapeHTML(pHTML);
                } else {
                    /* if sanitizer is activated sanitize html */
                    if (sanitizeHTML !== false) {
                        return DOMPurify.sanitize(pHTML, sanitizeConfigJSON);
                    } else {
                        return pHTML;
                    }
                }
            }

            /************************************************************************
             **
             ** Used to draw the whole region
             **
             ***********************************************************************/
            function drawCardsRegion(cardDataJSON) {
                /* empty container for new stuff */
                container.empty();

                /* draw cards and add it to the container */
                if (cardDataJSON.row && cardDataJSON.row.length > 0) {
                    drawCards(cardDataJSON.row, configJSON);
                } else {
                    container.css("min-height", "");
                    util.noDataMessage.show(container, noDataFoundMessage);
                }
            }

            /***********************************************************************
             **
             ** Used to draw a container
             **
             ***********************************************************************/
            function drawContainer(parent) {
                var div = $("<div></div>");
                div.addClass("s-g-container");
                div.css("min-height", "170px");
                parent.append(div);
                return (div);
            }

            /***********************************************************************
             **
             ** Used to draw a row
             **
             ***********************************************************************/
            function drawRow(parent) {
                var div = $("<div></div>");
                div.addClass("s-g-row");
                parent.append(div);
                return (div);
            }

            /***********************************************************************
             **
             ** function to get data from Apex
             **
             ***********************************************************************/
            function getData() {
                if (util.isAPEX()) {
                    util.loader.start(container);

                    var submitItems = items2Submit;

                    apex.server.plugin(
                        ajaxID, {
                            pageItems: submitItems
                        }, {
                            success: drawCardsRegion,
                            error: function (d) {
                                container.empty();
                                util.errorMessage.show(container, errMessage);
                                util.debug.error({
                                    "module": "getData",
                                    "msg": "Error occured on calling AJAX",
                                    "d": d
                                });
                            },
                            dataType: "json"
                        });
                } else {
                    try {
                        util.loader.start(container);
                        drawCardsRegion(dataJSON);
                    } catch (e) {
                        util.debug.error({
                            "module": "getData",
                            "msg": "Need data json",
                            "err": e
                        });
                    }
                }
            }

            /***********************************************************************
             **
             ** Used to draw cards
             **
             ***********************************************************************/
            function drawCards(cardData, cardConfig) {
                /* check data and draw cards */
                if (cardData && cardData.length > 0) {
                    /* define row and add it to the container */
                    var row = drawRow(container);
                    var cardNum = 0;
                    $.each(cardData, function (index, objData) {
                        cardNum = cardNum + configJSON.cardWidth;

                        objData.CARD_TITLE = escapeOrSanitizeHTML(objData.CARD_TITLE);
                        objData.CARD_VALUE = escapeOrSanitizeHTML(objData.CARD_VALUE);
                        objData.CARD_FOOTER = escapeOrSanitizeHTML(objData.CARD_FOOTER);


                        if (objData.CARD_TYPE) {
                            if (objData.CARD_TYPE.toLowerCase() === "icon") {
                                drawSmallCard(index, row, objData, cardConfig);
                            } else {
                                drawLargeCard(index, row, objData, cardConfig, objData.CARD_CHART_CONFIG);
                            }
                        } else {
                            drawSmallCard(index, row, objData, cardConfig);
                        }
                        if (cardNum >= 12) {
                            row = drawRow(container);
                            cardNum = 0;
                        }
                    });
                }
            }

            /***********************************************************************
             **
             ** Used to generate color style if nothing is set
             **
             ***********************************************************************/
            function generateDefaultCardStyle(pIndex) {
                return "background: linear-gradient(60deg, hsl(" + (pIndex * 23) % 350 + ", 55%, 60%), hsl(" + (pIndex * 23) % 350 + ", 50%, 60%));box-shadow: 0 12px 20px -10px rgba(230, 230, 230, 0.28), 0 4px 20px 0px rgba(0, 0, 0, 0.12), 0 7px 8px -5px rgba(230, 230, 230, 0.2);";
            }

            /***********************************************************************
             **
             ** Used to draw the small cards
             **
             ***********************************************************************/
            function drawSmallCard(index, parent, cardData, cardConfig) {
                /* this html should be added to page */
                /*
                <div class="s-g-col-4">
                        <div class="at-card at-card-stats">
                            <div class="card-header" data-background-color="orange">
                                <i class="fa fa-gear"></i>
                            </div>
                            <div class="card-content">
                                <p class="category">My Title</p>
                                <h3 class="title">19%</h3>
                            </div>
                            <div class="card-footer">
                                <div class="stats">
                                    <i class="fa fa-gear"></i>This is a Material Card
                                </div>
                            </div>
                        </div>
                    </div>
                */

                /* define new column for rows */
                var col = $("<div></div>");
                col.addClass("s-g-col-" + cardConfig.cardWidth);

                /* define card */
                var card = $("<div></div>");
                card.addClass("at-card");
                card.addClass("at-card-stats");

                /* add icon to card header */
                if (util.isDefinedAndNotNull(cardData.CARD_ICON)) {
                    /* define card style when nothing is set */
                    var searchString = "fa-";
                    var cardHeader = $("<div></div>");
                    cardHeader.addClass("card-header");

                    if (util.isDefinedAndNotNull(cardData.CARD_HEADER_CLASS)) {
                        cardHeader.addClass(cardData.CARD_HEADER_CLASS);
                    }

                    var icon = $("<i></i>");

                    /* check if it should be an icon or a background image */
                    if (cardData.CARD_ICON && cardData.CARD_ICON.substr(0, searchString.length) === searchString) {
                        var iconColor = (util.isDefinedAndNotNull(cardData.CARD_ICON_COLOR)) ? cardData.CARD_ICON_COLOR : "white";

                        icon.addClass("fa");
                        icon.addClass(cardData.CARD_ICON);
                        icon.css("color", iconColor);

                        if (util.isDefinedAndNotNull(cardData.CARD_HEADER_STYLE)) {
                            /* set header style */
                            cardHeader.attr("style", cardData.CARD_HEADER_STYLE);
                        } else {
                            /* set header style default */
                            if (!util.isDefinedAndNotNull(cardData.CARD_HEADER_CLASS)) {
                                cardHeader.attr("style", generateDefaultCardStyle(index));
                            }
                        }
                    } else {
                        if (util.isDefinedAndNotNull(cardData.CARD_HEADER_STYLE)) {
                            cardHeader.attr("style", cardData.CARD_HEADER_STYLE);
                        }
                        cardHeader.css("background-image", "url(" + cardData.CARD_ICON + ")");
                    }

                    cardHeader.append(icon);
                    /* append header to cards */
                    card.append(cardHeader);
                }

                /* define card body */
                var cardBody = $("<div></div>");
                cardBody.addClass("card-content");

                /* add title to body */
                if (util.isDefinedAndNotNull(cardData.CARD_TITLE)) {
                    var title = $("<p></p>");
                    title.addClass("category");
                    title.html(cardData.CARD_TITLE);
                    cardBody.append(title);
                    cardHeader.css("padding", "15px");
                } else {
                    cardHeader.css("padding", "5px");
                }

                /* add value to body */
                var value = $("<h2></h2>");
                value.addClass("title");
                if (util.isDefinedAndNotNull(cardData.CARD_VALUE)) {
                    value.html(cardData.CARD_VALUE);
                }
                cardBody.append(value);

                /* append body to card */
                card.append(cardBody);

                /* define footer */
                var cardFooter = $("<div></div>");
                cardFooter.addClass("card-footer");

                /* define footer text */
                var cardFooterStats = $("<div></div>");

                if (cardData.CARD_FOOTER) {
                    cardFooterStats = $("<div></div>");
                    cardFooterStats.addClass("stats");
                    cardFooterStats.append(cardData.CARD_FOOTER);
                }

                /* add footer text to footer */
                cardFooter.append(cardFooterStats);

                /* add footer to card */
                card.append(cardFooter);

                /* add card to column */
                col.append(card);

                /* if link is set make the card clickable and add column to parent (rows) */
                if (cardData.CARD_LINK) {
                    var link = $("<a></a>");
                    link.attr("href", cardData.CARD_LINK);
                    link.append(col);
                    parent.append(link);
                } else {
                    parent.append(col);
                }
            }

            /***********************************************************************
             **
             ** Used to draw the large cards with chartist.js charts
             **
             ***********************************************************************/
            function drawLargeCard(index, parent, cardData, cardConfig, chartConfig) {

                /* this html should be added to page */
                /*  <div class="s-g-col-4">
                        <div class="at-card">
                            <div class="card-header card-chart" data-background-color="orange">
                                <div class="ct-chart" id="dailySalesChart"></div>
                            </div>
                            <div class="card-content">
                                <h4 class="title">My Title</h4>
                                <p class="category">This is my Material Card</p>
                            </div>
                            <div class="card-footer">
                                <div class="stats">
                                    Hello World!
                                </div>
                            </div>
                        </div>
                    </div>
                */

                var standardChartConfig = {
                    fullWidth: true,
                    chartPadding: {
                        bottom: -12,
                        top: 28,
                        right: 30,
                        left: -5
                    }
                };

                /* get chartConfig Json and parse it if needed */
                var chartConfigJSON = {}
                if (chartConfig && typeof chartConfig == "string") {
                    try {
                        chartConfigJSON = JSON.parse(chartConfig);
                    } catch (e) {
                        util.debug.error({
                            "module": "drawLargeCard",
                            "msg": "Error while try to parse CARD_CHART_CONFIG",
                            "err": e,
                            "chartConfig": chartConfig
                        });
                    }
                } else {
                    chartConfigJSON = chartConfig;
                }

                /* merge config to standard config if something is missing that's needed */
                $.extend(true, standardChartConfig, chartConfigJSON);


                /* define chart unique id */
                var chartID = "ct-chart-" + parentID + index;

                /* define column */
                var col = $("<div></div>");
                col.addClass("s-g-col-" + cardConfig.cardWidth);

                /* define card */
                var card = $("<div></div>");
                card.addClass("at-card");

                /* define header */
                var cardHeader = $("<div></div>");
                cardHeader.addClass("card-header");
                cardHeader.addClass("card-chart");

                if (util.isDefinedAndNotNull(cardData.CARD_HEADER_CLASS)) {
                    cardHeader.addClass(cardData.CARD_HEADER_CLASS);
                }

                if (util.isDefinedAndNotNull(cardData.CARD_HEADER_STYLE)) {
                    /* set header style */
                    cardHeader.attr("style", cardData.CARD_HEADER_STYLE);
                } else {
                    /* set header style default */
                    if (!util.isDefinedAndNotNull(cardData.CARD_HEADER_CLASS)) {
                        cardHeader.attr("style", generateDefaultCardStyle(index));
                    }
                }

                /* define chart */
                var chart = $("<div></div>");
                chart.addClass("ct-chart");
                chart.attr("id", chartID);

                /* append chart to card header */
                cardHeader.append(chart);

                /* append header to card */
                card.append(cardHeader);

                /* define card body */
                var cardBody = $("<div></div>");
                cardBody.addClass("card-content");

                /* add title to card body */
                var title = $("<p></p>")
                title.addClass("category");
                if (util.isDefinedAndNotNull(cardData.CARD_TITLE)) {
                    title.html(cardData.CARD_TITLE);
                }
                cardBody.append(title);

                /* add card value to body */
                var value = $("<h2></h2>");
                value.addClass("title");
                if (util.isDefinedAndNotNull(cardData.CARD_VALUE)) {
                    value.html(cardData.CARD_VALUE);
                } else {
                    value.html("-");
                }
                cardBody.append(value);

                /* append body to card */
                card.append(cardBody);

                /* define card footer */
                var cardFooter = $("<div></div>");
                cardFooter.addClass("card-footer");

                /* define footert text */
                var cardFooterStats = $("<div></div>");
                if (cardData.CARD_FOOTER) {
                    cardFooterStats = $("<div></div>");
                    cardFooterStats.addClass("stats");
                    cardFooterStats.append(cardData.CARD_FOOTER);
                }

                /* append footer text to footer */
                cardFooter.append(cardFooterStats);

                /* append footer to card */
                card.append(cardFooter);

                /* add card to column */
                col.append(card);

                /* if link is set make card clickable and add it to parent (rows) */
                if (cardData.CARD_LINK) {
                    var link = $("<a></a>");
                    link.attr("href", cardData.CARD_LINK);
                    link.append(col);
                    parent.append(link);
                } else {
                    parent.append(col);
                }

                /* draw chart */
                var chartIst;
                if (cardData.CARD_CHART_DATA) {

                    var chartData = {}

                    /* try to get chart data as json */
                    if (typeof cardData.CARD_CHART_DATA == "string") {
                        try {
                            chartData = JSON.parse(cardData.CARD_CHART_DATA);

                        } catch (e) {
                            util.debug.error({
                                "module": "drawLargeCard",
                                "msg": "Error while try to parse CARD_CHART_DATA",
                                "CARD_CHART_DATA": cardData.CARD_CHART_DATA
                            });
                        }
                    } else {
                        chartData = cardData.CARD_CHART_DATA;
                    }

                    /* draw chart with type that is set */
                    switch (cardData.CARD_TYPE.toLowerCase()) {
                        case "chart-line":
                            chartIst = new Chartist.Line("#" + chartID, chartData, standardChartConfig);
                            break;
                        case "chart-bar":
                            chartIst = new Chartist.Bar("#" + chartID, chartData, standardChartConfig);
                            break;
                        case "chart-pie":
                            standardChartConfig.chartPadding = {};
                            chartIst = new Chartist.Pie("#" + chartID, chartData, standardChartConfig);
                            break;
                        default:
                            util.debug.info({
                                "module": "drawLargeCard",
                                "msg": "No valid Chart type"
                            });
                    }

                    /* style chart */
                    var iconColor = (util.isDefinedAndNotNull(cardData.CARD_ICON_COLOR)) ? cardData.CARD_ICON_COLOR : "white";

                    chartIst.on("draw", function (context) {
                        var cardChartData = {};
                        if (cardData.CARD_CHART_DATA && typeof cardData.CARD_CHART_DATA == "string") {
                            try {
                                cardChartData = JSON.parse(cardData.CARD_CHART_DATA);
                            } catch (e) {
                                util.debug.error({
                                    "module": "drawLargeCard",
                                    "msg": "Error while try to parse CARD_CHART_CONFIG",
                                    "chartConfig": chartConfig
                                });
                            }
                        } else {
                            cardChartData = cardData.CARD_CHART_DATA;
                        }

                        if (cardChartData.colors) {
                            iconColor = cardChartData.colors[context.index] || cardChartData.colors[0];
                        }
                        if (context.type === "bar" || context.type === "line" || context.type === "point") {

                            if (standardChartConfig.strokeWidth) {
                                context.element.attr({
                                    style: "stroke:  " + iconColor + "; stroke-width:" + standardChartConfig.strokeWidth + "px;"
                                });
                            } else {
                                context.element.attr({
                                    style: "stroke:  " + iconColor
                                });
                            }
                        }

                        if (context.type === "slice") {
                            context.element.attr({
                                style: "fill: " + iconColor + "; fill-opacity: " + ((cardChartData.colors) ? 0.6 : (((context.index) % 10) + 2) / 10)
                            });
                        }

                        if (context.type === "area") {
                            context.element.attr({
                                style: "fill: " + iconColor + "; fill-opacity: " + (((context.index) % 10) + 2) / 10
                            });

                        }
                        if (standardChartConfig.donut === true) {

                            if (standardChartConfig.sliceWidth) {
                                $(chart).find(".ct-slice-donut").css("stroke-width", standardChartConfig.sliceWidth.toString() + "px");
                            }
                            context.element.attr({
                                style: "stroke-opacity: " + (((-context.index) % 10) + 10) / 10 + "; stroke:  " + iconColor
                            });
                            $(chart).find(".ct-label").css("stroke", "initial");
                            $(chart).find(".ct-label").css("fill", ((cardChartData.colors) ? "white" : iconColor));
                        }
                        $(chart).find(".ct-slice-pie").attr("stroke", ((cardChartData.colors) ? "rgba(0,0,0,0)" : iconColor));
                        $(chart).find(".ct-slice-donut").attr("stroke", iconColor);
                        $(chart).find(".ct-label").css("color", ((cardChartData.colors) ? "white" : iconColor));
                        $(chart).find(".ct-grid").css("stroke", ((cardChartData.colors) ? "white" : iconColor));
                        $(chart).find(".ct-grid").css("opacity", "0.4");
                    });
                }
            }
        }
    }
})();

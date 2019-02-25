var materialCards = (function () {
    "use strict";
    var scriptVersion = "1.2.5";
    var util = {
        version: "1.0.5",
        isAPEX: function () {
            if (typeof (apex) !== 'undefined') {
                return true;
            } else {
                return false;
            }
        },
        debug: {
            info: function (str) {
                if (util.isAPEX()) {
                    apex.debug.info(str);
                }
            },
            error: function (str) {
                if (util.isAPEX()) {
                    apex.debug.error(str);
                } else {
                    console.error(str);
                }
            }
        },
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
            start: function (id) {
                if (util.isAPEX()) {
                    apex.util.showSpinner($(id));
                } else {
                    /* define loader */
                    var faLoader = $("<span></span>");
                    faLoader.attr("id", "loader" + id);
                    faLoader.addClass("ct-loader");

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
            stop: function (id) {
                $(id + " > .u-Processing").remove();
                $(id + " > .ct-loader").remove();
            }
        },
        jsonSaveExtend: function (srcConfig, targetConfig) {
            var finalConfig = {};
            /* try to parse config json when string or just set */
            if (typeof targetConfig === 'string') {
                try {
                    targetConfig = JSON.parse(targetConfig);
                } catch (e) {
                    console.error("Error while try to parse targetConfig. Please check your Config JSON. Standard Config will be used.");
                    console.error(e);
                    console.error(targetConfig);
                }
            } else {
                finalConfig = targetConfig;
            }
            /* try to merge with standard if any attribute is missing */
            try {
                finalConfig = $.extend(true, srcConfig, targetConfig);
            } catch (e) {
                console.error('Error while try to merge 2 JSONs into standard JSON if any attribute is missing. Please check your Config JSON. Standard Config will be used.');
                console.error(e);
                finalConfig = srcConfig;
                console.error(finalConfig);
            }
            return finalConfig;
        },
        noDataMessage: {
            show: function (id, text) {
                var div = $("<div></div>")
                    .css("margin", "12px")
                    .css("text-align", "center")
                    .css("padding", "64px 0")
                    .addClass("nodatafoundmessage");

                var subDiv = $("<div></div>");

                var subDivSpan = $("<span></span>")
                    .addClass("fa")
                    .addClass("fa-search")
                    .addClass("fa-2x")
                    .css("height", "32px")
                    .css("width", "32px")
                    .css("color", "#D0D0D0")
                    .css("margin-bottom", "16px");

                subDiv.append(subDivSpan);

                var span = $("<span></span>")
                    .text(text)
                    .css("display", "block")
                    .css("color", "#707070")
                    .css("font-size", "12px");

                div
                    .append(subDiv)
                    .append(span);

                $(id).append(div);
            },
            hide: function (id) {
                $(id).children('.nodatafoundmessage').remove();
            }
        }
    };

    return {
        /* Initialize function for cards */
        initialize: function (
            parentID, ajaxID, noDataFoundMessage, udConfigJSON, items2Submit, bindRefreshOnId, escapeRequired) {
            var stdConfigJSON = {
                "cardWidth": 4,
                "refresh": 0
            };

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
                        if (container.children('span').length == 0) {
                            getData();
                        }
                    });
                } catch (e) {
                    console.log("Can't bind refresh event on " + bindRefreshOnId + ". Apex is missing");
                    console.log(e);
                }

                /* Used to set a refresh via json configuration */
                if (configJSON.refresh > 0) {
                    setInterval(function () {
                        if (container.children('span').length == 0) {
                            getData();
                        }
                    }, configJSON.refresh * 1000);
                }


            } else {
                console.log("Can't find parentID: " + parentID);
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
                div.css("min-height", "170px")
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
                if (ajaxID) {
                    util.loader.start(container);

                    var submitItems = items2Submit;

                    apex.server.plugin(
                        ajaxID, {
                            pageItems: submitItems
                        }, {
                            success: drawCardsRegion,
                            error: function (d) {
                                container.empty();
                                console.log(d.responseText);
                                //container.append("<span>Error occured please check console for more information</span>");
                            },
                            dataType: "json"
                        });
                } else {
                    try {
                        util.loader.start(container);
                        /* just wait 5 seconds to see loader */
                        setTimeout(function () {
                            drawCardsRegion(dataJSON);
                        }, 500);

                    } catch (e) {
                        console.log('need data json');
                        console.log(e);
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
                        if (escapeRequired !== false) {
                            objData.CARD_ICON = util.escapeHTML(objData.CARD_ICON);
                            objData.CARD_ICON_COLOR = util.escapeHTML(objData.CARD_ICON_COLOR);
                            objData.CARD_HEADER_STYLE = util.escapeHTML(objData.CARD_HEADER_STYLE);
                            objData.CARD_TITLE = util.escapeHTML(objData.CARD_TITLE);
                            objData.CARD_VALUE = util.escapeHTML(objData.CARD_VALUE);
                            objData.CARD_FOOTER = util.escapeHTML(objData.CARD_FOOTER);
                        }

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
             ** Used to draw the small cards
             **
             ***********************************************************************/
            function drawSmallCard(index, parent, cardData, cardConfig) {
                /* define card style when nothing is set */
                var cardStdStyle = 'background: linear-gradient(60deg, hsl(' + (index * 23) % 350 + ', 55%, 60%), hsl(' + (index * 23) % 350 + ', 50%, 60%));box-shadow: 0 12px 20px -10px rgba(230, 230, 230, 0.28), 0 4px 20px 0px rgba(0, 0, 0, 0.12), 0 7px 8px -5px rgba(230, 230, 230, 0.2);';

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
                card.addClass("at-card at-card-stats");

                /* define header for card */
                var cardHeader = $("<div></div>");
                cardHeader.addClass("card-header");

                /* add icon to card header */
                if (cardData.CARD_ICON) {
                    var icon = $("<i></i>");
                    icon.addClass("fa " + cardData.CARD_ICON);

                    var iconColor = (cardData.CARD_ICON_COLOR != undefined && cardData.CARD_ICON_COLOR.length > 0) ? cardData.CARD_ICON_COLOR : 'white';
                    icon.attr("style", "color:" + iconColor);

                    cardHeader.append(icon);
                }

                /* add header styles */
                cardHeader.attr("style", cardData.CARD_HEADER_STYLE || cardStdStyle);

                /* append header to cards */
                card.append(cardHeader);

                /* define card body */
                var cardBody = $("<div></div>");
                cardBody.addClass("card-content");

                /* add title to body */
                var title = (cardData.CARD_TITLE != undefined) ? cardData.CARD_TITLE : '';
                cardBody.append('<p class="category">' + title + '</p>');

                /* add value to body */
                var value = (cardData.CARD_VALUE != undefined) ? cardData.CARD_VALUE : '';
                cardBody.append('<h2 class="title">' + value + '</h2>');

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
                /* define card style when nothing is set */
                var cardStdStyle = 'background: linear-gradient(60deg, hsl(' + (index * 23) % 350 + ', 55%, 60%), hsl(' + (index * 23) % 350 + ', 50%, 60%));box-shadow: 0 12px 20px -10px rgba(230, 230, 230, 0.28), 0 4px 20px 0px rgba(0, 0, 0, 0.12), 0 7px 8px -5px rgba(230, 230, 230, 0.2);';

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
                if (chartConfig && typeof chartConfig == 'string') {
                    try {
                        chartConfigJSON = JSON.parse(chartConfig);

                    } catch (e) {
                        console.log("Error while try to parse CARD_CHART_CONFIG: " + e + chartConfig);
                    }
                } else {
                    chartConfigJSON = chartConfig;
                }

                /* merge config to standard config if something is missing that'S needed */
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
                cardHeader.addClass("card-header card-chart");

                /* set header style */
                cardHeader.attr("style", cardData.CARD_HEADER_STYLE || cardStdStyle);

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
                var title = (cardData.CARD_TITLE != undefined && cardData.CARD_TITLE.length > 0) ? cardData.CARD_TITLE : '';
                cardBody.append('<p class="category">' + title + '</p>');

                /* add card value to body */
                var value = (cardData.CARD_VALUE != undefined && cardData.CARD_VALUE.length > 0) ? cardData.CARD_VALUE : '-';
                cardBody.append('<h2 class="title">' + value + '</h2>');

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
                    if (typeof cardData.CARD_CHART_DATA == 'string') {
                        try {
                            chartData = JSON.parse(cardData.CARD_CHART_DATA);

                        } catch (e) {
                            console.log("Error while try to parse CARD_CHART_DATA");
                            console.log(e);
                            console.log(cardData.CARD_CHART_DATA);
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
                            console.log("No valid Chart type");
                    }

                    /* style chart */
                    var iconColor = (cardData.CARD_ICON_COLOR != undefined && cardData.CARD_ICON_COLOR.length > 0) ? cardData.CARD_ICON_COLOR : 'white';

                    chartIst.on('draw', function (context) {
                        var cardChartData = {};
                        if (cardData.CARD_CHART_DATA && typeof cardData.CARD_CHART_DATA == 'string') {
                            try {
                                cardChartData = JSON.parse(cardData.CARD_CHART_DATA);

                            } catch (e) {
                                console.log("Error while try to parse CARD_CHART_CONFIG: " + e + chartConfig);
                            }
                        } else {
                            cardChartData = cardData.CARD_CHART_DATA;
                        }

                        if (cardChartData.colors) {
                            iconColor = cardChartData.colors[context.index] || cardChartData.colors[0];
                        }
                        if (context.type === 'bar' || context.type === 'line' || context.type === 'point') {

                            if (standardChartConfig.strokeWidth) {
                                context.element.attr({
                                    style: 'stroke:  ' + iconColor + '; stroke-width:' + standardChartConfig.strokeWidth + 'px;'
                                });
                            } else {
                                context.element.attr({
                                    style: 'stroke:  ' + iconColor
                                });
                            }
                        }

                        if (context.type === 'slice') {
                            context.element.attr({
                                //style: 'fill: hsl(' + context.index * 20 % 350 + ', 50%, 60%)'
                                style: 'fill: ' + iconColor + '; fill-opacity: ' + ((cardChartData.colors) ? 0.6 : (((context.index) % 10) + 2) / 10)
                            });
                        }

                        if (context.type === 'area') {
                            context.element.attr({
                                //style: 'fill: hsl(' + context.index * 20 % 350 + ', 50%, 60%)'
                                style: 'fill: ' + iconColor + '; fill-opacity: ' + (((context.index) % 10) + 2) / 10
                            });

                        }
                        if (standardChartConfig.donut === true) {

                            if (standardChartConfig.sliceWidth) {
                                $(chart).find(".ct-slice-donut").css("stroke-width", standardChartConfig.sliceWidth.toString() + "px");
                            }
                            context.element.attr({
                                style: 'stroke-opacity: ' + (((-context.index) % 10) + 10) / 10 + '; stroke:  ' + iconColor
                            });
                            $(chart).find(".ct-label").css("stroke", 'initial');
                            $(chart).find(".ct-label").css("fill", ((cardChartData.colors) ? "white" : iconColor));
                        }
                        $(chart).find(".ct-slice-pie").attr("stroke", ((cardChartData.colors) ? "rgba(0,0,0,0)" : iconColor));
                        $(chart).find(".ct-slice-donut").attr("stroke", iconColor);
                        $(chart).find(".ct-label").css("color", ((cardChartData.colors) ? "white" : iconColor));
                        $(chart).find(".ct-grid").css("stroke", ((cardChartData.colors) ? "white" : iconColor));
                        $(chart).find(".ct-grid").css("opacity", ".4");
                    });
                }
            }
        }
    }
})();

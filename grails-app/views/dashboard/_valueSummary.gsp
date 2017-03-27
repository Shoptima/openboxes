<div class="box">
    <h2>
        <warehouse:message code="inventory.value.label" default="Stock Value Summary"/>
        <%--
        <g:remoteLink controller="json" action="refreshTotalStockValue" onSuccess="refresh();" onFailure="showError();">
            <img src="${resource(dir:'images/icons/silk',file:'arrow_refresh_small.png')}" alt="Refresh" style="vertical-align: middle" /></g:remoteLink>
        --%>
    </h2>
    <div class="widget-content" style="padding:0; margin:0">
        <div id="alertSummary">

            <table class="zebra">
                <thead>
                    <tr class="prop odd">
                        <td colspan="3">
                            <div class="fade lastUpdated"><img class="spinner" src="${resource(dir:'images/spinner.gif')}" class="middle"/></div>
                        </td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <img src="${resource(dir:'images/icons/silk/sum.png')}" class="middle"/>
                        </td>
                        <td>
                            <div># of products with pricing information</div>
                        </td>
                        <td>
                            <div id="progressSummary" class="right">
                                <img class="spinner" src="${resource(dir:'images/spinner.gif')}" class="middle"/>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <img src="${resource(dir:'images/icons/silk/chart_pie.png')}" class="middle"/>
                        </td>
                        <td>
                            <div>Percentage of products with pricing information</div>
                        </td>
                        <td>
                            <div id="progressPercentage" class="right">
                                <img class="spinner" src="${resource(dir:'images/spinner.gif')}" class="middle"/>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="center" style="width: 1%">
                            <img src="${resource(dir:'images/icons/silk/money.png')}" class="middle"/>
                        </td>
                        <td>
                            <warehouse:message code="inventory.totalStockValue.label" default="Total value of inventory"/>
                        </td>
                        <td class="right">
                            <div id="totalStockValue">
                                <img class="spinner" src="${resource(dir:'images/spinner.gif')}" class="middle"/>
                            </div>
                        </td>
                    </tr>
                <%--
                    <tr>
                        <td colspan="3">
                            <div id="progressbar"></div>
                        </td>
                    </tr>
                    --%>
                </tbody>
                <tfoot>
                    <tr class="odd">
                        <td colspan="3">
                            <span id="totalStockSummary" class="fade"></span>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
</div>
<div class="box">
    <h2>
        <warehouse:message code="inventory.stockValueDetails.label" default="Stock Value Details"/>
        <g:remoteLink controller="json" action="refreshTotalStockValue" onSuccess="refresh();" onFailure="showError();">
            <img src="${resource(dir:'images/icons/silk',file:'arrow_refresh_small.png')}" alt="Refresh" style="vertical-align: middle" /></g:remoteLink>

    </h2>
    <div class="widget-content" style="padding:0; margin:0">
        <table id="stockValueDetailsTable">
            <thead>
            <th>Code</th>
            <th>Product</th>
            <%--<th>Unit Price</th>--%>
            <th>Value (${grailsApplication.config.openboxes.locale.defaultCurrencyCode})</th>
            </thead>
            <tbody>

            </tbody>
        </table>
    </div>
</div>


<script type="text/javascript">

    $(window).load(function(){
        //$( "#progressbar" ).progressbar({ value: 0 });
        //$( "#progressPercentage").html('')
        loadData();
        loadTableData();
    });

    function refresh() {
        loadData();
        //loadTableData();
        $('#stockValueDetailsTable').dataTable().ajax.reload();
    }

    function formatPercentage(x) {
        if (x) {
            return x.toFixed(0) + "%"
        }
        else {
            return 0 + "%"
        }
    }

    function formatCurrency(x) {
        return "$" + x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    function showError() {
        $("#errorMessage").append("There was an error.").toggle();
    }

    function loadData() {
        $.ajax({
            dataType: "json",
            timeout: 120000,
            url: "${request.contextPath}/json/getTotalStockValue?location.id=${session.warehouse.id}",
            //data: data,
            success: function (data) {
                console.log("updating total stock value", data);
                var value = data.totalStockValue?formatCurrency(data.totalStockValue.toFixed(0)):0;
                var progress = data.hitCount / data.totalCount
                var progressSummary = data.hitCount + " out of " + data.totalCount;
                var progressPercentage = progress*100;
                var lastUpdated = data.lastUpdated;
                if (lastUpdated) {
                    $(".lastUpdated").html(lastUpdated);
                }
                else {
                    $(".lastUpdated").html("<div class='error'>An unexpected error occurred while loading data</div>")
                }

                $('#totalStockValue').html(value);

                if (progress < 1.0) {
                    $("#totalStockSummary").html("* Pricing data is available for less " + progressPercentage  + "% of all products");
                }
                else {
                    $("#totalStockSummary").html("* Pricing data is available for all products");
                }
                $('#progressSummary').html(progressSummary);
                $( "#progressbar" ).progressbar({ value: progressPercentage });
                $( "#progressPercentage").html("<span title='" + progressSummary + "'>" + formatPercentage(progressPercentage) + "</span>");

            },
            error: function(xhr, status, error) {
                //console.log(xhr);
                //console.log(status);
                //console.log(error);
                $('#totalStockValue').html('ERROR');
                $("#totalStockSummary").html('Unable to calculate total value due to error: ' + error + " " + status + " " + xhr);
            }
        });
    }

    function loadTableData() {

        var dataTable = $('#stockValueDetailsTable').dataTable({
            "bProcessing": true,
            "sServerMethod": "GET",
            "iDisplayLength": 5,
            "bSearch": false,
            "bScrollCollapse": true,
            "bJQueryUI": true,
            "bAutoWidth": true,
            "sPaginationType": "two_button",
            "sAjaxSource": "${request.contextPath}/json/getStockValueByProduct",
            "fnServerParams": function (data) {
                //console.log("server data " + data);
                //var locationId = $("#locationId").val();
                //var date = $("#date").val();
                //data.push({ name: "location.id", value: locationId });
                //data.push({ name: "date", value: date })
            },
            "fnServerData": function (sSource, aoData, fnCallback) {
                $.ajax({
                    "dataType": 'json',
                    "type": "GET",
                    "url": sSource,
                    "data": aoData,
                    "success": fnCallback,
                    "timeout": 120000,   // optional if you want to handle timeouts (which you should)
                    "error": handleAjaxError // this sets up jQuery to give me errors
                });
            },
//            "fnServerData": function ( sSource, aoData, fnCallback ) {
//                $.getJSON( sSource, aoData, function (json) {
//                    console.log(json);
//                    fnCallback(json);
//                });
//            },
            "oLanguage": {
                "sZeroRecords": "No records found",
                "sProcessing": "<img alt='spinner' src='${request.contextPath}/images/spinner.gif' /> Loading... "
            },
            //"fnInitComplete": fnInitComplete,
            //"iDisplayLength" : -1,
            "aLengthMenu": [
                [5, 10, 25, 100, 1000, -1],
                [5, 10, 25, 100, 1000, "All"]
            ],
            "aoColumns": [

                //{ "mData": "id", "bVisible":false }, // 0
                //{"mData": "rank", "sWidth": "1%"}, // 1
                {"mData": "productCode", "sWidth": "1%"}, // 2
                {"mData": "productName"}, // 3
                //{"mData": "unitPrice"}, // 4
                {"mData": "totalValue", "sWidth": "5%", "sType": 'numeric'} // 5
                //

            ],
            "bUseRendered": false,
            "aaSorting": [[2, "desc"]],
            "fnRowCallback": function (nRow, aData, iDisplayIndex) {
                //console.log(nRow);
                //console.log(aData);
                //console.log(iDisplayIndex);

                $('td:eq(1)', nRow).html('<a href="${request.contextPath}/inventoryItem/showStockCard/' + aData["id"] + '">' +
                        aData["productName"] + '</a>');
                return nRow;
            }

        });
    }

    function handleAjaxError( xhr, status, error ) {
        if ( status === 'timeout' ) {
            alert( 'The server took too long to send the data.' );
        }
        else {
            // User probably refreshed page or clicked on a link, so this isn't really an error
            if(xhr.readyState == 0 || xhr.status == 0) {
                return;
            }

            if (xhr.responseText) {
                var error = eval("(" + xhr.responseText + ")");
                alert("An error occurred on the server.  Please contact your system administrator.\n\n" + error.errorMessage);
            } else {
                alert('An unknown error occurred on the server.  Please contact your system administrator.');
            }
        }
        console.log(dataTable);
        dataTable.fnProcessingDisplay( false );
    }

</script>


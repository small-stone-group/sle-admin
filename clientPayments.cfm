<!DOCTYPE html>
<html>
<head>
<title>Customer Payments</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>
<script src="scripts/main.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: false});
	});
</script>
<script type="text/javascript" src="scripts/checkDates.js"></script>
<script type="text/javascript">
		var toggle=false;
		function LoadLettersList() {
			$.ajax({
				type: 'POST',
				url: 'clientPaymentsLetterList.cfm',
				data: {"userID":$('#clientRef').val()},
				success:function(data){
					$('#lettersload').html(data);
				}
			});
		}
		function CheckClient() {
			$('#searchMsg').fadeOut();
			$('#clientResult').fadeIn();
			var dateFrom = $('#srchDateFrom').val()
			var clientRef=document.getElementById('clientRef').value;
			var allTrans=document.getElementById('allTrans').checked;
			$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading transactions...").fadeIn();
			$('#clientResult').load('checkClient.cfm?clientRef='+clientRef+'&allTrans='+allTrans+'&dateFrom='+dateFrom, function (response, status, xhr) {
				$('#loadingDiv').html("").fadeOut();
				if (response.indexOf('Reference') == -1) {
					var msg=$.trim($("#clientResult").text());
				//	alert(msg);
				//	$('#clientRef').focus(); let cursor go elsewhere
					$('#pay').fadeOut();
				} else {
				//	$('#trnRef').focus();
					$('#pay').fadeIn();
				}
			});
			$('#cltDetailsLink').attr("href", "clientDetails.cfm?row=0&ref="+clientRef).fadeIn();
			LoadLettersList();
		}
		function NextClient(direction) {
			$('#pay').fadeOut();
			$('#clientResult').fadeOut();
			var clientRef=document.getElementById('clientRef').value;
			var allTrans=document.getElementById('allTrans').checked;
			$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading transactions...").fadeIn();
			$('#clientResult').load('checkClient.cfm?clientRef='+clientRef+'&allTrans='+allTrans+'&'+direction+'=true', function (response, status, xhr) {
				var key=$('#clientKey').html();
				document.getElementById('clientRef').value=key;
				$('#loadingDiv').html("").fadeOut();
				$('#trnRef').focus();
				$('#pay').fadeIn();
				$('#clientResult').fadeIn();
			});
		}
		function checkTotal(formname) {
			var payTotal=0;
			var payAmnt=0;
			var maxLines=document.getElementById('tranCount').value;
			for (var c=1;c<=maxLines;c++) {
				if (eval("document.forms."+formname+".tick"+c+".checked")) {
					payAmnt=(eval("document.forms."+formname+".amnt"+c+".value"));
					payAmnt=Math.round(payAmnt*100); // force as clean integers or summation will float
					payTotal=payTotal+payAmnt;
				}
			}
			payTotal=payTotal/100; // convert back to decimal
			document.forms[formname].Total.value=payTotal.toFixed(2); 
		}
		function getSelectedButton(buttonGroup)	{
			for (var i=0; i<buttonGroup.length; i++)	{
				if (buttonGroup[i].checked)	{
					return i;
				}
			}
			return 0;
		}
	//	function checkall(formname,thestate)	{
	//		var maxLines=document.getElementById('tranCount').value;
	//		for (var c=1;c<=maxLines;c++)	{
	//			document.getElementById("tick"+c).checked=thestate;
	//		}
	//		toggle=!toggle;	
	//		
	//		checkTotal(formname);
	//	}
	
		function checkForm(form)	{
		//	if (!checkField(form.payAmnt1,"Amount received")) {return false;}
			if (!checkDateFormat(form.trnDate.value))	{
				alert("Transaction Date is incorrectly formatted");
				return false;
			}
			if (form.clientRef.length < 1) {
				alert("Please select a client first");
				form.clientRef.focus();
				return false;
			}
			if (document.getElementById('Total')) {
				var bType=getSelectedButton(form.trnType);
				if (form.trnType[bType].value == "pay")	{
					if (document.getElementById('btnClicked').value == "btnSavePayment") {
						if (Number(form.trnAmnt1.value) > 99999)	{
							alert("Transaction Amount entered is too high");
							return false;	
						}
						if (Number(form.trnAmnt2.value) > 99999)	{
							alert("Settlement Discount entered is too high");
							return false;	
						}
						if (Number(form.trnAmnt1.value)+Number(form.trnAmnt2.value) == 0) {
							alert("Please enter an amount in either the Net Amount or Discount field.");
							return false;		
						}
						if ($('#trnMethod').val() == "") {
							alert("Please select the payment method");
							return false;							
						}
					}
					if ((Number(form.trnAmnt1.value)+Number(form.trnAmnt2.value) != Number(form.Total.value)) && document.getElementById("Total").value != 0)	{
						alert("Net Amount does not equal the allocated balance.");
						return false;
					}
				}
			} else {
				alert("please select a client first");
				form.clientRef.focus();
				return false;
			}
			return true
		}
	$(document).ready(function() {
		$('#trnDate').blur(function(event) {
			var dateChecked=checkDate($('#trnDate').val(),false);
			if (!dateChecked) {
				alert('Date is out of range')
				setTimeout(function() {
					$('#trnDate').focus();
				}, 0);
			} else {
				$('#trnDate').val(dateChecked)			
			}
		});
		$('#crnDate').blur(function(event) {
			var dateChecked=checkDate($('#crnDate').val(),false);
			if (!dateChecked) {
				alert('Date is out of range')
				setTimeout(function() {
					$('#crnDate').focus();
				}, 0);
			} else {
				$('#crnDate').val(dateChecked)			
			}
		});
		$('#letter').click(function () {
			var clientRef=document.getElementById('clientRef').value;
			window.open("clientLetter.cfm?clientRef="+clientRef, '_blank');
			return false;
		});
		$(":submit").click(function () { $("#btnClicked").val(this.name);});
		$("#payForm").submit(function(e) {
			if (checkForm(this)) {
				$.ajax({
					type: 'POST',
					url: 'clientPaymentPost.cfm',
					data : $("#payForm").serialize(),
					beforeSend:function(){
						$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...").fadeIn();
					},
					success:function(data){
						var clientRef=$('#clientRef').val();
						$('#loadingDiv').html("").fadeOut();
						$('#payForm')[0].reset();
						$('#clientRef').val(clientRef);
						$('#clientRef').focus();
						$('#payResult').html(data);
						CheckClient();
					},
					error:function(data){
						$('#loadingDiv').html(data).fadeIn();
					}
				});
			}
			e.preventDefault();
		})
		$('#tabs').tabs();
		$('#btnSaveCredit').click(function(e) {
			$.ajax({
				type: 'POST',
				url: 'clientPaymentPostCredit.cfm',
				data : $('#payForm').serialize(),
				beforeSend:function(){
					$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...").fadeIn();
				},
				success:function(data){
					$('#loadingDiv').fadeOut();
					CheckClient();
				}
			});
			e.preventDefault();
		});
		
		$('.orderOverlayClose').click(function(e) {
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			e.preventDefault();
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	});
</script>
<cfif StructKeyExists(URL,"rec")>
	<script type="text/javascript">
		$(document).ready(function() {
			$('#clientRef').focus();
			CheckClient();
		});
	</script>
</cfif>

<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.datasource = application.site.datasource1>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div id="orderOverlay-ui"></div>
					<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<div id="print-area" style="padding:10px;width:700px;">
					<div id="LoadPrint" style="display:none;"></div>
				</div>
				<div class="form-wrap">
					<form name="payForm" id="payForm" method="post"><!--- onSubmit="return checkForm(this)"--->
						<div class="form-header">
							Customer Payments
						</div>
						<input type="hidden" size="10" name="btnClicked" id="btnClicked" />
						<div class="form-bar">
							<a href="" id="cltDetailsLink" style="float:right;display:none;" class="button" target="_blank">Client Details</a>
							<div id="loadingDiv"></div>
							<table cellpadding="0" cellspacing="0">
								<tr>
									<td width="120">Client Reference</td>
									<td>
										<input type="text" class="inputfield" name="clientRef" id="clientRef"
											value="<cfif StructKeyExists(URL,"rec")>#val(url.rec)#</cfif>" size="40" maxlength="20" onBlur="CheckClient()" />
										<label style="padding:0 0 0 10px;"><input type="checkbox" name="allTrans" id="allTrans" onClick="CheckClient()" />
											&nbsp;All transactions from: </label>
											<input type="text" name="srchDateFrom" id="srchDateFrom" value="" size="15" class="datepicker" onChange="CheckClient()" />
									</td>
								</tr>
							</table>
						</div>
						<div id="searchMsg" style="display:block;">Enter a client reference number</div>
						<div class="form-box" id="pay" style="display:none;">
							<div id="tabs">
								<ul>
									<li><a href="##Payment">Payment</a></li>
									<li><a href="##Credit">Credit</a></li>
								</ul>
								<div id="Payment">
									<div class="form-col1">
										<table cellpadding="2" cellspacing="0">
											<tr>
												<td align="right" width="100">Pay Reference</td>
												<td>
													<input type="text" class="inputfield" name="trnRef" id="trnRef" value="" size="20" maxlength="20" />
												</td>
											</tr>
											<tr>
												<td align="right">Date Received</td>
												<td>
													<input type="text" class="inputfield" name="trnDate" id="trnDate" value="" size="20" />
												</td>
											</tr>
											<tr>
												<td align="right" valign="top">Payment Method</td>
												<td>
													<select name="trnMethod" id="trnMethod">
														<option value="">Select...</option>
														<option value="cash" title="cash taken via shop till">Cash in Shop</option>
														<option value="chqs" title="cheque taken via the shop">Cheque in Shop</option>
														<option value="card" title="chip & pin card transaction">Card in Shop</option>
														<option disabled>-----------------</option>
														<option value="coll" title="money collected by drivers">Cash Collected</option>
														<option value="chq" title="cheque collected or posted">Cheque</option>
														<option value="chqx" title="cheque returned from bank">Returned Cheque</option>
														<option disabled>-----------------</option>
														<option value="phone" title="card payment taken over the phone">Card by Phone</option>
														<option value="ib" title="direct payment from customer">Internet Banking</option>
														<option value="acct" title="money held on account in till">Shop Credit Account</option>
														<option disabled>-----------------</option>
														<option value="dv" title="money off vouchers">Discount Voucher</option>
														<option value="cdv" title="don't know">Collected Voucher</option>
														<option disabled>-----------------</option>
														<option value="cp" title="for cornwall council payments only">Council Payments</option>
														<option value="na" title="for journals only">Not Applicable</option>
														<!---<option value="qs">Paid via Quickstop</option>--->
													</select><br>
												</td>
											</tr>
											<tr>
												<td align="right">Description</td>
												<td>
													<input type="text" class="inputfield" name="trnDesc" id="trnDesc" value="" size="40" maxlength="80" />
												</td>
											</tr>
										</table>
									</div>
									<div class="form-col2">
										<table cellpadding="2" cellspacing="0">
											<tr>
												<td align="right">Net Amount</td>
												<td>
													<input type="text" class="inputfield" name="trnAmnt1" id="trnAmnt1" value="" size="20" maxlength="20" />
												</td>
											</tr>
											<tr>
												<td align="right">Discount</td>
												<td>
													<input type="text" class="inputfield" name="trnAmnt2" id="trnAmnt2" value="" size="20" maxlength="20" />
												</td>
											</tr>
											<tr>
												<td align="right">Type</td>
												<td>
													<input type="radio" class="inputfield" name="trnType" id="trnTypepay" value="pay" checked="checked" /> Payment
													<input type="radio" class="inputfield" name="trnType" id="trnTypejnl" value="jnl" /> Journal
												</td>
											</tr>
										</table>
									</div>
									<div class="clear"></div>
									<div class="form-footer">
										<input type="submit" name="btnSaveAlloc" value="Save Allocation" />
										<input type="submit" name="btnSavePayment" value="Save Payment" />
										<button id="letter">Letter</button>
										<div class="clear"></div>
									</div>
								</div>
								<div id="Credit">
									<div class="form-col1">
										<table cellpadding="2" cellspacing="0">
											<tr>
												<td align="right" width="100">Pay Reference</td>
												<td>
													<input type="text" class="inputfield" name="crnRef" id="crnRef" value="" size="20" maxlength="20" />
												</td>
											</tr>
											<tr>
												<td align="right">Date Credited</td>
												<td>
													<input type="text" class="inputfield" name="crnDate" id="crnDate" value="" size="20" />
												</td>
											</tr>
											<tr>
												<td align="right" width="100">Description</td>
												<td>
													<input type="text" class="inputfield" name="crnDesc" id="crnDesc" value="" size="20" />
												</td>
											</tr>
										</table>
									</div>
									<div class="form-col2">
										<table cellpadding="2" cellspacing="0">
											<tr>
												<td align="right">Net Amount</td>
												<td>
													<input type="text" class="inputfield" name="crnAmnt1" id="crnAmnt1" value="" size="20" maxlength="20" />
												</td>
											</tr>
											<tr>
												<td align="right">VAT</td>
												<td>
													<input type="text" class="inputfield" name="crnAmnt2" id="crnAmnt2" value="" size="20" maxlength="20" />
												</td>
											</tr>
										</table>
									</div>
									<div class="clear"></div>
									<div class="form-footer">
										<input type="button" id="btnSaveCredit" value="Save Credit" />
										<div class="clear"></div>
									</div>
								</div>
							</div>
						</div>
						<div id="lettersload" class="module"></div>
						<div id="clientResult" class="module" style="display:none;"></div>
						<div id="payResult" class="module"></div>
					</form>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
</html>


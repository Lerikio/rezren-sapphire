// Datatables
$(document).ready( function () {
	$('#payments').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    null,
		    { "bSortable": false }
		]
	} );
} );
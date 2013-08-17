// Datatables
$(document).ready( function () {
	$('#switches').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    { "bSortable": false }
		]
	} );
} );
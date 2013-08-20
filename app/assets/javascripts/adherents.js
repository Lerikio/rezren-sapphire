// Datatables
$(document).ready( function () {
	$('#adherents').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	});
} );

// Datatables
$(document).ready( function () {
	$('#computers').dataTable( {
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
	} );
} );

$(document).ready( function () {
	$('#computers-adherent').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	} );
} );
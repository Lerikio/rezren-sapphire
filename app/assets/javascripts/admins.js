// Datatables
$(document).ready( function () {
	$('#admins').dataTable( {
		"sPaginationType": "full_numbers",
		"iDisplayLength": 50,
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	} );
	$('#admin_roles').select2();
} );


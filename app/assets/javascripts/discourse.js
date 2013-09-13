$(document).ready( function () {
	register_all_discourse();
} );

function register_all_discourse() {
	register_datatable_discourse();
	register_delete_buttons_discourse();
}

function register_datatable_discourse() {
	$('#discourse').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	});
}

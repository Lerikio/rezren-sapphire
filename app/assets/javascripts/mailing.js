// Datatables
$(document).ready( function () {
	register_all();
} );

function register_all() {
	register_datatable();
	register_delete_buttons();
}

function register_datatable() {
	$('#mailings').dataTable( {
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
}

function register_delete_buttons() {
	$('a.remote-delete').click(function() {
    	$.post(this.href, { _method: 'delete' }, null , "json").always(
  	  			function(data) { reload(); }
  		  	);
  	  return false;
  	});
}

function reload() {
	$('#wrapper').load('mailings/reload', function () {register_all();});
}

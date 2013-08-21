// Datatables
$(document).ready( function () {
	register_all_generic_dns_entries();
} );

function register_all_generic_dns_entries() {
	register_datatable_generic_dns_entries();
	register_delete_buttons_generic_dns_entries();
}

function register_datatable_generic_dns_entries() {
	$('#generic_dns_entries').dataTable( {
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

function register_delete_buttons_generic_dns_entries() {
	$('#generic_dns_entries a.remote-delete').click(function() {
		if (confirm("Êtes vous sûr de vouloir supprimer cette entrée DNS ?")) {
	    	$.post(this.href, { _method: 'delete' }, null , "json").always(
	  	  			function(data) { reload_generic_dns_entries(); }
	  		  	);
	    };
  	  return false;
  	});
}

function reload_generic_dns_entries() {
	$('#wrapper').load('generic_dns_entries/reload', function () {register_all_generic_dns_entries();});
}

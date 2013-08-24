$(document).ready( function () {
	register_all_switches();
} );

function register_all_switches() {
	register_datatable_switches();
	register_delete_buttons_switches();
}

function register_datatable_switches() {
	$('#switches').dataTable( {
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

function register_delete_buttons_switches() {
	$('#switches a.remote-delete').click(function() {
		if (confirm("Êtes vous sûr de vouloir supprimer ce switch ?")) {
	    	$.post(this.href, { _method: 'delete' }, null , "json").always(
	  	  			function(data) { reload_switches(); }
	  		  	);
	    };
  	  return false;
  	});
}

function reload_switches() {
	$('#wrapper').load('switches/reload', function () {register_all_switches();});
}

$(document).ready( function () {
	register_all_payments();
} );

function register_all_payments() {
	register_datatable_payments();
	register_delete_buttons_payments();
}

function register_datatable_payments() {
	$('#payments').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aaSorting": [[1, "desc" ]],
		"aoColumns": [
			{ "bSortable": false, "bSearchable": false },
			{ "sType": "title-numeric" },
			null,
		    null,
		    null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	} );
}

function register_delete_buttons_payments() {
	$('#payments a.remote-delete').click(function() {
		if (confirm("Êtes vous sûr de vouloir supprimer ce payement ?")) {
	    	$.post(this.href, { _method: 'delete' }, null , "json").always(
	  	  			function(data) { reload_mailings(); }
	  		  	);
	    }
  	  return false;
  	});
}

function reload_payments() {
	$('#wrapper').load('payments/reload', function () {register_all_payments();});
}

//Pour le tri par date
jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "title-numeric-pre": function ( a ) {
        var x = a.match(/title="*(-?[0-9\.]+)/)[1];
        return parseFloat( x );
    },
 
    "title-numeric-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },
 
    "title-numeric-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
} );
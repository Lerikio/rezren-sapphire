$(function () {
// Activation des tooltips de bootstrap
    $("[rel='tooltip']").tooltip();
<<<<<<< HEAD

// Utilisation des boutons dans les formulaires
    
    $('.collapse').collapse('hide');

    activate_button();

    $('.choosable').children().click(function(){
      choose_button();
    });


});


function activate_button() {
  $('.activable').children().click(function(){
    if ( $(this).hasClass('active') ){
      $(this).removeClass("btn-info active")
    } else {
      $(this).addClass("btn-info active");  
    };
    adherent_is_resident_or_supelec();
  });
};

function choose_button() {
  $(this).parent().children('.btn-info').addClass('disabled');
  $(this).parent().children('.btn-info').removeClass('btn-info');
  $(this).removeClass('disabled');
  $(this).addClass("btn-info");
};

function adherent_is_resident_or_supelec() {

  if( $("#resident-btn").hasClass("active")){
    console.log('1');
    $('#resident-check').attr('value', true);
    $('#resident-tab').attr('display', "");
    $('#resident').children().attr('disabled', false);
  } else {
    console.log('2');
    $('#resident-check').attr('value', false);
    $('#resident-tab').attr('display', "none");
    $('#resident').children().attr('disabled', true);
  };


  if( $("#supelec-btn").hasClass("active")){
    console.log('3');
    $('#supelec-check').attr('value', true);
    $('#supelec-tab').attr('display', "");
    $('#supelec').children().attr('disabled', false);
  } else {
    console.log('4');
    $('#supelec-check').attr('value', false);
    $('#supelec-tab').attr('display', "none");
    $('#supelec').children().attr('disabled', true);
  };

};
=======
});


//Traduction de DataTable
$.extend($.fn.dataTable.defaults.oLanguage, {
    "sProcessing":     "Traitement en cours...",
    "sSearch":         "Rechercher&nbsp;:",
    "sLengthMenu":     "Afficher _MENU_ &eacute;l&eacute;ments",
    "sInfo":           "Affichage des &eacute;lements _START_ &agrave; _END_ sur _TOTAL_ &eacute;l&eacute;ments",
    "sInfoEmpty":      "Affichage de l'&eacute;lement 0 &agrave; 0 sur 0 &eacute;l&eacute;ments",
    "sInfoFiltered":   "(filtr&eacute; de _MAX_ &eacute;l&eacute;ments au total)",
    "sInfoPostFix":    "",
    "sLoadingRecords": "Chargement en cours...",
    "sZeroRecords":    "Aucun &eacute;l&eacute;ment &agrave; afficher",
    "sEmptyTable":     "Aucune donnée disponible dans le tableau",
    "oPaginate": {
        "sFirst":      "Début",
        "sPrevious":   "Pr&eacute;c&eacute;dent",
        "sNext":       "Suivant",
        "sLast":       "Fin"
    },
    "oAria": {
        "sSortAscending":  ": activer pour trier la colonne par ordre croissant",
        "sSortDescending": ": activer pour trier la colonne par ordre décroissant"
    }
});

//Fermeture du modal lors de l'appui sur la touche échap
$(document).bind("keyup", null, function(e) { 
    if (e.keyCode == 27) {
        $('#modal-window').modal('hide');
    } 
});
>>>>>>> 6d299dfb9b0a4c3197311b60d44d613cd23cfd8f

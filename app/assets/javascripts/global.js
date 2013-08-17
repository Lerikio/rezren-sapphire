$(function () {
// Activation des tooltips de bootstrap
    $("[rel='tooltip']").tooltip();

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
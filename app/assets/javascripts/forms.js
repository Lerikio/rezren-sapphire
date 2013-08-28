


// Functions
function init_buttons() {
    if ($('#adherent_resident').attr('value')=="true") {
      $("#resident-btn").addClass("btn-info active");
    }
    if ($('#adherent_supelec').attr('value')=="true") {
      $("#supelec-btn").addClass("btn-info active");
    }
    if ($('#adherent_rezoman').attr('value')=="true") {
      $("#rezoman-btn").addClass("btn-info active");
    }
}

function activate_button() {
  $('.activable').children().click(function(){
    if ( $(this).hasClass('active') ){
      $(this).removeClass("btn-info active")
    } else {
      $(this).addClass("btn-info active");  
    };
    adherent_is_resident_supelec_rezoman();
    return false;
  });
};

function choose_button() {
  $('.choosable').children().click(function(){
    if ( $(this).hasClass('active') ){
      // do nothing
    } else {
      $('.choosable').children().removeClass("btn-info active")
      $(this).addClass("btn-info active");
    };
    payment_is_cheque_or_liquid();
    return false;
  });
};

function use_supelec_mail_button() {
  $('#supelec-mail-button').click(function(){
    if ( $(this).hasClass('active') ){
      $('#supelec-mail-check').val(false);
      $(this).removeClass("btn-info active");
    } else {
      $('#supelec-mail-check').val(true);
      $(this).addClass("btn-info active");
    };
    return false;
  });
}

function adherent_is_resident_supelec_rezoman() {

  if( $("#resident-btn").hasClass("active")){
    $('#adherent_resident').attr('value', true);
    $('#resident-tab').show();
    $('#resident').children().show();
  } else {
    $('#adherent_resident').attr('value', false);
    $('#resident-tab').hide();
    $('#resident').children().hide();
  };


  if( $("#supelec-btn").hasClass("active")){
    $('#adherent_supelec').attr('value', true);
    $('#supelec-tab').show();
    $('#supelec').children().show();
  } else {
    $('#adherent_supelec').attr('value', false);
    $('#supelec-tab').hide();
    $('#supelec').children().hide();
  };

  if( $("#rezoman-btn").hasClass("active")){
    $('#adherent_rezoman').attr('value', true);
  } else {
    $('#adherent_rezoman').attr('value', false);
  };
};

function payment_is_cheque_or_liquid(){

  var $field = $('#bank');
  var $input = $('#bank :input');

  if( $("#cheque-btn").hasClass("active")){
    $('#mean').val("cheque");
    $field.animate({opacity: 1}, 200);
    $input.removeAttr('disabled');

  } else {
    $('#mean').val("liquid");
    $field.animate({opacity: 0}, 200);
    setTimeout(function(){
      $input.delay(800).attr('disabled', true);
    });
  };
};
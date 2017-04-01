(function($){
  $(function(){
    // Set current year
    var currentDate = new Date();
    $('#credits-year').text( currentDate.getFullYear() );
  });
})(jQuery);
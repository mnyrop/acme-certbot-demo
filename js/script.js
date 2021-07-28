var protocol = location.protocol.trim();
$('#protocol-check').append("I'm loading over the <code>" + protocol + "</code> protocol");

$(document).on('click', '.notification > button.delete', function() {
  $(this).parent().addClass('is-hidden');
  return false;
});

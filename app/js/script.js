var protocol = location.protocol.trim();

$('#protocol-check').append("I'm currently loading over the <code>" + protocol + "</code> protocol");
if (protocol == 'https:') {
  $('#protocol-check').append("!!! 🎉🎉🎉<br>Try inspecting my SSL cert info near the URL bar.");
}
if (protocol == 'http:') {
  $('#protocol-check').append(".<br>Either I don't have working certs right now or HTTPS forced redirect is disabled.");
}

$(document).on('click', '.notification > button.delete', function() {
  $(this).parent().addClass('is-hidden');
  return false;
});

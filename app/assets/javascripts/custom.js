$(document).ready(function(){
    
    if ($('#use_billing_address').length) {
        $('#use_billing_address').on('click', use_billing_address);
        use_billing_address('#use_billing_address');
    }
    
    if ($('#card_number').length) {
        $('#card_number').mask('0000 0000 0000 0000');
    }
    if ($('#card_code').length) {
        $('#card_code').mask('000');
    }

    if ($('#remove_account').length) {
        $('#remove_account').on('click', function () {
            var form = $(this).parents('form');
            if (!$(this).parents('form').find('input[name=remove_account_confirm]').is(':checked')) {
                alert(form.find('.alert_message').text());
                return false;
            }
            return true;
        });
    }
    
}); // end ready
function use_billing_address(e) {
    var checkbox = (typeof e === 'string') ? $(e): $(this);
    $('#shipping_address').css('display', checkbox.is(':checked') ? 'none' : 'block');
};

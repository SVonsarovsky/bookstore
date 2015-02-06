$(document).ready(function(){
    
    if ($('#use_billing_address').length) {
        $('#use_billing_address').on('click', use_billing_address);
        use_billing_address('#use_billing_address');
    }
    
    if ($('#credit_card_number').length) {
        $('#credit_card_number').mask('0000 0000 0000 0000');
    }
    if ($('#credit_card_code').length) {
        $('#credit_card_code').mask('000');
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

    if ($('input[name="shipping_method_id"]').length) {
        $('input[name="shipping_method_id"]').on('click', select_shipping_method);
        select_shipping_method('input[name="shipping_method_id"]:checked');
    }


    
}); // end ready
function use_billing_address(e) {
    var checkbox = (typeof e === 'string') ? $(e): $(this);
    $('#shipping_address').css('display', checkbox.is(':checked') ? 'none' : 'block');
}
function select_shipping_method(e) {
    var current_radio = (typeof e === 'string') ? $(e): $(this);
    var items_total = 100*parseFloat($('#checkout_items_total').text())/100;
    var shipping = 100*parseFloat($('input[name='+current_radio.attr('id')+']').val())/100;
    $('input[name="shipping_cost"]').val(shipping);
    $('#checkout_shipping').text(shipping);
    $('#checkout_order_total').text(items_total+shipping);
}

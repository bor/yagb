function check_form(form,ar) {
    var msg;
    var f_name;
    var error = false;
    for ( var i=0; i<ar.length; i++ ) {
        f_name = ar[i];
        if ( !form.elements[ar[i]].value ) {
            error = true;
            msg = 'Fill required fields.';
            break;
        }
        if ( form.elements[ar[i]].name == 'email' ) {
            if ( ! validate_email(form.elements[ar[i]].value) ) {
                error = true;
                msg = 'Please insert a valid email';
                break;
            }
        }
    }
    if ( error ) {
        form.elements[f_name].focus();
        alert(msg);
        return false;
    }
    return true;
}


function validate_email(email) {
    var email_regexp = /^.+@.+\..{2,3}$/;
    if ( email_regexp.test(email) ) { return true; }
    else { return false; }
}

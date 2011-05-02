// Copyright (c) 2007  Firas Kassem (phiras@gmail.com)
// Creative Commons Attribution 3.0 Unported License
// Password strength meter
// This jQuery plugin is written by Firas Kassem [2007.04.05] and modified by Amin Rajaee [2009.07.26]
// Firas Kassem  phiras.wordpress.com || phiras at gmail {dot} com
// Amin Rajaee  rajaee at gmail (dot) com

// for more information : http://phiras.wordpress.com/2007/04/08/password-strength-meter-a-jquery-plugin/
//Password strength meter by Firas I. Kassem is licensed under a Creative Commons Attribution 3.0 Unported License.


/*var shortPass = 'Too Short Password'*/
var badPass = 'Week: Use letters and numbers'
var goodPass = 'Medium: Use special charecters'
var strongPass = 'Strong Password'
var sameAsUsername = 'Password is the same as username.'


function passwordStrength(password,username) {
    score = 0

    //password < 4
	 if (password.length == 0 ) {
		$("#validation_result").css('color', "#D70000");
		return "Please enter the password"
	 }
   /* if (password.length < 4 ) {
		$("#validation_result").css('color', "#D70000");
		return shortPass
	 }*/

    //password == username
    if (password.toLowerCase() == username.toLowerCase()) return sameAsUsername

    //password length
    score += password.length * 4
    score += ( checkRepetition(1,password).length - password.length ) * 1
    score += ( checkRepetition(2,password).length - password.length ) * 1
    score += ( checkRepetition(3,password).length - password.length ) * 1
    score += ( checkRepetition(4,password).length - password.length ) * 1

    //password has 3 numbers
    if (password.match(/(.*[0-9].*[0-9].*[0-9])/))  score += 5

    //password has 2 sybols
    if (password.match(/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/)) score += 5

    //password has Upper and Lower chars
    if (password.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/))  score += 10

    //password has number and chars
    if (password.match(/([a-zA-Z])/) && password.match(/([0-9])/))  score += 15
    //
    //password has number and symbol
    if (password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([0-9])/))  score += 15

    //password has char and symbol
    if (password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([a-zA-Z])/))  score += 15

    //password is just a nubers or chars
    if (password.match(/^\w+$/) || password.match(/^\d+$/) )  score -= 10

    //verifing 0 < score < 100
    if ( score < 0 )  score = 0
    if ( score > 100 )  score = 100

    if (score < 34 )	{
		$("#validation_result").css('color', "#D70000");
		return badPass
	 }

    if (score < 68 ) {
		$("#validation_result").css('color', "coral");
		return goodPass
	 }

	 $("#validation_result").css('color', "green");
    return strongPass
}

function passwordStrengthPercent(password,username) {
    score = 0

    //password < 4
    if (password.length < 4 ) { return 0 }

    //password == username
    if (password.toLowerCase()==username.toLowerCase()) return 0

    //password length
    score += password.length * 4
    score += ( checkRepetition(1,password).length - password.length ) * 1
    score += ( checkRepetition(2,password).length - password.length ) * 1
    score += ( checkRepetition(3,password).length - password.length ) * 1
    score += ( checkRepetition(4,password).length - password.length ) * 1

    //password has 3 numbers
    if (password.match(/(.*[0-9].*[0-9].*[0-9])/))  score += 5

    //password has 2 sybols
    if (password.match(/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/)) score += 5

    //password has Upper and Lower chars
    if (password.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/))  score += 10

    //password has number and chars
    if (password.match(/([a-zA-Z])/) && password.match(/([0-9])/))  score += 15
    //
    //password has number and symbol
    if (password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([0-9])/))  score += 15

    //password has char and symbol
    if (password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([a-zA-Z])/))  score += 15

    //password is just a nubers or chars
    if (password.match(/^\w+$/) || password.match(/^\d+$/) )  score -= 10
    if (score > 100) return 100
  return (score)

}

// checkRepetition(1,'aaaaaaabcbc')   = 'abcbc'
// checkRepetition(2,'aaaaaaabcbc')   = 'aabc'
// checkRepetition(2,'aaaaaaabcdbcd') = 'aabcd'

function checkRepetition(pLen,str) {
    res = ""
    for ( i=0; i<str.length ; i++ ) {
        repeated=true
        for (j=0;j < pLen && (j+i+pLen) < str.length;j++)
            repeated=repeated && (str.charAt(j+i)==str.charAt(j+i+pLen))
        if (j<pLen) repeated=false
        if (repeated) {
            i+=pLen-1
            repeated=false
        }
        else {
            res+=str.charAt(i)
        }
    }
    return res
}

function checkPassword() {
  $(document).ready(function() {
	 var bpos = "";
	 var perc = 0 ;
	 var minperc = 0 ;
	 $('#administrator_password').css( {backgroundPosition: "0 0"} );

	 $('#administrator_password').keyup(function(){
		$('#validation_result').html(passwordStrength($('#administrator_password').val(), '')) ;
		perc = passwordStrengthPercent($('#administrator_password').val(), '');

		bpos=" $('#colorbar').css( {backgroundPosition: \"0px -" ;
		bpos = bpos + perc + "px";
		bpos = bpos + "\" } );";
		bpos=bpos +" $('#colorbar').css( {width: \"" ;
		bpos = bpos + (perc * 2.06) + "px";
		bpos = bpos + "\" } );";
		eval(bpos);
		$('#percent').html(" " + perc  + "% ");
	 })
  })
}


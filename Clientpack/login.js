'use-strict'

function login() {
    console.log("login tap")

    try {
        // ios direct call
        webkit.messageHandlers.login.postMessage("JS needs authentication");
    } catch(err) {
        console.log('The native context does not exist yet');
    }
}

function callHookFromJS() {
    console.log("call hook tap")
    
    location.href = "hook://hook_content/"
}

function onFingerprintAuthenticationResult(success) {

    if (typeof(success) != "boolean") {
        console.log("error: callback type is not a boolean")
        return
    }

    const element = document.getElementsByClassName("div-title")

    if (element[0] != "undefined") {
        console.log(element[0])

        if (success) {
            element[0].innerHTML = "Logged In!!"
            alert("Hey! Congratulation!!")
        } else {
            element[0].innerHTML = "Try again!"
            alert("Oops...")
        }
    }
}

function replyHook(number) {
    console.log("reply hook")
    
    const element = document.getElementsByClassName("div-hook")
    
    if (element[0] != "undefined") {
        console.log(element[0])
        element[0].innerHTML = "<h1>hook replied (" + number.toString() + ")</h1>"
    }
}

// WARNING: JS form submition does not include form validation!

var alertPlaceholder = document.getElementById('formSubmitResult')
var intentionForm = document.getElementById('intentionForm')

function alert(message, type) {
  var wrapper = document.createElement('div')
  wrapper.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible" role="alert">' + message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>'

  alertPlaceholder.append(wrapper)
}

function onIntentionSubmit(event) {
  event.preventDefault()
  const formData = new FormData(this)
  const entries = formData.entries()
  const data = Object.fromEntries(entries)

  fetch("--- REPLACE ME WITH API URL ---", {
    method: "POST",
    body: JSON.stringify(data),
    headers: {
      "Content-Type": "application/json",
    }
  })
  .then((response) => response.json())
  .then(({statusCode, message}) => {
    let alertType = (statusCode == 200) ? 'success' : 'danger'
    alert(message, alertType)
  })
  .catch((err) => {
    alert('Failed to submit form :(', 'danger')
  })
}

if (intentionForm) {
  intentionForm.addEventListener('submit', onIntentionSubmit)
}

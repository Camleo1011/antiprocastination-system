const form = document.querySelector(".recovery form");
const email = document.querySelector("#email");
const error = document.querySelector("#email-error");
const errorMessage = document.querySelector("#email-error-message");
const notice = document.querySelector(".notice");
const submittedEmail = document.querySelector("#submitted-email");
const submitButton = form.querySelector("button");

function clearError() {
  email.removeAttribute("aria-invalid");
  email.removeAttribute("aria-describedby");
  error.hidden = true;
  errorMessage.textContent = "";
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  const { valid, valueMissing } = email.validity;

  if (valid) {
    clearError();
    submittedEmail.textContent = email.value;
    notice.hidden = false;
    return;
  }

  errorMessage.textContent = valueMissing
    ? "Ingresa tu correo electrónico"
    : "Formato de correo no válido";
  error.hidden = false;
  email.setAttribute("aria-invalid", "true");
  email.setAttribute("aria-describedby", error.id);
  email.focus();
});

email.addEventListener("input", clearError);

form.noValidate = true;
submitButton.disabled = false;

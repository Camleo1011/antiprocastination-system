const form = document.querySelector(".register form");
const submitButton = form.querySelector("button[type='submit']");
const notice = document.querySelector(".notice");
const password = document.querySelector("#password");
const toggle = document.querySelector(".password-toggle");

const messages = {
  name: { required: "Ingresa tu nombre" },
  mail: {
    required: "Ingresa tu correo electrónico",
    invalid: "Formato de correo no válido",
  },
  password: {
    required: "Ingresa una contraseña",
    invalid: "Usa al menos 8 caracteres, con una letra y un número",
  },
  age: { required: "Confirma que eres mayor de 18 años" },
};

const fields = Array.from(form.querySelectorAll("input[required]"), (input) => ({
  input,
  error: document.getElementById(`${input.id}-error`),
  description: input.getAttribute("aria-describedby"),
}));

function clearError({ input, error, description }) {
  input.removeAttribute("aria-invalid");
  if (description) {
    input.setAttribute("aria-describedby", description);
  } else {
    input.removeAttribute("aria-describedby");
  }
  error.hidden = true;
  error.textContent = "";
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  let firstInvalid;

  for (const field of fields) {
    const { input, error, description } = field;
    const { valid, valueMissing } = input.validity;
    if (valid) {
      clearError(field);
      continue;
    }

    const { required, invalid = required } = messages[input.id];
    error.textContent = valueMissing ? required : invalid;
    error.hidden = false;
    input.setAttribute("aria-invalid", "true");
    input.setAttribute("aria-describedby", description ? `${error.id} ${description}` : error.id);
    firstInvalid ??= input;
  }

  notice.hidden = Boolean(firstInvalid);
  firstInvalid?.focus();
});

for (const field of fields) {
  field.input.addEventListener("input", () => {
    clearError(field);
    notice.hidden = true;
  });
}

toggle.addEventListener("click", () => {
  const isHidden = password.type === "password";

  password.type = isHidden ? "text" : "password";
  toggle.textContent = isHidden ? "Ocultar" : "Mostrar";
  toggle.setAttribute("aria-pressed", String(isHidden));
});

form.noValidate = true;
submitButton.disabled = false;

{% set test_tag = tag | default(value="") %}
{% set test_backend_url = backend | default(value=config.extra.test_backend_url | default(value="")) %}

{% if test_tag %}
<style>
.test-attempt-form {
    margin: 0;
    padding: 0;
    border: 0;
}

.test-attempt-field,
.test-attempt-submit {
    border: 1px solid var(--border-color, currentColor);
    border-radius: 2px;
    overflow: hidden;
    padding: 1em;
    margin: 2em 0;
}

.test-attempt-field__label,
.test-attempt-submit__header {
    display: block;
    font-size: 1.2rem;
    line-height: 1.35;
    margin: 0.5em 0 1em 0;
}

.test-attempt-field__textarea,
.test-attempt-submit__author {
    box-sizing: border-box;
    width: 100%;
    border: 1px solid var(--border-color, currentColor);
    border-radius: 2px;
    background: transparent;
    color: inherit;
    font: inherit;
    line-height: 1.5;
    padding: 0.75em;
}

.test-attempt-field__textarea {
    min-height: 9rem;
    resize: vertical;
}

.test-attempt-submit__controls {
    display: grid;
    gap: 0.75em;
}

.test-attempt-submit__author-label {
    display: grid;
    gap: 0.35em;
}

.test-attempt-submit__button {
    justify-self: start;
    border: 1px solid var(--border-color, currentColor);
    border-radius: 2px;
    background: transparent;
    color: inherit;
    cursor: pointer;
    font: inherit;
    line-height: 1;
    padding: 0.75em 1em;
}

.test-attempt-submit__button:hover,
.test-attempt-submit__button:focus-visible {
    background: var(--bg-1, rgba(127, 127, 127, 0.12));
}

.test-attempt-submit__button:disabled {
    cursor: wait;
    opacity: 0.7;
}

.test-attempt-submit__status {
    min-height: 1.5em;
    margin: 0;
}

.test-attempt-submit__status[data-state="error"] {
    color: #b91c1c;
}

:root.dark .test-attempt-submit__status[data-state="error"] {
    color: #fca5a5;
}
</style>

<form class="test-attempt-form" data-test-attempt-form data-test-tag="{{ test_tag | escape }}" data-test-backend-url="{{ test_backend_url | escape }}">

{{ body | safe }}

<div class="test-attempt-submit">
    <div class="test-attempt-submit__header">Отправить ответы</div>
    <div class="test-attempt-submit__controls">
        <label class="test-attempt-submit__author-label">
            <span>От кого</span>
            <input class="test-attempt-submit__author" type="text" name="author" autocomplete="name" required>
        </label>
        <button class="test-attempt-submit__button" type="submit">Отправить</button>
        <p class="test-attempt-submit__status" data-test-attempt-status role="status" aria-live="polite"></p>
    </div>
</div>
</form>

<script>
(function () {
    if (window.__testAttemptShortcodeReady) {
        return;
    }
    window.__testAttemptShortcodeReady = true;

    function setStatus(form, message, state) {
        var status = form.querySelector("[data-test-attempt-status]");
        if (!status) {
            return;
        }
        status.textContent = message;
        if (state) {
            status.dataset.state = state;
        } else {
            delete status.dataset.state;
        }
    }

    function buildEndpoint(backendUrl, tag) {
        var normalizedBackend = backendUrl.trim().replace(/\/+$/, "");
        var endpoint = new URL(normalizedBackend + "/assempts", window.location.href);
        endpoint.searchParams.set("tag", tag);
        return endpoint.toString();
    }

    document.addEventListener("submit", function (event) {
        var form = event.target.closest("[data-test-attempt-form]");
        if (!form) {
            return;
        }

        event.preventDefault();

        var backendUrl = form.dataset.testBackendUrl || "";
        var tag = form.dataset.testTag || "";
        var authorInput = form.querySelector('input[name="author"]');
        var submitButton = form.querySelector('button[type="submit"]');
        var author = authorInput ? authorInput.value.trim() : "";

        if (!backendUrl.trim()) {
            setStatus(form, "Не указан test_backend_url в конфигурации Zola.", "error");
            return;
        }

        if (!tag.trim()) {
            setStatus(form, "Для теста не указан tag.", "error");
            return;
        }

        if (!author) {
            setStatus(form, "Подпишите, от кого отправлен ответ.", "error");
            if (authorInput) {
                authorInput.focus();
            }
            return;
        }

        var answers = Array.prototype.map.call(
            form.querySelectorAll("[data-test-attempt-answer]"),
            function (field) {
                return {
                    name: field.name,
                    label: field.dataset.testAttemptLabel || field.name,
                    value: field.value
                };
            }
        );

        if (submitButton) {
            submitButton.disabled = true;
        }
        setStatus(form, "Отправляю...", "");

        fetch(buildEndpoint(backendUrl, tag), {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                tag: tag,
                author: author,
                answers: answers
            })
        }).then(function (response) {
            if (!response.ok) {
                throw new Error("Сервер вернул " + response.status + ".");
            }
            setStatus(form, "Ответы отправлены.", "");
            form.reset();
        }).catch(function (error) {
            setStatus(form, error.message || "Не удалось отправить ответы.", "error");
        }).finally(function () {
            if (submitButton) {
                submitButton.disabled = false;
            }
        });
    });
}());
</script>
{% else %}
<div class="test-attempt-submit">
    <p class="test-attempt-submit__status" data-state="error">Для shortcode test нужно указать tag.</p>
</div>
{% endif %}

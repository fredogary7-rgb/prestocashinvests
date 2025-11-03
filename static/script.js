document.addEventListener('DOMContentLoaded', () => {

    const sendData = async (url, data) => {
        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data),
            });
            return response.json();
        } catch (error) {
            console.error('Erreur lors de l\'envoi de données:', error);
            return { success: false, message: 'Erreur de communication avec le serveur.' };
        }
    };

    // --- 3. Gestion de l'Inscription (index.html) ---
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', async function(e) {
            e.preventDefault();

            const data = {
                nom: document.getElementById('nom').value,
                email: document.getElementById('email').value,
                telephone: document.getElementById('telephone').value,
                motdepasse: document.getElementById('motdepasse').value,
                parrain_code: document.getElementById('parrain_code').value,
            };

            const result = await sendData('/api/register', data);

            if (result.success) {
                // Redirection après succès sur le serveur Flask
                window.location.href = '/success'; 
            } else {
                alert('Erreur d\'inscription: ' + result.message);
            }
        });
    }

    // --- 4. Gestion de la Connexion (login.html) ---
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', async function(e) {
            e.preventDefault();

            const data = {
                email: document.getElementById('loginEmail').value,
                motdepasse: document.getElementById('loginPassword').value
            };

            const result = await sendData('/api/login', data);

            if (result.success) {
                // Redirection après connexion réussie sur le serveur Flask
                window.location.href = '/dashboard'; 
            } else {
                alert('Erreur de connexion: ' + result.message);
            }
        });
    }

    // Fonction pour afficher/cacher le mot de passe
    window.togglePasswordVisibility = function(fieldId) {
        const field = document.getElementById(fieldId);
        const type = field.getAttribute('type') === 'password' ? 'text' : 'password';
        field.setAttribute('type', type);
    };

});


document.addEventListener('DOMContentLoaded', (event) => {
    // 1. Récupérer l'URL de la page
    const urlParams = new URLSearchParams(window.location.search);
    
    // 2. Chercher le paramètre 'ref' (référence) ou 'parrain'
    const parrainCode = urlParams.get('ref') || urlParams.get('parrain');

    // 3. Si un code de parrainage est trouvé...
    if (parrainCode) {
        // Afficher l'information à l'utilisateur
        const parrainDisplay = document.getElementById('parrainDisplay');
        parrainDisplay.textContent = `Vous êtes invité par le code : ${parrainCode}`;
        
        // Placer le code dans le champ caché du formulaire
        const parrainInput = document.getElementById('parrainCode');
        parrainInput.value = parrainCode;

        console.log(`Code de parrainage capturé : ${parrainCode}`);
    } else {
        // Optionnel : informer si l'utilisateur vient sans lien
        console.log("Pas de code de parrainage trouvé dans l'URL.");
    }
    
        // 4. Gestion de la soumission du formulaire (Simulation de backend)
    const form = document.getElementById('inscriptionForm');
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // **Ici, en production, le code enverrait les données au serveur**
        
        // SIMULATION : Une fois que le serveur confirme l'inscription :
        
        // Redirection vers la page de succès
        window.location.href = 'success.html'; 
    });
}); // Fin du DOMContentLoaded

});

// Fonction générique de copie (pour numéros de téléphone)
function copyNumber(number) {
    // Note : En Termux/mobile, la manipulation du presse-papiers est limitée. 
    // En production sur un vrai serveur web, ce code serait plus robuste.
    navigator.clipboard.writeText(number).then(() => {
        alert("Numéro " + number + " copié !");
    }).catch(err => {
        alert("Impossible de copier. Veuillez copier manuellement le numéro : " + number);
    });
}

// Fonction de copie pour l'adresse crypto
function copyCrypto() {
    const address = "0x321FE3416D4612D8223b6fC58095f2ED511F8749";
    navigator.clipboard.writeText(address).then(() => {
        alert("Adresse Crypto (USDT BEP20) copiée !");
    }).catch(err => {
        alert("Impossible de copier. Veuillez copier manuellement l'adresse.");
    });
}


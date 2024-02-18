const fs = require('fs');

function lireFichierCSV(cheminFichier) {
    return new Promise((resolve, reject) => {
        fs.readFile(cheminFichier, 'utf8', (err, data) => {
            if (err) {
                reject(err);
                return;
            }
            resolve(data);
        });
    });
}

function normaliserNom(nom) {
    return nom.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

function premierNomProjet(contributions) {
    return contributions.map(c => c.p)
                       .map(p => p.toLowerCase())
                       .sort((a, b) => normaliserNom(a).localeCompare(normaliserNom(b)))
                       .filter(p => p)
                       .shift() || '';
}


function nbContributeursUniques(contributions) {
    return [...new Set(contributions.map(c => c.c))].length;
}

function longueurMoyenneNom(contributions) {
    const nomsUniques = [...new Set(contributions.map(c => c.n))];
    const longueurTotale = nomsUniques.reduce((sum, nom) => sum + normaliserNom(nom).length, 0);
    return longueurTotale / nomsUniques.length;
}

function contributeurLePlusActif(contributions) {
    const contributionsParContributeur = contributions.reduce((acc, c) => {
        acc[c.n] = (acc[c.n] || 0) + 1;
        return acc;
    }, {});

    const contributeursTries = Object.entries(contributionsParContributeur)
                                   .sort(([, countA], [, countB]) => countB - countA);
                                   
    return contributeursTries.length > 0 ? contributeursTries[0][0] : null;
}




function top10Projets(contributions) {
    const compteurProjets = contributions.reduce((acc, c) => {
        acc[c.p] = (acc[c.p] || 0) + 1;
        return acc;
    }, {});
    const top10 = Object.entries(compteurProjets)
                       .sort(([, a], [, b]) => b - a)
                       .slice(0, 10)
                       .map(([nomProjet]) => nomProjet);
    return top10;
}

async function calculerStatistiques(cheminFichier) {
    try {
        const donneesCSV = await lireFichierCSV(cheminFichier);
        const lignes = donneesCSV.split('\n');
        const contributions = lignes.slice(1).map(l => {
            const [c, n, w, , p] = l.split(',');
            return { c: c || '', n: n || '', w: w || '', p: p || '' };
        });
        return {
            premierProjet: premierNomProjet(contributions),
            contributeursUniques: nbContributeursUniques(contributions),
            longueurMoyenneNom: longueurMoyenneNom(contributions),
            contributeurActif: contributeurLePlusActif(contributions),
            top10Projets: top10Projets(contributions)
        };
    } catch (erreur) {
        console.error('Une erreur est survenue lors de la lecture du fichier :', erreur);
        return null;
    }
}

var cheminFichier = 'apache_people_projects.csv';
calculerStatistiques(cheminFichier)
    .then(statistiques => console.log(statistiques))
    .catch(erreur => console.error('Une erreur est survenue :', erreur));

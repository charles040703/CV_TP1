function processData_imperatif(csvText) {
    const lines = csvText.split('\n');
    const contributors = [];

    for (let i = 1; i < lines.length; i++) {
        const columns = lines[i].split(',');
        const contributor = {
            username: columns[0],
            realName: columns[1],
            website: columns[2] === '' ? null : columns[2],
            projectName: columns[3]
        };
        contributors.push(contributor);
    }

    console.log(contributors);
}

function processData_fonctionnel(csvText) {
    const lines = csvText.split('\n'); 

    const contributors = lines.slice(1).map(line => {
        const columns = line.split(',');
        return {
            username: columns[0],
            realName: columns[1],
            website: columns[2] === '' ? null : columns[2],
            projectName: columns[3]
        };
    });

    console.log(contributors);
}

const fs = require('fs');

// Lecture du contenu du fichier
fs.readFile('apache_people_projects.csv', 'utf8', (err, data) => {
    if (err) {
        console.error('Une erreur est survenue lors de la lecture du fichier :', err);
        return;
    }
    processData_imperatif(data);
    processData_fonctionnel(data);
});


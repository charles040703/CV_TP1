function sum(...terms) {
    if (terms.length === 0) {
        throw new Error('Au moins une argument doit être renseigné');
    }

    var total = 0;
    for (var i = 0; i < terms.length; i++) {
        total += terms[i];
    }
    return total;
}

// Test de la fonction avec les différents cas demandés
try {
    console.log(sum()); 
} catch (error) {
    console.error(error.message);
}

console.log(sum(1));            
console.log(sum(1, 2, 3, 4)); 

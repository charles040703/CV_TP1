function map(array, transform) {
    const filtrer = [];
    for (var i = 0; i < array.length; i++) {
        filtrer.push(transform(array[i]));
    }

    return filtrer;
}

// Test de la fonction
const array = [1, 2, 3, 4, 5];
console.log(map(array, item => item * 2));

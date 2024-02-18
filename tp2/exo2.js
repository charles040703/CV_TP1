function filter(array, predicate) {
    const filtrer = [];
    for (var i = 0; i < array.length; i++) {
        if (predicate(array[i])) {
            filtrer.push(array[i]);
        }
    }

    return filtrer;
}

// Test de la fonction
const array = [1, 2, 3, 4, 5];
console.log(filter(array, item => item > 2));

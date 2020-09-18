//=====================================
//Title: KPMG Challenge 3
//Author: Kirils Jaross
//Date: 18/09/2020
//=====================================

//Objects Definition
const object1 = {
    a: {
        b: {
            c: 'd'
        }
    }
}

const object2 = {
    x: {
        y: {
            z: 'a'
        }
    }
}

//Return Nested Object Function
const getNestedObject = (nestedObj, pathArr) => {
    return pathArr.reduce((obj, key) =>
        (obj && obj[key] !== 'undefined') ? obj[key] : undefined, nestedObj);
}

//Test Cases
console.log(getNestedObject(object1, ['a', 'b', 'c']));

console.log(getNestedObject(object2, ['x', 'y', 'z']));

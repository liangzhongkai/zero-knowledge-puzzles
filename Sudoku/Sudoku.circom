pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";


/*
    Given a 4x4 sudoku board with array signal input "question" and "solution", check if the solution is correct.

    "question" is a 16 length array. Example: [0,4,0,0,0,0,1,0,0,0,0,3,2,0,0,0] == [0, 4, 0, 0]
                                                                                   [0, 0, 1, 0]
                                                                                   [0, 0, 0, 3]
                                                                                   [2, 0, 0, 0]

    "solution" is a 16 length array. Example: [1,4,3,2,3,2,1,4,4,1,2,3,2,3,4,1] == [1, 4, 3, 2]
                                                                                   [3, 2, 1, 4]
                                                                                   [4, 1, 2, 3]
                                                                                   [2, 3, 4, 1]

    "out" is the signal output of the circuit. "out" is 1 if the solution is correct, otherwise 0.                                                                               
*/

template CheckFourCells() {
    signal input cells[4];
    signal output valid;

    component eq[16];
    component digitOk[4];
    var iter = 0;

    for (var d = 1; d <= 4; d++) {
        for (var j = 0; j < 4; j++) {
            eq[iter] = IsEqual();
            eq[iter].in[0] <== d;
            eq[iter].in[1] <== cells[j];
            iter++;
        }
        digitOk[d - 1] = IsEqual();
        digitOk[d - 1].in[0] <== eq[iter - 4].out + eq[iter - 3].out + eq[iter - 2].out + eq[iter - 1].out;
        digitOk[d - 1].in[1] <== 1;
    }

    signal tmp[5];
    tmp[0] <== 1;
    for (var i = 0; i < 4; i++) {
        tmp[i + 1] <== tmp[i] * digitOk[i].out;
    }
    valid <== tmp[4];
}

template Sudoku () {
    // Question Setup 
    signal input  question[16];
    signal input solution[16];
    signal output out;
    
    // Checking if the question is valid
    for(var v = 0; v < 16; v++){
        assert(question[v] == solution[v] || question[v] == 0);
    }
    
    var m = 0 ;
    component row1[4];
    for(var q = 0; q < 4; q++){
        row1[m] = IsEqual();
        row1[m].in[0]  <== question[q];
        row1[m].in[1] <== 0;
        m++;
    }
    3 === row1[3].out + row1[2].out + row1[1].out + row1[0].out;

    m = 0;
    component row2[4];
    for(var q = 4; q < 8; q++){
        row2[m] = IsEqual();
        row2[m].in[0]  <== question[q];
        row2[m].in[1] <== 0;
        m++;
    }
    3 === row2[3].out + row2[2].out + row2[1].out + row2[0].out; 

    m = 0;
    component row3[4];
    for(var q = 8; q < 12; q++){
        row3[m] = IsEqual();
        row3[m].in[0]  <== question[q];
        row3[m].in[1] <== 0;
        m++;
    }
    3 === row3[3].out + row3[2].out + row3[1].out + row3[0].out; 

    m = 0;
    component row4[4];
    for(var q = 12; q < 16; q++){
        row4[m] = IsEqual();
        row4[m].in[0]  <== question[q];
        row4[m].in[1] <== 0;
        m++;
    }
    3 === row4[3].out + row4[2].out + row4[1].out + row4[0].out; 

    // Write your solution from here.. Good Luck!
    
    for(var i = 0; i < 16; i++) {
        assert(solution[i] >= 1 && solution[i] <= 4);
    }
    component rowCheck[4];
    signal rowOk[4];
    for (var p = 0; p < 4; p++) {
        rowCheck[p] = CheckFourCells();
        var base = p * 4;
        rowCheck[p].cells[0] <== solution[base];
        rowCheck[p].cells[1] <== solution[base + 1];
        rowCheck[p].cells[2] <== solution[base + 2];
        rowCheck[p].cells[3] <== solution[base + 3];
        rowOk[p] <== rowCheck[p].valid;
    }
    component colCheck[4];
    signal colOk[4];
    for (var p = 0; p < 4; p++) {
        colCheck[p] = CheckFourCells();
        colCheck[p].cells[0] <== solution[p];
        colCheck[p].cells[1] <== solution[p + 4];
        colCheck[p].cells[2] <== solution[p + 8];
        colCheck[p].cells[3] <== solution[p + 12];
        colOk[p] <== colCheck[p].valid;
    }
    component boxCheck[4];
    signal boxOk[4];
    for (var p = 0; p < 4; p++) {
        boxCheck[p] = CheckFourCells();
        var base = 8 * (p \ 2) + 2 * (p % 2);
        boxCheck[p].cells[0] <== solution[base];
        boxCheck[p].cells[1] <== solution[base + 1];
        boxCheck[p].cells[2] <== solution[base + 4];
        boxCheck[p].cells[3] <== solution[base + 5];
        boxOk[p] <== boxCheck[p].valid;
    }

    signal checks[13];
    checks[0] <== 1;
    for (var i = 0; i < 4; i++) {
        checks[i + 1] <== checks[i] * rowOk[i];
    }
    for (var i = 0; i < 4; i++) {
        checks[i + 5] <== checks[i + 4] * colOk[i];
    }
    for (var i = 0; i < 4; i++) {
        checks[i + 9] <== checks[i + 8] * boxOk[i];
    }
    out <== checks[12];
}


component main = Sudoku();


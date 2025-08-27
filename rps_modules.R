#hedonic modules

#add a secondary return module
if_else(A1play == A2play, 1, if_else(A1play == 1 & A2play == 2, 2, 
                              if_else(A1play ==1 & A2play == 3, 3, if_else(A1play ==2 & A2play == 1, 4, 
                                if_else(A1play ==2 & A2play ==3, 5, 
                                  if_else(A1play == 3 & A2play ==1, 6,
                                  if_else(A1play == 3 & A2play ==2, 7, 
                                  #false start high SD conditions
                                          if_else(A1play == 0 | A2play ==0, 8, 
                                  if_else(A1play ==5 | A2play == 5, 8, 8)))))))))


#outcome conditions 1/8 is a draw, 2, 5, 6 are PLAYER 2 win
#outcome conditions 3, 4, 7 are player 1 win


#assign hedonic change


#prospect theory, loses hurt twice as much as wins reward, absolute value model
#agent A wins
if (z %in% c(2,5,6)) { A2$H <- A2$H + 0.1; A1$H <- A1$H - 0.2 }
#agent B wins
if (z %in% c(3,4,7)) { A2$H <- A2$H - 0.2; A1$H <- A1$H + 0.1 }

#relative value model - does not drop below zero

#crashout 
#rage quit mechanic
#level is set at .005 to quit, allows more turns more realistically - this hedonicity level with base assumptions produces a 2 loss outcome
if(A1$H < .005) {print("SCREW YOU I QUIT!"); break()} else {""} 
if(A2$H < .005) {print("SCREW YOU I QUIT!"); break()} else {""} 


#exhaustion mechanic
#nested assumption - NO IF statement means that underlying values are unaffected
#rock paper
#set reward values
L <- .2
W <- .1

if (A1play == 1L && A2play == 2L) {
  A1$A <- A1$A - L
  A2$B <- A2$B + W
}

#rock scissors
if (A1play == 1L && A2play == 3L) {
  A1$A <- A1$A + W
  A2$C <- A2$C - L
}

#paper rock
if (A1play == 3L && A2play == 1L) {
  A1$B <- A1$B + W
  A2$A <- A2$A - L
}

#paper scissors
if (A1play == 2L && A2play == 3L) {
  A1$B <- A1$B - L
  A2$C <- A2$C + W
}

#scissors rock
if (A1play == 3L && A2play == 1L) {
  A1$C <- A1$C - L
  A2$A <- A2$A + W
}

#scissors paper
if (A1play == 3L && A2play == 2L) {
  A1$C <- A1$C + W
  A2$B <- A2$B - L
}



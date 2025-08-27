library(dplyr)

#set agent initial states - change A/B/C values for an opening book effect
A1<-data.frame(A=.33, B=.33, C=.33, H=.5)
A2<-data.frame(A=.33, B=.33, C=.33, H=.5)
#set loop state at turn zero
t=0

#create outcome bucket for the loop to add to
outcome<-data.frame(A1play = 0, A2play =0, z = 1)

#1000 turns
while(t<1000){
  #initialize plays - the plays never change
  a <- 1
  b <- 2
  c <- 3
  
  #player1 - produce a play based on current agent states
  weighted_value <- a * A1$A + b * A1$B + c * A1$C
  random_value <- rnorm(1, mean = weighted_value, sd = 1) # sd controls spread
  A1play<-round(random_value)
  A1play
  A1play <- if_else(A1play == 0, 1L, A1play)
  A1play <- if_else(A1play == 4, 3L, A1play)
  A1play <- abs(A1play)
  
  #player2 - produce a play based on current agent states
  weighted_value <- a * A2$A + b * A2$B + c * A2$C
  random_value <- rnorm(1, mean = weighted_value, sd = 1) # sd controls spread
  A2play<-round(random_value)
  A2play <- if_else(A2play == 0, 1L, A2play)
  A2play <- if_else(A2play == 4, 3L, A2play)
  A2play <- abs(A2play)
  
  #nested game branches - you can rewrite these using a case_when routine in dplyr or with base r
  z<-if_else(A1play == A2play, 1, if_else(A1play == 1 & A2play == 2, 2, 
                                          if_else(A1play ==1 & A2play == 3, 3, if_else(A1play ==2 & A2play == 1, 4, 
                                                                                       if_else(A1play ==2 & A2play ==3, 5, 
                                                                                               if_else(A1play == 3 & A2play ==1, 6,
                                                                                                       if_else(A1play == 3 & A2play ==2, 7, 
                                                                                                               #false start high SD conditions
                                                                                                               if_else(A1play == 0 | A2play ==0, 8, 
                                                                                                                       if_else(A1play ==5 | A2play == 5, 8, 8)))))))))
  
  
  
  #AGENT UPDATE AREA
  new_row<-data.frame(A1play, A2play, z)
  if (z %in% c(2,5,6)) { A2$H <- A2$H + 0.1; A1$H <- A1$H - 0.2 }
  if (z %in% c(3,4,7)) { A2$H <- A2$H - 0.2; A1$H <- A1$H + 0.1 }
  
  #rage quit mechanic
  if(A1$H < .005) {print("SCREW YOU I (agent 1) QUIT!"); break()} else {""} 
  if(A2$H < .005) {print("SCREW YOU I (agent 2) QUIT!"); break()} else {""} 

  #exhaustion mechanic - complex branching
if (A1play == 1L && A2play == 2L) {
  A1$A <- A1$A - 0.1
  A2$B <- A2$B + 0.1
}

#rock scissors
if (A1play == 1L && A2play == 3L) {
  A1$A <- A1$A + 0.1
  A2$C <- A2$C - 0.1
}

#paper rock
if (A1play == 3L && A2play == 1L) {
  A1$B <- A1$B + 0.1
  A2$A <- A2$A - 0.1
}

#paper scissors
if (A1play == 2L && A2play == 3L) {
  A1$B <- A1$B - 0.1
  A2$C <- A2$C + 0.1
}

#scissors rock
if (A1play == 3L && A2play == 1L) {
  A1$C <- A1$C - 0.1
  A2$A <- A2$A + 0.1
}

#scissors paper
if (A1play == 3L && A2play == 2L) {
  A1$C <- A1$C + 0.1
  A2$B <- A2$B - 0.1
}
  #RESULTS OUTPUT AREA
  #add new game to log  
  outcome<-add_row(outcome, new_row)
  
  #print game result
  print(new_row)
  
  #print internal states of agents
  print(A1)
  print(A2)
  
  #print turn status
  print("turn")
  print(dim(outcome)[1]) 
  t<-t+1
}

#summary of games played after loop completes
outcome %>% group_by(z) %>% count()

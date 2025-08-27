library(dplyr)
A1<-data.frame(A=.7, B=.33, C=.1, H=.5)
A2<-data.frame(A=.33, B=.33, C=.33, H=.5)
t=0
outcome<-data.frame(A1play = 0, A2play =0, z = "draw")
while(t<1000){
  #initialize plays
  a <- 1
  b <- 2
  c <- 3
  #player1
  weighted_value <- a * A1$A + b * A1$B + c * A1$C
  random_value <- rnorm(1, mean = weighted_value, sd = 1) # sd controls spread
  A1play<-round(random_value)
  A1play
  A1play <- if_else(A1play == 0, 1L, A1play)
  A1play <- if_else(A1play == 4, 3L, A1play)
  A1play <- abs(A1play)
  
  #player2
  weighted_value <- a * A2$A + b * A2$B + c * A2$C
  random_value <- rnorm(1, mean = weighted_value, sd = 1) # sd controls spread
  A2play<-round(random_value)
  A2play <- if_else(A2play == 0, 1L, A2play)
  A2play <- if_else(A2play == 4, 3L, A2play)
  A2play <- abs(A2play)

  #conditon 1 is draw
  #condition 2 is rock paper, condition 3 is rock scissors, 4 is paper rock, 5 is paper scissors
  #6 is scissors rock, 7 is scissors paper
  z<-if_else(A1play == A2play, "draw", if_else(A1play == 1 & A2play == 2, "player 2, paper", 
          if_else(A1play ==1 & A2play == 3, "player 1, rock", if_else(A1play ==2 & A2play == 1, "player 1, paper", 
                                                            if_else(A1play ==2 & A2play ==3, "player 2, scissors", 
                                                                    if_else(A1play == 3 & A2play ==1, "player 2, rock",
                                                                                                                           
                                                                            if_else(A1play == 3 & A2play ==2, "player 1, scissors", if_else(A1play == 0 | A2play ==0, "false start", "false start"))))))))
  new_row<-data.frame(A1play, A2play, z)
  
  outcome<-add_row(outcome, new_row)
  print(new_row)
  t<-t+1
}

outcome %>% group_by(z) %>% count()





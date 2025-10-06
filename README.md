# Welcome to the exciting world of rock paper scissors.

RPS is a great example of a triangular victory vector game, rock smashes scissors, but is covered by paper. This collection of functions was inspired by other agent-based work in the RPS game space especially work by [Traulsen](https://www.evolbio.mpg.de/3460755/rock-paper-scissors) (2020) on cyclic dominance, psychological factors by [Cook et al](https://royalsocietypublishing.org/doi/10.1098/rspb.2011.1024) (2011), and practically by [Smolla](https://marcosmolla.wordpress.com/2015/07/16/an-introduction-to-agent-based-modelling-in-r/) (2014). Actual play is important as neural synchronous research would suggest that prediction alone does not produce the same result [Kayhan and Nyguen](https://pure.mpg.de/pubman/faces/ViewItemOverviewPage.jsp?itemId=item_3398665) (2022).

RPS offers insight into various human and ecological processes. The basic problem that this code solves are psychological processes in RPS. These ABMs are designed to allow you to manipulate the various underlying psychological structures of game play between agents.

RPS_base runs a traditional 1000 game simulation.

RPS_complete includes both ragequit and exhaustion accommodations. As players lose they become angry (prospect theory like hedonic returns [Kahneman and Tversky](https://web.mit.edu/curhan/www/docs/Articles/15341_Readings/Behavioral_Decision_Theory/Kahneman_Tversky_1979_Prospect_theory.pdf) (1979)), they also become less likely to play what just failed.

RPS_modules includes various parts which can be swapped into RPS_complete, like a cook estimator (players tend to copy each other) or relative rather than absolute math. The code is highly commented so different mechanics can be produced and copied in as needed.

## Quick Demo

```{r}
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
```

And one might graph that outcome

```{r}
library(ggplot2)
library(dplyr)
library(tidyr)

#pivot for ease of graphing
outcomeB <- outcome %>%
  mutate(game = row_number()) %>%
  pivot_longer(
    cols = c(A1play, A2play), 
    names_to = "player",
    values_to = "play"
  )

#here is our GGPLOT
ggplot(outcomeB, aes(x = game, y = play, color = z, shape = player)) +
  geom_jitter()
  scale_y_continuous(breaks = 1:3, labels = c("rock","paper","scissors")) +
  labs(x = "Game", y = "Play", color = "Player", shape = "Player") +
  theme_minimal()

```

Proof of concept for the base model comes with these lovely results:

| Outcome                                  | Count |
|------------------------------------------|-------|
| Draw                                     | 230   |
| False Start                              | 11    |
| Paper over Rock (player 1 wins)          | 114   |
| Rock over Scissors (player 1 wins)       | 127   |
| Scissors over Paper (player 1 wins)      | 79    |
| Rock covered by Paper (player 2 wins)    | 181   |
| Scissors smashed by rock (player 2 wins) | 53    |
| Paper is cut by paper (player 2 wins)    | 116   |
| Total                                    | 1001  |

What are the false starts? In some cases the stochastic process throws a non-playable integer (moderate clamping is used).

What this looks like graphically (code from above):

![RPS markdown image](images/RPS%20markdown%20image.png)

Faceting can be helpful. Look at the player 1, rock - you see that the blue triangles are all on Scissors, thus player 2 went scissors, and was smashed by the red circles of rock. Paper was not played.

![RPS faceted](images/RPS%20faceted.png)

## RPS with an LLM

First major step is to initialize your link to a locally running LLM. In this case I am using LM studio and an open version of chatGPT. Notice you can pass a system prompt. For our code today, we will be using an initalizer prompt.

```{r}
library(ellmer)
Sys.setenv(OPENAI_BASE_URL = "http://127.0.0.1:1234/v1")
Sys.setenv(OPENAI_API_KEY = "not-needed")
chat <- chat_openai(
  model = "lmstudio-community/openai/gpt-oss-20b",
  system_prompt = "Be realistic, like how a normal person reasons.")
chat$chat("hell0")
  )

```

The response from the system: Hey there! Did you just type “hell0” or was that a typo for “hello”? Let me know how I can help you today. At this point enjoy your Dr. Frankenstein moment.

```{r}

chat$chat("do you know how to play rock paper scissors")
  )

```

Absolutely—here’s the quick rundown:

1.  **Players** – Two people (or you can even play against a computer or yourself in practice).
2.  **The “hand signs”**
    -   **Rock** – a closed fist.\
    -   **Paper** – an open hand, palm out.\
    -   **Scissors** – a fist with the index and middle fingers extended to form a V.
3.  **How it goes**
    -   On a count of “one‑two‑three, shoot!” each player simultaneously shows one of the three signs.\
4.  **Winning rules**
    -   Rock crushes scissors (rock wins).\
    -   Scissors cuts paper (scissors win).\
    -   Paper covers rock (paper wins).\
    -   If both players show the same sign it’s a tie and you usually play again to break the tie.
5.  **Why we play it** – It’s a quick, fair way to make a decision when you’re stuck or just want a simple game.

Optional: Some folks try to read patterns in their opponent’s choices or mix up their own moves randomly to stay unpredictable. But at its core, it’s all about those three signs and the classic “rock beats scissors” logic!

Excellent - how the most important thing in developing our code is to stage the interaction so that our LLM can send back a variable that is easily understood by our central loop, an integer which corresponds to the play.

```{r}
chat$chat("for this version of rock paper scissors you will be sent a number, which coresponds to the value 1 rock 2 paper 3 scissors, you need to send back an integer with your best play 1 rock 2 paper 3 scissors")

chat$chat("1")

```

The system replies "2" which I take as proof of concept. Now we can run our initial model which loops to the LLM. The key is to clean the return data, in this case as.numeric does the trick.

```{r}
library(dplyr)
chat$chat("for this version of rock paper scissors you will be sent a number, which coresponds to the value 1 rock 2 paper 3 scissors, you need to send back an integer with your best play 1 rock 2 paper 3 scissors, you are player 2")
A1<-data.frame(A=.7, B=.33, C=.1, H=.5)
A2<-data.frame(A=.33, B=.33, C=.33, H=.5)
t=0
outcome<-data.frame(A1play = 0, A2play =0, z = "draw")
while(t<10){
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
A2play<-chat$chat("your turn")
  A2play<-as.numeric(A2play)
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
```

The challenge with this model is that the more sophisticated the instructions passed to the LLM the higher likelihood it throws back an NA as you will be more likely to hit the barrier of the context window. It can be extremely frustrating as you work on these models as after just a few turns many LLMs pick up the nasty trait of yammering on. You will be lucky to have four of ten games play effectively. It is also possible your LLM will just freak out and refuse to play unless it knows what happened last time. Here is code to handle that:

```{r}
library(dplyr)
chat$chat("for this version of rock paper scissors you will be sent a number, which coresponds to the value 1 rock 2 paper 3 scissors, you need to send back an integer with your best play 1 rock 2 paper 3 scissors, you are player 2, do no extra chit-chat, integers ONLY on your replies")
A1<-data.frame(A=.7, B=.33, C=.1, H=.5)
t=0
outcome<-data.frame(A1play = 0, A2play =0, z = "draw")
while(t<10){
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
  #we are pasting in the results from last round and then asking for the new integer
A2play<-chat$chat(paste("the last round was", new_row, "what do you want to do this round"))
  A2play<-as.numeric(A2play)
  #conditon 1 is draw
  #condition 2 is rock paper, condition 3 is rock scissors, 4 is paper rock, 5 is paper scissors
  #6 is scissors rock, 7 is scissors paper
  z<-if_else(A1play == A2play, "draw", if_else(A1play == 1 & A2play == 2, "player 2, paper", 
                                               if_else(A1play ==1 & A2play == 3, "player 1, rock", if_else(A1play ==2 & A2play == 1, "player 1, paper", 
                                                                                                           if_else(A1play ==2 & A2play ==3, "player 2, scissors", 
                                                                                                                   if_else(A1play == 3 & A2play ==1, "player 2, rock",
                                                                                                                           
                                                                                                                           if_else(A1play == 3 & A2play ==2, "player 1, scissors", if_else(A1play == 0 | A2play ==0, "false start", "false start"))))))))
  chat$chat("prepare to hear what happened last time")
  #this is key - you need to pass the text of what happeend last time back to the agent
  #z is the result of the last game
  chat$chat(z)
  new_row<-data.frame(A1play, A2play, z)
  
  outcome<-add_row(outcome, new_row)
  print(new_row)
  t<-t+1
}

outcome %>% group_by(z) %>% count()
```

### That is very annoying, how do I fix it?

Great question - the key is getting away from LLMs which have been salted with a personality. The best solution is to switch to Mistral.

```{r}
chat <- chat_openai(
  model = "mistralai/devstral-small-2505",
  system_prompt = "Be realistic, like how a normal person reasons."
)
```

This little switch took us from getting bogged on unnecessary personality to a compelling simulation:

|   | static simulation player | dynamic LLM player (mistral) |   |
|:---|:---|:---|:---|
| **1** | 0 | 0 | draw |
| **2** | 3 | 2 | player 1, scissors |
| **3** | 1 | 2 | player 2, paper |
| **4** | 1 | 3 | player 1, rock |
| **5** | 3 | 2 | player 1, scissors |
| **6** | 1 | 2 | player 2, paper |
| **7** | 1 | 3 | player 1, rock |
| **8** | 2 | 3 | player 2, scissors |
| **9** | 3 | 1 | player 2, rock |
| **10** | 2 | 1 | player 1, paper |
| **11** | 1 | 3 | player 1, rock |

If you really like to party you can have mistral explain why it did what it did...

```{r}
library(dplyr)
chat$chat("for this version of rock paper scissors you will be sent a number, which coresponds to the value 1 rock 2 paper 3 scissors, you need to send back an integer with your best play 1 rock 2 paper 3 scissors, you are player 2, do no extra chit-chat, your reply must include an INTEGER then a semicolon then an explanation of why you did what you did")
A1<-data.frame(A=.7, B=.33, C=.1, H=.5)
t=0
outcome<-data.frame(A1play = 0, A2play =0, z = "draw")
while(t<10){
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
  #we are pasting in the results from last round and then asking for the new integer
A2play<-chat$chat(paste("the last round was", new_row, "what do you want to do this round,"))
library(stringr)
splitty<-str_split(A2play, ";")  
library(reshape2)
splitsville<-melt(splitty)
A2play<-tidyrA2play<-as.numeric(splitsville$value[1])
print(splitsville)
  #conditon 1 is draw
  #condition 2 is rock paper, condition 3 is rock scissors, 4 is paper rock, 5 is paper scissors
  #6 is scissors rock, 7 is scissors paper
  z<-if_else(A1play == A2play, "draw", if_else(A1play == 1 & A2play == 2, "player 2, paper", 
                                               if_else(A1play ==1 & A2play == 3, "player 1, rock", if_else(A1play ==2 & A2play == 1, "player 1, paper", 
                                                                                                           if_else(A1play ==2 & A2play ==3, "player 2, scissors", 
                                                                                                                   if_else(A1play == 3 & A2play ==1, "player 2, rock",
                                                                                                                           
                                                                                                                           if_else(A1play == 3 & A2play ==2, "player 1, scissors", if_else(A1play == 0 | A2play ==0, "false start", "false start"))))))))
  chat$chat("prepare to hear what happened last time")
  #this is key - you need to pass the text of what happeend last time back to the agent
  #z is the result of the last game
  chat$chat(z)
  new_row<-data.frame(A1play, A2play, z)
  
  outcome<-add_row(outcome, new_row)
  print(new_row)
  t<-t+1
}

outcome %>% group_by(z) %>% count()

```

Mistral will start to let you in on the reasoning, I have that accumulate in the console, but it could just as easily be saved for later use.

## Works Cited

Cook, Richard, Geoffrey Bird, Gabriele Lünser, Steffen Huck, and Cecilia Heyes. “Automatic Imitation in a Strategic Context: Players of Rock–Paper–Scissors Imitate Opponents’ Gestures†.” *Proceedings of the Royal Society B: Biological Sciences* 279, no. 1729 (2011): 780–86. <https://doi.org/10.1098/rspb.2011.1024>.

Kahneman, Daniel, and Amos Tversky. “Prospect Theory: Ana Analysis of Decision under Risk.” *Econometrica* 47, no. 2 (1979): 263–91.

Kayhan, Ezgi, T. Nguyen, Daniel Matthes, et al. “Interpersonal Neural Synchrony When Predicting Others’ Actions during a Game of Rock-Paper-Scissors.” *Scientific Reports* 12, no. 1 (2022). <https://doi.org/10.1038/s41598-022-16956-z>.

Smolla, Marco. “An Introduction to Agent-Based Modelling in R.” *Marco Smolla*, July 16, 2015. <https://marcosmolla.wordpress.com/2015/07/16/an-introduction-to-agent-based-modelling-in-r/>.

Trausen, Arne. “Rock, Paper, Scissors - Can Cyclic Dominance Explain Diversity of Species and Individuals?” Accessed August 27, 2025. <https://www.evolbio.mpg.de/3460755/rock-paper-scissors>.

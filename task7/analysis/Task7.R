# PACKAGES

library(ggplot2)
library(tidyverse) 
library(tm)
library(stringr)
library(stringi)
library(wordcloud)
library(dplyr)
library(tidyr)
library(slam)
library(SparseM)
library(e1071)
library(tidytext)
library(reshape2)

setwd("C:/Users/buca4591/Desktop/GIT/Applied_Empirical/task7")
indir_105 = "raw/105-extracted-date"
sen105_party = read.csv("raw/sen105_party.csv", stringsAsFactors=FALSE)
senator_corpus_105 = VCorpus(DirSource(indir_105))

#Tokenization
senators_td105 = senator_corpus_105 %>%
  tidy() %>%
  select(id,text) %>%
  mutate(id=str_match(id,"-(.*).txt")[,2]) %>%
  unnest_tokens(word, text) %>% 
  group_by(id) %>%
  mutate(row=row_number()) %>%
  ungroup()

# Create vector with senator names (in lower case)
names = sen105_party %>%
  mutate(word=tolower(lname)) %>%
  select(word)

# Create a df with state names in lower case
states = as.data.frame(c(tolower(state.abb), tolower(state.name)))
colnames(states) <- "word"

# Combine names and states with lowercase
# in order to merge below
sen105_party_ = sen105_party %>%
  mutate(lname=tolower(lname), 
         stateab=tolower(stateab),
         id=str_c(lname,stateab, sep="-"))

# Clean data -- remove non-alphabetic characters, stopwords, senator 
# and state names 
droplist = c("text","doc","docno")
senators_td105 = senators_td105 %>% 
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na(word)   %>%
  filter(!(word %in% droplist)) %>% 
  anti_join(stop_words) %>%
  anti_join(names) %>%
  anti_join(states)

# Generate dataframes for all bigrams and trigrams for the set of all senators
senators_bigram = senators_td105 %>%
  arrange(id,row) %>%
  group_by(id) %>%
  mutate(bigram = str_c(lag(word,1), word, sep = " ")) %>%
  filter(row == lag(row,1)+1) %>%
  select(-word) %>%
  ungroup()

senators_trigram = senators_td105 %>%
  arrange(id,row) %>%
  group_by(id) %>%
  mutate(trigram = str_c(lag(word,2), lag(word,1),  word, sep = " ")) %>%
  filter(row == lag(row,1)+1 & lag(row,1) == lag(row,2)+1) %>%
  select(-word) %>%
  ungroup()

# Create lists of  overall frequency of words, bigrams and trigrams
wordlist = senators_td105 %>%
  count(word, sort = TRUE)

bigramlist = senators_bigram %>%
  count(bigram, sort = TRUE)

trigramlist = senators_trigram %>%
  count(trigram, sort = TRUE)

# List 50 most frequent words, bigrams and trigrams
wordlist %>% 
  filter(row_number()<50) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word,n)) + 
  geom_bar(stat = "identity") + 
  xlab(NULL) + 
  coord_flip()

bigramlist %>% 
  filter(row_number()<50) %>%
  mutate(bigram = reorder(bigram, n)) %>%
  ggplot(aes(bigram,n)) + 
  geom_bar(stat = "identity") + 
  xlab(NULL) + 
  coord_flip()

trigramlist %>% 
  filter(row_number()<50) %>%
  mutate(bigram = reorder(trigram, n)) %>%
  ggplot(aes(trigram,n)) + 
  geom_bar(stat = "identity") + 
  xlab(NULL) + 
  coord_flip()

# Use lists to plot word frequency graph
word_plot <- wordlist %>%
  filter(row_number() < 50) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) + 
  geom_bar(stat = "identity") + 
  xlab(NULL) + 
  coord_flip()

# Save the word frequency graph
ggsave(filename = "Analysis/Output/word_freq.png", plot = word_plot)

# Plot bigram frequency graph
bigram_plot <- bigramlist %>%
  filter(row_number() < 50) %>%
  mutate(bigram = reorder(bigram, n)) %>%
  ggplot(aes(bigram, n)) + 
  geom_bar(stat = "identity") + 
  xlab(NULL) + 
  coord_flip()

# Save the bigram frequency graph
ggsave(filename = "Analysis/Output/bigram_freq.png", plot = bigram_plot)

# Plot and save trigram frequency graph ordered by frequency
trigram_plot <- trigramlist %>%
  filter(row_number() < 50) %>%
  mutate(trigram = reorder(trigram, n)) %>%
  arrange(desc(n)) %>% 
  ggplot(aes(trigram, n)) + 
  geom_bar(stat = "identity") + 
  xlab(NULL) + 
  coord_flip()

# Save the trigram frequency graph
ggsave(filename = "Analysis/Output/trigram_freq.png", plot = trigram_plot)

# Most common word: president. Most common bigram: unanimous consent. Most common trigram: word war II.

#Merge in party information
# Compute frequency lists for bigrams and trigrams by party.
  
# Frequency list of words by party
  wordlist_party = senators_td105 %>% 
  inner_join(sen105_party_) %>%
  count(party, word, sort=TRUE) %>%
  group_by(party) %>% 
  mutate(share = n / sum(n), ran=row_number()) %>%
  ungroup()

# Frequency list bigram
  bigramlist_party = senators_bigram %>% 
  inner_join(sen105_party_) %>%
  count(party, bigram, sort=TRUE) %>%
  group_by(party) %>% 
  mutate(share = n / sum(n), ran=row_number()) %>%
  ungroup()

# Frequency list trigram
trigramlist_party = senators_trigram %>% 
  inner_join(sen105_party_) %>%
  count(party, trigram, sort=TRUE) %>%
  group_by(party) %>% 
  mutate(share = n / sum(n), ran=row_number()) %>%
  ungroup()

# Wordcloud by party 
wordlist_party %>%
  select(word, party, n) %>%
  acast(word ~ party, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#00FF00", "#545454"), 
                   max.words = 100,
                   random.order=FALSE)

# Step 1: Compute bigram freuency, by senator
bigramfreq_s = senators_bigram %>% 
  inner_join(sen105_party_) %>%
  count(id, party, bigram, sort=TRUE) %>%
  ungroup()

# Step 2: Data managmememt for SVM analysis. Recode (by casting) bigramlist into a matrix object
x = bigramfreq_s %>%
  cast_sparse(id, bigram, n)
class(x) # matrix

# Data management: Order x-matrix to match y-vector
x = x[order(rownames(x)),]

# Data managememnt: code dependent variable y as factor 
y = sen105_party_[order(sen105_party_$id),]
y = as.matrix(y$party)
y = as.factor(y)

# Step 3: Estimate SVM 
svmfit = svm(x, y, kernel="linear", cost=0.1)
summary(svmfit)

# Step 4:set tuning parameter 
set.seed(1234)
tune.out = tune(svm, x, y, kernel="linear",
                ranges=list(cost=c(0.00001, 0.001, 0.01, 0.1, 1)))
summary(tune.out)

bestmod = tune.out$best.model 
ypred = predict(bestmod, x)
table(predict = ypred, truth=y)

# Step 5: retrieve beta coefficients 
beta = drop(t(bestmod$coefs)%*%as.matrix(x)[bestmod$index,])
beta = as.data.frame(beta)


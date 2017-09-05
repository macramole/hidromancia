
sentiments = c("anger", "fear", "joy", "love", "sadness")

df = list()

for ( sentiment in sentiments ) {
  df[ sentiment ] = read.csv( paste("../data/sentiments/", sentiment, ".txt", sep = ""), header = F)
}

df.all = data.frame(
  anger = df[["anger"]],
  fear = df[["fear"]],
  joy = df[["joy"]],
  love = df[["love"]],
  sadness = df[["sadness"]]
)

library("dplyr")

df.all = df.all %>%
  mutate( total = anger + fear + joy + love + sadness ) %>%
  mutate( anger = anger/total,  fear = fear/total, joy = joy/total, love = love/total, sadness = sadness/total )

# for ( sentiment in sentiments ) {
#   df[[ sentiment ]] = as.numeric( scale( df[[ sentiment ]] ) )
# }
# par( mfrow = c(2,3) )
# for ( sentiment in sentiments ) {
#   plot( df[[ sentiment ]], type = "l", main = sentiment, ylab = "twit count", xlab = "hours" )
# }

for ( sentiment in sentiments ) {
  df.all[, sentiment] = as.numeric( scale( df.all[, sentiment] ) )
}
par( mfrow = c(2,3) )
for ( sentiment in sentiments ) {
  plot( df.all[, sentiment], type = "l", main = sentiment, ylab = "twit count", xlab = "hours" )
}
par( mfrow = c(1,1) )

# lengthSentiments = length(df[["anger"]])
lengthSentiments = length(df.all[, "anger"])



# df.waves = read.csv( "../data/wavesWithID.tsv", sep = "\t" )
df.waves = read.csv( "../data/wavesPerFrame.tsv", sep = "\t" )
#plot( stats::filter(df.waves[ df.waves$id == 1, "y" ], rep(1/6,6), circular = T), type = "l")

maxCrossCorrelations = data.frame( id = numeric(),
                                   anger = numeric(),
                                   fear = numeric(),
                                   joy = numeric(),
                                   love = numeric(),
                                   sadness = numeric() )

for ( i in 0:max(df.waves$id) ) {
  currentWave = df.waves[ df.waves$id == i, "y" ]
  
  if ( all( currentWave == rep(0, length(currentWave)) ) ) {
    maxCrossCorrelations = rbind( maxCrossCorrelations, data.frame(
      id = i,
      anger = 0,
      fear = 0,
      joy = 0,
      love = 0,
      sadness = 0
    ) )
    next
  }
  
  currentWave = stats::filter(currentWave, rep(1/6,6), circular = T)
  
  currentCrossCorrelations = c()
  
  for ( sentiment in sentiments ) {
    # esto es solo con lag 0
    crossCorrelation = ccf( df.all[,sentiment],  currentWave, main = sentiment, lag.max = 0, plot = F )
    currentCrossCorrelations = c(currentCrossCorrelations, crossCorrelation$acf[1] )

    # este saca el maximo lag    
    # crossCorrelation = ccf( currentWave, df.all[,sentiment], main = sentiment, plot = F, lag.max = 700 )
    # currentCrossCorrelations = c(currentCrossCorrelations, max(as.numeric(crossCorrelation$acf)) )
  }
  
  # maxCrossCorrelation = max(currentCrossCorrelations)
  # maxCrossCorrelations = rbind( maxCrossCorrelations, data.frame(
  #   id = i,
  #   maxCorrelation = maxCrossCorrelation,
  #   sentiment = sentiments[ which.max( currentCrossCorrelations ) ]
  # ) )
  maxCrossCorrelations = rbind( maxCrossCorrelations, data.frame(
    id = i,
    anger = currentCrossCorrelations[1],
    fear = currentCrossCorrelations[2],
    joy = currentCrossCorrelations[3],
    love = currentCrossCorrelations[4],
    sadness = currentCrossCorrelations[5]
  ) )
}

corr = 0.6
maxCrossCorrelations[ abs(maxCrossCorrelations$joy) > corr, ]


# plot( df.wave[ row$waveFrom:row$waveTo ], type="l" )
# plot( df[[ row$sentiment ]], type="l" )

par( mfrow = c(1,1) )
plot( maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ]$sentiment )

# a = ccf( df[["anger"]],  df.1[1:lengthSentiments], main = sentiment )

# write.csv(maxCrossCorrelations, file="maxCrossCorrelationsSingleWave.tsv", )
write.table(maxCrossCorrelations[,2:6], file="../data/maxCrossCorrelationsPerFrame.tsv", sep="\t", row.names = F )

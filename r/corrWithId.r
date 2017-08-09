
sentiments = c("anger", "fear", "joy", "love", "sadness")

df = list()

for ( sentiment in sentiments ) {
  df[ sentiment ] = read.csv( paste("../data/sentiments/", sentiment, ".txt", sep = ""), header = F)
}
for ( sentiment in sentiments ) {
  df[[ sentiment ]] = as.numeric( scale( df[[ sentiment ]] ) )
}

par( mfrow = c(2,3) )
for ( sentiment in sentiments ) {
  plot( df[[ sentiment ]], type = "l", main = sentiment, ylab = "twit count", xlab = "hours" )
}

lengthSentiments = length(df[["anger"]])

par( mfrow = c(1,1) )

df.waves = read.csv( "../data/wavesWithID.tsv", sep = "\t" )


# plot(df.wave[1:lengthSentiments], type="l")
# par( mfrow = c(2,3) )
# for ( sentiment in sentiments ) {
#   ccf( df[[sentiment]],  df.1[1:lengthSentiments], main = sentiment )
# }
# par( mfrow = c(1,1) )

# filter( seno2ruidounif ,rep(1/3,3), circular =TRUE)


maxCrossCorrelations = data.frame( id = numeric(), 
                                   maxCorrelation = numeric(),
                                   sentiment = character())

for ( i in 0:max(df.waves$id) ) {
  currentWave = df.waves[ df.waves$id == i, "y" ]
  
  if ( all( currentWave == rep(0, length(currentWave)) ) ) {
    next
  }
  
  currentCrossCorrelations = c()
  
  for ( sentiment in sentiments ) {
    # esto es solo con lag 0
    # crossCorrelation = ccf( df[[sentiment]],  currentWave, main = sentiment, lag.max = 0, plot = F )
    # currentCrossCorrelations = c(currentCrossCorrelations, crossCorrelation$acf[1] ) 
    
    crossCorrelation = ccf( currentWave, df[[sentiment]]  , main = sentiment, plot = F, lag.max = 300 )
    currentCrossCorrelations = c(currentCrossCorrelations, max(as.numeric(crossCorrelation$acf)) ) 
  }
  
  maxCrossCorrelation = max(currentCrossCorrelations)
  maxCrossCorrelations = rbind( maxCrossCorrelations, data.frame(
    id = i,
    maxCorrelation = maxCrossCorrelation,
    sentiment = sentiments[ which.max( currentCrossCorrelations ) ]
  ) )
}
# par( mfrow = c(1,2) )
corr = 0.9
row = maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ][1,]

maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ]
nrow(maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ])

# plot( df.wave[ row$waveFrom:row$waveTo ], type="l" )
# plot( df[[ row$sentiment ]], type="l" )

par( mfrow = c(1,1) )
plot( maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ]$sentiment )

# a = ccf( df[["anger"]],  df.1[1:lengthSentiments], main = sentiment )


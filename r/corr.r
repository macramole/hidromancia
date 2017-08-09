
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

waves = c("1","2","3")
df.wave = c()
for ( wave in waves ) {
  currentWave = read.csv( paste("../data/",wave,".txt", sep=""), header = F)
  currentWave = currentWave$V1
  
  # for ( point in seq(1,length(currentWave), 4) ) {
  #   df.wave = c(df.wave,  currentWave)
  # }
  # df.wave = c(df.wave, spline( 1:length(currentWave), currentWave, length(currentWave)/8 )$y )
  df.wave = c(df.wave,  currentWave)
}
df.wave = as.numeric( scale( df.wave ) )
df.wave = filter( df.wave, rep(1/7,7), circular = T)
# filter( seno2ruidounif ,rep(1/3,3), circular =TRUE)


par( mfrow = c(2,3) )
plot(df.wave[1:lengthSentiments], type="l")
for ( sentiment in sentiments ) {
  plot( df[[ sentiment ]], type = "l", main = sentiment, ylab = "twit count", xlab = "hours" )
}


# plot(df.wave[1:lengthSentiments], type="l")
# par( mfrow = c(2,3) )
# for ( sentiment in sentiments ) {
#   ccf( df[[sentiment]],  df.1[1:lengthSentiments], main = sentiment )
# }
# par( mfrow = c(1,1) )

# filter( seno2ruidounif ,rep(1/3,3), circular =TRUE)

lengthWaveToSearch = lengthSentiments / 6

maxCrossCorrelations = data.frame( waveFrom = numeric(), 
                                   waveTo = numeric(), 
                                   maxCorrelation = numeric(),
                                   sentiment = character())

for ( i in seq(1, length(df.wave), lengthWaveToSearch) ) {
  waveFrom = i
  waveTo = (i-1+lengthWaveToSearch)
  currentWave = df.wave[waveFrom:waveTo]
  
  currentCrossCorrelations = c()
  
  for ( sentiment in sentiments ) {
    # esto es solo con lag 0
    # crossCorrelation = ccf( df[[sentiment]],  currentWave, main = sentiment, lag.max = 0, plot = F )
    # currentCrossCorrelations = c(currentCrossCorrelations, crossCorrelation$acf[1] ) 
    
    crossCorrelation = ccf( df[[sentiment]],  currentWave, main = sentiment, plot = F )
    currentCrossCorrelations = c(currentCrossCorrelations, max(as.numeric(crossCorrelation$acf)) ) 
  }
  
  maxCrossCorrelation = max(currentCrossCorrelations)
  maxCrossCorrelations = rbind( maxCrossCorrelations, data.frame(
    waveFrom = waveFrom,
    waveTo = waveTo,
    maxCorrelation = maxCrossCorrelation,
    sentiment = sentiments[ which.max( currentCrossCorrelations ) ]
  ) )
}
# par( mfrow = c(1,2) )
corr = 0.6
row = maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ][1,]

maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ]
nrow(maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ])

# plot( df.wave[ row$waveFrom:row$waveTo ], type="l" )
# plot( df[[ row$sentiment ]], type="l" )

par( mfrow = c(1,1) )
plot( maxCrossCorrelations[ maxCrossCorrelations$maxCorrelation > corr, ]$sentiment )

# a = ccf( df[["anger"]],  df.1[1:lengthSentiments], main = sentiment )


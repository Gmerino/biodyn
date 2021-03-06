####################################################################################
####################################################################################
####################################################################################

#### 
hcrSBT1=function(cpue,tac,k1=1.5,k2=3,gamma=1,nyrs=5,lag=1,interval=3){
  
     dat=as.data.frame(cpue[,ac(-((nyrs-1):0)+dims(cpue)$maxyear)])
     lambda=as.FLQuant(ddply(dat, .(iter), with,  data.frame(data=coefficients(lm(data~year))[2])))
     
     flag  =lambda<0
     lambda=abs(lambda)
  
     res=1+ifelse(flag,-k1,k2)*lambda^ifelse(flag,gamma,1)
     res=res*tac
     
     dmns=dimnames(tac)
     dmns$year=as.integer(dmns$year)+lag+seq(interval)-1
     dmns$iter=dimnames(cpue)$iter
     
     res=FLQuant(rep(c(res),each=interval),dimnames=dmns)
     
     return(res)}

####
mseSBT1<-function(om,brp,srDev,
                        start=dims(om)$maxyear,end=start+20,lag=1,interval=3,
                        k1=1.5,k2=3.0,gamma=1,nyrs=5,   
                        seed=7890,   nits=100,
                        uCV =0.3){
  
  set.seed(seed)
  
  ## Get number of iterations in OM
  nits=c(om=dims(om)$iter, sr=dims(params(brp))$iter, rsdl=dims(srDev)$iter)
  if (length(unique(nits))>=2 & !(1 %in% nits)) ("Stop, iters not '1 or n' in OM")
  nits=max(nits)
  
  om=fwdWindow(om,end=end+interval,brp)
  #om=fwd(om,f=FLQuant(0.01,dimnames=list(year=start:(end+interval),iter=seq(nits))),sr=brp,sr.residuals=srDev)
  stock(om)=propagate(computeStock(om),nits)
  
  #### Observation Error (OEM) setup #######################
  ## Random variation for CPUE
  
  uDev=rlnorm(nits,FLQuant(0,dimnames=list(year=(dims(om)$minyear:(end+interval)))),uCV)
  cpue=window(computeStock(om),end=start)*window(uDev,end=start)
  
  mn=apply(cpue,6,mean)
  sd=apply(cpue,6,sd)
  
  ## cut in capacity
  maxF=max(fbar(window(om,end=start)))*2
  
  ## Loop round years
  tac=catch(om)[,ac(start-1)]
  for (iYr in seq(start,end,interval)){
    #iYr = (start:(range(om,"maxyear")-2))[1]
    cat("===================", iYr, "===================\n")
    
    cpue=window(cpue,end=iYr)
    cpue[,ac(iYr-(interval:1)+1)]=stock(om)[,ac(iYr-(interval:1)+1)]*uDev[,ac(iYr-(interval:1)+1)]
        
    #tac=hcrSBT1(log(cpue),tac,k1,k2,gamma,nyrs,lag,interval)
    tac=hcrSBT1((cpue%/%mn),tac,k1,k2,gamma,nyrs,lag,interval)
    
    om <-fwd(om,catch=tac,sr=brp,maxF=maxF,sr.residuals=srDev)
    tac=tac[,interval]}
  
  return(window(om,end=end))}


####
hcrSBT2=function(adult,juve,yrAdult,yrJuve,refJuve=-(1:5),tac,tarCatch,eb=0.25,er=0.75,lag=1,interval=3){
  
  adultIdx=adult[,ac(dims(adult)$maxyear)]
  adultRef=aaply(adult[,ac(yrAdult)],3:6,mean)
  flag    =adultIdx<adultRef
  cBit    =tarCatch*(adultIdx/adultRef)*(1+ifelse(flag,-eb,eb))

  juveIdx =aaply(juve[,ac(dims(juve)$maxyear+refJuve)],3:6,mean)
  juveRef =aaply(juve[,ac(yrJuve) ],3:6,mean)
  flag    =juveIdx<juveRef
  rBit    =(juveIdx/juveRef)*(1+ifelse(flag,er,-er))

# cat("ref Juve:",   as.integer(mean(refJuve)),
#     "\t Juve:",    as.integer(mean(juve)),
#     "\t ratio:",   mean(juve/refJuve),
#     "\t rBit:",    mean(rBit),"\n")

  res =0.5*(tac+cBit*rBit)
  
#   cat("TAC:",        as.integer(mean(tac)),
#       "\t ratio:",   as.integer((mean(adult/refAdult))),
#       "\t delta:",   as.integer((mean(cBit))),
#       "\t New TAC:", as.integer(mean(res)),
#       "\t rBit:",    mean(rBit),"\n")

  dmns=dimnames(tac)
print(dmns$year)
print(lag)
print(interval)
print(as.integer(dmns$year)+lag+seq(interval)-1)

dmns$year=as.character(as.integer(dmns$year)+lag+seq(interval)-1)
dmns$iter=dimnames(adult)$iter
  
  res=FLQuant(rep(c(res),each=interval),dimnames=dmns)
    
  return(res)}
 

####
mseSBT2<-function(om,brp,srDev,yrAdult,yrJuve,refJuve=-(1:5),tarCatch,
                        start=dims(om)$maxyear,end=start+20,lag=1,interval=3,
                        eb=0.25,er=0.75,nyrs=5,   
                        seed=7890,   nits=100,
                        uCV =0.3){

  set.seed(seed)
 
  ## Get number of iterations in OM
  nits=c(om=dims(om)$iter, sr=dims(params(brp))$iter, rsdl=dims(srDev)$iter)
  if (length(unique(nits))>=2 & !(1 %in% nits)) ("Stop, iters not '1 or n' in OM")
   nits=max(nits)
   
  om=fwdWindow(om,end=end+interval,brp)
  stock(om)=propagate(computeStock(om),nits)
   
   #### Observation Error (OEM) setup #######################
  # # Random variation for CPUE
  
  uDev =rlnorm(nits,FLQuant(0,dimnames=list(year=(dims(om)$minyear:(end+interval)))),uCV[1])
  adult=window(ssb(om),end=start)*window(uDev,end=start)
  
  rDev =rlnorm(nits,FLQuant(0,dimnames=list(year=(dims(om)$minyear:(end+interval)))),uCV[min(1,length(uCV))])
  juve =window(rec(om),end=start)*window(rDev,end=start)
   
  ## cut in capacity
  maxF=max(fbar(window(om,end=start)))*2
   
  ## Loop round years
  tac=catch(om)[,ac(start-1)]
  for (iYr in seq(start,end,interval)){
     #iYr = (start:(range(om,"maxyear")-2))[1]
    cat("===================", iYr, "===================\n")
    
    adult=window(adult,end=iYr)
    adult[,ac(iYr-(interval:1)+1)]=ssb(om)[,ac(iYr-(interval:1)+1)]*uDev[,ac(iYr-(interval:1)+1)]
  
    juve=window(juve,end=iYr-1)
    juve[,ac(iYr-(interval:1))]=rec(om)[,ac(iYr-(interval:1))]*rDev[,ac(iYr-(interval:1))]

    tac=hcrSBT2(adult,juve,yrAdult,yrJuve,refJuve,tac,tarCatch,eb,er,lag,interval)
    
    om <-fwd(om,catch=tac,sr=brp,maxF=maxF,sr.residuals=srDev)
    tac=tac[,interval]}
  
  return(window(om,end=end))}


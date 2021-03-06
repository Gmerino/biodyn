##############################################################
#' setParams<-
#'
#' Sets up the param slot in a biodyn object given an index
#'
#' @param  \code{object}, an object of class \code{biodyn}
#'
#' @export
#' @docType methods
#' @rdname setParams
#'
#' @examples
#' \dontrun{
#' data(bd)
#' setParams(bd) <-swonIndex
#' setParams(bd)}
#' 
setGeneric('setParams<-', function(object,value,...)  standardGeneric('setParams<-'))

setMethod('setParams<-', signature(object='biodyn',value="data.frame"), function(object,value) {
  nms=c(biodyn:::modelParams(as.character(object@model)),"b0")
  object@params=object@params[nms]

  object@params =setQ(object,value)
  
  return(object)})

setMethod('setParams<-', signature(object='biodyn',value="FLPar"), function(object,value) {
  object@params=value 
  
  return(object)})

setMethod('setParams<-', signature(object='biodyn',value="FLQuant"), function(object,value) {
  nms=c(biodyn:::modelParams(tolower(as.character(object@model))),"b0")
  object@params=object@params[nms]

  #value=FLCore:::apply(value,2,mean)
  object@params =setQ(object,value)
  
  return(object)})

setMethod('setParams<-', signature(object='biodyn',value="FLQuants"), function(object,value) {
  nms=c(biodyn:::modelParams(as.character(object@model)),"b0")
  object@params=object@params[nms]
    
  object@params =setQ(FLCore:::iter(object,1),FLQuants(lapply(value, function(x) FLCore:::apply(x,2,mean,na.rm=T))))
  
  nms=dimnames(params(object))$param
  n  = as.numeric(summary(substr(nms,1,1)=="q")["TRUE"])
  nms[substr(nms,1,1)=="q"]    =paste("q",    seq(n),sep="")
  nms[substr(nms,1,5)=="sigma"]=paste("sigma",seq(n),sep="")
  
  dimnames(params(object))$params=nms
  
  return(object)})

##############################################################
#' control
#'
#' Sets up the control slot in a biodyn object given the values in the \code{params}
#' slot. The starting values are set to the values in \code{params} and the min and
#' max bounds to .1 and 10 times of these.
#'
#' @param  \code{object}, an object of class \code{biodyn}
#'
#' @export
#' @docType methods
#' @rdname control
#'
#' @examples
#' /dintrun{
#' data(bd)
#' control(bd) <-params(bd)
#' params(bd)
#' control(bd)}
#' 
#'      
setGeneric('setControl<-', function(object,value,...)  standardGeneric('setControl<-'))

setMethod('setControl<-', signature(object='biodyn',value="FLPar"), function(object,value,phase=NULL,min=0.1,max=10.0) {
   
  if (dims(value)$iter>1 & dims(object@control)$iter==1)
    object@control=propagate(control(object),dims(value)$iter)

  nms=dimnames(object@params)$params
  object@control=FLPar(array(rep(c(1,NA,NA,NA),each=length(nms)), dim=c(length(nms),4,dims(value)$iter), dimnames=list(params=nms,option=c("phase","min","val","max"),iter=seq(dims(value)$iter))))

  object@control[nms,"val"]=value
  
  object@control[nms,"min"]=value[nms]*min
  object@control[nms,"max"]=value[nms]*max
 
  if (!is.null(phase)){
     nms.=nms[nms %in% dimnames(object@params)$phase]
     object@control[nms.,"phase"]=phase[nms.]
     }
  
  if (!is.na(any(value[nms]<0)) & any(value[nms]<0))
    object@control[nms[value[nms]<0],c("min","max")]=object@control[nms[value[nms]<0],c("max","min")]

  prr=object@priors
  object@priors=array(rep(c(0,0,0.3,1),each=length(nms)), dim=c(length(nms),4),   dimnames=list(params=nms,c("weight","a","b","type")))
  nms=dimnames(prr)$params[dimnames(prr)$params %in%  dimnames(object@priors)$params]
  
  object@priors[nms,]=prr[nms,]
  
  return(object)})

calcSigma <- function(obs,hat=rep(0,length(obs)),na.rm=T){
  
  n  =length(obs[!is.na(obs+hat)])
  SS =sum((obs-hat)^2,na.rm=na.rm)
  
  return((SS/n)^.5)}

calcB0<-function(index,q,k,nyrB0=3,error="log"){
  if (is.null(nyrB0)) return(params["b0"])
  
  if (error=="log"){
    t.<-sweep(log(index[,1:nyrB0,,,,,drop=FALSE]),c(1,6),q,"/")
    return(qmax(qmin(exp(apply(t.,c(1,6),mean))/k,1),0))}
  if (error=="normal"){
    t.<-sweep(index[,1:nyrB0,,,,,drop=FALSE],c(1,6),q,"/")
    return(qmax(qmin(apply(t.,c(1,6),mean)/k,1),0))}       
}

calcQ<-function(stock,index,error="log",na.rm=T){
  
  stock<-(stock[-length(stock)]+stock[-1])/2
  n    <-length(stock)
  index<-index[seq(n)]
  if (na.rm)
    n=length(seq(n)[!is.na(index+stock)])
  
  res=switch(error,
             normal={q    =sum(stock*index, na.rm=T)/sum(stock*stock, na.rm=na.rm)
                     sigma=calcSigma(index/(q*stock))
                     data.frame(q=q,sigma=sigma)
             },
             log   ={q    =exp(sum(log(index)-log(stock), na.rm=na.rm)/n)
                     sigma=calcSigma(log(index),log(q*stock))
                     data.frame(q=q,sigma=sigma)},
             cv   ={res   <-sum(index/stock)
                    sigma2<-calcSigma(res,na.rm=na.rm)
                    q     <-(-res+(res^2+4*length(index)*sigma2*sum((index/stock)^2)))/(2*length(index)*sigma2)
                    data.frame(q=q,sigma=sigma)})
  
  return(res)}

setQ=function(object,index,error="log"){
    
  fn=function(index,stock){
    if (dims(stock)$iter==1 & dims(index)$iter>1)
      stock=propagate(stock,dims(index)$iter)
    
    model.frame(mcf(FLQuants(stock=stock,index=index)))}
  
  res=switch(is(index)[1],
             FLQuant   ={res=fn(index,stock(object));data.frame(name=1,res)},
             #FLQuants  =ldply(index, fn, model.frame(mcf(FLQuants(stock=stock,index=x))),stock=stock(object)),
             FLQuants  =ldply(index, function(x,stock) fn(x,stock), stock=stock(object)),
             data.frame=merge(model.frame(FLQuants("stock"=stock(object))),index,by="year",all=T))

  res=res[!is.na(res$iter),]
  
  if (!("name" %in% names(res))) 
    names(res)[1]="name"
  
  res=res[!is.na(res$name),]
  
  res=ddply(res, .(name,iter), function(x,log) data.frame(calcQ(x$stock,x$index)),log="log")
  
  its=max(as.numeric(ac(res$iter)))
  
  res.=transform(melt(res,id=c("name","iter")),params=paste(variable,name,sep=""))[,c("params","value","iter")]
  names(res.)[2]="data"
 
  #bug
  res=as(res.,"FLPar")[,1]
  #res=FLCore:::iter(res,seq(its))
  units(res)="NA"
  res=res.[with(res.,order(iter,params)),]
  
  if (dims(object@params)$iter==1)
    object@params=propagate(object@params,its)

  t.=rbind(object@params,FLPar(as.FLQuant(res)[drop=T]))
  dmns=dimnames(t.)
  names(dmns)=c("params","iter")
  t.=FLPar(array(t.,dim=unlist(lapply(dmns,length)),dimnames=dmns))
  units(t.)="NA"
  
  object@params=t.
  #object@params=FLPar(rbind(FLPar(object@params),FLPar(res)))
  
  object@params}

setMethod('setControl<-', signature(object='biodyn',value="FLQuant"), function(object,value,min=0.1,max=10.0) {
  setParams(object)<-value
  setControl(object,min=min,max=max)<-params(object)
  
  return(object)})


setMethod('setControl<-', signature(object='biodyn',value="FLQuants"), function(object,value,min=0.1,max=10.0) {
  setParams(object)<-value
  setControl(object,min=min,max=max)<-params(object)
    
  return(object)})

setMethod('control<-', signature(object='biodyn',value="FLPar"), function(object,value) {
  object@control=value
    
  return(object)})
setMethod('control', signature(object='biodyn'), function(object) {
  object@control})


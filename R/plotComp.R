# plotComp.R - 
# ggplotFL/R/plotComp.R

# Copyright 2003-2007 FLR Team. Distributed under the GPL 2 or later
# Maintainer: Iago Mosqueira, JRC, Laurie Kell, ICCAT
# $Id:  $

# whooow {{{
whooow  =function(x,fn,probs)
  as.data.frame(FLQuants(lapply(fn,
        function(fn,x)
          quantile(fn(x), probs=probs, na.rm=T), x=x))) # }}}
          
# plotComp {{{
plotComp = function(x, fn=NULL, probs=c(0.75,0.50,0.25), size=c(0.5,1.0,0.5),
  lty=c(2,1,2), facet=facet_wrap(~qname, scale="free"),worm=NA) {

  if (dims(x)$iter>=length(probs)){  
    res = whooow(x,fn,probs)
      p1  = ggplot(res) + geom_path(aes(x=year,y=data,group=iter,size=iter,lty=iter)) +
                        scale_size_manual(    values=size, name="Quantile") +
                        scale_linetype_manual(values=lty , name="Quantile")
  }else{
    res = whooow(x,fn,0.5)
    p1  = ggplot(res) + geom_path(aes(x=year,y=data))    }

  p1 = p1 +  expand_limits(y = 0) +
             xlab("Year") + ylab("") +
             facet

  if (length(worm) > 0)
  if (length(worm)<=dims(x)$iter)
  if (!(length(worm)==1 & is.na(worm[1])))  
     p1=p1+geom_path(aes(year,data,group=iter,colour=iter),
                data=transform(subset(as.data.frame(FLQuants(lapply(fn,function(f,x) f(x), x=x))),iter %in% worm),iter=factor(iter)))
  
  p1
} # }}}

# plotComps {{{
plotComps = function(x, fn=NULL, probs=c(0.75,0.50,0.25), size=c(0.5,1.0,0.5),
  lty=c(2,1,2), facet=facet_wrap(~qname,scale="free")) {

  x=x[seq(length(x))]
  
  if (max(laply(x,function(x) dims(x)$iter))>=length(probs))
    res = ldply(x, whooow, fn=fn, probs=probs)
  else
    res = ldply(x, whooow, fn=fn, probs=0.5)

  if ("X1" %in% names(res)) 
    names(res)[names(res)=="X1"]=".id"
  
  if (".id" %in% names(res)) 
    res$.id  = factor(res$.id)
  
  res$iter = factor(res$iter)
  
  if (length(unique(res$iter))>=length(probs)){
    p1  = ggplot(res) + geom_path(aes(x=year,y=data,group=.id:iter,size=iter,col=.id)) +
                        scale_size_manual(    values=size, name="Quantile") +
                        scale_linetype_manual(values=lty , name="Quantile")
  }else{
    p1  = ggplot(res) + geom_path(aes(x=year,y=data,group=.id,col=.id)) 
    }  

    p1= p1 + expand_limits(y = 0) +
           xlab("Year") + ylab("") +
           facet

   p1} 
# }}}

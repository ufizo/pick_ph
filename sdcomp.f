      subroutine sdcomp(accg,na,omn,beta,dt,sd)
c This is a modified version of "Quake.For", written by
c Stavros A. Anagnostopoulos, Oct. 1986.  The formulation is that of
c Nigam and Jennings (BSSA, v. 59, 909-922, 1969).  This modification 
c eliminates the computation of the relative velocity and absolute 
c acceleration; it returns only the relative displacement.  
c Dates: 05/06/95 - Modified by David M. Boore
c This subroutine was implemented in agram developed by Gail Atkinson
      dimension accg(*)
      omt=omn*dt
      d2=1-beta*beta
      d2=sqrt(d2)
      bom=beta*omn
      d3=2.*bom
      omd=omn*d2
      om2=omn*omn
      omdt=omd*dt
      c1=1./om2
      c2=2.*beta/(om2*omt)
      c3=c1+c2
      c4=1./(omn*omt)
      ss=sin(omdt)
      cc=cos(omdt)
      bomt=beta*omt
      ee=exp(-bomt)
      ss=ss*ee
      cc=cc*ee
      s1=ss/omd
      s2=s1*bom
      s3=s2+cc
      a11=s3
      a12=s1
      a21=-om2*s1
      a22=cc-s2
      s4=c4*(1.-s3)
      s5=s1*c4+c2
      b11=s3*c3-s5
      b12=-c2*s3+s5-c1
      b21=-s1+s4
      b22=-s4
      sd=0.
      n1=na-1
      y=0.
      ydot=0.
      do 1 i=1,n1
      y1=a11*y+a12*ydot+b11*accg(i)+b12*accg(i+1)
      ydot=a21*y+a22*ydot+b21*accg(i)+b22*accg(i+1)
c next two lines have been added for hardware portability
      if (y1.lt.1.e-30.and.y1.gt.0.) y1=0.
      if (ydot.lt.1.e-30.and.ydot.gt.0.) ydot=0.
      y=y1
      z=abs(y)
      z1=abs(ydot)
      if (z.gt.sd) sd=z
1     continue
      return
      end

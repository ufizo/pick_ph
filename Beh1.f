      program  Beh1
      dimension acc(1000000),psa(200,2)
      dimension npts(20000)
      character*512 ctrl,input(20000),output,tmp
      character*8 c8
      
      open(unit=1,file='Beh1.ctl',status='old')
      read(1,*)nfile
      do i=1,nfile
          read(1,'(512a)')tmp
          ispc=index(tmp,' ')
          input(i)=tmp(1:ispc)
          read(tmp(ispc+1:512),*)npts(i)
      enddo
      read(1,*)output
      read(1,*)nskip
      read(1,*)dmp
      read(1,*)nfreq
      read(1,*)(psa(i,1),i=1,nfreq)
      close(unit=1)
      
      pi=atan(1.)*4.
      eta=dmp*0.01      

      open(unit=2,file=output,status='unknown')
      write(2,10)'0',(psa(i,1),i=1,nfreq)   
10    format(a9,200(2x,g13.5))
      
      c8(1:3)=''
      do i=1,nfile
          write(c8(4:8),'(i5.5)')i
          open(unit=3,file=trim(input(i)),status='unknown')
          if(nskip>0)then
             do j=1,nskip
                 read(3,*)
             enddo
          endif
          read(3,*)SR
          read(3,*)(acc(j),j=1,npts(i))
          close(unit=3)
          dt=1./SR
          do j=1,nfreq
              omega=2*pi*psa(j,1)
              call sdcomp(acc(1:npts(i)),npts(i),omega,eta,dt,sd)
              psa(j,2)=omega*omega*sd
          enddo
          write(2,10)c8,(psa(j,2),j=1,nfreq)   
      enddo
      close(unit=2)

      end

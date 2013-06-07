#Make file for compiling the program Beh1

OBJS= Beh1.o sdcomp.o 

#FC	= g77
FC	= gfortran
FFLAGS	= -O
#LINK.f	= g77
LINK.f	= gfortran
LIBS	=
LDFLAGS	=

.f.o:
	$(FC) $(FFLAGS) -c $<

Beh1: $(OBJS)
	$(LINK.f) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	@-rm -f $(OBJS)

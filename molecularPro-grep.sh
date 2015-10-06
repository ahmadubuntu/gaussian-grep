#! /bin/bash
#clear
# This script used for greping molecular properties (Ehumo, Elumo, Ionisation energy, electron affinity, global hardness, electronic chemical potential) from gaussian output.
# usage: ./molecularP-grep.sh gaussian-output.log


infile=$1

#===============================================================================================================================================================
#   extract data
#===============================================================================================================================================================
Ehomo=`cat $infile | grep "Alpha  occ. eigenvalues" | tail -1 | awk '{print $NF}'`  ; 
Elumo=`cat $infile | grep "Alpha virt. eigenvalues" | head -n -1 | sed -n "1p" | awk '{print $5}'`  ; 

# convert componnets to standard representation
Ehomo=`echo ${Ehomo} | sed 's/D/\*10\^/' | sed 's/+//'`
Elumo=`echo ${Elumo} | sed 's/D/\*10\^/' | sed 's/+//'`


# au * 27.211396132 = eV
Ehomo=$(echo "scale=8; ($Ehomo)*(27.211396132)" | bc -l);
Elumo=$(echo "scale=8; ($Elumo)*(27.211396132)" | bc -l);

# HOMO-LUMO gap
gap=$(echo "scale=8; ($Elumo)-($Ehomo)" | bc -l);

# The Ionisation energy (E) and electron affinity (A) can be expressed in terms of HOMO and LUMO orbital energies as I = - E HOMO and A = - E LUMO
I=$(echo "scale=8; ($Ehomo)*(-1)" | bc -l);
A=$(echo "scale=8; ($Elumo)*(-1)" | bc -l);

# global hardness which is associated with the stability of the molecule (etha) can be expressed as η = 1 / 2(E LUMO – E HOMO )
etha=$(echo "scale=8; 0.5*(($Elumo)-($Ehomo))" | bc -l);

# electronic chemical potential (μ) in terms of electron affinity and ionization potential is given by μ = 1 / 2(E HOMO + E LUMO )

mu=$(echo "scale=8; 0.5*(($Elumo)+($Ehomo))" | bc -l);

# The global electrophilicity index, ω = (μ^2) / 2η
omega=$(echo "scale=8; 0.5*(($mu)^2/(2*($etha)))" | bc -l);


#===============================================================================================================================================================
#   print extracted data
#===============================================================================================================================================================
printf  "structure,Ehomo(eV),Elumo(eV),Eg,I,A,η,μ,ω\n"

printf  "%s,=%.4f,=%.4f,=%.4f,=%.4f,=%.4f,=%.4f,=%.4f,=%.4f\n" $file $Ehomo $Elumo $gap $I $A $etha $mu $omega 

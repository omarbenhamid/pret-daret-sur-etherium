pragma solidity 0.4.25;


//A faire
//Vote pour  pour demarrer le premier mois
contract Daret {
    //Nombre d'ETH a payer par mois
    uint mensualite;
    //Index du mois courrent
    uint8 public moisCourrent;
    
    constructor(uint _mensualiteEther) public {
        mensualite = _mensualiteEther * (1 ether);
    }
    
    //Suivi du nombre de mois qu'a paye un participant
    mapping(address => uint8) public moisPayes;
    
    //Participants dans l'ordre de reception du pret
    address [] public participants;
    
    // Inscrit un participant au daret
    // Doit payer la premier mensualite
    function inscription() public payable {
        require(moisCourrent == 0 && msg.value == mensualite && moisPayes[msg.sender] == 0);
        moisPayes[msg.sender] = 1;
        participants.push(msg.sender);
    }
    
    // Paye son la monsualite
    function payerMois() public payable {
        require(msg.value == mensualite && moisPayes[msg.sender] != 0);
        moisPayes[msg.sender]++; //Payer un mois de plus
    }
    
    //On execute le paiement du mois et on passe  au mois suivant
    //Essaye d'executer les paiements du moi.
    //Si certain n'ont pas encore payé le passage de mois échoue
    //Si tous les mois sont payes daret s'arrete
    function executerMoisCourrent() public {
        require(moisCourrent < participants.length);
        address tourActuel = address(0);
        
        for (uint8 c = 0; c < participants.length; c++){
            //Il faut que tout le monde aie paye
            require(moisPayes[participants[c]]> moisCourrent);
            if(c == moisCourrent) tourActuel = participants[c];
        }
        
        assert(tourActuel != address(0));
        //Payer le participant pour le mois courrent
        moisCourrent++;
        tourActuel.transfer((uint)(participants.length * mensualite));
    }
    
}
